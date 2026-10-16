# Phase 8: agents and guards

Preserve history first. Audit configuration second. Rebuild only what the owner approves, because a blind profile copy carries obsolete trust and account settings.

## Audit and shared instructions

Inventory global, account, workspace, scope, repo and worktree configuration. List skills, plugins, hooks, connectors, MCP servers, trust paths and scheduled agents by name. Do not open auth or mixed credential configs. Ask the owner to export a sanitized schema if needed.

Review a bounded owner-approved sample of non-secret session summaries to understand actual work. Record sample size and selection bias. Archive old config privately before changes; do not bulk-copy opaque credential state through the agent.

Keep one canonical instructions file. Add thin provider adapters and scope rules for data storage, identity, messaging and publication. Test imports from a nested repo in a fresh session, because discovery differs by tool and level. If using hard links, verify actual file identity and remember they require compatible local storage. If using copies, record source hash and a controlled refresh process. Preserve the owner's original files.

Keep account rules separate from scope rules. Either login may do several kinds of work, while each login's storage restrictions still apply. Confirm the active identity without retrieving or printing credentials. Test Git author from the actual scoped repo, not a scratch directory outside that scope.

## Secret boundary

| Layer | Pattern | Limit |
|---|---|---|
| Human custody | Mature password manager; owner login and recovery | Agent must not unlock/export it |
| Local opaque storage | Vault outside project trees; restrictive OS access | Same-user code may still have access |
| Examples | Commit variable names in `.env.example`, without values | A filename detector cannot find every hardcoded secret |
| Temporary use | Owner-managed wrapper injects approved keys into one child command | That child can read its environment; this is not isolation |
| Guard hook | Deny secret reads/writes and source writes; route system actions | Regex rules miss indirect code paths |
| Stronger separation | Narrow tool service under another identity/process with inaccessible keys | Requires capability and OS access design |

Never place key values on a command line, in logs, screenshots, test fixtures or instructions. Do not allow environment dumps, auth-token retrieval or arbitrary child code through the wrapper. Protect wrapper and guard edits separately from ordinary invocation. A denial must not be bypassed by moving the same command into a script.

A system manager is an optional owner-controlled review process, not a service installed by this kit. If none exists, the owner reviews and runs approved system changes directly. Define a system-manager request with action, reason, affected paths, exact proposed command, dry-run evidence, authority and rollback. The manager may allow only an already authorized, bounded action. It asks the owner when authority or consequences are new. Its classifier should have no secret access and no execution tools; an approved executor performs the action. It cannot expand its own permissions.

## Test matrix

| Test | Expected result |
|---|---|
| Read ordinary README | Allowed |
| Read `.env`, `service.env`, `.secrets/`, credential JSON or private key | Denied before contents are read |
| Print injected environment | Denied |
| Write original source | Denied |
| Edit guard/wrapper or change installs/PATH | System-manager review or owner gate |
| Upload from restricted scope | Denied unless separately authorized |
| Write message to another person | Owner approval required |
| New nested session in each provider/account | Correct shared and scope rules loaded |
| Guard crash, unsupported tool or unknown action | Fail closed or mark enforcement unsupported |

Use harmless synthetic filenames and values for tests. Test each provider independently; a Claude hook does not imply Codex or Gemini enforcement. Do not advertise a regex guard as protection against arbitrary code running as the owner.

## History and account handoff

Snapshot sessions before retention cleanup. Record file counts and bytes separately from transcript counts. Stop all session writers before the final copy. Long-path-aware checks must find every expected file; a changing live transcript blocks switchover. Share history between accounts only when the owner explicitly approves the data boundary. Otherwise retain separate stores. Verify resume behavior for each selected account. Never recursively remove old profile trees containing links to active history.

Record launchers, PATH resolution, history locations, retention policy and session index in the system map. Park unused skills behind a short catalog if the owner wants on-demand loading. Treat token-saving estimates as inferred until a fresh session measures them.

Gate: approved configuration is tested per provider/account, retained history is verified, limitations are explicit, and phase 7 checks affected by the changes pass again.
