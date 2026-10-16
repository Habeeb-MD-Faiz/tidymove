---
type: system-map
updated: <TIMESTAMP>
writer: <RECORDER>
sources: <EVIDENCE-POINTERS>
---
<!-- Current facts only. Separate verified facts, owner testimony, inference and pending checks. -->
# System map

## Machine and storage
| Logical device | Physical identity reference | Mount / path | Role | Same failure domain | State / checked |
|---|---|---|---|---|---|
| `<SOURCE-1>` | Private disk record | `<SOURCE-1>` | Kept original | Separate old disk | needs checking |

## Where things live
| Area | Active path | Retained original / backup | Links and dependencies | Evidence |
|---|---|---|---|---|
| `<PROJECT>` | `<TARGET>/<SCOPE>/<PROJECT>` | `<SOURCE-1>/<PROJECT>` | None confirmed | needs checking |

## Identities and storage policy
<!-- Labels only; never login material. -->
| Scope | Git author rule | Outgoing account | Agent account policy | Allowed cloud destinations |
|---|---|---|---|---|
| `<SCOPE>` | `<RULE>` | `<ACCOUNT-LABEL>` | `<RULE>` | Pending owner choice |

## Tools, agents and secrets
| Component | Version / path | Configuration source | Test / limitation |
|---|---|---|---|
| Agent instructions | `<CANONICAL-FILE>` | Scope adapters | Fresh nested-session test pending |

<!-- State secret-store roles and wrapper/service boundaries without values or contents. -->
Secret custody: `<PASSWORD-MANAGER>` | Local opaque location: `<VAULT>` | Agent access: `<BOUNDARY>`

## Procedures and open items
| Procedure / item | Steps or pointer | Owner | Next check |
|---|---|---|---|
| Restore backup | `verification-report.md` | `<OWNER>` | Owner-run recovery exercise |
