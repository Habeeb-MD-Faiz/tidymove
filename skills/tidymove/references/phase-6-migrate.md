# Phase 6: migrate

Execute only the approved batch. Keep originals frozen and destinations inactive. Use new log directories for each attempt so evidence survives.

## Ordinary files

1. Recheck frozen state, capacity, manifest version and absence of live writers.
2. Run `copy-verify` without `-Execute`. Review every row and every exclusion.
3. After approval, run `-Execute` with full hashing by default. Folder rows use robocopy or rsync. File rows copy directly to the exact approved filename with overwrite disabled, then verify SHA-256. The tool never purges or deletes.
4. Review the verification CSV and row logs. Transport exit codes alone do not prove byte equality. A preflight refusal records `REFUSED` and the batch reason for each parsed row in `preflight.csv`, before any destination copy. If a safe report cannot be written, retain the console refusal. Do not reuse an output directory or put logs in source data to force a report.
5. Preserve partial targets. If a pre-existing file differs, use a fresh target and record the superseded partial copy; never force an overwrite.
6. Recheck source state and counts. Obtain the owner's application checks before switching consumers.

For folder rows, the Windows helper uses `/E /COPY:DAT /DCOPY:DAT /XJ /Z` with bounded retries. `/XC /XN /XO` skips pre-existing files, which are fully hashed in preflight. This differs from blindly trusting timestamps on a partial restartable file. It preserves extra destination files and reports their number. A sample pass checks all expected paths/sizes and only the declared hash sample, plus existing files. Each file row contains one file, so it is always hashed. A different destination filename changes only the new copy’s name. The original remains in place. Identical existing files are retained; conflicting files stop the batch.

Do not add `/MIR`, `/PURGE`, `/MOVE`, `/MOV` or a source cleanup step. Do not use rsync `--delete` or `--remove-source-files`. Logs must not be inside the source, destination or opaque vault.

## Special rows

| Item | Procedure | Gate |
|---|---|---|
| Long paths | Use extended paths for Windows metadata/hash checks; keep robocopy long-path support enabled | Test a fixture over 260 characters |
| Junctions/symlinks | Record target; map copies explicitly; do not traverse originals through links | All links resolve within approved destinations |
| ACL-denied files | Record denial; owner may use reviewed backup-mode copy to a new destination | Never take ownership or change source ACLs |
| Cloud placeholders | Ask owner to recover into a new target through the correct cloud account | Never hydrate onto a frozen original |
| Secret names and vaults | Owner handles copy/encryption/import in a separate terminal | Record confirmation without reading contents |
| Archives | Copy ordinary data; compare entry counts; run integrity test and restore sample | Non-ASCII names survive; no hidden exclusions |
| Browser/app profiles | Stop app; preserve databases and profile mapping; owner handles auth | Open copied profile without unintended sync |
| VM/database state | Stop writers; keep a pristine verified image and a separate live copy | Version and data checks before network exposure |

The bundled generic copier rejects special rows before destination writes. Splitting a row means creating explicit, non-overlapping ordinary-data rows and separate special-item dispositions. Do not simply remove the safety check or silently exclude a subtree.

## Repositories

Copy full trees including hidden files, `.git`, dirty tracked work, untracked files, stashes, local refs and nested repos. Cache names can contain tracked files; check before excluding them. Record source refs/status with optional locks and fsmonitor disabled.

Repair only copied worktree pointers. Build a literal old-to-new map for worktree `.git` and admin `gitdir` files, including historically stale prefixes. Verify common-dir, every worktree path, refs, stashes, dirty status and full `fsck` on destination repositories. Never run repair while a copied pointer can reach an original. Treat non-ASCII and relative pointers as explicit test cases. The bundled copier does not relink Git for you.

If source Git integrity fails, keep the raw copy. Clone the approved remote into a different destination only after approval of outgoing identity. Compare every available ref and restore local-only work separately. A remote clone cannot prove recovery of missing unpushed objects.

## Stateful services

Preserve both old and current VM generations until their data is reconciled. Do not replace the only verified image with an activated copy. Disable restart policies on the copy before starting services; ask about webhooks, schedules and tunnels. Pin the app version and database major version evidenced by the copied data, because latest tags may perform irreversible migrations.

For database exports, write inside the container and copy the result out; PowerShell redirection can change encoding. Use a minimal reviewed DB-only configuration if unrelated required compose variables block parsing. Never print a resolved compose config containing secrets. Owner-run secret-bearing exports remain opaque.

Do not prune volumes, reset Docker, unregister a distribution or reinstall over preserved state. These are separate owner decisions outside this kit.

## Overnight and cloud batches

Use a durable background job with logs, PID and stop conditions. Keep one writer per target. Check descendants after timeout before restarting. Avoid sleep loops in an agent tool call; use the host's job monitor.

For an approved upload, name account and scope, check quota and privacy exclusions, then use copy semantics. Verify exclusion behavior on a local stand-in before sending. Retain originals and remote extras. Distinguish transport checksums from a later size-only check. Diagnose 0 B/s with bounded logs: source read, network, service quota and client identity are separate causes. Do not run a verification pass while the network is unavailable and call it a data mismatch.

After owner-approved switchover, write `.tidymove-active` at each target boundary and update STATE. To roll back, stop consumers and redirect them to a retained verified copy; never write back into a frozen original.
