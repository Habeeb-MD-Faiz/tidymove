# Phase 5: plan and audit

Use `migration-plan.md` and `audit-report.md`. Build execution batches with prerequisites, exact input/output, expected count/bytes, verification method, owner gate and rollback. Separate local copy from activation, uploads, credential operations and elevation.

1. Convert triage decisions into a manifest, because a plan written only in prose cannot prove coverage.
2. Validate CSV with a parser, not comma counting. Quote notes and paths containing commas. Keep encoding explicit.
3. Resolve paths and reject overlap, duplicate target rows, path traversal, links into sources and log paths inside data roots.
4. Dry-run every row. For file rows, review the exact destination filename, including any change from the source name. Two sources with the same name need distinct destination paths. Existing destinations must match by SHA-256 and are never overwritten. Check actual selected bytes, not a total that includes excluded files. A preflight refusal writes `preflight.csv` with the batch reason for each parsed row when the output path is safe and fresh. If reporting is refused, retain the console reason and correct the path without changing source data or prior evidence.
5. Test scripts on synthetic files, including spaces, Unicode, long paths, extra target files, missing sources and corruption. A skipped dependency check is not a pass.
6. Complete reviews, fix findings and rerun only the relevant checks. Record proof of each fix.
7. Present the exact phase packet to the owner. State identity, destinations, time/capacity estimate, failure stops and rollback.

| Independent review | Checks |
|---|---|
| Coverage | Every source/root/loose file; personal documents in Downloads; nested and dirty repos; app data; cloud placeholders; explicit exclusions |
| Safety | Freeze and physical identity; secret boundaries; no destructive flags; destination conflicts; ACLs; copy-before-activation; privilege and approval |
| Final | Fresh live state; plan/script agreement; capacity; all blocker fixes; power/network state; readiness and unchanged approvals |
| Second-model or separate-person review | Challenge assumptions, script failure paths, false-success checks and the owner's stated constraints |

These are useful review areas, not a fixed number of audits that guarantees safety. If independent agents are authorized, assign one report per reviewer and read-only access to the plan and non-secret evidence. Otherwise hand the packet to another reviewer/session; mark independence pending.

Use severity blocker/high/medium/low and verdict GO / GO-WITH-FIXES / NO-GO. GO-WITH-FIXES does not open the gate until required fixes are verified. An auditor's GO is not owner approval.

For unattended runs, document allowed rows, maximum retries, disk/network stop signals, log location, process ID, expected completion signal and actions that wait for morning. Use a durable job and an OS-held lock; do not launch another writer while the first is alive. The bundled lock covers a single manifest, not every overlapping target across different manifests. A tool timeout does not prove its child exited.

Gate: no unresolved safety blocker, complete row dispositions, fresh dry-run evidence and explicit phase approval. Re-audit affected parts when scope or scripts change.
