# Windows recipes

Evidence status: these are generalized recipes derived from the author's account, not independently verified instructions for every machine. The bundled smoke test exercises ordinary file handling on Windows PowerShell 5.1; it does not test disk mutation, cloud, Docker, elevation or an actual backup restore. Review current platform documentation and the actual device before system changes.

Set `$source`, `$target`, `$run` and `$kit` to owner-approved absolute paths. Keep scripts and logs outside originals. Use Windows paths for Windows programs. Preserve line endings when editing existing files. Never put credential values in variables shown to an agent, command arguments or transcripts.

## Inventory and identity

```powershell
Get-Disk | Select-Object Number,SerialNumber,UniqueId,Size,BusType,IsBoot,IsSystem,IsReadOnly,IsOffline
Get-Volume | Select-Object DriveLetter,FileSystemLabel,FileSystem,Size,SizeRemaining,HealthStatus
Get-Partition | Select-Object DiskNumber,PartitionNumber,DriveLetter,Size
& "$kit\skills\tidymove\scripts\verify-frozen.ps1" -Root $source
```

Record the private device identity and have the owner confirm it. Numbers and mount letters are temporary selectors. Do not infer ownership from a username or folder name.

## Owner-run freeze script pattern

Prepare this as a separate reviewed script. Run once without `-Execute`, then ask the owner to run the same script elevated with `-Execute`. Match the privately recorded serial; never paste a guessed serial. This changes disk flags, so it requires the owner's yes.

```powershell
[CmdletBinding()]
param([Parameter(Mandatory=$true)][string]$DiskIdentity,[switch]$Execute)
$ErrorActionPreference = 'Stop'
function Find-SourceDisk {
    if ([string]::IsNullOrWhiteSpace($DiskIdentity)) { throw 'A nonblank confirmed disk identity is required' }
    $sourceMatches = @(Get-Disk | Where-Object {
        $null -ne $_.SerialNumber -and $_.SerialNumber.Trim() -eq $DiskIdentity.Trim()
    })
    if ($sourceMatches.Count -ne 1) { throw 'Expected exactly one identified source disk' }
    if ($sourceMatches[0].IsBoot -or $sourceMatches[0].IsSystem) { throw 'Refuse a system or boot disk' }
    return $sourceMatches[0]
}
$selected = Find-SourceDisk
$selected | Select-Object Number,SerialNumber,Size,IsReadOnly,IsOffline
if (-not $Execute) { 'DRY RUN: offline -> read-only -> assert -> online'; return }
$selected = Find-SourceDisk
Set-Disk -Number $selected.Number -IsOffline $true
$selected = Find-SourceDisk
Set-Disk -Number $selected.Number -IsReadOnly $true
$selected = Find-SourceDisk
if (-not $selected.IsReadOnly) { throw 'Protection failed; leave source offline' }
Set-Disk -Number $selected.Number -IsOffline $false
Find-SourceDisk | Select-Object Number,IsReadOnly,IsOffline
```

If it fails after offline, leave the disk offline. Do not use a `finally` block to bring it back online. Run `verify-frozen.ps1` against the mounted source after success. Record current and persisted protection separately. Do not infer persisted protection from undocumented registry values or assume every enclosure retains the setting. Recheck after an owner-controlled reconnect when appropriate.

For elevation, let the owner open an elevated PowerShell and run the reviewed file. Avoid string-built nested commands and arbitrary execution-policy changes. Do not include partitioning in this script. Partition design needs its own backup, measured supported size and owner-approved procedure; no generic partition rollback is promised.

## Events, power and maintenance

```powershell
$since = Get-Date '<LOCAL-CHECK-START>'
Get-WinEvent -FilterHashtable @{LogName='System'; Id=11,50,51,140,153; StartTime=$since} -ErrorAction Stop |
    Select-Object TimeCreated,ProviderName,Id,Message
Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-Partition/Diagnostic'; Id=1006; StartTime=$since} -ErrorAction Stop
powercfg /query
Get-ScheduledTask -TaskPath '\Microsoft\Windows\Defrag\' | Select-Object TaskName,State
```

