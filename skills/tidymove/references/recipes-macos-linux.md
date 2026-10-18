# macOS and Linux recipes — untested

Every recipe in this file and every `.sh` script is **untested** on macOS/Linux. The author's account concerns Windows; it is not target-platform validation. Validate the platform, filesystem, rsync version and failure cases on synthetic fixtures before using real data. Do not install dependencies without owner approval.

| Recipe — all untested | Candidate equivalent | Required validation |
|---|---|---|
| Device identity | Linux `lsblk -o NAME,SERIAL,UUID,SIZE,RO,MOUNTPOINTS`; macOS `diskutil list` and `diskutil info` | Match physical device with owner; never infer from enumeration order |
| Freeze | Linux owner-run read-only block/mount procedure; macOS owner-run unmount then `diskutil mount readOnly <DEVICE>` | Dry-run packet must show device; root/system disk refused; recheck mount flags |
| Protection check | `bash verify-frozen.sh <SOURCE-1>` | No test file; reject remote/ambiguous filesystems |
| Inventory | `bash inventory.sh <SOURCE-1> <RUN>/inventory.csv` | Complete metadata coverage; errors nonzero; provider-specific placeholders |
| Current-machine metadata | Add `--allow-live-scan` | Label live and not consistent; no copy permission implied |
| Dry copy | `bash copy-verify.sh <RUN>/manifest.csv <RUN>/dry-01` | Target remains absent; exit semantics checked |
| Copy | Same command plus `--execute` | Source mount proved read-only; all rows preflight; no overwrite/delete |
| Hash | Python SHA-256 streaming; alternatively Linux `sha256sum`, macOS `shasum -a 256` | Ordinary data only; nonempty output and native success |
| Links | `readlink`, `lstat` and an explicit destination map | Never follow a link into original or vault |
| Permissions | `stat`, platform ACL inspection and owner-approved destination ACLs | rsync basic file copy does not prove ACL/xattr/resource-fork preservation |
| Stateful apps | Stop services, export consistently, keep pristine copy | DB version, volume ownership and activation effects |
| Background run | Owner-approved service/job manager with logs and PID | Parent exit does not kill copy; one writer; bounded retries |
| Eject | Platform safe unmount/eject; full shutdown if busy and unresolved | No active readers; next boot works without originals |

The scripts need Bash, Python 3.9+ and rsync 3.x. An older bundled macOS rsync may lack required options. Stop rather than silently removing options. Use the owner's selected package manager if an upgrade is approved.

For folder rows, `copy-verify.sh` uses `--recursive --times --ignore-existing --partial --protect-args`. It checks every existing mapped file by SHA-256 before invoking rsync. It never uses `--delete` or `--remove-source-files`. Existing conflicts and incomplete files stop the run and remain intact; restart to a fresh target. Output directories must be new; the destination parent must exist for a dry run on rsync versions that require it. An execution creates missing destination parents only after preflight. Refusals write `preflight.csv` with `REFUSED` and a batch reason per parsed row when the output path is safe and fresh; otherwise retain the console refusal.

Source directories and their ancestors must be real directories, not symlinks. File rows use the exact destination filename, which may differ from the source name. They use exclusive file creation and SHA-256 verification; an existing identical destination is retained, and a conflicting one is refused. Preview name changes before execution. Special files, symlinks, opaque secret names and recognized cloud placeholders stop copying. The macOS placeholder heuristic is incomplete across providers; use a provider-specific inventory and owner recovery plan. Verify sparse files, extended attributes, resource forks, case collisions and Unicode normalization in separate fixtures before declaring application data supported.

Read-only mount flags are evidence of current access mode, not hardware health. The Linux helper rejects common remote/virtual filesystems and fails if findmnt cannot prove a single read-only mount. The macOS helper checks diskutil's read-only-volume result. Do not treat this as a universal filesystem certification.

The inventory does not invoke Git. It records repository markers and leaves dirty status for a separate approved content/configuration review. The filename detector intentionally does not exempt `.example` or `.sample` suffixes.

Name patterns also cover passwords, passwd, secrets, credentials, tokens, private keys, wallets and recovery codes. Filename filters cannot detect every secret. Inventory and copy inspect ancestor symlink metadata and names through the filesystem root, even in fixtures. Copy also probes ancestor activation markers. `--strict-subtree` refuses before inspecting supplied paths or writing output, because these checks cannot honor that boundary. No ancestor file contents are read.

Use `--verify sample --sample-size <COUNT>` only when the owner accepts that unsampled bytes remain unchecked. Default is all-file hashing. Put `.tidymove-active` in the activated folder target or beside a file target. Never use `--fixture-root` for real data; it exists only to let synthetic tests operate on writable storage.

For an owner-run Linux freeze, inspect filesystem-specific read-only and journal-replay behavior first. A generic `mount -o ro` can be insufficient for forensic preservation on some filesystems. Prepare the exact dry run, rollback and recovery plan from current platform documentation; this kit does not prescribe an untested mutation command as safe for every disk.
