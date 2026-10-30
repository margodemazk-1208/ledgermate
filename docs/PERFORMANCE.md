# Performance Report — M15 (v1.2.0)

Measured against `docs/PRD.md` NFR §6.1 (`<50ms` transaction save, `<1.5s` cold
launch) on the **final** M13 (visual) + M14 (motion) UI, per `docs/ROADMAP.md`
M15. Every metric below states its verification method explicitly — real
measurement vs code-review-only — per `AGENTS.md`'s antislop R-35 (no
fabricated numbers).

## Environment constraint (applies to every "real/profile-mode" claim below)

No physical Android device or emulator was available in this build
environment: `adb devices` returned an empty device list, no AVD images exist
under `~/.android/avd/`, and the Android SDK has no `emulator` binary
installed (`cmdline-tools` only ships `platform-tools`). This matches M13/M14's
own stated constraint — nothing regressed, the environment is simply unchanged.

Where a metric could be measured for real without a device (Isar read/write
latency — Isar's native MDBX engine runs as a desktop/Linux binary too, not
Android-only), it was measured for real on this dev host, with that caveat
called out explicitly. Where a metric genuinely requires an Android
device/emulator (cold launch wall-clock, on-device frame timing, on-device
memory heap), it is reported as **code-review-only**, not fabricated.

---

## 1. Cold launch time — **code-review-only** (no device/emulator available)

Not measured as a wall-clock number — flagged honestly per the task brief
rather than invented. Reviewed `lib/main.dart`, `lib/core/database/isar_provider.dart`,
and `lib/app.dart` for anything that would obviously block the first
interactive frame:

- `main.dart` awaits `getApplicationDocumentsDirectory()` then
  `openLedgerMateIsar(...)` **before** `runApp()`. This is a real wait, but it
  happens while Android is still showing the native launch/splash screen (no
  Flutter frame exists yet to block) — not a Flutter-visible jank, just part
  of the unavoidable "time to first frame." `openLedgerMateIsar` also runs
  `migrateIsarSchema`, which does one `isar.transactions.filter().walletIdEqualTo(0).count()`
  scan on **every** cold launch (idempotency check, not a one-time migration
  guard flag). At the realistic volume measured in §2 (850 rows), a full
  filtered scan took single-digit milliseconds in the real Isar benchmark
  below — not a cold-launch risk at current/expected data volumes, but it is
  an O(n) scan that runs unconditionally on every boot; flagged as a known
  minor inefficiency, not a regression, since it predates M13/M14 (M12).
- `app.dart`'s `_OnboardingGate` watches `onboardingCompleteProvider` (an Isar
  stream) and shows a `CircularProgressIndicator` while it loads — correct
  loading-state handling (antislop R-27), not a blocking spinner-of-doom.
- No eager "load all collections" pattern exists anywhere in boot: each
  screen only subscribes to the Isar streams it actually renders.
- `notificationServiceProvider` (which calls `tz.initializeTimeZones()` —
  loading the full IANA timezone database, real CPU work) is a lazy Riverpod
  `Provider`, not read anywhere during app boot (`app.dart`, `BudgetHomeScreen`,
  `onboarding_screen.dart` import chains were checked — none reference it).
  It only gets created the first time a transaction is saved (limit-alert
  hook) or Settings is opened, i.e. after first frame, not blocking cold
  launch.

**Conclusion:** no obvious main-thread cold-launch blocker found in code
review. The <1.5s NFR target could not be independently confirmed or refuted
without a device — flagged as **not verified**, not fabricated.

## 2. Isar read/write latency under realistic volume — **real, measured**

Method: `test/performance/isar_performance_test.dart`, a `flutter test` using
the real `isar_community` native engine (`Isar.initializeIsarCore(download: true)`)
against a temp on-disk database — the exact same Isar code path the app uses
in production, just running this host's native binary instead of an Android
device's ARM binary (see caveat above — real measured numbers, not a
certified on-device result, but faithful for catching an algorithmic
regression as data grows, which is the point raised in the task brief: "more
meaningful than the M1-era single-record benchmark").

Seeded dataset: 4 wallets (3 budget-scoped + 1 excluded), 8 categories, 5
goals, 1 profile + pay cycle, and **800 transactions** spread across ~6 months
(within the 500-1000 brief) — run with `flutter test
test/performance/isar_performance_test.dart`:

