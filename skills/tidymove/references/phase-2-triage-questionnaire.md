# Phase 2: triage and short questionnaires

Use `triage.csv`, `questions-batch.md` and `decision-log.md`. Keep uncertainty visible until the owner resolves it.

1. Assign stable IDs to unknown items, because filenames can recur in different places.
2. Record source, size, count, dates, likely purpose, evidence and the unresolved choice. Label guesses inferred.
3. Group at most four related questions. Put the whole decision context in each card, because preceding text may be hidden by the question UI.
4. Offer a recommended option with a reason, reasonable alternatives, and Other / explain / defer. A recommendation is never a selected answer.
5. Save the raw dictated answer and normalized meaning. Clarify ambiguous scope, filenames or a misheard tool before changing a row.
6. Update the triage disposition, destination, approval scope and linked manifest row. Record rejected options and reasons.

Example card:

> **Q-01: What should happen to `<PROJECT>`?** What this is: a 1.6 GB folder on `<SOURCE-1>`, containing local work with no known remote. Its last modified date is recorded in inventory row I-01. Copying preserves it and consumes 1.6 GB plus backup space. A: copy to `<TARGET>/<SCOPE>/<PROJECT>` (Recommended, because no other copy is verified). B: retain only on the original (no target space, unavailable when unplugged). C: defer until the owner inspects it (migration acceptance stays conditional). Other / explain: describe another destination or ask for more context.

Do not ask the owner to infer what "leave it" means. Say "retain only on the original; do not copy; never delete." Do not label regenerable files disposable without checking Git tracking and app ownership. Treat "work can be rebuilt" separately from "its database can be rebuilt."

| Answer | Triage result | Next action |
|---|---|---|
| Copy to recommended destination | copy-approved | Add bounded manifest row |
| Keep only on original | retain-original | Record consequence and owner acceptance |
| Secret or sensitive document | owner-handled | Record location and owner-run evidence only |
| Decide later | deferred | Assign owner and next review; do not upload |
| Cancelled, missing or unclear answer | unresolved | Continue independent planning; keep gate closed |

Gate: every unknown has an answer or a named deferred disposition. Do not convert a batch's partial answers into blanket approval.
