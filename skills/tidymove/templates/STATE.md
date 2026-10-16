<!-- Private run handoff. Update facts with UTC timestamp, evidence and confidence; retain earlier decisions in decision-log.md. -->
# STATE: <RUN-ID>

Updated: <TIMESTAMP-AND-TIMEZONE>

## Goal
<!-- State one completion boundary. -->
Copy `<SOURCE-1>` into `<TARGET>` and verify the owner's active workspace while keeping the original.

## Current state
<!-- Include phase, evidence, active jobs/PIDs/logs, changed settings and protected sources. -->
| Area | Status | Evidence class | Evidence / last checked |
|---|---|---|---|
| Inventory | Pending freeze | needs checking | `<SOURCE-1>` has not been checked |

## Decisions
<!-- Link durable decisions rather than reconstructing approval from memory. -->
| ID | Choice | Reason | Owner approval / scope |
|---|---|---|---|
| D-01 | Keep original | Preserve recovery | Intake; no source mutations |

## Rejected options
<!-- Preserve why a tempting approach was rejected. -->
| Option | Reason | Decision |
|---|---|---|
| Mirror with purge | Could remove destination data | D-01 |

## Owner constraints, verbatim
<!-- Paste only this owner's non-secret words. Do not treat this example as their approval. -->
> <OWNER'S EXACT CONSTRAINT>

## Open threads and next three actions
<!-- Name who acts and the gate. Silence is never approval. -->
1. Agent: confirm source identity with owner; no freeze yet.
2. Agent: prepare the bounded freeze dry run.
3. Owner: review and run the approved elevated step.

## Pointers
<!-- Include actual private run paths, manifest revision, logs, reports and retained-original locations. -->
| Record | Location | Purpose |
|---|---|---|
| Decision ledger | `decision-log.md` | Authority and rationale |