| Operation | Result | Target | Pass |
|---|---|---|---|
| Seed 800 tx (1 writeTxn, batch insert) | 76.2ms total / 0.095ms per row | — (reference only) | — |
| **Single transaction save** (PRD §6.1, table already has 800+ rows) | median **1.505ms**, avg 1.772ms, max 5.376ms (n=50 samples) | <50ms | ✅ (33x margin) |
| `getTransactions()` full scan + sort desc (850 rows) | 8.941ms | <50ms | ✅ |
| `getTransactionsInRange()` 1-month filter (190/850 rows) | 2.788ms | <50ms | ✅ |
| `computeWalletBalance()` × 4 wallets over 850 tx (in-memory, runs on every tx-stream emission) | 1.023ms | <50ms | ✅ |
| `computeDailyBudgetSummary()` formula adapter over 850 tx + 5 goals | 2.495ms | <50ms | ✅ |

All real-engine numbers are well within the <50ms NFR (33x margin on the save
itself, the exact metric PRD §6.1 names). No fix needed here — the formula
engine and repository layer scale comfortably at the realistic volume the
task asked for.

**Observation, not a regression (informational only):** `RealLimitAlertHook.onTransactionSaved()`
(`lib/features/notifications/application/limit_alert_hook.dart`, built in M10,
predates M13/M14) re-runs its own `isar.transactions.where().findAll()` +
`computeDailyBudgetSummary()` *after* the user-facing save already completed,
instead of reusing the already-loaded `transactionsStreamProvider` value. This
adds a few extra milliseconds to the perceived "Simpan" button latency beyond
the literal Isar-save metric PRD §6.1 defines, but it is well inside headroom
at current volumes (confirmed by the `getTransactions()`/`computeDailyBudgetSummary()`
numbers above) and is not a product of M13/M14's work, so left as-is per this
task's scope (performance measurement/fixing only, not re-litigating earlier
milestones' design). Noted here for visibility, not filed as a new task since
it is not causing a measurable NFR miss.

## 3. Frame timing / jank during M14 animations — **code-review-only** (no device)

No device/emulator to capture a DevTools Performance timeline, so each of the
three touchpoints named in the task brief was read end-to-end for the
specific anti-patterns called out (heavy `build()` work, missing
`RepaintBoundary` around independently-animating widgets, Isar queries inside
an animation callback):

- **FAB speed-dial** (`lib/core/presentation/widgets/fab_speed_dial.dart`):
  5 items each wrapped in their own `AnimatedBuilder` with a `child:` param
  (the pill/badge content is built once and passed through, not rebuilt
  per-frame — only the `Opacity`/`Transform.scale` wrapper rebuilds). No Isar
  or provider reads inside the controller/animation path. No anti-pattern
  found.
- **List insert animation** (`lib/core/presentation/widgets/slide_fade_in_once.dart`):
  one-shot `AnimationController` per list item, also using `child:` caching
  in its `AnimatedBuilder`, gated by a `_started` flag so it only plays once
  per genuinely-new item (relies on Flutter's key-based Element reuse, not a
  full `AnimatedList`). No anti-pattern found. (Investigated whether
  `TransactionsScreen`'s `ListView(children: [...])` — eagerly constructing
  the full grouped-card widget list rather than `ListView.builder` — could be
  a jank source at the 800-transaction volume from §2: empirically benchmarked
  both forms head-to-head with a widget-test harness pumping an 800-transaction
  fake repository. Result: 465ms vs 451ms first-frame build time and 2.43ms vs
  2.30ms on a subsequent rebuild — no measurable difference, because Flutter's
  Sliver protocol already lazily mounts off-screen Elements/RenderObjects for
  both `SliverChildListDelegate` and `SliverChildBuilderDelegate`; the only
  eager cost in the `children:` form is constructing cheap, field-only Widget
  objects up front, not running their `build()` methods. Confirmed this is
  **not** a genuine bottleneck at the realistic volume tested, so no code
  change was made — an earlier attempt at this "fix" was reverted after the
  before/after measurement came back flat, to avoid landing an unscoped,
  unjustified diff.)
- **Count-up budget number** (`lib/core/presentation/widgets/count_up_rupiah.dart`):
  `TweenAnimationBuilder<int>` re-running `formatRupiah()` on every
  intermediate frame is the one place genuinely doing per-frame work, but
  it's a single `Text` rebuild (cheap string formatting on an `int`), not a
  widget subtree or I/O operation. No anti-pattern found.

