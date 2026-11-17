// Плагин OpenCode: компактная память + автоочистка.
//
// Идея: в каждый запрос подмешивается только ядро (michael-profile.md, ≤ 32 КБ),
// индекс тем и 2–3 последние записи журнала. Подробности лежат в memory/topics/*
// и читаются по требованию инструментом `memory`.
//
// Автоочистка (раз в 6 часов, без участия модели):
//   - убирает точные дубли записей журнала;
//   - записи старше 180 дней и хвост сверх 80 записей переносит в memory/archive/;
//   - следит за бюджетом ядра: если оно больше 32 КБ, ставит флаг .needs-compaction
//     и не отдаёт модели больше 48 КБ (защита контекста).
//
// Команды: /remember — обновить память по диалогу, /memory-gc — принудительная чистка.

import { Plugin } from "@opencode/plugin"
import {
  appendFileSync,
  copyFileSync,
  existsSync,
  mkdirSync,
  readFileSync,
  readdirSync,
  rmSync,
  statSync,
  writeFileSync,
} from "node:fs"
import { homedir } from "node:os"
import { basename, extname, join, resolve } from "node:path"

const HOME = homedir()
const DATA = join(HOME, ".local", "share", "opencode")
const MEM = join(DATA, "memory")
const TOPICS = join(MEM, "topics")
const JOURNAL = join(MEM, "journal")
const ARCHIVE = join(MEM, "archive")
const CORE = join(DATA, "michael-profile.md")
const AGENTS = join(HOME, "AGENTS.md")
const LAST_GC = join(MEM, ".last-gc")
const NEEDS = join(MEM, ".needs-compaction")

const CORE_BUDGET = 32 * 1024
const INJECT_BUDGET = 48 * 1024
const JOURNAL_MAX_ENTRIES = 80
const JOURNAL_MAX_BYTES = 96 * 1024
const GC_INTERVAL_MS = 6 * 60 * 60 * 1000

function ensureDirs() {
  for (const dir of [MEM, TOPICS, JOURNAL, ARCHIVE]) {
    if (!existsSync(dir)) mkdirSync(dir, { recursive: true })
  }
}

function readText(path, fallback = "") {
  try {
    return readFileSync(path, "utf8")
  } catch {
    return fallback
  }
}

function writeText(path, text) {
  writeFileSync(path, text, "utf8")
}

function listFiles(dir) {
  try {
    return readdirSync(dir).filter((f) => f.endsWith(".md")).sort()
  } catch {
    return []
  }
}

function human(bytes) {
  if (bytes < 1024) return `${bytes} Б`
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} КБ`
  return `${(bytes / 1024 / 1024).toFixed(1)} МБ`
}

// --- индекс тем -----------------------------------------------------------

let indexCache = { at: 0, text: "" }

function topicIndex() {
  if (Date.now() - indexCache.at < 60_000) return indexCache.text
  const lines = ["## Темы памяти (читать по необходимости)", ""]
  for (const file of listFiles(TOPICS)) {
    const text = readText(join(TOPICS, file))
    const heads = text
      .split("\n")
      .filter((l) => l.startsWith("## "))
      .map((l) => l.slice(3).trim())
      .slice(0, 6)
    lines.push(`- \`topics/${file}\` — ${heads.join("; ") || "без подразделов"}`)
  }
  indexCache = { at: Date.now(), text: lines.join("\n") }
  return indexCache.text
}

// --- журнал ---------------------------------------------------------------

function splitEntries(text) {
  const parts = text.split(/\n(?=- \d{2}\.\d{2}\.\d{4}\b)/)
  const header = parts.length && !/^- \d{2}\.\d{2}\.\d{4}\b/.test(parts[0]) ? parts.shift() : ""
  return { header: header.trim(), entries: parts.map((p) => p.trim()).filter(Boolean) }
}

function recentJournal(limit = 3, maxBytes = 4096) {
  const files = listFiles(JOURNAL).sort()
  if (!files.length) return ""
  const file = files[files.length - 1]
  const { entries } = splitEntries(readText(join(JOURNAL, file)))
  let picked = entries.slice(-limit)
  let text = picked.join("\n\n")
  while (text.length > maxBytes && picked.length > 1) {
    picked = picked.slice(1)
    text = picked.join("\n\n")
  }
  if (text.length > maxBytes) text = text.slice(0, maxBytes) + "\n…"
  return text ? `## Последние записи журнала (${file})\n\n${text}` : ""
}

