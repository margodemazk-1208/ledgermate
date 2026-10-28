# Design Direction — LedgerMate

> **Status: draft by agent, needs your confirmation/adjustment** (per antislop R-37 — this was written by the agent, not supplied by the user, so it is flagged honestly rather than presented as final).

## Identity
A personal daily-budget tracker for people who've felt the "money just disappeared" problem — students, first-jobbers, people on irregular income. The tone should feel like a calm, competent friend who's good with numbers, not a corporate banking app and not a cutesy gamified app.

## Dial (from user's choice: "balanced, Stripe/Vercel-style")
`ENERGY 2 / RHYTHM 2 / MOTION 2`
- Mostly calm and data-forward, with a few deliberate moments of personality (the daily number, goal milestones) that get more visual weight.
- Not uniform-boring (dial 1) but not loud/animated everywhere (dial 3).

## Palette
- **Base (dark, default):** near-black charcoal `#121417` background, elevated surfaces `#1C1F24`, primary text `#F2F3F5`, secondary text `#9CA3AF`.
- **Base (light, must be fully functional too — see AGENTS.md R-21/R-34):** `#FAFAFA` background, `#FFFFFF` elevated surfaces, primary text `#14161A`, secondary text `#5B6370`.
- **One brand accent:** deep teal `#0FA37F` — used for the primary CTA, active tab, and the "safe to spend" number when positive. *Reason: teal reads as "calm/trustworthy" rather than the generic blue-purple gradient antislop flags (R-01); it is also distinct from the semantic green below so the two don't collide.*
- **Semantic status colors (functional, not decorative — exempt from the "1 accent" cap because they encode data, not branding):**
  - Over-limit / expense emphasis: warm red `#E5484D`
  - Goal progress / positive savings: emerald `#22C55E`
  - Warning (goal unrealistic, FR-06b): amber `#F5A623`

## Typography
**Inter** (or the platform default if Inter adds APK size concerns — decide at M0). *Reason: tabular/lining figures and strong numeral legibility, which matters more here than in most apps since every screen is numbers-first.* Not chosen because it's "the AI default" — chosen because this is a numbers-heavy app and Inter's digit rendering is specifically good at that job.

## Identity motif (the "one repeated thing" that makes this feel like LedgerMate, not a generic finance app)
**The daily safe-spend number is always the single largest, boldest element on whatever screen shows it** — it is the one focal point the whole Home screen defers to (see antislop Liveliness Toolkit: "one focal point per screen"). Every other number on that screen is visually quieter than it.

## Mood keywords
Calm, precise, honest, a little warm (not sterile/corporate-cold) — never playful/gamified (this isn't a kids' app), never alarming (red is reserved for genuine overspend, not used decoratively).

## What NOT to do (explicit antislop call-outs for this project)
- No blue-to-purple gradients, no glassmorphism on nav/cards/modals simultaneously, no glow-everywhere (see `AGENTS.md` → antislop R-01/R-10/R-13).
- No fabricated stats/testimonials anywhere in the app (not relevant for marketing copy since this isn't a landing page, but applies to anything resembling "X% of users save more" claims — never show one unless it's real, computed from the user's own data).
- Dark AND light mode both fully styled and tested — this is explicitly required (PRD FR-09), not optional.

---
**To confirm/adjust:** reply with changes to any hex value, the typeface choice, or the dial — otherwise this stands as the direction for all UI work from M2 onward.