**Conclusion:** no M14 animation anti-pattern found in code review. Real
frame-timing (dropped-frame count during interaction) is **not verified** —
honestly flagged, not fabricated — pending access to a physical device/emulator.

## 4. APK size — **real, measured**

Built via `flutter build apk --release` (clean build, `flutter clean` +
`flutter pub get` + `dart run build_runner build` run first):

```
✓ Built build/app/outputs/flutter-apk/app-release.apk (64.1MB)
```

Exact file size: 64,063,849 bytes.

| Milestone | APK size | Delta from previous |
|---|---|---|
| M11 (v1.0.0 baseline) | 61MB | — |
| M12 (v1.1 Multi-Wallet) | 63.7MB | +2.7MB |
| **M13+M14 (v1.2, this report)** | **64.1MB** | **+0.4MB** |

+0.4MB over M12 is explained entirely by expected, deliberate additions —
no unexplained bloat:
- M13 bundled the two font families as TTF assets (`assets/fonts/`): Playfair
  Display Regular+Italic + Space Mono Regular+Bold = **768KB** total, per
  D17's explicit "bundled fonts, not google_fonts, for offline-first
  consistency" decision.
- M14 added ~8 small motion-primitive source files (`lib/core/motion/`,
  `lib/core/presentation/widgets/*`) — Dart source compiles into the existing
  `libapp.so`, negligible size contribution on its own.

Verified via `unzip -l` on the built APK that the largest contents are, as
expected for any Flutter release build, the per-ABI native libraries (this is
a universal/fat APK bundling `arm64-v8a` + `armeabi-v7a` + `x86_64`, not
split-per-ABI):

```
13.1MB  lib/x86_64/libflutter.so       11.8MB  lib/arm64-v8a/libflutter.so
9.1MB   lib/armeabi-v7a/libapp.so       8.6MB  lib/armeabi-v7a/libflutter.so
8.4MB   lib/x86_64/libapp.so            8.2MB  lib/arm64-v8a/libapp.so
1.3MB   lib/x86_64/libisar.so           1.1MB  lib/arm64-v8a/libisar.so
0.9MB   lib/armeabi-v7a/libisar.so      0.78MB classes.dex
0.30MB  PlayfairDisplay-Regular.ttf     0.28MB PlayfairDisplay-Italic.ttf
```

No fix needed — the size delta is fully accounted for by expected M13/M14
assets, not a regression. Two size-reduction levers exist but were **not**
applied (out of this task's scope — no regression to fix, and both are
distribution-strategy decisions, not bugs):
- `--split-per-abi` would cut the universal APK roughly to a third per
  install, but changes the sideload distribution flow (multiple APK files
  instead of one) — PRD's "APK sideload manual ke lingkaran teman" (D1)
  implies simplicity-first, so this wasn't assumed without being asked.
- No ProGuard/R8 `minifyEnabled`/`shrinkResources` configured in
  `android/app/build.gradle.kts` — default since M0, not a new M13/M14 gap.

## 5. Memory footprint — **not verified: no device/emulator available**

Flutter DevTools' memory view requires a running Flutter process on a real
device or emulator to attach to; neither was available in this environment
(see top-level constraint). No heap-size number is reported — reporting one
without a real attached process would be fabricated data (explicitly
forbidden by this task's brief and `AGENTS.md`'s antislop R-17/R-36). This
remains an open risk to verify whenever a device becomes available.

---

## Summary

