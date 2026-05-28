---
name: relayify
description: Write front-end code in Relay Financial's design language — either React/TSX (for webapps) or plain HTML/JS (for static dashboards and internal tooling). Use whenever an agent is creating or modifying UI components, pages, forms, dashboards, or styling for a Relay project — anything involving JSX, TSX, plain HTML, styled-components, Tailwind, CSS modules, or component composition in a Relay codebase. Triggers on requests like "build me a Relay-style settings page," "add a button in Relay's style," "make a dashboard in html," or any front-end work in this repo.
---

# Relay Design-System Authoring

You are writing code that must look and behave like Relay's product. Your job is to produce **idiomatic, accessible** front-end code — either **React/TSX** (type-safe webapp code) or **plain HTML/JS** (static dashboards, internal tooling) — that visually matches Relay's design language.

## Source of truth

1. **Visual language** → query the MCP server (tools below) backed by `registry/`. This is what Relay's product actually looks like.
2. **Code quality** → read `style-guide/` files. This is what *good code* looks like, independent of design.

Never invent tokens or component names. Either look them up via MCP or ask the user.

## The two design surfaces

Relay has **two distinct visual environments**. Always identify which one you are targeting before touching the registry.

| Surface | Host | When you're building… |
|---|---|---|
| **Marketing** | `relayfi.com` | Public pages — homepage, pricing, case studies, request-demo |
| **App** | `bonkers.relayfi.com` | Authenticated dashboard — accounts, payments, settings, team |

- Marketing = bold editorial (pill buttons, hero sections, feature blocks, testimonials).
- App = compact SaaS dashboard (sidebar nav, data tables, side drawers, form fields).
- **Tokens are shared** across both surfaces. Components are surface-specific — do not mix them.

Call `get_context("marketing")` or `get_context("app")` at the start of any task to get the full list of available components and key visual rules for that surface.

## Design philosophy: commit, don't converge

Generic AI dashboard output is the enemy. White-on-white admin templates, Tailwind blue-600 CTAs, Inter everywhere, shadcn rounded-md cards — that's *AI slop*, not Relay. **Pick a clear visual direction and execute it with intention.**

### Translation, not transcription

You are **redesigning**, not transcribing. A common failure mode: find every component in the source (topbar, card, button, badge), swap each one 1:1 for a Telegraph equivalent, ship. That produces a structurally identical but visually worse version of the source — because it copies the source's *layout* without thinking about what the page is *for*.

Before writing any code:

1. **State the page's purpose in one sentence.** ("A gallery where Relay employees discover and open each other's internal prototypes.") Write it down mentally; let it drive every component decision.
2. **Identify the 2–3 things that matter most.** For a gallery: scanability, owner attribution, fast filtering. The redesign must make *those* feel great — not preserve every chrome detail.
3. **Pick a design move.** Editorial typography? Generous whitespace? Confident color block in the header? A single hero card pinned at top? Whatever it is, commit. A redesign without a clear move reads like the source minus its personality.
4. **Re-cast components in service of the design move, not the source's layout.** If the source has a tight 3-column card grid and your move is "editorial gallery," maybe the right answer is large featured cards stacked vertically with metadata woven into the type, not a denser 3-col grid in Relay colors.

A redesign that looks like the source with restyled components has failed. A redesign that looks like a Relay product designed it from scratch — using the source only as a brief, not a template — has succeeded.

### Brand hierarchy

For any **internal Relay tool** (Forge, the app, internal dashboards), the Relay parent brand belongs in the page chrome (top-left of the header, the favicon, the document title). The tool's own mark can appear adjacent or in the page hero. Both coexist — they don't compete for the same slot.

**Use the real Relay wordmark. Do NOT invent your own.** The exact SVG paths are inlined below — paste them directly into your output as inline `<svg>` (preferred — survives any deployment, no asset-path resolution needed) or, if the consumer's project already serves the plugin's `registry/assets/icons/` directory, reference `relay-logo-dark.svg` / `relay-logo-lime.svg` via `<img src>`. The bundled files in `${CLAUDE_PLUGIN_ROOT}/registry/assets/icons/` are byte-identical to the snippets below.

