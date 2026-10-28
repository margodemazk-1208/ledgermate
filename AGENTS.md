# AGENTS.md — LedgerMate

Read this file before doing any work in this repo, regardless of which tool/agent/profile you are.

## What this project is
Personal finance & smart daily budget tracker. Flutter, Android-only, 100% offline (Isar local DB, no backend, no accounts). Full product spec: `docs/PRD.md`. Do not implement anything that contradicts it without a new PRD revision — see `docs/DECISIONS.md` before "fixing" something that looks like an oversight; it probably isn't.

## Required reading order before starting a task
1. `docs/PRD.md` — the spec. Your task card should point you to specific FR/BR ids; read those sections, not necessarily the whole doc, unless the task is architectural.
2. `docs/ARCHITECTURE.md` — folder structure and the formula-engine isolation rule (non-negotiable).
3. `docs/DECISIONS.md` — scan the table. If your task seems to require reversing one of these, stop and flag it instead of just doing it.
4. `docs/ROADMAP.md` — confirms you're not starting milestone N+1 before N is done.
5. `docs/DESIGN.md` — required before touching any UI/widget code.

## Coding conventions
- Dart/Flutter standard formatting: run `dart format .` before considering work done.
- `flutter analyze` must be clean (no new warnings) before marking a task complete.
- State management: Riverpod only — no `setState`-driven business logic, no second state management library introduced ad hoc.
- The formula engine (`lib/core/formulas/`) stays framework-free and independently unit-tested — see `ARCHITECTURE.md`.
- No hardcoded strings in widgets for anything a user reads — route through the `.arb` localization files (app is dwibahasa ID/EN per PRD FR-09).
- Comments: explain *why*, not *what* — no restating the line below in English. See `antislop-code` skill if available in your runtime.

<!-- antislop:start -->
## antislop (anti AI-slop filter)
Before building or editing any screen/widget, load the `antislop` skill/rules (Hermes profiles: `skill_view(name='antislop')`; non-Hermes agents: request the equivalent ruleset from the user if not locally available) and `docs/DESIGN.md` for direction. Key points adapted for this Flutter app (full rules in the skill):
- Every interactive element (button, toggle, nav item) must have real behavior — no dead controls (R-26).
- Every screen showing data needs empty/loading/error states, not just the happy path (R-27).
- Both dark and light theme must be fully functional before a screen is considered done (R-21/R-34) — this app's dark mode is a deliberate choice in `DESIGN.md`, not a default-and-forget.
- No fabricated numbers/stats anywhere (R-17/R-36) — this is a finance app; every number shown must come from real local data, never a placeholder dressed as real.
- Run the app and click through what you built before declaring a task done (R-35) — a screen that was never run is not finished. Record what you clicked and what happened.
- Follow `docs/DESIGN.md`'s palette/typography/dial exactly — don't default to generic Material blue-purple or invent a different palette mid-project.
<!-- antislop:end -->

## Kanban workflow
Tasks for this project are tracked on the shared Hermes kanban board. Each task card should name the specific FR/BR id(s) and doc section(s) it implements — if a task card you're working from doesn't, ask for that context rather than guessing scope from the task title alone.

## When in doubt
Flag it (kanban comment, or ask the user) rather than making an architectural judgment call solo — the whole point of `docs/DECISIONS.md` existing is that these calls were already made deliberately once; silently re-deciding them is the failure mode we're avoiding.
