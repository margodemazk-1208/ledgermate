# LedgerMate Roadmap

Milestones map 1:1 to FR/BR ids in `docs/PRD.md`. Each milestone = one unit of work assignable to a kanban task. Do not start M(n+1) work before M(n) is merged — later milestones depend on earlier data models/providers existing.

- [x] **M0 — Project Skeleton & Environment**
  Flutter project created, folder structure per `ARCHITECTURE.md`, dependencies pinned (riverpod, isar, fl_chart, flutter_local_notifications, flutter_localizations), `flutter analyze` clean, runs on a connected device showing a blank scaffold. *(Dev environment itself already verified — see `SETUP.md`.)*

- [x] **M1 — Core Data Layer (Isar)**
  All 6 Isar collections from PRD §8 (`LocalProfile`, `PayCycle`, `Transaction`, `Category`, `FinancialGoal`, `Asset`) with schemas, codegen, and a working local DB instance. No UI yet — verified via unit tests inserting/reading each collection.

- [x] **M2 — Onboarding Wizard** (FR-01)
  Income Frequency picker (Mode A/B), initial income input, mandatory expenses input. Gates entry to Home until complete.

- [x] **M3 — Transaction CRUD** (FR-02, FR-03)
  Add/edit transaction, Rupiah-formatted input validation, delete restricted to today only.

- [x] **M4 — Smart Daily Budget Engine** (FR-04, BR-01, BR-02)
  Both formula modes (Periodic + Daily/carry-over) implemented as a pure, independently unit-testable function — not tangled into widget code. Recalculates on every transaction/income/goal change.

- [x] **M5 — Pay Cycle Transition** (FR-05)
  Prompt + re-input flow when a new cycle starts (payday reached, or user manually rolls to next day in Daily mode).

- [x] **M6 — Goals & Projection Tracker** (FR-06, FR-06b, FR-06c, BR-03)
  Multi-goal CRUD, manual allocation override, realism warning, auto-accrual into `currentAmount`, withdraw flow.

- [x] **M7 — Asset/Investment Tracker** (FR-10)
  New tab, manual value entry, gain/loss display. Confirm this never touches BR-01 formula inputs.

- [x] **M8 — Visual Analytics** (FR-07)
  Pie/bar breakdown + month-over-month trend comparison.

- [x] **M9 — Export/Import** (FR-08)
  JSON/CSV export of all local data to Downloads; import/restore flow with validation against corrupt/foreign files.

- [ ] **M10 — Settings, Notifications, i18n, Theming** (FR-09, FR-11)
  4 local reminder types (toggle + scheduling), dark/light toggle, ID/EN switch.

- [ ] **M11 — Polish & Release Candidate**
  Run the antislop Delivery Gate (see `AGENTS.md`) on every screen, empty/loading/error states on every data view, manual click-through on a real device per FR acceptance criteria, build release APK.

## Non-goals (do not implement without a new PRD revision)
See `docs/PRD.md` §3.2 Out-of-Scope and `docs/EXTENDING.md`.