**On light backgrounds → use the evergreen (#004822) wordmark:**

```html
<svg width="121" height="62" viewBox="0 0 121 62" fill="none" xmlns="http://www.w3.org/2000/svg" aria-label="Relay">
  <path d="M14.7125 36.8154C19.9685 41.4223 35.5022 49.1116 35.7533 49.2289C37.7787 50.2173 34.5983 55.0587 33.0081 55.0252C30.2294 55.0252 13.5408 44.9738 7.89977 39.948C7.46457 43.7118 7.30786 47.5025 7.43104 51.2894C7.43104 52.5458 5.4224 52.5793 3.48069 52.6966C1.53898 52.8138 0.132925 52.6966 0.0324915 51.7082C-0.586846 32.1917 7.7156 12.8092 19.1482 3.51165C26.212 -2.23441 38.2975 -1.3968 36.5064 9.52574C35.0167 18.5553 26.279 31.0693 14.7459 36.8154H14.7125ZM9.33929 32.6105C22.0106 28.3889 33.5269 9.77703 29.8444 6.59408C26.1618 3.41113 13.909 14.7357 9.33929 32.6105ZM118.527 21.3361C116.97 20.7833 114.811 20.7498 114.526 22.0732C112.601 30.751 109.27 40.2663 105.37 39.0602C103.696 38.5241 102.625 36.6813 106.274 25.4907C106.676 24.2343 105.722 23.6312 104.299 23.0952C102.876 22.5591 101.269 22.8104 100.951 23.6982C97.0509 33.3141 93.9374 38.7754 91.1253 38.2225C87.9784 37.586 92.7155 27.6015 93.4185 26.1608C94.1216 24.7201 92.2636 23.983 91.3429 23.6145C90.4223 23.2459 88.9158 22.6093 88.3969 23.6145C88.196 23.9495 87.7441 24.8709 87.4763 25.407C87.6269 21.4367 83.8272 19.1583 79.7764 20.9173C72.3946 24.1338 68.4275 32.309 67.9253 37.1337C67.624 39.9648 68.3605 43.1477 71.1726 44.4879C76.4454 46.984 82.237 40.6684 83.8272 37.3514C83.6598 41.3218 86.2209 43.7676 89.4682 43.6503C93.904 43.4995 97.1011 39.1607 98.005 37.2342C97.3019 43.7843 103.512 46.2804 108.048 43.0975C105.364 48.2849 101.985 53.0812 98.005 57.3537C96.8667 58.6101 98.4402 60.1849 99.0094 60.7042C99.9467 61.6256 101.319 62.3795 102.123 61.7931C104.55 60.1179 109.321 54.7906 114.627 44.3539C117.553 38.0595 119.662 31.4163 120.904 24.5861C121.239 22.9109 120.753 22.09 118.594 21.3361H118.527ZM75.0728 38.3231C73.717 37.3682 75.0728 33.1801 76.6463 30.7008C78.8223 27.099 82.17 24.4353 83.6096 25.5745C85.8359 27.2497 82.7559 31.6891 81.1824 34.3192C79.609 36.9493 76.8304 39.5627 75.0728 38.3231ZM56.8609 34.1015C51.7388 42.5949 45.1437 45.2418 40.574 45.3758C39.2161 45.4417 37.86 45.2148 36.5974 44.7107C35.3347 44.2065 34.1951 43.4367 33.2555 42.4535C32.3159 41.4702 31.5983 40.2965 31.1513 39.0116C30.7043 37.7267 30.5383 36.3607 30.6646 35.0061C30.8703 31.9592 31.9185 29.0295 33.6921 26.5445C35.4656 24.0595 37.8947 22.117 40.7079 20.9341C46.2819 18.8568 51.3538 22.9276 50.2658 27.635C49.9892 29.0308 49.4373 30.3573 48.6425 31.537C47.8477 32.7168 46.8258 33.7262 45.6367 34.5061C44.4475 35.286 43.1149 35.8208 41.7168 36.0792C40.3187 36.3377 38.8831 36.3145 37.4941 36.0112C37.7786 39.3617 41.3608 41.2212 46.4159 38.6246C49.7637 36.9494 53.4796 33.5989 56.9948 25.1222C59.606 18.7563 63.3221 5.6727 64.9792 2.77454C65.4647 1.93692 67.1888 2.17147 68.6618 2.89182C70.1348 3.61217 71.6413 4.65079 71.1726 5.95748C68.1176 13.6802 65.7701 21.6649 64.159 29.8129C62.8403 36.4679 63.006 43.3322 64.6444 49.9157C65.0127 51.3062 63.2552 52.1773 62.1839 52.395C61.5372 52.5873 60.8465 52.571 60.2096 52.3485C59.5727 52.126 59.0219 51.7086 58.6352 51.1554C55.8566 46.1297 56.1578 39.948 56.8107 34.135L56.8609 34.1015ZM37.3769 32.2252C42.5324 33.9004 47.1021 28.2549 45.5119 25.9598C43.9217 23.6647 38.0632 26.1943 37.3769 32.2252Z" fill="#004822"/>
</svg>
```

**On dark backgrounds (evergreen / dark surfaces) → use the lime (#D5E27B) wordmark:** identical path, change `fill="#004822"` to `fill="#D5E27B"`. That is the *only* difference between the two variants.

**Sizing:** the SVG ships at 121×62. Scale via the `width`/`height` attributes or wrap in a styled container — 28px tall for app chrome, 40-56px for marketing nav. Keep aspect ratio (`viewBox` does the work). Apply a CSS color override via `fill="currentColor"` if the tool's color scheme needs dynamic theming, but **prefer the canonical fills unless you have a clear reason**.

**Hard rules — break these and the brand mark is wrong:**

- ❌ Generating your own SVG wordmark with letters that "look like" RELAY — even close lookalikes
- ❌ Using an emoji in place of the wordmark (`⚡`, `🛠️`, the Phosphor `ph-cube`, etc.)
- ❌ Setting the wordmark in BasisGrotesque or RadionB text (the actual mark is a hand-drawn custom shape, not a font)
- ❌ Hand-tweaking the path data — paste the exact path string above
- ❌ Recoloring beyond the two documented fills (`#004822` evergreen / `#D5E27B` lime). The wordmark has only those two canonical variants; do not use orange, lime-bold, gray, or any other color.
- ❌ Skipping the wordmark "because the tool has its own mark" — for internal Relay tools, the Relay parent mark belongs in the page chrome AND the tool's own mark belongs in the hero / brand block. Both coexist.

**For the tool's own mark** (Forge's anvil, etc.): if the source has a recognizable mark, preserve it. If you don't have access to its actual SVG, use a Phosphor icon that visually approximates it (e.g., `ph-anvil` for Forge) inside a colored tile that matches the tool's accent color — never an emoji standing alone.

### Concrete guardrails (when redesigning an existing tool)

- **Preserve the tool's identity.** If the source has an orange accent, a custom mark, a dark theme — keep what makes it distinctive. You're applying Relay typography + components + tokens *over* the tool's personality, not replacing it with beige SaaS.
- **Typography is non-negotiable.** Body text in BasisGrotesque. Display/headings in RadionB (or Tobias / GalaxieCopernicus for editorial moments). Never Inter, never Roboto, never system fonts in final output.
- **Brand mark survives.** Whatever logo / wordmark / icon the source uses, the redesign must include a recognizable equivalent. An emoji placeholder (⚡, 🛠️) is not a logo. **The Relay parent wordmark, when used, MUST be the inline SVG documented in the "Brand hierarchy" section above — paste the canonical path data, do not draw your own.**
- **Color choice is intentional.** Relay's brand is dark-green + lime, but internal tools commonly carry their own accent (forge = orange, etc.). Either commit to Relay brand colors *or* commit to the tool's accent — never default to Telegraph's neutral grays because you can't decide.
- **Hierarchy through scale, not boxes.** Big headings, breathable spacing, a single primary CTA per region. Don't fill every region with borders and equal-weight content.

If the redesign could be mistaken for a Bootstrap admin template, it's wrong.

## Output format: TSX or HTML

Relay teammates work in two different code environments. Both are first-class — **determine the format before writing any code**.

| Format | When | Signals |
|---|---|---|
| **React / TSX** | Internal webapps, the main Relay app, anything with a build step | File ends in `.tsx` / `.jsx`; `package.json` lists `react`; existing files use JSX |
| **Plain HTML** | Static dashboards, internal tooling, prototypes, ad-hoc reports | File ends in `.html` / `.htm`; no `package.json` with React; static asset layout |

If the project context is ambiguous (new file, fresh project, no clear signal), **ask the user** before generating code. Mixing modes inside one project (e.g., suggesting Recharts in an HTML file) is a failure.

### TSX mode
- Use the registry's `idiomaticUsage` field (JSX, `className`, self-closing tags).
- React-only libraries are fine: **Recharts** for charts, `@phosphor-icons/react` for icons, shadcn/ui ChartContainer for chart theming.
- Add `'use client'` to any file that imports a Recharts component — Recharts cannot SSR.
- Follow `style-guide/typescript.md` and `style-guide/react-patterns.md`.

### HTML mode
- **Prefer `idiomaticUsageHtml`** in the registry when present (currently on `kpi-tile`, `kpi-tile-sparkline`, `dashboard-chart`; more being added).
- If only `idiomaticUsage` (JSX) is present, translate on the fly using these rules:
  - `className` → `class`
  - Self-closing non-void elements: `<i ... />` → `<i ...></i>`. Void elements (`img`, `br`, `hr`, `input`, `meta`, `link`) may self-close.
  - JSX boolean / expression attrs → string attrs: `aria-hidden={true}` → `aria-hidden="true"`; `tabIndex={-1}` → `tabindex="-1"`.
  - camelCase event handlers → lowercase: `onClick` → `onclick`.
  - Inline style objects → CSS string: `style={{ height: 320 }}` → `style="height: 320px"`.
  - Curly-brace expressions → resolved literal text. If the value is dynamic, leave a clear placeholder like `<!-- {balance} -->` and tell the user where to template it.
- **Charts**: use **Chart.js** (recommended) or **ApexCharts** via a `<script>` tag. Never Recharts. See `dashboard-chart.htmlMode` for the canonical pattern (token bridge via `getComputedStyle`).
- **Sparklines**: prefer pure inline `<svg>` with `<polyline>` + `<linearGradient>` — zero JS dependency. See `kpi-tile-sparkline.idiomaticUsageHtml` and the `idiomaticUsageHtmlScaler` helper.
- **Phosphor icons**: use the CSS-class form `<i class="ph ph-arrow-up"></i>` loaded via the Phosphor CSS bundle. The React component form is React-only.
- Tokens still resolve from CSS custom properties (`var(--color-...)`), and the `rt-*` utility classes work the same in plain HTML as in JSX.
- TypeScript hard rules don't apply (there's no TS); token and accessibility rules still do.

