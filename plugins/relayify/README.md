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

## Setup for consumers (95% of teammates)

If you just want to generate Relay-style code, you only need this section. The maintainer (the person refreshing the registry) handles the extraction pipeline below.

### Option A: Claude Desktop (recommended — most teammates)

Two files, two double-clicks. **No Node install needed** (Claude Desktop ships its own runtime).

1. **Install the MCP server** — download `relayify-<version>.mcpb`, double-click. Claude Desktop opens an Install dialog → click Install.
2. **Install the skill** — open claude.ai → Customize → Skills → "+" → Upload ZIP → select `relayify-skill-<version>.zip`.

(Team/Enterprise admins can provision the skill org-wide from the same UI so teammates don't each upload it.)

Once installed, the skill auto-activates on Relay UI work; the MCP server provides `search_components`, `get_component`, `get_tokens`, and `validate_usage` tools.

### Option B: Claude Code CLI

The plugin ships everything pre-built: bundled MCP server (~650KB single file, no `node_modules`), the consumer skill, the curated registry, and the style guide.

**Prerequisites:** Claude Code CLI + Node.js ≥ 20 (`brew install node`).

```bash
# From a built plugin-dist/ directory (after maintainer runs `npm run build:plugin`):
claude --plugin-dir /path/to/plugin-dist

# Or from a tarball:
tar -xzf relayify-0.1.0.tgz -C ~/relay-plugin
claude --plugin-dir ~/relay-plugin

# Future, after marketplace publish:
claude /plugin install relayify
```

Once installed, the skill auto-activates on Relay UI work. Invoke explicitly with `/relayify:relayify`.

### Option C: Skill-only fallback (zero install, no MCP)

For locked-down environments or as an offline fallback, the skill reads `registry/index.json` directly. Clone the repo and the skill will find the registry — no `node`, no MCP, no build step. Trade-off: no fuzzy search, no `validate_usage` tool.

### Option D: Manual MCP server install (Cursor / Windsurf / Cline)

For non-Claude clients that speak MCP, use a project-scoped `.mcp.json` at the repo root:

```bash
cd mcp-server && npm install && npm run build && cd ..
```

```json
{
  "mcpServers": {
    "relayify": {
      "command": "node",
      "args": ["./mcp-server/dist/index.js"],
      "env": { "RELAY_REGISTRY_ROOT": "./registry" }
    }
  }
}
```

---

## Setup for maintainers (extraction pipeline)

**Only the person refreshing the registry or rebuilding the plugin needs this.** If you're not running `/relay-extract` or `npm run build:plugin`, skip this whole section.

### Building artifacts for distribution

```bash
cd mcp-server && npm install && cd ..    # one-time: esbuild + MCP SDK
npm install                              # one-time: @anthropic-ai/mcpb at root

npm run build:plugin                     # → plugin-dist/        (Claude Code CLI)
npm run build:mcpb                       # → mcpb-dist/*.mcpb + *.zip (Claude Desktop)
npm run build:all                        # both targets
```

**Outputs:**

```
plugin-dist/                       ← Claude Code (Option B in consumer setup)
├── .claude-plugin/plugin.json
├── skills/relayify/
├── mcp-server/dist/index.js       ← esbuild single-file bundle (~650KB)
├── registry/                      ← index.json + storybook + tokens + assets
├── style-guide/
└── README.md

mcpb-dist/                         ← Claude Desktop (Option A — primary)
├── relayify-<v>.mcpb        ← double-click to install in Claude Desktop
└── relayify-skill-<v>.zip   ← upload at claude.ai → Customize → Skills
```

Both targets share the same `mcp-server/dist/index.js` bundle, the same `registry/`, and the same `SKILL.md`. Only packaging differs.

**Testing:**
- Claude Desktop: double-click the `.mcpb` file. Upload the skill ZIP separately at claude.ai.
- Claude Code: `claude --plugin-dir ./plugin-dist`; run `/reload-plugins` after edits.

### 1. Install MCP server deps

If you haven't already done the consumer setup, do that first.

### 2. Connect Claude in Chrome

The extraction pipeline needs the Claude in Chrome extension. Make sure:
- Chrome is open
- You are logged in to `https://bonkers.relayfi.com/`
- The Claude in Chrome MCP tools are available in your agent

### 3. Run the first extraction

```
/relay-extract --scope both --max-pages 50
```

Populates `registry/`. First run is capped at 50 pages; subsequent runs are uncapped once `registry/.bootstrapped` exists.

### Capturing the internal app (`bonkers.relayfi.com`)

The Claude in Chrome extension hard-blocks Relay's app subdomains as a safety policy — automated extraction won't work there. Workaround: paste DOM data from your own browser, ingest locally.

#### One-shot (clipboard)

```bash
npm run snippet                          # copies the DevTools snippet to clipboard
# 1. Paste into Chrome DevTools Console on a Relay app page, hit Enter
# 2. Copy the JSON output the snippet returns
# 3. Ingest:
npm run ingest
```

The snippet redacts all text content before returning (`<redacted>`), and the ingest script defensively re-redacts `$amounts`, emails, SSN-like patterns, and long digit runs, plus strips `business/<slug>` from the URL. PII never leaves your browser as plain text.

#### Batch (watch mode)

```bash
npm run ingest:watch
```

Drop snapshot JSON files into `registry/_inbox/` — each is processed and moved to `.done/` automatically.

#### Other input modes

```bash
npm run ingest:stdin < snapshot.json    # from stdin
npm run ingest:file -- ./snapshot.json  # from file
```

After ingesting app pages, re-run the synthesis pass to merge their components into the registry.

### Refreshing the registry

Re-run `/relay-extract` whenever Relay ships visual changes, new pages, or token updates. The crawl is incremental: routes already in `registry/crawled.json` are skipped unless `--force` is passed.

---

## How quality is enforced

Three layers, in order of priority during code generation:

1. **Relay's visual language** — extracted live, served by the MCP server. Components, tokens, states.
2. **Curated best practices** — `style-guide/typescript.md`, `style-guide/react-patterns.md`, `style-guide/accessibility.md`. Independent of design.
3. **Validation** — `validate_usage(code)` from the MCP server + the existing `/code-review` skill for non-trivial changes.

The extraction is the source of truth for *what Relay looks like*. The style guide is the source of truth for *what good code looks like*. They are deliberately separate so that shipped code that isn't best-practice doesn't leak its anti-patterns into future code.

## Open follow-ups

- **Style-guide path resolution in plugin context** — SKILL.md references `style-guide/typescript.md` etc. as project-relative paths. When the plugin is installed in a consumer's project, those paths don't resolve. Fix options: (a) add a `get_style_guide(name)` MCP tool that serves the markdown, (b) inline the critical rules into SKILL.md, (c) use `${CLAUDE_PLUGIN_ROOT}`-aware path resolution in the skill text.
- **Variants for app primitives** — `app-button`, `account-tile`, `side-drawer`, etc. lack the tone/size variant pattern that `kpi-tile` and `status-pill` have. Deeper authoring pass.
- **Selector field disclaimer in SKILL.md** — the `selector` field contains real CSS-module class names (`RelayNavbar-module__navBarContainer`) useful for search but not for code generation. Add a one-line note telling Claude to use `idiomaticUsage` exclusively, not `selector`.
- **`/relay-extract --force`** for full re-crawl.
- **CI check** — run `validate_usage` on PRs touching `.tsx` or `.html`.
- **Eval harness** — feed the agent a design task, score output against the registry.
- **Publish the plugin to a marketplace** so `claude /plugin install relayify` works without `--plugin-dir`.
