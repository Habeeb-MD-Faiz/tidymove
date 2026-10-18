# Phase 1: freeze and inventory

Read `recipes-windows.md` or the explicitly untested platform reference. Keep scan output and logs outside every source. Record OS version and tools used.

## Freeze

1. Save work and close editors, terminals, Git watchers, cloud sync, Docker, VMs and scheduled writers touching the source, because even metadata probes may write.
2. Confirm physical identity with the owner. Prepare an elevated script that prints the matched disk and planned effects in dry run. Refuse zero or multiple matches and any system/boot disk.
3. After approval, take the old disk offline, set read-only, assert the flag, then bring it online. If any step fails, stop; never bring it online from a `finally` block.
4. Run `verify-frozen` and retain evidence. Recheck after replug, sleep/wake, reboot and before every copy batch, because disk numbers and runtime flags can change.
5. Observe errors and power transitions. Distinguish owner unplug/sleep events from unexplained retries. A SMART pass or a read-only flag does not prove hardware health.

Never write a test file. A file's read-only attribute is not a disk freeze. Do not run repair tools, change source ACLs or take ownership to make a scan succeed. If a disk cannot be frozen or mounted safely, keep it offline and ask the owner for a recovery plan.

An active system disk cannot be frozen while the owner works on it. Use `inventory -AllowLiveScan` for metadata reconciliation and label it live. For actual copy, close writers and export to storage that can be frozen, or review a separate consistent-snapshot procedure with the owner. The bundled copy tool has no production bypass for writable sources.

## Inventory coverage

| Area | Record without reading secrets |
|---|---|
| Every root and loose file | Direct counts/bytes, oldest/newest modified dates, type mix, denied paths |
| Ordinary folders | Full depth, intentional exclusions and representative non-sensitive names |
| Duplicates | Candidate names/sizes first; hash only approved non-secret content after freeze |
| Caches and toolchains | Actual purpose, package ownership, tracked Git files; do not infer from names |
| Cloud roots | Offline/recall/reparse attributes, online-only counts, linked account label |
| Repositories | Main repos, nested repos, worktrees, dirty/untracked files, stashes, refs, unpublished branches and local-only repos |
| Stateful apps | Docker/VM disks, volumes, bind mounts, DB versions, restart policy, app state |
| Profiles | Browser profiles, downloads, app data, agent transcripts, desktop/CLI settings |
| Opaque locations | SSH, password stores, credentials and secret-looking names; owner handles contents |
| OS areas | Protected system files, recovery folders, public/default profiles and installed apps |

The scanner reports **direct-child** folder totals, so sum folder rows without double counting. Dates are file modification dates, not proof of last use. It skips secret-named subtrees and reparse/cloud entries, with separate rows. It does not hash duplicates or inspect browser databases. List those follow-ups explicitly.

Secret name patterns include passwords, passwd, secrets, credentials, tokens, private keys, wallets, recovery codes, backup codes and seed phrases. The check uses names only and never opens their contents. Filename filters cannot detect every secret.

Fixture scans still inspect ancestor metadata above the selected root to reject links and opaque locations. They cannot honor a strict subtree requirement. Pass `-StrictSubtree` or `--strict-subtree` to refuse that incompatible request before inspecting supplied paths. The [usage guide](../../../docs/USAGE.md#check-the-scripts) lists the exact ancestor checks. Keep those checks intact.

Inventory identifies Git markers without invoking Git or reading repository contents. Dirty status remains `needs-checking`; linked worktree pointers are not followed. A separate Git review requires owner-approved content access and review of repository-controlled configuration and helpers. Disable optional locks and filesystem monitors in that review. A denied directory makes inventory incomplete and exits non-zero. Never set global `safe.directory=*` to hide errors.

Maintain a coverage ledger: discovered root/path, scan status, triage ID, manifest row or retained-original decision, and exception evidence. A broad triage row for a drive is not coverage of every descendant. Self-test the coverage matcher with known included and excluded paths.

Gate: every source has freeze evidence or a live-metadata limitation, and all scan gaps have explicit dispositions. A successful process exit alone does not prove full coverage.
