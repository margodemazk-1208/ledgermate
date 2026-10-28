# Architecture

## Stack
- **Flutter (Dart)** — Android only for v1 (see `docs/PRD.md` §3).
- **State management: Riverpod** (`flutter_riverpod` + `riverpod_annotation`/`riverpod_generator` for codegen providers).
- **Local database: Isar** — the only data store. No backend, no REST, no sync layer exists anywhere in this codebase for v1.
- **Charting: fl_chart**.
- **Notifications: flutter_local_notifications** — on-device scheduling only, never a push/FCM dependency.
- **i18n: flutter_localizations** + `.arb` files for ID/EN.

## Folder structure (feature-first)

```
lib/
  core/
    database/          # Isar setup, schema registration, migrations
    formulas/           # BR-01/BR-02/BR-03 engine — PURE functions, no widget/provider imports
    theme/               # Dark/light ColorScheme, typography (see docs/DESIGN.md)
    l10n/                 # .arb files + generated localizations
    utils/                # Rupiah formatting, date math, validators
  features/
    onboarding/
    transactions/
    budget_engine/        # UI wrapper around core/formulas
    goals/
    assets/
    analytics/
    notifications/
    settings/
  app.dart                 # MaterialApp, router, theme wiring
  main.dart
```

Each `features/<x>/` folder contains its own `data/` (Isar repository), `application/` (Riverpod providers/notifiers), and `presentation/` (widgets/screens) subfolders. Features do not import each other's `presentation/` layer directly — cross-feature reads go through `application/` providers.

## Formula engine isolation (critical)

`core/formulas/` must stay framework-free: plain Dart functions taking primitive/model inputs and returning the computed `UangJajanAmanHariIni`, `DailySavingsReserve`, etc. This is non-negotiable because:
1. It is the single most business-critical piece of logic in the app (see `docs/PRD.md` §7.1-7.3) and must be unit-testable without a widget harness.
2. It is the piece most likely to silently drift if touched by UI-focused work — keeping it in one isolated module makes any formula change a reviewable, single-file diff.

## Data flow (no backend, repeat for clarity)

```
User input → Riverpod Notifier → Isar write → Riverpod watches Isar query (reactive) → UI rebuilds
```

There is no network call anywhere in this diagram for core functionality. The only I/O outside Isar is: (a) manual JSON/CSV export/import to device storage (FR-08), (b) local notification scheduling (FR-11). Both are on-device only.

## Theming
Dark mode is default per `docs/PRD.md`, light mode must be fully functional (not an afterthought — see `AGENTS.md` antislop R-21/R-34). Palette and rationale live in `docs/DESIGN.md`.