Some logs require elevation; a denied query is not zero errors. Match provider and device identity and correlate sleep/wake, power loss and owner unplugs. Departure counts alone missed a continuous retry storm. Repeated scans can stress a source; reuse captured evidence if errors appear.

The historical preparation used `powercfg`, `chkntfs /x`, scheduled-task controls and `fsutil behavior set disablelastaccess 1`. These are system changes, not automatic prerequisites for every machine. Record original values first, propose only necessary changes, and restore recorded values at closeout. Cover battery as well as AC if the plan temporarily prevents sleep. Do not disable protection or updates indefinitely. Never run `chkdsk` or a "scan and fix" action on originals.

## Copy and verify

```powershell
& "$kit\skills\tidymove\scripts\copy-verify.ps1" -Manifest "$run\manifest.csv" -OutputDir "$run\dry-01"
& "$kit\skills\tidymove\scripts\copy-verify.ps1" -Manifest "$run\manifest.csv" -OutputDir "$run\copy-01" -Execute
```

Historical ordinary-copy flags were `/E /COPY:DAT /DCOPY:DAT /XJ /R:5 /W:15`. Large stopped VM images used restartable `/Z`; one recipe also used `/J`. Keep HDD reads serial; test limited parallelism on an SSD before changing concurrency. The kit uses shorter bounded retries and rejects conflicts instead of overwriting them.

Robocopy 0-7 are nonfatal transport results; 8 or higher fails. Independently check missing sources before invoking it. A file filter matching nothing can return success. A list-only verification must reject listing failures as well as remaining files. Never use `/MIR`, `/PURGE`, `/MOVE` or `/MOV`.

For ordinary short-path files, this historical SHA-256 pattern ran successfully:

```powershell
$sourceHash = (Get-FileHash -LiteralPath $source -Algorithm SHA256 -ErrorAction Stop).Hash
$targetHash = (Get-FileHash -LiteralPath $target -Algorithm SHA256 -ErrorAction Stop).Hash
if (-not $sourceHash -or -not $targetHash -or $sourceHash -ne $targetHash) { throw 'Hash mismatch' }
```

