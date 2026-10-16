<!-- Reuse first as a reconcile table, then fill observed outcomes. Counts do not imply hashes. -->
# Verification: <RUN-ID>

Cutoff / timezone: `<TIME>` | Manifest revision: `<REVISION>` | Checker: `<RECORDER>`

## Reconciliation
| Item / row | Source / current / cloud copies | Chosen authority and why | Expected paths/count/bytes | Observed | Method / hash scope | Evidence / confidence |
|---|---|---|---|---|---|---|
| B-01 row 1 | `<SOURCE-1>/<PROJECT>` | Local-only work | 1 file / 1024 bytes | Pending | All SHA-256 plus path/size | needs checking |

## Source protection and integrity
| Source | Identity evidence | Read-only before / after | Original content checks | Limitation |
|---|---|---|---|---|
| `<SOURCE-1>` | Owner-confirmed disk record | Pending / pending | Selected ordinary files only | Secret contents remain opaque |

## Operational checks
| Check | Expected | Observed / date | Owner or agent | Evidence |
|---|---|---|---|---|
| Open `<PROJECT>` | Correct files and local changes | Pending | `<OWNER>` | Record specific check |

## Exceptions and extras
| Item | Status | Cause | Retained location | Owner acceptance / next action |
|---|---|---|---|---|
| S-01 | owner-handled | Opaque data | Original retained | Confirmation pending |

## Acceptance
<!-- Choose a precise boundary; never replace exceptions with a blanket done marker. -->
Result: `<VERIFIED / PARTIAL / BLOCKED>`

Backup assurance: `<PATH-SIZE / SAMPLE-HASH / ALL-HASH / RESTORE-TEST / OWNER-REPORTED>`

Owner switchover approval: `<DECISION-ID>` | Activation markers: `<PATHS>`
