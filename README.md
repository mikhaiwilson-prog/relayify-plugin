# relayify-plugin

Claude Code marketplace that hosts the **relayify** plugin — generates front-end code in Relay Financial's design language.

What the plugin provides:

- **Skill** that auto-activates when Claude detects front-end work in a Relay project (TSX, HTML, marketing-site, app-surface). Walks through color direction → critic-subagent review → preview link → variant offer before generating.
- **MCP server** with tools for component lookups, token queries, Storybook references, and code validation: `search_components`, `get_component`, `get_tokens`, `get_storybook_index`, `validate_usage`, plus six more.
- **Curated registry** of 48 components (kpi-tile, status-pill, dashboard-chart, hero-section, pricing-card, sidebar-nav, data-table, …) with full anatomy, variants, idiomatic JSX + HTML examples.
- **Style guide** covering TypeScript patterns, React patterns, and accessibility rules.

---

## Install

Inside Claude Code (Desktop or CLI):

```
/plugin marketplace add mikhaiwilson-prog/relayify-plugin
/plugin install relayify@relayify-plugin
```

After install, start a fresh Claude Code session — the skill is available as `/relayify:relayify` and auto-activates on Relay UI work, and the MCP tools register automatically.

To verify the MCP server activated, ask Claude:

> Use the relayify `get_tokens` tool with category "colors" and paste the raw response.

If Claude returns a JSON blob of Relay color tokens, the install worked end-to-end.

---

## Updating

```
/plugin marketplace update relayify-plugin
/plugin update relayify
```

This repo treats every commit as a new version (the plugin's `version` field is not pinned, so Claude Code resolves by git SHA).

---

## Repository layout

```
.
├── .claude-plugin/
│   └── marketplace.json        ← catalog: declares the relayify plugin
├── plugins/
│   └── relayify/               ← the plugin itself
│       ├── .claude-plugin/
│       │   └── plugin.json     ← plugin manifest (MCP + metadata)
│       ├── skills/relayify/
│       │   └── SKILL.md        ← auto-activating skill
│       ├── mcp-server/
│       │   ├── dist/index.js   ← bundled MCP server (~650KB, vendored deps)
│       │   └── package.json
│       ├── registry/
│       │   ├── index.json      ← 48 components, 60+ tokens
│       │   ├── storybook/
│       │   ├── tokens/
│       │   └── assets/
│       ├── style-guide/
│       └── README.md           ← consumer-facing plugin doc
└── README.md                   ← this file
```

---

## Building from source

The plugin payload at `plugins/relayify/` is the output of a build pipeline that lives in the upstream `relay-front-end-design` repo. To rebuild from source:

```bash
git clone https://github.com/<your-org>/relay-front-end-design
cd relay-front-end-design
cd mcp-server && npm install && cd ..
npm install
npm run build:plugin            # → plugin-dist/
# Then copy plugin-dist/ → this marketplace's plugins/relayify/
```

The upstream repo also produces a `.mcpb` artifact for Claude Desktop (Chat-mode-only install) via `npm run build:mcpb`. That artifact is **not** distributed through this marketplace — `.mcpb` and Claude Code plugins are different distribution formats.

---

## Distribution scope

This marketplace is intentionally narrow: one plugin (relayify). Future additions live in `plugins/<name>/` with an entry in `marketplace.json`.
