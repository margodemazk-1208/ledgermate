# Decisions Log (ADR-style)

One entry per major decision made during PRD grilling (see full conversation/PRD v2 changelog for detail). Read this before "helpfully" reverting any of these — each was a deliberate tradeoff, not an oversight.

| # | Decision | Why | Do NOT |
|---|---|---|---|
| D1 | No backend server, no accounts, no login | App is personal + shared informally as APK to <20 friends; original PRD v1 was generic SaaS boilerplate (admin/RBAC/shadowing) that didn't fit this use case at all | Add a server "for sync" without a new PRD revision + explicit user approval |
| D2 | Admin Web Dashboard + Consent-Based Shadowing removed entirely | User's original plan to build this was abandoned before v2; each friend's install is fully independent | Re-add any admin/shadowing concept |
| D3 | Android only, no iOS | Distribution is APK sideload to Android-using friends | Add iOS target/config without being asked |
| D4 | No PIN/biometric lock in v1 | Explicitly descoped for simplicity; may return in v2 | Add a lock screen unprompted |
| D5 | Two Income Frequency modes (Periodic / Daily) instead of one monthly-only model | Real users include both salaried earners (weekly/biweekly/monthly lump sum) and students with daily/irregular pocket money (bekel) — one rigid "monthly" model excludes a real target user | Hardcode a monthly-only assumption anywhere in the formula engine |
| D6 | BR-01 formula is self-balancing (recalculates `RemainingBalance / RemainingDays` on every transaction), not a static once-a-month division | Matches the original intent ("smart" budget) and keeps the number honest after over/under-spending | Replace with a static daily allowance |
| D7 | Goal `currentAmount` auto-accrues daily from `DailySavingsReserve`; withdrawal is allowed and feeds back into available balance | App is a tracker, not a wallet — money isn't physically moved, so the mechanic has to be virtual bookkeeping that stays reversible | Build any real money-movement/wallet feature |
| D8 | Asset/Investment tracking exists in v1 but values are 100% manually updated, never fetched from an API | Matches offline-first principle; "no Open Banking/auto-sync" in PRD excludes automation, not the feature itself | Add a price-fetching API integration without a new decision entry |
| D9 | Notifications are on-device only (`flutter_local_notifications`), never FCM/push | No backend exists to push from; also privacy — nothing leaves the device | Introduce any push notification dependency |
| D10 | Riverpod for state management | Modern default, good codegen ergonomics, team familiarity assumed | — |
| D11 | Repo is public on GitHub | User's explicit choice despite being a personal finance app; code is public, user data never is (no data ever leaves the device, nothing to leak) | Commit any seed/sample data that looks like real personal finances |
| D12 | Visual direction: ENERGY 2 / RHYTHM 2 / MOTION 2 (Stripe/Vercel-balanced) per `docs/DESIGN.md` | User's explicit choice over calm-minimal or energetic-consumer alternatives | Default to generic AI gradient/glassmorphism patterns — see antislop rules referenced in `AGENTS.md` |

## Changing a decision

If a milestone genuinely requires revisiting one of these, add a new row below with the date, what changed, and why — never silently edit an existing row.
