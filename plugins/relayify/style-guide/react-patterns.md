# React Patterns

## Component shape

- Function components only. No class components.
- Props type lives above the component, named `<Component>Props`. Exported alongside the component.
- Destructure props in the signature, with defaults inline:
  ```tsx
  type ButtonProps = { variant?: 'primary' | 'secondary'; disabled?: boolean; children: ReactNode; onClick?: () => void };
  export function Button({ variant = 'primary', disabled = false, children, onClick }: ButtonProps) { ... }
  ```
- Avoid `React.FC` — it implicitly adds `children` and obscures the prop type.

## State

- `useState` for local UI state.
- For multi-field forms, prefer a single reducer (`useReducer`) or a form library — not 8 `useState` calls.
- Derived state is a smell. If you're calling `useState` + `useEffect` to sync, you probably want `useMemo` or to compute inline.
- Lift state only as far as it needs to go. Don't hoist to context until two unrelated subtrees need it.

## Effects

- `useEffect` is for syncing with **external systems** (DOM, subscriptions, browser APIs). Not for data transforms.
- Always include a cleanup function for subscriptions and timers.
- Dependency arrays: include every reactive value. If ESLint complains, fix the code, don't suppress the rule.

## Composition

- Prefer composition over conditional rendering inside one big component. `<Card><Card.Header/><Card.Body/></Card>` beats a `Card` with 12 conditional props.
- `children` is the most powerful prop. Use it.
- Render props or hooks for shared behavior, not HOCs.

## Performance

- `React.memo`, `useMemo`, `useCallback` are tools, not defaults. Measure first.
- Lists need stable `key`s. Never use array index unless the list never reorders.
- Lazy-load route-level components with `React.lazy` + `Suspense`. Don't lazy-load tiny components.

## Forms

- Controlled inputs by default. Uncontrolled (with refs) only when integrating with non-React code.
- Validation lives in one place — either in the field component or in a shared schema (Zod). Not both.
- Submit handler is async. Disable the submit button while pending. Show errors inline next to the field.

## Anti-patterns

- Index-as-key in dynamic lists.
- Mutating state directly (`state.items.push(...)`).
- Calling hooks conditionally or inside loops.
- Side effects in render bodies.
- Massive prop drilling (>3 levels) — use context or a state manager.
- "God components" with 500+ lines. Split.

## Files

- One component per file (with exception for tightly-coupled compounds: `Tabs`, `Tabs.Item`, `Tabs.Panel`).
- Hooks in `hooks/` named `useThing.ts`. Pure utilities in `utils/`.