function entryDate(entry) {
  const m = entry.match(/^- (\d{2})\.(\d{2})\.(\d{4})/)
  if (!m) return 0
  return Date.parse(`${m[3]}-${m[2]}-${m[1]}T00:00:00Z`) || 0
}

// --- автоочистка ----------------------------------------------------------

function gcJournal(force) {
  const report = []
  const cutoff = Date.now() - 180 * 86_400_000
  for (const file of listFiles(JOURNAL)) {
    const path = join(JOURNAL, file)
    const original = readText(path)
    const { header, entries } = splitEntries(original)
    if (!entries.length) continue

    // точные дубли: оставляем более длинную версию
    const byKey = new Map()
    for (const e of entries) {
      const key = e.replace(/\s+/g, " ").trim()
      const prev = byKey.get(key)
      if (!prev || e.length > prev.length) byKey.set(key, e)
    }
    let kept = [...byKey.values()]

    // старое — в архив
    const old = kept.filter((e) => entryDate(e) && entryDate(e) < cutoff)
    kept = kept.filter((e) => !old.includes(e))

    // хвост сверх лимита — в архив
    let overflow = []
    if (kept.length > JOURNAL_MAX_ENTRIES) {
      overflow = kept.slice(0, kept.length - JOURNAL_MAX_ENTRIES)
      kept = kept.slice(kept.length - JOURNAL_MAX_ENTRIES)
    }

    const archived = [...old, ...overflow]
    let next = [header, ...kept].filter(Boolean).join("\n\n") + "\n"
    if (next.length > JOURNAL_MAX_BYTES && kept.length > 20) {
      const cut = kept.slice(0, kept.length - 20)
      archived.push(...cut)
      kept = kept.slice(kept.length - 20)
      next = [header, ...kept].filter(Boolean).join("\n\n") + "\n"
    }

    if (next === original) continue
    const day = new Date().toISOString().slice(0, 10)
    copyFileSync(path, join(ARCHIVE, `${basename(file, ".md")}.${day}.bak.md`))
    if (archived.length) {
      const apath = join(ARCHIVE, `${basename(file, ".md")}-archive.md`)
      appendFileSync(apath, `\n\n<!-- перенесено ${new Date().toISOString().slice(0, 10)} -->\n\n` + archived.join("\n\n") + "\n", "utf8")
    }
    writeText(path, next)
    report.push(
      `${file}: ${entries.length} → ${kept.length} записей` +
        (archived.length ? `, в архив ${archived.length}` : "") +
        ` (${human(original.length)} → ${human(next.length)})`,
    )
  }
  return report
}

function gcCore() {
  const size = statSafe(CORE)
  if (size > CORE_BUDGET) {
    writeText(
      NEEDS,
      `Ядро памяти ${human(size)} — больше бюджета ${human(CORE_BUDGET)}. ` +
        `Сожми: перенеси подробности в memory/topics/ и оставь в ядре только постоянное.\n`,
    )
    return [`ядро ${human(size)} > ${human(CORE_BUDGET)}: нужен смысловой сжим (флаг .needs-compaction)`]
  }
  if (existsSync(NEEDS)) rmSync(NEEDS, { force: true })
  return [`ядро ${human(size)} — в бюджете`]
}

// Помечает темы, которые давно не перепроверяли. Ничего не удаляет:
// решение о правке принимает модель/пользователь.
function staleTopics() {
  const cutoff = Date.now() - 180 * 86_400_000
  const out = []
  for (const file of listFiles(TOPICS)) {
    const text = readText(join(TOPICS, file))
    const seen = new Set()
    for (const m of text.matchAll(/(?:проверено|обновлено)\s+(\d{2})\.(\d{2})\.(\d{4})/gi)) {
      const stamp = `${m[1]}.${m[2]}.${m[3]}`
      if (seen.has(stamp)) continue
      seen.add(stamp)
      const ts = Date.parse(`${m[3]}-${m[2]}-${m[1]}T00:00:00Z`)
      if (ts && ts < cutoff) out.push(`topics/${file}: проверено ${stamp} — стоит перепроверить`)
    }
  }
  return out
}

