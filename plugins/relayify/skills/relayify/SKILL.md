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

Relay parent brand assets live in `registry/assets/icons/`:
- `relay-logo-dark.svg` — for light backgrounds
- `relay-logo-lime.svg` — for dark backgrounds

Use these directly (`<img src="/...svg">` or inline SVG). Don't redraw them, don't substitute emoji, don't recolor them with `recolor_asset` (which is for marketing-site icons).

### Concrete guardrails (when redesigning an existing tool)

- **Preserve the tool's identity.** If the source has an orange accent, a custom mark, a dark theme — keep what makes it distinctive. You're applying Relay typography + components + tokens *over* the tool's personality, not replacing it with beige SaaS.
- **Typography is non-negotiable.** Body text in BasisGrotesque. Display/headings in RadionB (or Tobias / GalaxieCopernicus for editorial moments). Never Inter, never Roboto, never system fonts in final output.
- **Brand mark survives.** Whatever logo / wordmark / icon the source uses, the redesign must include a recognizable equivalent. An emoji placeholder (⚡, 🛠️) is not a logo.
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
9. **Dispatch a critic subagent** — see "Critic gate" below. Mandatory before any Write.
10. **Save the file** with the `Write` tool, only after the critic has cleared the code or its blocking findings have been fixed.
11. **Surface a preview link** — see "Preview + variant offer" below. The user must be able to see the output before answering the next question.
12. **Ask: happy with this, or want a variant?** — see "Preview + variant offer." Offer 2–3 specific alternative directions. Do not generate the variant until the user picks one.

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

Code follows below. Review it and return findings.

[PROPOSED CODE]

Return findings as a bulleted list. Each bullet: ONE failure mode number from the list above + a one-line description of where in the code it occurs. If there are no blocking issues, return exactly the string:

OK — ship it.

(nothing else)
```

### Handling the critic's response

- **`OK — ship it.`** → call `Write` to save the file.
- **Blocking findings** → fix EVERY blocking item in your proposed code, then save. One critic pass is normally enough. If you made substantive changes, run it once more.

This step is **mandatory** before any `Write` to a code file. Skipping it is a process failure even when the output looks clean. The only legitimate skips:

- Pure registry/JSON edits, markdown docs, config files — non-code.
- Trivial single-line fixes the user explicitly asked for (rename, typo).

When you skip, say so explicitly in your reply: "Skipped critic gate — change was a single-line variable rename, not a code write."

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
- **Emoji as brand mark** — `⚡`, `🛠️`, `📦`, `🔨`. **This includes "restyling" the source's emoji in a colored box.** For internal Relay tools, use `registry/assets/icons/relay-logo-dark.svg` or `relay-logo-lime.svg` in the page chrome. The tool's own mark, if it has one, should be an SVG you import — never an emoji.
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
