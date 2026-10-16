#requires -Version 5.1
<# Metadata-only inventory. No source writes. -Library exposes shared safe path helpers.
   Folder counts/bytes are DIRECT children; sum folder rows for totals without double counting.
   Secret names, links and cloud placeholders are recorded, never opened or traversed.
   Exit 0: scan completed (review exclusions); 1: fatal; 2: enumeration errors.
#>
[CmdletBinding()]
param([string]$Root, [string]$OutputCsv, [switch]$Library, [switch]$AllowLiveScan)

function Get-TidymovePath([string]$Path) {
    if ([string]::IsNullOrWhiteSpace($Path) -or $Path -notmatch '^[A-Za-z]:\\') { throw 'Use an absolute local drive path.' }
    $p = [IO.Path]::GetFullPath($Path)
    if ($p -notmatch '^[A-Za-z]:\\' -or $p.Substring(2).Contains(':')) { throw 'Only local drive paths without alternate streams are supported.' }
    if ($p -match '[*?<>|\x00-\x1f"]' -or $p -match '(^|\\)[^\\]*[ .](\\|$)' -or $p -match '(?i)(^|\\)(CON|PRN|AUX|NUL|COM[1-9]|LPT[1-9])($|[.\\])') { throw 'Ambiguous or reserved Windows path.' }
    return $p.TrimEnd('\') + $(if ($p.Length -eq 3) { '\' } else { '' })
}
function Test-TidymoveWithin([string]$Path, [string]$Parent) {
    return $Path.Equals($Parent,[StringComparison]::OrdinalIgnoreCase) -or $Path.StartsWith($Parent.TrimEnd('\')+'\',[StringComparison]::OrdinalIgnoreCase)
}
function Get-TidymoveExtended([string]$Path) { return '\\?\' + $Path }
function Test-TidymoveSecret([string]$Name) {
    # Names are a conservative triage aid, not a complete secret detector.
    return $Name -match '(?i)(^\.env($|\.)|\.env$|^\.(secrets?|ssh|gnupg|aws|azure)($|\.)|vault|credentials?|creds([._-]|$)|(^|[._-])tokens?([._@-]|$)|client_secret|recovery.codes?|private.keys?|^id_(rsa|dsa|ecdsa|ed25519)|\.(pem|key|pfx|p12)($|\.)|^auth\.json($|\.)|^hosts\.yml($|\.)|^rclone\.conf($|\.)|^\.netrc$|^\.git-credentials$|^\.clasprc\.json$|(^|[._-])secrets?([._-]|$)|^\.(npmrc|pypirc|gitcookies)($|\.)|^\.(docker|kube)($|\.)|^gcloud$|^(Cookies|Login Data|Web Data)($|[.-])|\.(kdbx|keychain|keychain-db)($|\.))'
}
function Assert-TidymoveAncestors([string]$Path) {
    $cursor = $Path
    while ($cursor) {
        $xp = Get-TidymoveExtended $cursor
        if ([IO.Directory]::Exists($xp) -or [IO.File]::Exists($xp)) {
            $attr = [IO.File]::GetAttributes($xp)
            if (($attr -band [IO.FileAttributes]::ReparsePoint) -ne 0) { throw "Link/reparse ancestor is not supported: $cursor" }
            if (([int]$attr -band 0x441000) -ne 0) { throw 'Cloud/offline ancestor is not supported.' }
        }
        if (Test-TidymoveSecret ([IO.Path]::GetFileName($cursor))) { throw 'An opaque secret location is outside this scanner/copy tool.' }
        $parent = [IO.Path]::GetDirectoryName($cursor)
        if ($parent -eq $cursor) { break }
        $cursor = $parent
    }
}
function Get-TidymoveHash([string]$Path) {
    $stream = [IO.File]::Open((Get-TidymoveExtended $Path),[IO.FileMode]::Open,[IO.FileAccess]::Read,[IO.FileShare]::Read)
    $sha = [Security.Cryptography.SHA256]::Create()
    try { return ([BitConverter]::ToString($sha.ComputeHash($stream))).Replace('-','') }
    finally { $sha.Dispose(); $stream.Dispose() }
}
function Get-TidymoveTree([string]$Path) {
    Assert-TidymoveAncestors $Path
    $files = New-Object 'System.Collections.Generic.List[object]'
    $dirs = New-Object 'System.Collections.Generic.List[string]'
    $issues = New-Object 'System.Collections.Generic.List[object]'
    $pending = New-Object 'System.Collections.Generic.Stack[string]'
    $seen = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
    if ([IO.File]::Exists((Get-TidymoveExtended $Path))) { $pending.Push($Path) }
    elseif ([IO.Directory]::Exists((Get-TidymoveExtended $Path))) { $pending.Push($Path) }
    else { throw "Source does not exist: $Path" }
    while ($pending.Count -gt 0) {
        $current = $pending.Pop()
        try {
            if (-not $seen.Add($current)) { throw 'Case-colliding source paths need a separate reviewed copy method.' }
            $attr = [IO.File]::GetAttributes((Get-TidymoveExtended $current))
            $name = [IO.Path]::GetFileName($current)
            $kind = ''
            if (Test-TidymoveSecret $name) { $kind = 'secret-name' }
            elseif (([int]$attr -band 0x441000) -ne 0) { $kind = 'cloud-placeholder' }
            elseif (($attr -band [IO.FileAttributes]::ReparsePoint) -ne 0) { $kind = 'link-or-cloud' }
            if ($kind) { $issues.Add([pscustomobject]@{path=$current;kind=$kind;detail='Not opened or traversed'}); continue }
            if (($attr -band [IO.FileAttributes]::Directory) -ne 0) {
                $dirs.Add($current)
                # Enumerate eagerly so access errors cannot disappear during iteration.
                $children = [IO.Directory]::GetFileSystemEntries((Get-TidymoveExtended $current))
                foreach ($child in $children) { $pending.Push($child.Substring(4)) }
            } else {
                $fi = New-Object IO.FileInfo((Get-TidymoveExtended $current))
                $files.Add([pscustomobject]@{path=$current;bytes=$fi.Length;modified=$fi.LastWriteTimeUtc;extension=$fi.Extension.ToLowerInvariant()})
            }
        } catch { $issues.Add([pscustomobject]@{path=$current;kind='error';detail=$_.Exception.GetType().Name}) }
    }
    return [pscustomobject]@{files=$files;directories=$dirs;issues=$issues}
}
function Assert-TidymoveOutput([string]$Path,[string]$Source) {
    Assert-TidymoveAncestors $Path
    if (Test-TidymoveWithin $Path $Source) { throw 'Output must be outside the source.' }
    if ([IO.File]::Exists((Get-TidymoveExtended $Path)) -or [IO.Directory]::Exists((Get-TidymoveExtended $Path))) { throw 'Use a new output path; existing evidence is retained.' }
    $parent = [IO.Path]::GetDirectoryName($Path)
    [void][IO.Directory]::CreateDirectory((Get-TidymoveExtended $parent))
}
if ($Library) { return }
try {
    $ErrorActionPreference = 'Stop'
    $Root = Get-TidymovePath $Root
    $OutputCsv = Get-TidymovePath $OutputCsv
    Assert-TidymoveAncestors $Root
    if (-not $AllowLiveScan) {
        & "$PSScriptRoot\verify-frozen.ps1" -Root $Root
        if ($LASTEXITCODE -ne 0) { throw 'Freeze the source first, or explicitly use -AllowLiveScan for metadata reconciliation of the current machine.' }
    }
    Assert-TidymoveOutput $OutputCsv $Root
    $tree = Get-TidymoveTree $Root
    $rows = New-Object 'System.Collections.Generic.List[object]'
    $groups = @{}
    foreach ($f in $tree.files) {
        $parent = [IO.Path]::GetDirectoryName($f.path)
        if (-not $groups.ContainsKey($parent)) { $groups[$parent] = New-Object 'System.Collections.Generic.List[object]' }
        $groups[$parent].Add($f)
    }
    foreach ($dir in $tree.directories) {
        $items = @(); if ($groups.ContainsKey($dir)) { $items = @($groups[$dir].ToArray()) }
        [long]$bytes = 0; foreach ($f in $items) { $bytes += $f.bytes }
        $dates = @($items | Sort-Object modified)
        $oldest=''; $newest=''
        if ($dates.Count) { $oldest=$dates[0].modified.ToString('o'); $newest=$dates[-1].modified.ToString('o') }
        $types = ($items | Group-Object extension | Sort-Object Name | ForEach-Object { '{0}:{1}' -f $_.Name,$_.Count }) -join ';'
        $repo=''; $dirty=''; $detail='Direct children only; excluded subtrees have separate rows'
        $gitPath = Join-Path $dir '.git'
        $gitSpecial = @($tree.issues | Where-Object { $_.path -eq $gitPath }).Count -gt 0
        if ([IO.File]::Exists((Get-TidymoveExtended ([IO.Path]::Combine($gitPath,'commondir'))))) { $gitSpecial=$true }
        if ($gitSpecial) { $repo='linked-or-unreadable'; $dirty='needs-checking'; $detail='Git marker excluded; no Git process invoked' }
        elseif ([IO.File]::Exists((Get-TidymoveExtended $gitPath))) { $repo='worktree'; $dirty='needs-checking'; $detail='Pointer not followed; inspect destination links separately' }
        elseif ([IO.Directory]::Exists((Get-TidymoveExtended $gitPath))) {
            $repo='repository'
            $dirty='needs-checking'
            $detail='Repository marker only; no Git process or content read. Review configuration and sensitive paths before a separate status check.'
        }
        $rows.Add([pscustomobject]@{kind='folder';path=$dir;bytes=$bytes;file_count=$items.Count;oldest_utc=$oldest;newest_utc=$newest;type_mix=$types;repo=$repo;dirty=$dirty;detail=$detail})
    }
    if ($tree.directories.Count -eq 0 -and $tree.files.Count -eq 1) {
        $f=$tree.files[0]; $rows.Add([pscustomobject]@{kind='file';path=$f.path;bytes=$f.bytes;file_count=1;oldest_utc=$f.modified.ToString('o');newest_utc=$f.modified.ToString('o');type_mix=$f.extension;repo='';dirty='';detail='Single-file scan'})
    }
    foreach ($issue in $tree.issues) { $rows.Add([pscustomobject]@{kind=$issue.kind;path=$issue.path;bytes='';file_count='';oldest_utc='';newest_utc='';type_mix='';repo='';dirty='';detail=$issue.detail}) }
    $rows | Export-Csv -LiteralPath $OutputCsv -NoTypeInformation -Encoding UTF8
    Write-Output ('Inventory: {0} files; {1} directories; {2} exclusions/errors. CSV: {3}' -f $tree.files.Count,$tree.directories.Count,$tree.issues.Count,$OutputCsv)
    if (@($tree.issues | Where-Object kind -eq 'error').Count) { exit 2 }
    exit 0
} catch { Write-Error $_; exit 1 }