function statSafe(path) {
  try {
    return statSync(path).size
  } catch {
    return 0
  }
}

function gc(force = false) {
  ensureDirs()
  if (!force && existsSync(LAST_GC)) {
    try {
      if (Date.now() - statSync(LAST_GC).mtimeMs < GC_INTERVAL_MS) return null
    } catch {}
  }
  const report = [...gcJournal(force), ...gcCore(), ...staleTopics()]
  writeText(LAST_GC, new Date().toISOString() + "\n")
  indexCache.at = 0
  return report
}

// --- чтение и поиск -------------------------------------------------------

function safeMemoryPath(input) {
  let p = String(input || "").trim()
  if (!p) return null
  if (p.startsWith("memory/")) p = p.slice(7)
  if (!extname(p)) p += ".md"
  const full = resolve(MEM, p)
  if (!full.startsWith(MEM + "/")) return null
  return full
}

function searchMemory(query) {
  const q = String(query || "").trim()
  if (q.length < 2) return "Нужен запрос длиной хотя бы 2 символа."
  const hits = []
  const files = [
    ...listFiles(TOPICS).map((f) => join(TOPICS, f)),
    ...listFiles(JOURNAL).map((f) => join(JOURNAL, f)),
    ...listFiles(ARCHIVE).filter((f) => f.endsWith(".md")).map((f) => join(ARCHIVE, f)),
  ]
  for (const file of files) {
    const lines = readText(file).split("\n")
    for (let i = 0; i < lines.length; i++) {
      if (lines[i].toLowerCase().includes(q.toLowerCase())) {
        hits.push(`${file.replace(MEM + "/", "")}:${i + 1}: ${lines[i].trim().slice(0, 300)}`)
        if (hits.length >= 25) break
      }
    }
    if (hits.length >= 25) break
  }
  return hits.length ? hits.join("\n") : `По запросу «${q}» ничего не найдено.`
}

function memoryStats() {
  const core = statSafe(CORE)
  const topics = listFiles(TOPICS).map((f) => `${f}: ${human(statSafe(join(TOPICS, f)))}`)
  const journal = listFiles(JOURNAL).map((f) => `${f}: ${human(statSafe(join(JOURNAL, f)))}`)
  const archive = listFiles(ARCHIVE)
  return [
    `ядро: ${human(core)} (бюджет ${human(CORE_BUDGET)})`,
    `тем: ${topics.length}`,
    ...topics,
    `журнал: ${journal.length} файл(ов)`,
    ...journal,
    `архив: ${archive.length} файл(ов)`,
  ].join("\n")
}

function runMemory(input) {
  const action = String(input?.action || "").trim()
  if (action === "search") return searchMemory(input.query)
  if (action === "read") {
    const path = safeMemoryPath(input.path)
    if (!path) return "Путь должен быть внутри memory/ (например topics/nixos.md)."
    const text = readText(path, "")
    if (!text) return `Файл не найден: ${path}`
    return text.length > 20_000 ? text.slice(0, 20_000) + "\n…(обрезано)" : text
  }
  if (action === "stats") return memoryStats()
  if (action === "gc") {
    const report = gc(true)
    return report?.length ? report.join("\n") : "Чистить нечего."
  }
  if (action === "journal") {
    const text = String(input.text || "").trim()
    if (!text) return "Нужен текст записи."
    const d = new Date()
    const stamp = `${String(d.getDate()).padStart(2, "0")}.${String(d.getMonth() + 1).padStart(2, "0")}.${d.getFullYear()}`
    const file = join(JOURNAL, `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}.md`)
    if (!existsSync(file)) writeText(file, `# Журнал ${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}\n\n`)
    appendFileSync(file, `\n- ${stamp} — ${text}\n`, "utf8")
    return `Записано в ${file.replace(MEM + "/", "")}`
  }
  return "Неизвестное действие. Доступно: search, read, stats, gc, journal."
}

// --- контекст -------------------------------------------------------------

function readCore() {
  const text = readText(CORE, "(ядро памяти ещё не создано)")
  if (text.length > INJECT_BUDGET) {
    return (
      text.slice(0, INJECT_BUDGET) +
      `\n\n[ядро обрезано: ${human(text.length)} > ${human(INJECT_BUDGET)}. ` +
      `Сожми его: подробности — в memory/topics/, ядро — только постоянное.]\n`
    )
  }
  return text
}

