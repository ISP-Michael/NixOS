// OpenCode v2 plugin: local SearXNG web search provider.
// SearXNG is already running at 127.0.0.1:8888 (Docker). No API key, no limits.

import { Plugin } from "@opencode/plugin"
import fs from "node:fs"

const BASE = process.env.SEARXNG_URL || "http://127.0.0.1:8888"

async function search(query, signal) {
  try { fs.writeFileSync("/tmp/opencode/searxng-called", String(Date.now())) } catch {}
  const url = new URL("/search", BASE)
  url.searchParams.set("q", query)
  url.searchParams.set("format", "json")
  url.searchParams.set("categories", "general")
  url.searchParams.set("language", "ru")

  const response = await fetch(url, {
    signal,
    headers: {
      "accept": "application/json",
      "user-agent": "opencode-searxng/1.0",
    },
  })
  if (!response.ok) {
    throw new Error(`SearXNG ${response.status}: ${(await response.text()).slice(0, 200)}`)
  }

  const data = await response.json()
  return (data.results || []).slice(0, 5).map((r) => ({
    url: String(r.url || ""),
    title: r.title ? String(r.title) : undefined,
    content: r.content ? String(r.content) : undefined,
    time: {
      published: r.publishedDate ? (Date.parse(r.publishedDate) || Date.now()) : Date.now(),
    },
  }))
}

export default Plugin.define({
  id: "searxng-search",
  async setup(ctx) {
    const reg = await ctx.websearch.transform((editor) => {
      editor.add({
        id: "searxng",
        name: "SearXNG (local)",
        execute: async (input, context) => search(input.query, context.signal),
      })
      editor.default.set("searxng")
    })
    return () => {
      void reg.dispose()
    }
  },
})