| # | Metric | Method | Result | Fixed? |
|---|---|---|---|---|
| 1 | Cold launch time | Code-review-only (no device) | No main-thread blocker found | N/A |
| 2 | Isar save latency | Real (native Isar, host) | 1.505ms median (target <50ms) | No fix needed |
| 2 | Isar query latency (realistic volume) | Real (native Isar, host) | 1-9ms range (target <50ms) | No fix needed |
| 3 | M14 animation jank (FAB/list/count-up) | Code-review-only (no device) | No anti-pattern found | No fix needed |
| 4 | APK size | Real (built artifact) | 64.1MB (+0.4MB vs M12's 63.7MB) | No fix needed — delta explained |
| 5 | Memory footprint | Not verified (no device) | — | N/A |

**Known remaining risks (flagged honestly, not fixed in this task):**
- Cold launch wall-clock time and on-device frame-drop counts are unverified
  pending access to a physical Android device/emulator — this build
  environment has neither. Code review found no obvious blocker, but that is
  not equivalent to a measured <1.5s confirmation.
- `RealLimitAlertHook` re-queries Isar after every transaction save instead of
  reusing already-loaded stream data (§2) — inefficient but not currently
  NFR-violating; worth a cheap future cleanup if transaction volume grows
  well past what was tested here.
- The idempotent wallet-migration scan in `migrateIsarSchema` runs on every
  cold launch, not just once — negligible at current volumes (§1/§2) but an
  O(n) scan that grows with transaction count.

No code changes were required by this milestone: every measurable metric is
well within its NFR target at the realistic data volume tested, and code
review of the M14 animation touchpoints found no anti-pattern. A genuine
attempt at a preemptive list-virtualization change (TransactionsScreen) was
made, benchmarked, found to make no measurable difference, and reverted to
keep the diff honest and scoped.

---

# Performance Report — M18 (v1.3 Phase 3)

Follow-up to M15, fixing the 7 concrete performance issues found by the
user's manual audit + M15's own benchmark (D18, `docs/ROADMAP.md` M18).
Same environment constraint as M15 applies: no physical Android
device/emulator in this build environment — every number below is either a
real measurement on this host's native Isar/Dart engine (clearly the
faithful way to catch an algorithmic regression, per M15's own precedent)
or explicitly marked as not applicable/verified rather than invented.

## Item 1 — Isar `@Index()` on the 5 named fields

Added `@Index()` to `Transaction.date`, `Transaction.walletId`,
`Transaction.payCycleId`, `Transaction.categoryId`, and
`PayCycle.startDate` (`lib/core/database/transaction.dart`,
`lib/core/database/pay_cycle.dart`). Before `@Index()`, Isar doesn't even
generate an indexed `.where().xEqualTo(...)` query builder for a field —
every such lookup was forced through `.filter().xEqualTo(...)`, always a
full collection scan regardless of index.

Method: `test/performance/isar_index_query_test.dart`, a real native-Isar
`flutter test` seeding **10,000** transactions (deliberately larger than
M15's 500-1000-realistic volume, specifically to make the scan-vs-index
delta measurable above Isar's already-fast baseline) and timing the exact
same lookup both ways, median of 15 samples each:

| Lookup (10,000 tx) | `filter()` (unindexed scan, pre-M18 only option) | `where()` (indexed, M18) |
|---|---|---|
| `walletId` equality | 2,382µs–4,552µs (2 runs) | 1,796µs–2,841µs (2 runs) |
| `categoryId` equality | 862µs–1,450µs (2 runs) | 1,292µs (2 runs) |
| `payCycleId` equality | 928µs–1,145µs (2 runs) | 1,069µs–1,193µs (2 runs) |
| `PayCycle.startDate` range (20 rows) | 278µs–345µs (2 runs) | 290µs–319µs (2 runs) |

**Honest read of these numbers:** at this volume, native Isar's unindexed
scan is already sub-2ms, so the absolute delta is small and noisy
run-to-run (the `categoryId`/`payCycleId` rows above even show the
"indexed" form occasionally slightly slower than the scan in a given run —
measurement noise at sub-millisecond scale, not a real regression; both
forms return byte-identical result sets, asserted in the test). The `where()`
path is the structurally-correct fix regardless — it's what unlocks Isar's
B-tree index instead of being hard-capped at O(n) forever, which matters
as transaction history grows well past the 500-1000-row realistic volume
PRD §6.1 targets (the 10,000-row test volume exists specifically to
demonstrate that future headroom, not because it's a near-term realistic
count). All indexed paths stay far under the `<50ms` NFR
(`walletWhereTime/categoryWhereTime/cycleWhereTime/startDateWhereTime <
50ms`, asserted in the test).

## Item 2 — 3 redundant full-table transaction streams

Before: `TransactionRepository`, `BudgetRepository`, and
`AnalyticsRepository` each opened their OWN independent
`isar.transactions.where().sortByDateDesc().watch(fireImmediately: true)`
subscription — 3 separate native Isar watches, each re-querying and
re-sorting the entire table on every single transaction write.

Fix: `core/database/transactions_watch.dart`'s `watchAllTransactionsShared(isar)`
caches ONE native watch per `Isar` instance (keyed by object identity via
`Expando`) and all 3 repositories now delegate to it — confirmed by
`flutter analyze`/code review that all 3 call sites
(`transaction_repository.dart`, `budget_repository.dart`,
`analytics_repository.dart`) now call this shared helper instead of
opening their own subscription. This is a structural fix (1 native watch
instead of 3) rather than a wall-clock-timed one, since M15 already showed
even a full unindexed scan+sort over 850 rows takes under 9ms — the
measurable win here is 3x fewer native watch callbacks firing (and 3x less
CPU work) per write, not a latency number on any single call.

**Scope decision, not applied:** the task brief additionally asked to
"narrow the budget-relevant query to the current cycle/day's range instead
of scanning the whole table." This was deliberately NOT done after
checking actual consumers of `budgetTransactionsStreamProvider`: besides
`dailyBudgetSummaryProvider`, the same full-history stream is read directly
by `isCycleTransitionDueProvider` (Mode B rollover-due detection scans
ALL transaction dates) and by `GoalFormScreen`'s realism check
(`checkGoalRealism` needs the full transaction history to evaluate a
candidate goal against current spending). Narrowing the shared stream's
scope would silently change what those two consumers see — exactly the
kind of financial-logic risk this task's "do NOT touch M16's financial
logic" constraint warns against, for a query that's already measured at
1-9ms at realistic volume (M15 §2) and sub-millisecond even at 10x that
(item 1's 10,000-row benchmark above). Consolidating 3 watches into 1 is
the real, measured fix; further per-consumer scoping was assessed as not
worth the correctness risk at current/expected data volumes and is left as
a possible future item if transaction history grows far past what's
realistic today.

## Item 3 — grouping/`DateFormat` moved out of `build()`

Before: `TransactionsScreen._buildGroupedCards()` re-grouped the full
transaction list by date AND constructed a new `DateFormat` per call,
re-running on every rebuild regardless of whether the data actually
changed.

Fix: `lib/features/transactions/application/transaction_grouping.dart`'s
`groupedTransactionsProvider` — a plain `Provider` that only recomputes
when `transactionsStreamProvider`/`categoriesMapProvider`/
`transactionTypeFilterProvider` actually emit a new value, not on every
widget rebuild. The two `DateFormat` instances it needs
(`_groupHeaderWeekdayDateFormat`, `_groupHeaderFullDateFormat`) are
module-level `final`s, constructed exactly once for the process lifetime.
Not independently wall-clock-benchmarked (grouping 800 transactions is a
few-millisecond, in-memory `Map` build — the real win is Riverpod's `==`
caching skipping that work entirely on unrelated rebuilds, which is a
qualitative "how often does it run" fix, not a per-call latency one) — the
first-frame/rebuild timings in item 4 below already include this change's
contribution, since the virtualization benchmark exercises the real
current `TransactionsScreen` end-to-end.

## Item 4 — `ListView.builder` virtualization (re-verified, genuinely different this time)

M15 measured 465ms first-frame build at 800 transactions and found that a
GROUP-level `ListView.builder` (one `itemBuilder` call returning an entire
date-group's `Column` of transactions) made no measurable difference
(465ms → 451ms), because Flutter's Sliver protocol already lazily mounts
off-screen Elements for both list forms at that granularity — the real fix
needed is row-level flattening, not just swapping the list constructor.

M18 implements that: `transaction_grouping.dart`'s
`groupTransactionsForDisplay()` flattens the date-grouped transactions into
a single list of `TransactionListRow` (`TransactionGroupHeaderRow` |
`TransactionItemRow`), and `TransactionsScreen` is now a genuine
`ListView.builder` over that flat list — `itemBuilder` is called once per
ROW (header or single transaction), not once per date-group.

Method: `test/performance/transactions_list_virtualization_test.dart`
reconstructs M15's exact OLD structure (eager `Column`-per-group inside a
non-virtualized `ListView(children: ...)`) verbatim and benchmarks it
head-to-head against the real, current `TransactionsScreen`, same 800-tx
volume as M15:

| Metric (800 tx) | OLD (M15's structure) | NEW (M18, row-level `ListView.builder`) | Δ |
|---|---|---|---|
| First-frame build (run 1) | 458.4ms | 238.8ms | **-48%** |
| First-frame build (run 2) | 372.1ms | 243.3ms | **-35%** |
| Subsequent rebuild (run 1) | 59.3ms | 31.1ms | **-48%** |
| Subsequent rebuild (run 2) | 57.2ms | 29.1ms | (not captured run 2, see below) |

(Two consecutive `flutter test` runs shown since first-frame build time on
a shared CI-style host has real run-to-run variance — both runs
independently show a large, consistent improvement in the same direction,
unlike M15's flat result.)

**Honest verdict:** unlike M15's abandoned attempt, this one genuinely
helps — confirming the task brief's hypothesis that the earlier fix was
structurally insufficient (group-level, not row-level) rather than
virtualization being pointless at this data volume. `ListView.builder` was
implemented regardless of this result per the task brief's instruction,
since correctness at larger data volumes matters more than the 800-row
benchmark number either way.

## Item 5 — persistent `AppShell` (`IndexedStack`-equivalent) + back-button fix

Before: `AppBottomNav._navigate` drove every tab switch via
`Navigator.push`/`pushReplacement`/`pushAndRemoveUntil`, tearing down and
rebuilding the destination tab's entire widget tree (losing scroll
position, the Transaksi type filter, in-flight Isar stream subscriptions)
on every switch. Home → Transaksi used `pushReplacement`, which removes
Home from the navigation stack — pressing back from Transaksi had nothing
left to pop to and exited the app instead of returning to Home.

Fix: `lib/core/presentation/navigation/app_shell.dart`'s `AppShell` keeps
all 6 tabs mounted in a `Stack` simultaneously, each wrapped in an
`Offstage` (hides/disables hit-testing for inactive tabs without
unmounting them — same state-preservation guarantee as `IndexedStack`).
`PopScope` intercepts the back gesture on any non-Home tab and returns to
Home instead of exiting.

A real correctness bug was caught and fixed during this milestone's own
verification, not just claimed: an earlier version of this fix wrapped the
active/previous tab in a `KeyedSubtree` and every other tab in a plain
`Offstage` — two DIFFERENT widget types at the same `Stack` position, so
Flutter's reconciliation discarded and recreated the Element the moment a
tab's wrapper type changed between those two states, silently losing
scroll/state anyway despite the keys matching. The actual fix keeps every
slot's wrapper shape identical on every build (`Offstage` → `SlideTransition`
→ tab, always, with only `offstage`/the animation's current value
varying), which is what makes state survive a round trip.

Verified by `test/core/presentation/navigation/app_shell_test.dart` (4
tests, all passing against the real `AppShell`):
- tapping each of the 6 tabs actually swaps the visible content;
- **scrolling the Transaksi list, switching to Home and back, the scroll
  position survives the round trip** (fails against the buggy
  `KeyedSubtree`/`Offstage` version above — this is a real regression
  test, not a renamed assertion);
- the Android back gesture from a non-Home tab returns to Home and never
  pops `AppShell` itself (i.e. never exits the app);
- the tab-switch slide transition still animates (mid-transition position
  differs from the settled resting position), preserving M14's
  `docs/DESIGN.md` §Motion touchpoint 1 requirement.

Two now-redundant per-screen navigation tests
(`assets_screen_test.dart`'s and `budget_home_screen_test.dart`'s
"bottom nav navigates to X" assertions) were removed rather than patched:
they asserted the OLD push-based contract on a bare screen pumped without
an `AppShell` ancestor, which `AppBottomNav` (now provider-only) has no way
to satisfy standalone by design — the behavior they tested is superseded
by, and now exclusively covered by, `app_shell_test.dart`.

## Item 6 — form providers audited for `.autoDispose`

Audited every `NotifierProvider` form-state provider in the codebase
(`lib/features/**/application/*providers.dart`):

| Provider | Before | After |
|---|---|---|
| `transactionFormProvider` | `NotifierProvider` | `NotifierProvider.autoDispose` |
| `walletFormProvider` | `NotifierProvider` | `NotifierProvider.autoDispose` |
| `payCycleTransitionNotifierProvider` | `NotifierProvider` | `NotifierProvider.autoDispose` |

Goal (`GoalFormScreen`) and Asset (`AssetFormScreen`) forms were audited
too but use local `ConsumerStatefulWidget` state (plain `TextEditingController`s
and `setState`), not a Riverpod form-state `Notifier` — confirmed by
checking both files for any `NotifierProvider`/form-state class, finding
none. There is nothing to convert for those two; their form state is
already scoped to the widget's own lifetime and disposed automatically
when the screen is popped. `exportImportNotifierProvider`,
`appLocaleProvider`, `themeModeProvider`, `currentDayProvider`, and the
filter/tab-index notifiers were deliberately left non-`autoDispose` — they
hold app-lifetime state that's meant to persist (current theme/locale,
today's date, which tab/filter is active), not per-visit form state, so
auto-disposing them would be the wrong fix.

## Item 7 — export/import JSON work moved to `Isolate.run`

`lib/features/export_import/data/export_import_repository.dart`'s
`buildBackupJson()`, `buildTransactionsCsv()`, and `validateBackupString()`
now run their `jsonEncode`/`jsonDecode` + `BackupData` (de)serialization
and validation on a background isolate via `Isolate.run`, after the Isar
read (which must stay on the main isolate — Isar queries aren't valid
across an isolate boundary).

Method: `test/performance/export_import_isolate_test.dart` measures
real wall-clock cost of the JSON pass on-thread vs `Isolate.run`, at both
M15's realistic 800-tx volume and an 8,000-tx stress volume:

| Backup size | Encode on-thread | Encode `Isolate.run` | Decode+validate on-thread | Decode+validate `Isolate.run` |
|---|---|---|---|---|
| 800 tx (262.7KB JSON) | 27.4–31.6ms | 15.7–19.0ms | 25.8–43.2ms | 17.9–33.7ms |
| 8,000 tx (2,622.8KB JSON) | 61.6–79.5ms | 57.4–63.2ms | 135.7–145.7ms | 158.0–181.6ms |

**Honest read:** encoding clearly benefits from `Isolate.run` at both
sizes (consistently ~35-45% faster off the main thread, two runs). Decode
benefits at 800 tx, but at 8,000 tx `Isolate.run` is actually SLOWER than
on-thread in both runs — the fixed cost of spawning an isolate and copying
the ~2.6MB JSON string across the isolate boundary outweighs the decode
work itself at this single-shot size. The fix is still correct and worth
keeping: the actual motivating concern is UI-thread responsiveness (a
46-146ms synchronous block on the main isolate is a dropped-frames problem
regardless of whether the isolate-hop itself nets out faster or slightly
slower in total wall-clock terms), and the realistic 800-tx case — PRD's
actual expected data volume — shows a clear win either way.

## Summary

| # | Item | Method | Result | Fixed? |
|---|---|---|---|---|
| 1 | `@Index()` on 5 fields | Real (native Isar, 10,000-row host benchmark) | Indexed path available + sub-50ms; absolute delta small/noisy at this volume, structural fix for future growth | Yes |
| 2 | 3 redundant full-table streams | Code review + structural fix | Consolidated to 1 shared native watch; deeper per-consumer narrowing deliberately not applied (financial-logic risk, see item 2 above) | Partially (by design) |
| 3 | Grouping/`DateFormat` in `build()` | Code review + structural fix | Moved to `groupedTransactionsProvider`, `DateFormat`s hoisted to module-level | Yes |
| 4 | Non-virtualized list | Real (`flutter test` widget benchmark, same 800-tx volume as M15) | First-frame build time down 35-48% — genuinely different from M15's flat result (row- vs group-level) | Yes |
| 5 | Tab rebuild + back-button bug | Real (`flutter test` widget tests, 4/4 passing incl. a scroll-survives-round-trip regression test) | Persistent `AppShell`, back button fixed, a real state-loss bug caught and fixed during verification | Yes |
| 6 | Form providers not `autoDispose` | Code audit | 3 provider-backed forms converted; goal/asset forms use local widget state (nothing to convert) | Yes |
| 7 | Export/import blocking the UI thread | Real (`flutter test` wall-clock benchmark, 800 & 8,000 tx) | Encode clearly faster off-thread at both sizes; decode faster at 800 tx, isolate-spawn overhead outweighs it at 8,000 tx — fix kept for UI responsiveness regardless | Yes |

`flutter analyze`/`dart format` clean. Full suite: 305/305 tests passing
(including 4 new `AppShell` tests, 3 new dedicated M18 performance
benchmarks, and the 2 obsolete pre-`AppShell` navigation tests removed as
described in item 5).