function buildHeader() {
  const sections = [
    "## Память пользователя и системы",
    "",
    "Источник: `~/.local/share/opencode/michael-profile.md` (ядро) + `memory/topics/*`.",
    "Сверяйся с ядром и не выдумывай версии ПО, ОС и устройство — проверяй командой.",
    "",
    "<user_profile>",
    readCore().trim(),
    "</user_profile>",
    "",
    topicIndex(),
    "",
    recentJournal(),
    "",
    "## Правила памяти",
    "",
    "1. Новый **постоянный** факт — кратко в ядро (если нужен в каждой сессии) или в тему",
    "   `memory/topics/<тема>.md` (если это деталь). Запись о сделанной работе — в журнал",
    "   через `memory` (`action: journal`). Не дублируй то, что уже есть.",
    "2. Секреты (пароли, токены) в память не писать. Пароль сервиса OpenCode — в",
    "   `~/.local/state/opencode/service.json`.",
    "3. Подробности не грузи в контекст целиком: сначала `memory` → `search`, потом `read`.",
    "4. Версии ПО и устройство сначала проверь командой, потом записывай.",
    "5. Ядро держи ≤ 32 КБ; всё лишнее — в темы. Автоочистка работает сама.",
    "",
  ]
  return sections.filter((s) => s !== null).join("\n")
}

export default Plugin.define({
  id: "memory-sync",
  async setup(ctx) {
    ensureDirs()
    gc(false)

    const contextHook = await ctx.session.hook("context", (event) => {
      gc(false)
      event.system.push({ type: "text", text: buildHeader() })
    })

    const toolReg = await ctx.tool.transform((editor) => {
      editor.add({
        name: "memory",
        description:
          "Долговременная память пользователя: поиск и чтение тем, запись в журнал, статистика и очистка. " +
          "Используй перед тем, как спрашивать пользователя о его системе, проектах или прошлых решениях.",
        input: {
          type: "object",
          properties: {
            action: {
              type: "string",
              enum: ["search", "read", "stats", "gc", "journal"],
              description: "Что сделать",
            },
            query: { type: "string", description: "Строка поиска для action=search" },
            path: {
              type: "string",
              description: "Путь внутри memory/, например topics/nixos.md или journal/2026-10.md",
            },
            text: { type: "string", description: "Текст записи для action=journal" },
          },
          required: ["action"],
          additionalProperties: false,
        },
        execute: async (input) => ({ content: runMemory(input) }),
      })
    })

    await ctx.command.transform((editor) => {
      editor.add({
        name: "remember",
        description: "Обновить память о пользователе и системе по текущему диалогу",
        execute: async ({ sessionID, prompt, delivery }) => {
          await ctx.session.prompt({
            ...prompt,
            sessionID,
            text: [
              "Просмотри текущий диалог и обнови постоянную память.",
              "1. Новые постоянные факты — кратко в ядро `~/.local/share/opencode/michael-profile.md`.",
              "2. Детали — в подходящую тему `~/.local/share/opencode/memory/topics/<тема>.md`.",
              "3. Запись о работе — в журнал: инструмент `memory`, action `journal`.",
              "4. Не выдумывай: только то, что реально прозвучало или проверено командой.",
              "5. Секреты не записывай. В конце перечисли, что записал.",
            ].join("\n"),
            delivery,
          })
        },
      })
      editor.add({
        name: "memory-gc",
        description: "Почистить память: дубли, старый журнал, бюджет ядра",
        execute: async ({ sessionID, prompt, delivery }) => {
          const report = gc(true)
          await ctx.session.prompt({
            ...prompt,
            sessionID,
            text:
              "Результат автоочистки памяти:\n\n" +
              (report?.length ? report.map((r) => `- ${r}`).join("\n") : "- чистить нечего") +
              "\n\nЕсли ядро превышает бюджет — сожми его, перенеся подробности в темы. " +
              "Ничего не выдумывай и не удаляй полезное.",
            delivery,
          })
        },
      })
    })

    return () => {
      void contextHook.dispose()
      void toolReg.dispose()
    }
  },
})
