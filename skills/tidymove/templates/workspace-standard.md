---
type: workspace-standard
version: 1
written: <TIMESTAMP>
supersedes: none
status: draft-awaiting-owner
---
<!-- Desired rules, not claims about the current machine. Replace examples with owner choices. -->
# Workspace standard

## Scopes and layout
| Root / scope | Holds | Excludes | Access / allowed destinations |
|---|---|---|---|
| `<TARGET>/<SCOPE>` | `<PROJECT>` code and work | Other scopes' data | Owner-defined policy |

<!-- Assign separate roles for records, archive, inbox, reference, tools, cache, VMs, agents, system and opaque vault. -->
| Role | Chosen path | Naming / retention |
|---|---|---|
| System records | `<TARGET>/system` | Dated changes and verified map |

## Scope metadata
<!-- Fill one SCOPE.md per scope. Account choice and scope ownership are distinct. -->
```yaml
scope: <SCOPE>
entity: <OWNER-OR-ENTITY>
via: <PARENT-SCOPE>
git_identity: <IDENTITY-RULE>
agent_profile: <ALLOWED-ACCOUNTS-AND-POLICY>
vault: <OPAQUE-LOCATION>
password_manager_folder: <FOLDER-LABEL>
nda: <KNOWN-OR-UNKNOWN>
```

## Naming and structure
<!-- Record slugs, date format, code-versus-record boundary, relative-path dependencies and worktree convention. -->
| Rule | Reason | Exception |
|---|---|---|
| Keep code in its project repo | Preserve history and ownership | Record linked worktrees explicitly |

## Tools, caches, secrets and agents
<!-- One shared toolchain manager; per-project versions; opaque secrets; one canonical rules source. -->
| Area | Standard | Owner action / verification |
|---|---|---|
| Shared runtimes | One managed copy; project environments explicit | Fresh shell resolves intended executable |

## Backup and growth
<!-- Include failure domains, recovery exercise, quota, costs and onboarding. -->
| Scenario | Procedure | Acceptance |
|---|---|---|
| New device | Restore approved data/rules from independent backup | Owner opens representative work |

## Capacity and approval
<!-- Budget peak copies, live+rescue images, archives, staging and reserve. -->
Peak required: `<BYTES>` | Available: `<BYTES>` | Independent backup: `<LOCATION>`

Owner decision: `<ID, DATE, SCOPE>` | Unresolved: `<ITEMS>`
