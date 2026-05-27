# Accessibility

Target: WCAG 2.2 AA. Banking software has regulatory exposure here — this isn't optional.

## Semantic HTML first

- `<button>` for actions, `<a>` for navigation. Never `<div onClick>`.
- Headings in order: `h1` → `h2` → `h3`. Don't skip levels for styling — style independently.
- `<label>` every form input. `htmlFor` matches the input's `id`, or wrap the input.
- Lists are `<ul>`/`<ol>`. Tabular data is `<table>` with `<thead>`/`<tbody>`/`<th scope>`.

## Keyboard

- Every interactive element must be reachable via Tab.
- Focus order matches visual order.
- Visible focus indicator — never `outline: none` without a replacement.
- Esc closes modals/popovers. Enter submits forms. Arrow keys navigate within radio groups, menus, tabs.
- Trap focus inside modal dialogs. Return focus to the trigger on close.

## Screen readers

- Decorative icons: `aria-hidden="true"`.
- Meaningful icons without visible label: `aria-label="Close"` on the button.
- Loading state: `aria-busy="true"` on the container; live region (`aria-live="polite"`) announces completion.
- Error messages: link to the input via `aria-describedby`; set `aria-invalid="true"` on the input.
- Don't use `aria-*` to paper over bad HTML. Fix the HTML.

## Color and contrast

- Text: 4.5:1 minimum (3:1 for large text ≥18pt).
- Non-text UI (borders, focus rings, icons): 3:1.
- Never convey meaning by color alone. Add icons or text labels.

## Motion

- Respect `prefers-reduced-motion: reduce`. Disable non-essential animations.
- No flashing > 3 Hz.

## Forms

- Error summary at the top of the form, linking to each error.
- Error messages explain *what's wrong* and *how to fix it*.
- Required fields marked visually AND with `aria-required="true"`.
- Don't disable the submit button until the user has tried — disabled buttons can't be focused and don't explain themselves.

## Tables

- `<caption>` describing the table.
- `<th scope="col">` and `<th scope="row">` as appropriate.
- Sortable column headers: `aria-sort="ascending" | "descending" | "none"`.

## Quick checks before declaring done

1. Tab through the feature. Can you reach everything? Is focus visible?
2. Trigger every action with keyboard only. Does it work?
3. Run axe-core (or equivalent). Address every violation.
4. Zoom to 200%. Does layout break?
