# Phase 9: close out and retain recovery

Write `closeout.md`, `session-record-index.md`, `change-log.md` and the final `docs/STATE.md`. Keep an executive outcome separate from the detailed debugging record.

1. Reconcile all phases and manifest dispositions against current evidence, because old progress reports can overstate completion.
2. List accepted exceptions with owner, consequence, next action and review date. Keep unrelated improvements in separate tasks.
3. Prepare an owner-run restoration script for temporary power, scan, indexing or scheduled-task changes. Dry-run it first and restore recorded original values, not guesses.
4. Require the current run's full disposition ledger before restoration and decommissioning. Do not hardcode the case study's row count into a gate.
5. Leave original disks read-only. Safely eject them. If the OS reports "in use", close handles and retry; if unresolved, save work, shut down, then let the owner unplug.
6. Record each retained disk's physical label, custody and reconnection procedure privately. Never format, reuse or delete originals as a closeout step.
7. Verify the next boot and representative work without originals attached. A path can appear correct while an old drive still satisfies a hidden dependency.
8. Record owner acceptance and known backup gaps. Mark the run closed only to that explicit scope.

The detailed session record needs a timezone, date range, source list, coverage gaps, event timeline, decisions, failures and fixes, artifact index and correction precedence. Preserve raw history privately. Do not publish raw transcripts or pretend a regex redaction proves anonymity.

When notes disagree, prefer later verified evidence and actual artifacts; preserve the old claim with a dated correction. Distinguish the last planning session, execution session and later closing verification so final steps do not vanish from the record.

STATE must name what works, what is owner-reported, what remains unverified, active jobs if any, retained originals, changed settings and the next three actions. If no migration action remains, say so and point to the later-work list rather than inventing more work.
