# Phase 3: reconcile with the current machine and cloud

Inventory is what exists. Reconciliation establishes what should win. Use the comparison table in `verification-report.md` before copying, then fill its observed columns afterward.

| Compare | Evidence | Decision |
|---|---|---|
| Old and current project copies | Refs, dirty status, untracked work, stashes, file dates and full hashes where appropriate | Preserve each distinct version; choose a working copy |
| Local and remote Git | All branches and refs, unpublished commits, nested repos | A fresh clone alone cannot preserve local work |
| Documents and media | Relative paths, lengths, hashes, owner intent | Do not choose only by newest timestamp |
| App/VM state | Disk dates, app versions, volumes and owner knowledge | Keep both generations until data checks pass |
| Cloud | Correct account, quota, accessible objects and placeholders | Decide local/archive/owner-recovery destination |
| Software | Package ID, version, scope, install path, method and use | Keep, reinstall, drop-from-new-setup or defer |
| Agent config | Global, account, scope and project layers; loaded behavior | Preserve history; rebuild config deliberately |

1. Record a reconciliation cutoff and timezone, because work may continue between audits.
2. Rescan changed paths on the current machine and frozen sources. Record new downloads, repos and sessions since the cutoff.
3. If the owner worked after the plan, repeat the delta check before execution. Record denied areas rather than claiming zero changes.
4. Resolve aliases to package IDs and real executable paths. Do not uninstall a package kept under another name.
5. Inspect commands in a fresh shell after PATH changes. Distinguish a store alias from an installed runtime and an app-private runtime from a duplicate shared toolchain.
6. Record accounts by role and storage policy; do not read auth configuration or retrieve tokens to prove identity.
7. Keep alternative copies in separately named target locations. Never overwrite a conflict merely because one copy appears newer.

Cloud auth and quota checks require the owner's approved account. Run interactive login in a separate owner terminal, because some commands print OAuth material. Provider quotas and consent requirements change; check current official documentation before giving account setup steps.

Gate: each conflicting item has an explicit winner for active use and a retained alternative, or remains deferred. Update manifest counts and capacity after every decision.
