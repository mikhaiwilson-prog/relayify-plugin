# Relay Front-End Design System (for coding agents)

A two-layer system that lets any MCP-compatible coding agent (Claude Code, Cursor, Windsurf, Cline) write code in Relay Financial's design language — TypeScript/React for webapps, or plain HTML for static dashboards and internal tooling.

## Architecture

```
┌──────────────────────────────────────────────────────────┐
│  EXTRACTION  (maintainer — one-time + periodic refresh)  │
│  /relay-extract → 4 parallel subagents via Claude in     │
│  Chrome MCP → crawl live sites → registry/*.json         │
└──────────────────────────────────────────────────────────┘
                            ↓
┌──────────────────────────────────────────────────────────┐
│  RUNTIME  (every consumer)                               │
│  mcp-server  ←  registry/index.json                      │
│       ↑                                                  │
│       │  MCP protocol (stdio)                            │
│       │                                                  │
│  Any coding agent uses tools:                            │
│   - search_components, get_component, get_tokens,        │
│     get_pattern, validate_usage                          │
│  AND reads style-guide/ for code-quality rules           │
└──────────────────────────────────────────────────────────┘
```

## Layout

```
.claude/skills/
  relay-extract/         Orchestrator skill — runs the crawl
    SKILL.md
    subagents/
      components.md      UI building blocks
      tokens.md          Colors, spacing, typography…
      layouts.md         Page-level structure
      states.md          Hover/focus/disabled/loading/error
  relayify/   Consumer skill — used while writing code
    SKILL.md
mcp-server/              The MCP server that serves the registry
  src/index.ts
  src/registry.ts
  package.json
registry/                Extraction output (mostly gitignored — large)
  components/
  tokens/
  layouts/
  states/
  screenshots/
  index.json             Consolidated, queryable
style-guide/             Curated code-quality layer (manually authored)
  typescript.md
  react-patterns.md
  accessibility.md
```

---
 the agent a design task, score output against the registry.
- **Publish the plugin to a marketplace** so `claude /plugin install relayify` works without `--plugin-dir`.
