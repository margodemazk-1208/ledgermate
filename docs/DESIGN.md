# Design Direction — LedgerMate

> **Status: v2 (2026-10-30) — confirmed by user.** Supersedes the v1 agent-draft below (teal/#0FA37F, Inter) which was never confirmed; this version reflects the user's own Figma mockups (`docs/design/mockups/`) plus a motion grilling session, both explicitly approved. See D17 in `docs/DECISIONS.md`.

## Identity
A personal daily-budget tracker for people who've felt the "money just disappeared" problem — students, first-jobbers, people on irregular income. The tone should feel like a calm, competent friend who's good with numbers, not a corporate banking app and not a cutesy gamified app.

## Dial
`ENERGY 2 / RHYTHM 2 / MOTION 2` — calm and data-forward by default, with deliberate moments of personality (the daily number, goal milestones, FAB) that get more visual/motion weight. Confirmed unchanged from v1; MOTION 2 re-confirmed explicitly during the 2026-10-30 motion grilling session (see §Motion below) over MOTION 1 (minimal) and MOTION 3 (playful/energetic).

## Palette (v2 — from user's Figma mockups, see `docs/design/mockups/`)
- **Base (dark, default):** near-black `#121212` background, elevated surface `#1e1e1e`, secondary surface `#262626`, border `rgba(255,255,255,0.08)`, primary text `#e9e8e4`, muted text `#8a8a86` / `#6f6f6b`.
- **Base (light — still mandatory per PRD FR-09/AGENTS.md R-21/R-34):** invert the above with the same structure — e.g. `#FAFAFA` background, `#FFFFFF` surfaces, `#14161A` primary text, `#5B6370` muted text. The burgundy accent and semantic colors below stay the same in both themes (adjust only for contrast, not hue).
- **Brand accent: doff/muted burgundy `#7d4349`** (soft variant `#a8767b` for text-on-dark contexts like the logo wordmark and active nav, deep variant `#5e3236` for pressed/darker states). *Replaces the v1 teal `#0FA37F` draft — user's explicit choice, added as "pemanis" (accent) over the dark monochrome base, applied deliberately to brand/action moments only: logo, FAB, active nav indicator, primary buttons, progress bars, selected filter pills — NOT splashed everywhere (that would undo the calm monochrome base it's meant to accent).*
- **Semantic status colors (functional, exempt from the "1 accent" cap because they encode data, not branding):**
  - Expense / over-limit: soft red `#e0a0a0`
  - Income / positive / goal progress: soft green `#9fd6a8`
  - Warning (goal unrealistic, FR-06b): keep the existing amber `#F5A623` (not covered by the mockups, carried over from v1 — fine since it's semantic, not brand).

## Typography (v2 — from mockups)
- **Display/script (`Playfair Display`, italic, weight 500):** the "LedgerMate" wordmark, screen titles, card section labels, bottom-nav labels. This is the typeface doing the brand-personality work — it's what makes the app feel "a calm, competent friend" rather than a generic fintech dashboard.
- **Data/numeric (`Space Mono`, regular/bold):** every amount, every form input, every label that's data rather than voice. *Reason: fixed-width digits so Rupiah amounts don't visually jitter as they change (matters a lot given FR-04's live-recalculating daily number), and a monospace grid reads as "precise/financial" — a deliberate choice, not the AI-default Inter the v1 draft reached for.*
- Keep both font families to exactly these two weights/styles each (italic 500 for Playfair, regular+bold for Space Mono) — do not introduce more weights without a new decision entry; the mockups use this restraint deliberately.

## Identity motif
Unchanged from v1: **the daily safe-spend number is always the single largest, boldest element on whatever screen shows it.** In v2 this number additionally gets the count-up motion treatment (see §Motion) — it is the one element in the entire app allowed to visibly "perform."

## Iconography
Simple 1.5px-stroke line icons (no filled icons, no duotone, no emoji) — see `docs/design/mockups/style.css` `.icon-circle` pattern (small dark circle badge, 24px, centered icon). Category/wallet icons live inside these circular badges consistently across screens.

## Source of truth for screen layouts
`docs/design/mockups/` contains the user-approved HTML mockups + rendered PNGs for: Transaksi (`02_*`), Tambah Transaksi (`03_*`), Goals (`04_*`), Aset (`05_*`), Analytics (`06_*`), Settings (`07_*`), and the FAB speed-dial overlay state (`08_*`), plus the two original Figma sketches the mockups were built from (`renders/00_*`, `renders/01_*` — these show the Total Saldo/wallet-cards/Rincian Transaksi Home layout and the bar-chart-as-tren concept). **Read these files directly before implementing any screen — do not re-derive layout from this document's prose alone**, per the project's "inspect actual source files" convention (see `AGENTS.md`). `style.css` in that folder is the literal token reference (hex values, spacing, border-radius) — lift values from it directly rather than re-guessing them.

The mockups predate the Wallet feature's final UI (M12 backend already exists; `03_tambah_transaksi.html` already shows a wallet-picker row as a forward-looking placeholder) — the Wallets list/CRUD screen itself has no dedicated mockup and should be designed to match the established card/pill/icon-circle visual language, not invented from a different style.

## Motion (new in v2 — grilled explicitly with the user on 2026-10-30)

Dial: **MOTION 2** (confirmed). Motion exists at specific, deliberate touchpoints — not as ambient decoration on every widget. Respect `MediaQuery.of(context).disableAnimations` (Android's reduce-motion system setting): when true, collapse all durations below to non-zero but near-instant (~1 frame) rather than fully skipping state changes, so nothing *looks* broken, it's just not performing.

| Touchpoint | Treatment | Implementation notes |
|---|---|---|
| **Screen/tab navigation** | Horizontal slide (platform-standard push/pop — new screen slides in from the right on push, exits right on pop; tab switches slide left/right by tab order) | Use Flutter's default `MaterialPageRoute`/`CupertinoPageRoute`-style horizontal slide for stack navigation; for the bottom-nav `IndexedStack`/tab switch, a lighter horizontal slide (~200ms, `Curves.easeOutCubic`) keyed by tab index direction (left-to-right nav order) so moving Home→Settings slides opposite to Settings→Home. **Explicitly NOT** Hero/shared-element transitions — user picked plain slide over Hero specifically to avoid over-dramatizing navigation. |
| **"Uang Jajan Aman Hari Ini" value change** | Count-up/count-down tween from old value to new value whenever it recalculates (new transaction, income, goal change, pay-cycle rollover) | `TweenAnimationBuilder<int>` (or similar) animating the integer Rupiah value over ~500-700ms with an ease-out curve; format with the existing Rupiah formatter on every frame, not just the endpoints, so the user sees real intermediate numbers counting, not a blurred placeholder. |
| **New transaction/goal appears in a list** | Slide-in from top + fade, existing items below shift down smoothly | `AnimatedList` (or `implicit` animation per item via `AnimatedSlide`+`AnimatedOpacity`) — new item enters from ~-16px offset + opacity 0→1 over ~250ms; do NOT re-animate the entire list on every rebuild, only the newly-inserted item. |
| **FAB speed-dial open** | Staggered reveal — each of the 5 options appears in sequence (bottom-to-top order: Pengeluaran, Pemasukan, Transfer, Goal, Aset) with a short delay between each (~40-60ms stagger), each item itself fades+scales in (0.8→1.0 scale, 0→1 opacity) | The FAB icon itself rotates 45° (+→×) over the same total duration. Closing reverses the stagger (top-to-bottom collapse) for symmetry — don't just hard-cut on close while keeping stagger on open. |
| **Button/card press feedback** | Scale-down (~0.96 scale) on press-down, spring back on release, + `HapticFeedback.lightImpact()` on primary actions (Simpan, FAB, Tarik dari Goal) | Apply to primary CTAs and interactive cards (transaction rows, goal cards), not to every tappable pixel — list-row taps that just navigate don't need haptic, only actions with a real consequence (save, delete, withdraw, transfer). |
| **Loading state (data screens: Transaksi, Analytics, Goals, Aset lists)** | Skeleton shimmer placeholders matching the real content's shape (card outlines, text-line bars) while data loads | Given Isar's sub-50ms query time (NFR §6.1), this will usually be imperceptibly brief in practice — implement it anyway for the rare slow case (large dataset, first cold query after import) and for consistency, but don't force an artificial minimum-display duration just to "show off" the shimmer. |
| **Goal/budget progress bar fill** | Animates smoothly from old % to new % (not an instant jump) whenever `currentAmount` changes (daily auto-accrual, withdraw, manual edit) | `AnimatedContainer`/`TweenAnimationBuilder` on the fill width, ~400-500ms ease-out. |
| **Save success feedback** | Animated checkmark that appears then auto-fades out after ~2s (toast/snackbar-style, non-blocking) | A small custom overlay/snackbar with a checkmark icon that scales/fades in, holds briefly, fades out — not Flutter's default plain-text `SnackBar` alone; this is the one explicit "confirmation moment" per the grilling answer, so it should feel a notch more crafted than a generic Material snackbar, while still being quick and non-modal (never blocks the next action). |

### Explicit non-goals for motion (avoid scope creep into MOTION 3 territory)
- No animation on every single widget rebuild — only the touchpoints listed above.
- No Hero/shared-element transitions (explicitly declined in favor of plain slide).
- No looping/idle "ambient" animation anywhere (e.g. no pulsing icons, no floating decorative shapes) — this app's motion communicates state changes, it doesn't perform for its own sake (see antislop Motion principles).

## Mood keywords
Calm, precise, honest, a little warm (not sterile/corporate-cold) — never playful/gamified (this isn't a kids' app), never alarming (red is reserved for genuine overspend, not used decoratively).

## What NOT to do (explicit antislop call-outs for this project)
- No blue-to-purple gradients, no glassmorphism on nav/cards/modals simultaneously, no glow-everywhere (see `AGENTS.md` → antislop R-01/R-10/R-13).
- No fabricated stats/testimonials anywhere in the app (not relevant for marketing copy since this isn't a landing page, but applies to anything resembling "X% of users save more" claims — never show one unless it's real, computed from the user's own data).
- Dark AND light mode both fully styled and tested — this is explicitly required (PRD FR-09), not optional. The burgundy accent and semantic colors stay the same hue in light mode, only surface/text neutrals invert.
- Burgundy is an **accent**, not a new base color — if more than ~10-15% of any screen's visible area ends up burgundy, that's a sign it's being overused; pull it back to the specific brand/action moments listed in §Palette.

---
## v1 draft (2026-10-28, superseded — kept for history per "never silently edit" convention)
Original teal `#0FA37F` / Inter draft is preserved in git history (see `docs/DECISIONS.md` D12 and the file's pre-2026-10-30 version via `git log -p docs/DESIGN.md`) rather than repeated here.
