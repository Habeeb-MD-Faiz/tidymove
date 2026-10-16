<!-- Eight sections keep the final record readable. Replace examples; keep detailed chronology in the session index. -->
# Closeout: <RUN-ID>

As of `<TIME, TIMEZONE>` | Accepted by `<OWNER / DECISION-ID>`

## 1. Outcome
<!-- State scope, confidence, retained originals and exceptions. -->
`<PROJECT>` is `<STATUS>`. Originals remain at `<SOURCE-1>`. Acceptance depends on the checks listed below.

## 2. Phase status
| Phase | Planned | Actual | Status | Evidence / class |
|---|---|---|---|---|
| 6 Copy | B-01 | `<RESULT>` | Pending | needs checking |

## 3. Decisions
| ID | Choice | Why | Rejected alternative | Approver / consequence |
|---|---|---|---|---|
| D-01 | Keep original | Recovery | Destructive move | Owner; original storage retained |

## 4. Left for later
<!-- Group owner, system-manager and separate-project work. Give each an owner and acceptance criterion. -->
| Item | Owner / category | Reason deferred | Dependency / next action | Done when / review date |
|---|---|---|---|---|
| Off-device restore test | `<OWNER>` | Awaiting media | Choose approved backup | Representative restore passes / `<DATE>` |

## 5. Where things live
| Area | Active destination | Retained original / archive | Links / backup |
|---|---|---|---|
| `<PROJECT>` | `<TARGET>/<SCOPE>/<PROJECT>` | `<SOURCE-1>/<PROJECT>` | `<VERIFIED-BACKUP>` |

## 6. Where secrets go
<!-- Roles only, never values or secret file contents. -->
| Role | Custodian / location | Agent boundary |
|---|---|---|
| Human credentials | Owner's password manager | No unlock, read or export |

## 7. Undo and recovery
<!-- State prerequisites and actions needing approval. Do not propose writing back into originals. -->
| Scenario | Recovery path | Gate | Evidence |
|---|---|---|---|
| Active copy fails | Stop consumers; use retained verified copy | Owner approves switch | `verification-report.md` |

Temporary settings restored: `<EVIDENCE>` | Originals safely unplugged: `<EVIDENCE>` | Next boot checked: `<EVIDENCE>`

## 8. Files and context
| Artifact / session | Private location | Purpose / range | Known gap |
|---|---|---|---|
| Session index | `session-record-index.md` | Chronology and corrections | `<NONE-OR-GAP>` |
