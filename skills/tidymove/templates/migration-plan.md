---
type: migration-plan
version: 1
written: <TIMESTAMP>
revised: <TIMESTAMP>
supersedes: none
companions: inventory.csv, triage.csv, workspace-standard.md, manifest.csv
status: draft-not-authorized
---
<!-- Fill gates and exact operations. This template is not execution permission. -->
# Migration plan

## Hard rules and delta
<!-- Quote owner's non-secret constraints; record changes since the last inventory. -->
Original sources remain untouched. Copy, verify, switch consumers, keep originals.

| Since / cutoff | Changed item | Evidence | Manifest / capacity effect |
|---|---|---|---|
| `<TIME>` | New local work in `<PROJECT>` | Fresh inventory | Reconcile before approval |

## Capacity
| Data | Selected bytes | Additional live/rescue/staging copies | Peak | Free / reserve | Evidence |
|---|---|---|---|---|---|
| `<PROJECT>` | 1024 | Independent backup budget separate | 1024 | `<MEASURED>` | Dry row 1 |

## Execution batches
<!-- Use any batch IDs; journey phases remain 0-9. Owner approval is separate from an audit verdict. -->
| Batch / phase | Prerequisites | Exact work / outputs | Gate / owner action | Failure stop | Rollback |
|---|---|---|---|---|---|
| B-01 / 6 | Frozen source; approved plan | Copy manifest row 1 to inactive target | Full hash pass; owner opens project | Any mismatch or denied read | Retain partial copy; use fresh target; originals untouched |

## Manifest contract
<!-- Save the following schema as manifest.csv without Markdown/comments. Quote CSV values normally. -->
```csv
source,target,mode
<SOURCE-1>/<PROJECT>,<TARGET>/<SCOPE>/<PROJECT>,folder
<SOURCE-1>/notes.txt,<TARGET>/Documents/notes-home.txt,file
<SOURCE-2>/notes.txt,<TARGET>/Documents/notes-project.txt,file
```

`folder`: target is the exact destination root. `file`: target includes the exact destination filename, which may differ from the original. Preview each name change. The destination must be absent or already match the source by SHA-256; it is never overwritten. Replace placeholders with absolute platform paths. Keep manifest/logs outside all data roots. Use only non-overlapping ordinary-data rows. Separate secrets, links, placeholders, cloud and activation into owner-led rows below.

<!-- Optional richer planning fields; only source,target,mode go into the executable CSV. -->
| Planning field | Convert to executable form |
|---|---|
| phase / scope / notes | Keep in batch ledger and decision log |
| kind=folder or ordinary repo | mode=folder, after all special entries have dispositions |
| kind=file with destination directory | mode=file; append the approved destination filename |
| src / dst | source / target; validate resolved paths |
| remote / cloud / archive / worktree relink | Separate reviewed operation; generic copier does not implement it |
| xd / xf exclusions | Explicit bounded rows plus exclusion ledger; no silent loss |

## Special rows and coverage
| ID | Source item | Disposition | Owner / approval | Verification | Included in acceptance? |
|---|---|---|---|---|---|
| S-01 | `<SOURCE-1>/<OPAQUE-LOCATION>` | Owner handles separately | Pending | Owner-reported, contents never read | Pending |

## Reviews and execution authority
| Review | Verdict / evidence | Required fixes | Verified closure |
|---|---|---|---|
| Coverage | Pending independent review | None assessed yet | Pending |

Owner approval: `<EXACT BATCH, DESTINATIONS, IDENTITY, TIMESTAMP>`

Unattended limits: `<ROWS, RETRIES, STOP SIGNALS, MONITOR, PID/LOGS, MORNING HANDOFF>`

Activation and rollback: `<CONSUMERS TO SWITCH, APPROVAL, MARKERS, RETAINED VERIFIED COPY>`