Do not use it on secret files. For long paths the bundled helper opens a stream through the extended `\\?\` prefix; the smoke test covers a path over 260 characters. Never add robocopy `/256`. A failed ordinary `Test-Path` can be a path-limit failure, not a missing file.

## ACLs, links and archives

`/COPY:DAT` copies data, attributes and timestamps; it does not migrate security descriptors. Inspect destination ACLs with `Get-Acl -LiteralPath`. Use reviewed SID-based rules for the current owner, administrators and system. Disabling inheritance alone leaves explicit broad entries. Make ACL changes only on approved destinations.

Backup-mode `robocopy /B` recovered source files denied by old-account ACLs. The owner runs that privileged operation against a bounded file list, into a new destination; agents do not inspect secret bytes. Never take ownership on the original.

Robocopy `/SJ /SL` preserved link objects in isolated harness fixtures in the run. It does not remap their targets. The generic copier rejects all reparse points. For a special link plan, inventory each link, record old/new target, copy data first, then create a new link only at an unused path:

```powershell
# Owner-approved new destination adapter only; $link must not exist.
New-Item -ItemType Junction -Path $link -Target $target
Get-Item -LiteralPath $link -Force | Select-Object FullName,LinkType,Target
```

Do not recursively delete an old profile containing a junction to active history. This kit leaves originals in place and changes consumer configuration or creates new adapter paths; it does not rename sources to make room for links.

7-Zip replaced a Windows tar path that crashed on non-ANSI names. For ordinary approved data, `7z a -tzip -mx=0 -mcu=on -bd <archive> <source>` and `7z t <archive>` were used. Compare entry count with selected source files, and extract a sample into a fresh directory. For secrets, only the owner may create a header-encrypted archive with an interactive password; never put the password on the command line. A deliberately wrong password proves neither the saved password nor a successful restore.

## Git and stateful apps

```powershell
git --no-optional-locks -c core.fsmonitor=false -C $repo status --porcelain=v1
git --no-optional-locks -c core.fsmonitor=false -C $repo for-each-ref
git --no-optional-locks -c core.fsmonitor=false -C $repo rev-parse --path-format=absolute --git-common-dir
git --no-optional-locks -c core.fsmonitor=false -C $repo worktree list --porcelain
git --no-optional-locks -c core.fsmonitor=false -C $repo fsck --full
```

These Git commands are a separate content review, not metadata-only inventory. First review repository-controlled configuration, includes, filters, and helpers without exposing credentials; an owner-reviewed safe export may be needed. Disabling fsmonitor alone is not a sandbox. Do not run Git against an unreviewed old repository simply because its drive is read-only.

Record each native exit immediately. Do not decide integrity from stderr wording; an empty repo can emit warnings without corruption. Preserve dirty/untracked work and full trees, because bundles omit it. Relink copied worktrees only after proving no pointer reaches originals.

For Docker, inventory images, volumes, stopped containers and bind mounts without dumping environments or auth files. Stop services before image copy. Keep the pristine rescue image separate from the live image. Pin versions and disable automatic external effects before activation. The tested export pattern was `pg_dump -f <container-file>` inside the DB container followed by `docker compose cp` to a fresh approved destination, because PowerShell `>` could produce UTF-16. Secret-bearing dumps are owner-only.

WSL `--import-in-place <NAME> <COPIED-IMAGE>` was used after hashing a copied image; registration and start require approval. Check the intended default user and data. Never use unregister as cleanup: it can remove the registered disk.

## Jobs, cloud and PowerShell 5.1

Start approved long scripts using `Start-Process powershell -WindowStyle Hidden -PassThru` with a correctly quoted script path and explicit log output. Record the PID and child processes. Use the host job monitor; do not block the agent in sleep loops. Allow one writer per target. Keep owner-visible interactive windows only for actions requiring their input.

The evidence upload used rclone `copy`, followed by `check --one-way --size-only`. A private-file exclusion test ran first on a local stand-in. Name the approved outgoing identity before upload. Use a bounded timeout and bandwidth budget. Shared-client quota throttling and a later network outage were distinct failures. Provider-specific OAuth instructions must come from current official docs; never substitute another organization's branding/domain to satisfy consent requirements. Run auth in the owner's separate terminal, not an agent command-capture shortcut.

| PowerShell 5.1 constraint | Safe pattern |
|---|---|
| No `&&`, ternary or `??` | Use explicit `if` blocks |
| Case-insensitive variable names; automatic `$args` | Use descriptive, distinct names |
| `R` aliases history execution | Use unique function names |
| Native stderr under `Stop` | Scope error preference carefully; capture native exit immediately |
| Inner native quotes stripped | Pass simple argument arrays; parse JSON with `ConvertFrom-Json`; use script files |
| `-Include` with `-LiteralPath` failed to filter | Filter names explicitly before reading contents |
| UTF-8 without BOM can parse as ANSI | Keep script source ASCII or use a BOM; read/write CSV explicitly as UTF-8 |
| `-File` plus integer-array comma arguments | Accept a string and validate/split it explicitly |
| `continue` inside `switch` | Label the intended outer loop |
| Parser refs must exist | Initialize token/error variables before `ParseFile` |
| `NUL` is not a normal redirected stdin file | Use a fresh empty fixture file |
| A new install does not refresh parent PATH | Validate in a new shell with the intended executable path |
| `[int]`/number conversion loses large browser timestamps | Use exact 64-bit integer parsing; only inspect owner-approved non-secret copies |

```powershell
$parseTokens=$null; $parseErrors=$null
[void][Management.Automation.Language.Parser]::ParseFile($scriptPath,[ref]$parseTokens,[ref]$parseErrors)
if ($parseErrors.Count -gt 0) { throw ($parseErrors | Out-String) }
```

Official references: [robocopy options and exit codes](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/robocopy), [Set-Disk](https://learn.microsoft.com/en-us/powershell/module/storage/set-disk), and [Git status](https://git-scm.com/docs/git-status).

Keep parser checks separate from runtime tests. A printed zero after a failed parser call proves nothing.
