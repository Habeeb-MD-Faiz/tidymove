# Phase 4: design the workspace standard

Write `workspace-standard.md` for the desired rules and `system-map.md` for live facts. Version the standard and state what it supersedes, because decisions evolved during the evidence run.

| Area | Decide | Reason |
|---|---|---|
| Scopes | Owner-defined agency, employer, client and personal boundaries | Different work has different storage rules |
| Code and records | Code per project; project index and decisions separately linked | A record should not accidentally contain every codebase |
| Taxonomy | Active work, archive, reference, inbox, tools, caches, VMs, agents, system records and opaque vault | Each folder needs a distinct purpose |
| Naming | Stable project slugs, date format and collision suffixes | Paths should survive new devices and teammates |
| Repo structure | Preserve sibling/relative dependencies; choose worktree convention | A tidy folder tree must still run |
| Toolchains | One managed shared copy; explicit per-project versions | Duplicate PATH entries produce inconsistent execution |
| Caches | Shared known locations; separate from irreplaceable state | Capacity planning needs reproducibility boundaries |
| Secrets | Password manager for human custody; opaque vault for local use | Agents need capability without credential disclosure |
| Agents | One canonical rules file plus account and scope adapters | Independent copies drift |
| Backup | Separate device/service, scope/account, frequency, encryption and restore exercise | A second partition is not a backup |
| Growth | New scope/project/device/teammate checklist | The standard must remain usable after this move |

Create scope metadata with owner/entity, parent relationship, Git identity rule, agent account policy, vault location, password-manager folder, confidentiality and allowed destinations. Keep account choice distinct from scope ownership.

Prefer the owner's existing intentional hierarchy over a generic taxonomy. Read ordinary project documentation and relative-path assumptions before proposing new destinations. Do not open `.env` or credential configs for this purpose.

If worktrees live inside a repository, exclude their container from search, indexing, test discovery and build context. Keep existing external worktrees unless the owner approves a separate relink plan. Preserve `.git` histories and pointers in the copies.

Model capacity at peak: source copies on target, pristine rescue images, live images, archives, upload staging, logs, caches and growth reserve. Do not use compressed-size guesses as guaranteed free space. Record whether partitions share physical storage and which reset/reinstall options would erase the workspace.

A new teammate gets their own identity and access; they do not inherit the owner's credentials. A new device restores tools, rules and data from recorded sources and tests recovery. A new client gets a scope and storage policy before files arrive.

Gate: the owner approves the standard, capacity and backup policy. Creating scaffolding under future copy destinations waits until copy behavior is known, because an occupied destination can make older scripts skip data.
