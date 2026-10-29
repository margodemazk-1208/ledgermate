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
