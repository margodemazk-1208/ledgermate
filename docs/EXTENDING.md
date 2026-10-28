# Extending LedgerMate (post-v1 ideas)

Everything below is explicitly OUT of v1 scope (see `docs/PRD.md` §3.2 and `docs/DECISIONS.md`). Listed here so a future "let's add X" conversation starts from an informed baseline instead of rediscovering the same tradeoffs. **None of this should be implemented without a new PRD revision and explicit user go-ahead** — adding any of it silently is exactly the "deviating from plan" failure mode this doc structure exists to prevent.

- **PIN / Biometric lock** — descoped in v2.0 of the PRD for v1 simplicity (D4). Isar already supports encryption; a lock screen is additive, not a rearchitecture.
- **iOS support** — Android-only was a deliberate distribution-model choice (D3), not a technical limitation. Flutter makes this mechanically easy later; the cost is an Apple Developer account + a Mac to build.
- **Accounts + cloud backup/sync** — would require introducing the backend server this project explicitly avoided (D1). This is the single biggest architecture change on this list; treat it as effectively "different app" territory.
- **Open Banking / bank & e-wallet auto-sync** — explicitly excluded even for the Asset tracker (D8); only manual value entry exists today.
- **Real-time asset price fetching (stocks/crypto/gold APIs)** — same reasoning as above; would also break the "offline-first, no network dependency" principle for core app function.
- **Receipt OCR** — `receipt_url` field is already reserved (nullable) on the Transaction-adjacent data model per original PRD v1 assumption, but no OCR pipeline exists.
- **Monetization** — app is free by design; no payment/subscription infrastructure exists or is planned.
- **Multi-currency** — IDR-only assumption is baked into formatting/validation (`core/utils/`); adding a second currency touches that layer plus every amount-displaying widget.

## If one of these gets greenlit later
1. Update `docs/PRD.md` with the new requirement (new FR/BR id, not a silent edit to an existing one).
2. Add a row to `docs/DECISIONS.md` explaining the reversal.
3. Re-run the "grill me" clarification pass for the new feature specifically — don't bolt it on from a single one-line request.
