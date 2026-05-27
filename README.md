# relayify-plugin
What the plugin provides:

- **Skill** that auto-activates when Claude detects front-end work in a Relay project (TSX, HTML, marketing-site, etc). Walks through color direction → critic-subagent review → preview link → variant offer before generating.
- **MCP server** with tools for component lookups, token queries, Storybook references, and code validation: `search_components`, `get_component`, `get_tokens`, `get_storybook_index`, `validate_usage`, plus six more.
- **Curated registry** of 48 components (kpi-tile, status-pill, dashboard-chart, hero-section, pricing-card, sidebar-nav, data-table, …) with full anatomy, variants, idiomatic JSX + HTML examples.
- **Style guide** covering TypeScript patterns, React patterns, and accessibility rules.

---

## Install

### Inside Claude Code CLI

```
/plugin marketplace add mikhaiwilson-prog/relayify-plugin
/plugin install relayify@relayify-plugin
```
### If you are using the desktop app 

Go to the Co-work or Code tab
Customize -> hit the plus beside personal plugins -> create plugin -> add marketplace, then paste this repo link

After install, start a fresh Claude Code session, the skill is available as `/relayify:relayify` and auto-activates on Relay UI work, and the MCP tools register automatically.

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
