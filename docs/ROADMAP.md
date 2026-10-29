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

- [x] **M10 — Settings, Notifications, i18n, Theming** (FR-09, FR-11)
  4 local reminder types (toggle + scheduling), dark/light toggle, ID/EN switch.

- [x] **M11 — Polish & Release Candidate**
  Run the antislop Delivery Gate (see `AGENTS.md`) on every screen, empty/loading/error states on every data view, manual click-through on a real device per FR acceptance criteria, build release APK.

- [x] **M12 — Multi-Wallet System** (FR-12, FR-13, BR-04, D16, v1.1 — post release)
  New `Wallet` collection + data migration for existing `Transaction` rows, wallet CRUD UI, inter-wallet transfer, budget-engine wallet scoping (`includeInDailyBudget`). See D16 for full reasoning — this reopens frozen v1.0.0 scope with explicit user approval.

- [x] **M13 — Visual Reconstruction (v1.2)** (D17)
  Rebuild every screen's visuals (Home, Transaksi, Tambah Transaksi, Goals, Aset, Analytics, Settings, Wallets, FAB speed-dial static state) to match `docs/design/mockups/` exactly: dark monochrome base + doff burgundy accent, Playfair Display italic for labels/brand, Space Mono for all numeric/data text. No new features, no logic changes — pure presentation-layer rework on top of the existing M0-M12 data/business logic. Bundled TTF fonts (not google_fonts) for offline-first consistency. Shared widgets (`AppBottomNav`, `FabSpeedDial`, `IconCircle`, `FilterPill`, `DashedAddCard`) added under `lib/core/presentation/widgets/` for visual consistency across screens. 229 tests passing, `flutter analyze`/`dart format` clean, debug APK built. No physical Android device/emulator available in the build environment — verified via full widget-test suite (every screen's dark+light theme render assertions) instead of manual on-device click-through.

- [x] **M14 — Motion & Micro-interactions (v1.2)** (D17)
  Implement the full Motion spec from `docs/DESIGN.md` §Motion: slide navigation, count-up/down budget number, staggered FAB speed-dial, animated list inserts, animated progress bars, scale+haptic button feedback, skeleton loading shimmer, crafted save-confirmation toast. Gated on M13 (motion is layered onto the new visual system, not the old one). All 8 touchpoints implemented via shared `lib/core/motion/` + `lib/core/presentation/widgets/` primitives (`SlidePageRoute`, `CountUpRupiah`, `SlideFadeInOnce`, `FabSpeedDial` stagger, `PressScale`, `ShimmerBox`/skeleton lists, `AnimatedProgressBar`, `showSuccessToast`), all respecting `MediaQuery.disableAnimations`. 242 tests passing (229 pre-existing + 13 new motion-specific), `flutter analyze`/`dart format` clean, debug APK built. No physical Android device/emulator available in the build environment — verified via widget tests exercising real state transitions (old value → new value, pointer down → up, mount of a new list item, mid-transition render position) rather than manual on-device click-through; jank/frame-timing was NOT measured (code-review only) — that's explicitly M15's job.

- [x] **M15 — Performance Testing & Optimization**
  Measured and reported in `docs/PERFORMANCE.md`: Isar save/query latency (real, native-engine `flutter test` benchmark at 800 realistic transactions — 1.5ms median save vs <50ms target, 33x margin), APK size (real build, 64.1MB vs M11's 61MB / M12's 63.7MB, delta fully explained by M13 fonts), cold launch + M14 animation jank + memory footprint (code-review-only / not verified — no physical Android device or emulator available in this build environment, flagged explicitly per metric rather than fabricated). No NFR regression or M14 jank anti-pattern found; no fix was required. A candidate `ListView.builder` virtualization change for `TransactionsScreen` was benchmarked head-to-head and reverted after showing no measurable improvement, to keep the diff honest and scoped.

## Non-goals (do not implement without a new PRD revision)
See `docs/PRD.md` §3.2 Out-of-Scope and `docs/EXTENDING.md`.