## MCP tools you have

If the `relayify` MCP server is connected, you can call:

- `get_context(surface?)` — **start here**. Returns the usage guide for `"marketing"`, `"app"`, or `"overview"` (default). Lists available components, key visual rules, and common mistakes.
- `get_storybook_index({category?})` — **canonical Telegraph design-system inventory** from Relay's internal Storybook. 70 components grouped into Components / Layout / Foundations / Typography, each with the real `Telegraph<Name>` and a direct docs URL. Prefer this over `search_components` for app code.
- `get_storybook_url({component})` — resolve any free-form name (`"Button"`, `"icon-button"`, `"file upload"`) to the canonical Telegraph component + Storybook docs URL. Use this to cite the design-system spec for the user.
- `search_components(query)` — fuzzy search the DOM-scraped registry (marketing site components). For app code, prefer `get_storybook_index`.
- `get_component(name)` — full spec: variants, props, states, screenshot path
- `get_tokens(category)` — `colors`, `spacing`, `typography`, `shadows`, `radii`
- `get_assets(type?)` — font files (`woff2`) and SVG icons extracted from the live marketing site. **App code should use [@phosphor-icons/react](https://github.com/phosphor-icons/react) instead** — these assets are marketing-only.
- `recolor_asset({source, target?, replacements, dryRun?})` — recolor a marketing-site SVG icon. Not applicable to app code.
- `get_pattern(name)` — composite patterns (forms, tables, dashboards)
- `validate_usage(code)` — lints proposed code. Flags hardcoded hex, `any`, unknown `<Telegraph...>` names, and deprecated `<Relay...>` prefixes with suggested Telegraph replacements.

If the MCP server is NOT connected, fall back to reading `registry/index.json` directly. Tell the user the MCP server isn't running so they can start it.

## Telegraph API at a glance

**Most Telegraph components are FLAT, not compound.** There is no `<TelegraphCard.Body>`, no `<TelegraphPageLayout.Content>`, no `<TelegraphMenu.Item>`. For these, if you find yourself writing a dot-subpath, you are inventing API. Use the flat name (`<TelegraphCard>`) and compose with `<TelegraphStack>` / `<TelegraphBox>` inside.

**Exception — Radix-derived composites DO expose sub-components**, because they wrap multi-part Radix primitives that require slot children to function (focus management, ARIA wiring, etc.). These specific components use the compound dot pattern as their canonical API:

| Composite | Sub-components |
|---|---|
| `TelegraphModal` | `.Trigger`, `.Content`, `.Title`, `.Description`, `.Close` |
| `TelegraphPopover` | `.Trigger`, `.Content`, `.Close` |
| `TelegraphSelect` | `.Item` |
| `TelegraphRadioGroup` | `.Item` |
| `TelegraphTabs` | `.List`, `.Trigger`, `.Content` |
| `TelegraphTable` | `.Header`, `.Body`, `.Row`, `.ColumnHeaderCell`, `.RowHeaderCell`, `.Cell` |

These are documented in the `get_component()` MCP response for each — anything not in this table is inventing API. Layout primitives (`TelegraphBox`, `TelegraphStack`, `TelegraphFlex`), typography (`TelegraphHeading`, `TelegraphText`), and display atoms (`TelegraphButton`, `TelegraphBadge`, `TelegraphAvatar`, `TelegraphLink`, etc.) are FLAT — no sub-components, ever.

**Variant vocabulary (memorize these — wrong names crash at runtime):**

| Component | Valid variants | Valid sizes | Notes |
|---|---|---|---|
| `TelegraphButton` | `solid`, `soft`, `outline`, `ghost` | `'1'`, `'2'`, `'3'` (strings) | Not `primary`/`secondary`. Color via `color="accent"` for brand fill. |
| `TelegraphTag` / `TelegraphBadge` | `solid`, `soft`, `outline` | `'0'`, `'1'`, `'2'` | Not `subtle`/`secondary`. Color via `color="orange"` etc. |
| `TelegraphTextInput` | `outline`, `ghost` | `'1'`, `'2'`, `'3'` | Use `LeadingComponent={<Icon/>}`, not `leadingIcon`. |
| `TelegraphHeading` | — | `'1'`–`'6'` or omitted | Set the level with `as="h1"`; size is independent. |
| `TelegraphText` | — | `'0'`–`'5'` | `as="span"` by default; pass `as="p"` for paragraphs. |
| `TelegraphStack` | — | — | `direction="row"` / `column`; `gap` is a spacing token like `"3"`. |

**General prop rules:**
- Sizes are **string digits** (`"2"`), not `"md"`. T-shirt sizes will silently render the wrong size or crash.
- Spacing/color values reference Telegraph tokens, not hex.
- Layout primitives (`TelegraphBox`, `TelegraphStack`, `TelegraphFlex`) take `padding`, `gap`, `align`, `justify`. Use them for spacing — don't pile on Tailwind utilities for things the component already does.

## Phosphor icon catalog (common UI affordances)

Phosphor names are **noun-first**, not verb-first. Common mistakes (left = wrong, right = correct):

| You'd reach for | Real Phosphor name |
|---|---|
| `MessageCircle`, `MessageSquare` | `ChatCircle`, `ChatsTeardrop`, `ChatCenteredText` |
| `Search` | `MagnifyingGlass` |
| `Edit` | `PencilSimple`, `NotePencil` |
| `Trash` | `Trash`, `TrashSimple` |
| `Settings` | `Gear`, `GearSix` |
| `User` | `User`, `UserCircle` |
| `Calendar` | `Calendar`, `CalendarBlank` |
| `Upload` | `UploadSimple`, `CloudArrowUp` |
| `Download` | `DownloadSimple`, `CloudArrowDown` |
| `Plus` | `Plus`, `PlusCircle` |
| `ChevronDown` | `CaretDown`, `CaretDownLight` |
| `ExternalLink` | `ArrowSquareOut` |
| `Info` | `Info`, `Question` |
| `AlertCircle` | `Warning`, `WarningCircle` |
| `CheckCircle` | `CheckCircle`, `SealCheck` |

If you guess a name like `MessageCircle`, the import will throw at runtime. If you're unsure, lean toward `Plus`, `MagnifyingGlass`, `ChatCircle`, `ArrowUp`, `Gear`, `User`, `CaretDown`, `Warning`, `CheckCircle` — those are confirmed.

## Workflow

1. **Confirm the color direction with the user** — see "Color direction" below. **Always ask before generating**, even when the prompt seems to imply the answer. One round-trip; wait for the reply.
2. **Identify the surface** — call `get_context("app")` or `get_context("marketing")` before anything else.
3. **Identify the output format** — TSX or HTML (see "Output format" section above). If ambiguous, ask the user.
4. **Look up tokens** — `get_tokens('colors')`, `get_tokens('spacing')`. Reference these in code, never hardcode hex.
5. **Look up components** — for each UI primitive you need, `get_component(name)`. Use `idiomaticUsage` for TSX and `idiomaticUsageHtml` for HTML (translate JSX → HTML if no HTML field exists; see the rules in the "HTML mode" section).
6. **Read the relevant style-guide files** — `style-guide/typescript.md` + `style-guide/react-patterns.md` (TSX only), `style-guide/accessibility.md` for any interactive component (both modes).
7. **Compose the code** (in your response, not on disk yet) — small, accessible, token-driven. In TSX: typed (no `any`), semantic HTML, visible focus rings. In HTML: same semantics + focus rings, just no TS rules.
8. **Self-validate** — call `validate_usage(yourCode)` if the MCP server is connected. Fix every `error`. Document any `warning` you choose to ignore.
9. **Dispatch a critic subagent** — see "Critic gate" below. Catches code-correctness failures (hex, fonts, hallucinated icons, surface mixing, scope creep, fabricated wordmark, etc.). Mandatory before any Write.
10. **Dispatch a density review subagent** — see "Density review" below. Catches duplicate information and visual clutter that the critic gate doesn't enforce. Runs on the POST-critic-fix code. Mandatory before any Write.
11. **Save the file** with the `Write` tool, only after both gates have cleared the code or their blocking findings have been fixed.
12. **Surface a preview link** — see "Preview + variant offer" below. The user must be able to see the output before answering the next question.
13. **Ask: happy with this, or want a variant?** — see "Preview + variant offer." Offer 2–3 specific alternative directions. Do not generate the variant until the user picks one.

## Color direction

Before generating anything, ask the user one question about the color direction. **Always ask** — even if the prompt seems to imply the answer (e.g., "Relay-style settings page"). The cost of one extra round-trip is small; the cost of regenerating a 400-line page because the user actually wanted to preserve an existing tool's accent is large.

Use this exact opening (verbatim or close to it):

> "Before I start: should this use Relay's standard palette (lime + evergreen on cream/sand surfaces), or do you want a different color direction? For redesigns of an existing tool, we'd usually preserve the tool's own accent (e.g., Forge's orange) and apply Relay's typography + components on top. If you have a specific palette in mind, describe it."

Wait for the user's reply. Their answer will be one of:

1. **"Relay palette"** → use brand tokens (lime + evergreen + sand surfaces). The default for net-new tools and most marketing surfaces.
2. **"Preserve the tool's existing accent"** (or names a specific color like "keep the orange") → use that accent for the primary CTA / brand mark; Relay tokens for everything else (typography, surfaces, secondary components).
3. **A bespoke direction** (e.g., "monochrome evergreen", "dark with magenta accent") → use the user's spec; cross-check against the SKILL.md anti-patterns (no Tailwind stock colors, no Inter).

Once you have the answer, proceed to Workflow step 2. Don't ask again later — the answer holds for the whole generation including any variants the user asks for.

## Critic gate (mandatory)

Before saving any code file with the `Write` tool, dispatch an **independent critic subagent**. The critic runs in a fresh context with no memory of your reasoning — different model, focused failure-mode brief. Independent eyes catch what self-review hand-waves; this is the single biggest fix against scope creep, hallucinated icon names, and surface confusion.

### How to call it

Use the `Agent` tool with:

- `subagent_type: "general-purpose"`
- `model: "opus"` — the canonical Opus 4.7 model is `claude-opus-4-7`; passing `"opus"` resolves to the latest Opus available
- `description: "Critic review — <feature name>"`
- The full prompt template below, with `[PROPOSED CODE]` replaced by the complete code you are about to save

### The critic prompt (use verbatim)

```
You are an independent critic for code about to be written in Relay Financial's design language. Return ONLY blocking issues — things that will produce visibly broken or anti-pattern output for a Relay user. No design opinions. No commentary. Be terse.

Check against these failure modes:

1. Hardcoded hex outside the documented `rt-[#hex]` arbitrary-value escape pattern.
2. Inter / Roboto / system-ui font drift — body must be BasisGrotesque, display RadionB.
3. shadcn defaults — `rounded-md`, `bg-gray-*`, `bg-blue-*`, default `<Card>`, default `<Button>`.
4. Emoji standing in for a brand mark, an icon, or a Phosphor glyph (⚡, 🛠️, 📦, 🔨).
5. Telegraph compound API misuse — most Telegraph components are flat. The exceptions that DO use `.Subpath` are limited: Modal, Popover, Select, RadioGroup, Tabs, Table. Any other dot-subpath is invented API.
6. Phosphor icon names that don't exist. Common gotchas: `MessageCircle` (use `ChatCircle`), `Search` (use `MagnifyingGlass`), `ChevronDown` (use `CaretDown`), `Edit` (use `PencilSimple`), `AlertCircle` (use `WarningCircle`).
7. Surface mixing — marketing pill buttons on app pages, or app data-table density on marketing pages.
8. Scope creep beyond what the user's prompt asked for. If the prompt says "just the trigger, not the open state" — the code must NOT build the open state. Match the requested scope exactly.
9. Missing accessibility — aria-label on icon-only buttons, role/aria on dialogs, keyboard path on every clickable element, tabular-nums on numbers that can change, focus-visible rings.
10. Brand hierarchy — internal Relay tools must show the Relay parent mark in the page chrome (top-left or equivalent), not just the tool's own mark.
11. Fabricated Relay wordmark — the parent mark MUST be the canonical inline SVG documented in the "Brand hierarchy" section (path data starts `M14.7125 36.8154…`). Generating a custom RELAY-like wordmark, using a font to spell "Relay," or substituting an emoji is a hard fail. Check that the SVG path data matches and the fill is either `#004822` or `#D5E27B`.

Code follows below. Review it and return findings.

[PROPOSED CODE]

Return findings as a bulleted list. Each bullet: ONE failure mode number from the list above + a one-line description of where in the code it occurs. If there are no blocking issues, return exactly the string:

OK — ship it.

(nothing else)
```

### Handling the critic's response

- **`OK — ship it.`** → proceed to the **Density review** gate (next section). The critic is the first of two mandatory reviews.
- **Blocking findings** → fix EVERY blocking item in your proposed code, then re-run the critic if changes were substantive. One pass is normally enough. Only after the critic clears do you move on to density review.

This step is **mandatory** before any `Write` to a code file. Skipping it is a process failure even when the output looks clean. The only legitimate skips (which also skip the density gate):

- Pure registry/JSON edits, markdown docs, config files — non-code.
- Trivial single-line fixes the user explicitly asked for (rename, typo).

When you skip, say so explicitly in your reply: "Skipped critic + density gates — change was a single-line variable rename, not a code write."

## Density review (mandatory)

After the critic gate clears, dispatch a **second independent subagent** focused on information density and visual restraint. The critic checks if the code is *correct*; density review checks if the result is *coherent* — no duplicated data, no card-in-card-in-card nesting, no five badges crammed into one row, no headings competing for the same hierarchy slot.

Relay's design principle: **hierarchy through scale, not boxes**. Generous whitespace and typography do the heavy lifting; borders and surface tints are sparing. Density review enforces this against the LLM tendency to "fill the canvas" with chrome.

### How to call it

Use the `Agent` tool with:

- `subagent_type: "general-purpose"`
- `model: "opus"` — same as critic; the density review is judgment-heavy and benefits from the largest model. Passing `"opus"` resolves to the latest Opus available.
- `description: "Density review — <feature name>"`
- The full prompt template below, with `[PROPOSED CODE]` replaced by the complete code you are about to save (post-critic-fix version)

### The density-review prompt (use verbatim)

```
You are an independent design density critic for code about to be written in Relay Financial's design language. Code correctness has already been reviewed by a separate critic. Your job is to find DUPLICATE INFORMATION and VISUAL CLUTTER — design density failures, not code bugs. Be terse. No design opinions about aesthetic preference; only call out objective duplication and chrome overload.

Relay's design principle: HIERARCHY THROUGH SCALE, NOT BOXES. Generous whitespace and typography do the heavy lifting; borders and surface tints are sparing. Single primary CTA per region. The LLM tendency to "fill the canvas" with chrome — cards inside cards, three CTAs where one would do, restated labels — is the enemy.

Check against these failure modes:

1. DUPLICATE INFORMATION
   - Same data displayed twice in close proximity (a name in the avatar AND in nearby text; an amount in the row AND in a tooltip; a count in a tab AND in a separate header)
   - Repeated CTAs that should be consolidated to one (a "Get started" button in the nav AND in the hero AND in a banner — pick one per region)
   - Multiple sections delivering the same value prop with different words
   - Labels that restate what the data already shows (a column header "$ Amount" above tabular-nums dollar values)
   - Tooltips that repeat the visible label

2. VISUAL CLUTTER
   - Cards nested inside cards inside cards
   - Borders, dividers, and surface tints stacked in close proximity (border-on-border-on-shadow)
   - More than 2-3 icons / badges crowding a single row
   - Decorative chrome that doesn't carry information (purely ornamental rounded shapes, gradients on flat surfaces, decorative svg blobs)
   - Background tints stacked unnecessarily (a section with bg-surface-default INSIDE a page with bg-default — pick one)

3. COMPETING HIERARCHY
   - More than one "primary" CTA visible in the same region (Relay rule: one primary per region; others must be secondary/tertiary)
   - Headings of equal visual weight when they're actually different semantic levels (h2 + h3 rendering at the same size suggests missing scale)
   - Color used decoratively in 5+ places on one screen — lime is the accent, not the wallpaper
   - All-caps text used for emphasis (Relay prefers RadionB weight over uppercase; uppercase is only for preheader labels)

4. UNEARNED SPACE / OVER-DENSE BLOCKS
   - A section with 1-2 items spread thin across a wide area (consider consolidating with a neighbor)
   - A section with 20+ items packed into a narrow column (consider splitting or compacting)
   - Hero copy longer than ~25 words on a marketing page — Relay marketing prefers short, confident lines
   - Bullet lists when prose would carry the same information more naturally

Code follows below. Review it and return findings.

[PROPOSED CODE]

Return findings as a bulleted list. Each bullet: ONE failure mode number (1–4) + a one-line description naming the specific element(s) at issue. If there are no blocking issues, return exactly the string:

OK — clean.

(nothing else)
```

### Handling the density review's response

- **`OK — clean.`** → call `Write` to save the file.
- **Blocking findings** → fix EVERY item, then save. Typical fixes: collapse a repeated CTA, remove a duplicate label, demote a competing h2 to h3, drop an outer Card wrapper, consolidate two near-identical sections into one. After substantive fixes, you may re-run the density review for a sanity check, but one pass is usually enough.

This gate is **mandatory** alongside the critic gate. Both must clear before `Write`. The legitimate skips are the same as for the critic gate (non-code edits, trivial one-line fixes — declared explicitly in your reply).

## Preview + variant offer

After the file is saved, the user must be able to **see the output** before they can judge it. Don't ask "happy?" before the user has a way to look at the rendered result.

### 1. Surface a preview link

In your reply, after the file is written, surface the most direct preview path that exists in the user's project. Pick by file type + project shape:

| Situation | What to say |
|---|---|
| `.html` file in a Vite / Next / Astro project with a dev server | `Saved to <path>. If your dev server isn't running, `npm run dev`, then open `http://localhost:5173/<route>`.` |
| `.html` file in a static folder (no project framework) | `Saved to <path>. Double-click to open in your browser, or run `python3 -m http.server 8000` in `<dir>` and open `http://localhost:8000/<file>`.` |
| `.tsx` in a React project with a dev script | `Saved to <path>. `<the project's dev command>` (e.g., `npm run dev`), then visit `<route>`.` |
| Ad-hoc generation, no project context | Write the output as a **self-contained `.html` file** (inline `<style>`, inline `<script type="module">` if interactive). Tell the user the absolute path and "double-click to open in your browser." |

The preview link goes in your reply **before** the variant question. If you don't know how to preview the file in the user's environment, ask — don't guess.

### 2. Ask: happy, or want a variant?

Right after the preview link, ask explicitly and offer **2–3 concrete alternative directions** (not vague "make it different" — specific design moves). Example:

> "Take a look at `<preview link>`. Happy with this direction, or want me to produce a variant?
>
> Options I'd try:
> A. **More editorial** — bigger display heading, fewer cards, generous whitespace, one hero card pinned at top.
> B. **Denser grid** — same content compressed to a 4-column grid with smaller type, more scanability per screen.
> C. **Inverted surface** — same layout but on a dark evergreen page with lime accents instead of cream + evergreen text.
>
> Or tell me a direction in your own words."

Tailor the options to what you just built. For a dashboard, offer density / chart-style / KPI-arrangement variants. For a marketing page, offer hero treatment / pricing layout / palette variants. For an app page, offer table density / nav style / drawer-vs-modal variants.

**Do not generate the variant until the user picks one.** Wait. The variant question is the END of your turn — the next user message decides what happens.

## Security-sensitive changes

For anything touching auth, money movement, customer data display, or any place that handles secrets / tokens, the critic gate isn't enough — **tell the user to run `/security-review`** in your reply so they invoke it explicitly. Relay is a banking product; this gate matters.

## Anti-patterns — never produce these

These read as AI slop, not Relay:

- **shadcn/ui defaults** — `rounded-md` cards, default border colors, default `Card` from shadcn. Telegraph is the system; do not import or imitate shadcn primitives.
- **Stock Tailwind brand colors** — `bg-blue-600`, `text-indigo-500`, `bg-lime-400 to-lime-600` gradients. Use Telegraph tokens or the tool's intentional accent. No `from-X to-Y` gradient CTAs.
- **Inter / Roboto / system font stacks** — body text must be BasisGrotesque, headings RadionB. If the render is missing fonts, that's a *render bug to fix*, not a license to fall back to `-apple-system`.
- **Emoji as brand mark** — `⚡`, `🛠️`, `📦`, `🔨`. **This includes "restyling" the source's emoji in a colored box.** For internal Relay tools, use the canonical inline SVG documented in "Brand hierarchy" (paste the path data directly into your output). The tool's own mark, if it has one, should be an SVG you import — never an emoji.
- **Generated / fabricated Relay wordmark** — drawing your own "RELAY" letters in SVG, setting it in BasisGrotesque or RadionB text, or copying a path that *looks* like the wordmark. The wordmark is a hand-drawn custom shape with one canonical path string; paste it verbatim from the "Brand hierarchy" section. Any other approach is wrong even if the result looks close.
- **Mechanical 1:1 component swap** — finding each source element and replacing it with a Telegraph component without rethinking what the page is for. This produces structurally-identical-but-uglier-than-source output. See "Translation, not transcription."
- **Dark text on dark backgrounds (or light on light)** — when you commit to a dark theme, text/border/icon tokens have to flip with it. Verify contrast on every interactive element. If a card is invisible against its container, the render is broken.
- **`<TelegraphX.Subpath>` compound APIs on flat components** — Card, Heading, Text, Button, Badge, Stack, Box, Flex etc. have no sub-components. (Modal/Popover/Select/RadioGroup/Tabs/Table DO use dot-subpaths — they're the documented exceptions.) See "Telegraph API at a glance."
- **`variant="primary"` / `"secondary"` / `"interactive"`** — these are not Telegraph variants. Use `solid` / `soft` / `outline` / `ghost`.
- **Tailwind utilities competing with Telegraph styling** — Tailwind for *layout* (grid, flex, gap, padding) is fine. Tailwind for *colors and component styling* is not — use Telegraph props (`bg="surface-1"`, `color="accent-11"`).
- **Single-column "card list"** — if the source has a grid of cards, the redesign must keep the grid. A vertical stack of cards with hairline separators is a list, not a gallery.
- **Marketing pill buttons inside the app** (or app-button shape on a marketing page). Use the surface-appropriate component.

## Hard rules

**Apply to both TSX and HTML modes:**
- **Tokens, not literals** — never inline `#0F62FE`; reference the token (`var(--color-...)` in CSS, `rt-*` utility classes for everything else). If a token doesn't exist, ask the user to extend the registry.
- **Accessibility is non-negotiable** — every interactive element gets a keyboard path, focus ring, and screen-reader label.
- **Don't mix modes inside one project** — Recharts in an HTML file or `<i class="ph ph-arrow-up"></i>` next to JSX is a failure. Pick the format from the project signals (file extension, `package.json`) and stay consistent.
- **No client-side data fetching in render** — use the project's data layer; ask the user what it is if unclear.

**TSX mode only:**
- **No `any`**, no `as unknown as`, no `// @ts-ignore` without a one-line justification comment.
- **Component composition over prop explosion** — five Boolean props on one component is a smell; split.
- **`'use client'`** for any file importing Recharts or other client-only deps.

## Pre-delivery checklist

Walk this before you say you're done. If anything is unchecked, fix it.

- [ ] **Typography**: every visible text node renders in a Relay font (BasisGrotesque body / RadionB display). No Inter, no system.
- [ ] **Brand mark**: the source's logo / wordmark is preserved in the redesign (not replaced with an emoji).
- [ ] **Color**: every color reference is a token or a deliberate tool-accent. Zero `bg-blue-600`, zero hex literals.
- [ ] **Design move is real**: the page has a clear visual idea, not a mechanical swap of source components. If you can't say what the move is in one sentence, redesign.
- [ ] **Contrast**: every text node, icon, and border is visible against its background. Dark text on dark surface = broken render.
- [ ] **Telegraph API**: every `<TelegraphX>` tag is a real export. Dot-subpaths only on the six documented composites (Modal/Popover/Select/RadioGroup/Tabs/Table) — never on flat primitives (Card/Heading/Text/Button/Badge/Stack/Box/Flex/etc.). Variants and sizes use the canonical vocabulary (see "Telegraph API at a glance").
- [ ] **Icons**: every Phosphor import is a real name (verify against the catalog — `ChatCircle`, not `MessageCircle`).
- [ ] **Layout**: a grid stays a grid; a card stays a card. The composition reads like the source's hierarchy, not a vertical list of orphans.
- [ ] **Interactivity**: every clickable element is a `<button>` or polymorphic-button card. Visible focus ring. Keyboard path works.
- [ ] **Validate**: `validate_usage(yourCode)` returns clean. Hex literals, unknown Telegraph tags, deprecated Relay prefixes all fail the gate.

## When the registry is empty

If `registry/index.json` doesn't exist or is empty, the extraction hasn't run yet. Stop and tell the user to run `/relay-extract` first.

## Output style

Generate code, then briefly explain *why* you picked those tokens/components — link to the registry entry. Keep the explanation under 4 lines.
