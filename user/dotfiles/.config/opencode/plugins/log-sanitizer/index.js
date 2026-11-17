// OpenCode v2 plugin: sanitize pasted logs before they reach the model.
// Redacts JWT, bcrypt, long base64 blobs and very long quoted strings.
// `<no-redact>...</no-redact>` blocks are preserved.

import { Plugin } from "@opencode/plugin"

const MAX_STRING = 300

const JWT = /\beyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\b/g
const BCRYPT = /\$2[aby]\$\d{2}\$[A-Za-z0-9./]{53}/g
const BASE64 = /(?=[A-Za-z0-9+/]*[+/])[A-Za-z0-9+/]{300,}={0,2}/g
const NO_REDACT = /<no-redact>([\s\S]*?)<\/no-redact>/g
const QUOTED = /"([^"\\]|\\.){300,}"/g
const CLASS_ATTR = /\b(?:class|className)\s*=\s*"([^"]*)"/g

function sanitize(text) {
  if (typeof text !== "string" || text.length < 300) return text

  const keep = []
  const stash = (value) => {
    const token = `\u0000NR${keep.length}\u0000`
    keep.push(value)
    return token
  }

  let out = text.replace(NO_REDACT, (m) => stash(m))
  out = out.replace(CLASS_ATTR, (m) => stash(m))
  out = out.replace(JWT, "[redacted:jwt]")
  out = out.replace(BCRYPT, "[redacted:bcrypt]")
  out = out.replace(BASE64, (m) => `[redacted:base64:${m.length}chars]`)
  out = out.replace(QUOTED, '"redacted"')

  out = out.replace(/\u0000NR(\d+)\u0000/g, (_, i) => keep[Number(i)] ?? "")
  return out
}

export default Plugin.define({
  id: "log-sanitizer",
  async setup(ctx) {
    const hook = await ctx.session.hook("prompt", (event) => {
      if (event.prompt && typeof event.prompt.text === "string") {
        event.prompt.text = sanitize(event.prompt.text)
      }
    })
    return () => {
      void hook.dispose()
    }
  },
})
