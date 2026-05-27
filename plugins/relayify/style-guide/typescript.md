# TypeScript Style Guide

Curated baseline. These rules are independent of Relay's design — they're how to write good TS regardless.

## Type definitions

- Prefer `type` for unions and intersections; `interface` for object shapes that may be extended via declaration merging (rare).
- Use **branded types** for IDs that are semantically distinct: `type UserId = string & { __brand: 'UserId' }`. Prevents passing an `OrgId` where a `UserId` is expected.
- `readonly` on public fields and arrays you don't mutate. Default to immutability.
- Discriminated unions over optional fields: `type Result = { ok: true; data: T } | { ok: false; error: E }` beats `{ data?: T; error?: E }`.

## Forbidden

- `any` — use `unknown` and narrow.
- `as` casts except at trusted boundaries (JSON parse output, third-party untyped libs). Always add a one-line comment when you cast.
- `// @ts-ignore` / `// @ts-expect-error` without a justification comment on the same line.
- Non-null assertion (`!`) on values you can't prove non-null at the call site.

## Function signatures

- Prefer narrow input types and wide output types. Accept `ReadonlyArray<T>`, return `T[]` only if mutation is part of the contract.
- Optional parameters at the end. No more than 3 positional params — switch to an options object.
- Async functions: name them `loadX` / `fetchX` / `saveX`. Never just `get`.

## Errors

- Throw `Error` subclasses with meaningful names: `class NotFoundError extends Error {}`.
- At system boundaries (API handlers, route loaders), convert thrown errors into typed `Result` unions for the UI.
- Never `catch (e) {}` silently. Either rethrow, log with context, or convert to a typed error.

## Generics

- Use generics when the type relationship between params and return is real — not just for flexibility.
- Constrain generics: `<T extends Record<string, unknown>>` beats bare `<T>`.
- Don't be clever. If a generic type makes the function signature unreadable, refactor.

## Imports

- Type-only imports: `import type { Foo } from './foo'` when you only use `Foo` in type positions. Helps tree-shaking.
- No deep relative paths (`../../../foo`). Configure path aliases (`@/components/...`).

## File organization

- One default export per file, named the same as the file (PascalCase for components).
- Co-locate types with the code that uses them unless shared across 3+ files.
- Tests next to source: `Button.tsx` + `Button.test.tsx`.
