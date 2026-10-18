#requires -Version 5.1
<# CSV: source,target,mode (folder or file). File target is the exact filename.
   Dry run is the default. -Execute writes only missing destination files.
   Existing conflicts, links, placeholders and secret names STOP before copying.
   All destinations must be inactive. After switchover put .tidymove-active in each
   folder target (or beside a file target). Reruns then refuse that location.
   Exit 0: dry plan or verification passed; 1: failed. No deletes or source writes.
   -FixtureRoot is ONLY for synthetic tests with a .tidymove-fixture marker.
#>
[CmdletBinding(DefaultParameterSetName='Dry')]
param(
    [Parameter(Mandatory=$true)][string]$Manifest,
    [Parameter(Mandatory=$true)][string]$OutputDir,
    [Parameter(ParameterSetName='Dry')][switch]$DryRun,
    [Parameter(ParameterSetName='Execute')][switch]$Execute,
    [ValidateSet('All','Sample')][string]$Verify='All',
    [ValidateRange(1,1000000)][int]$SampleSize=20,
    [string]$FixtureRoot,
    [switch]$StrictSubtree
)
if ($StrictSubtree) {
    Write-Output 'STRICT SUBTREE REFUSED: Safety checks require ancestor metadata through the drive root. No manifest, marker or output writes performed.'
    exit 1
}
$ErrorActionPreference='Stop'
. "$PSScriptRoot\inventory.ps1" -Library
$results=New-Object 'System.Collections.Generic.List[object]'
$lock=$null
$records=New-Object 'System.Collections.Generic.List[object]'
$recordsComplete=$false
$outputReady=$false
function Initialize-PreflightOutput {
    # A refusal report must never write into data, a link, or prior evidence.
    Assert-TidymoveAncestors $OutputDir
    foreach ($p in @($Manifest,$lockPath)) {
        if ((Test-TidymoveWithin $OutputDir $p) -or (Test-TidymoveWithin $p $OutputDir)) { throw 'Logs, manifest and lock must be disjoint.' }
    }
    foreach ($record in @($records.ToArray() | Select-Object -Skip 1)) {
        if ($record.Count -lt 2) { throw 'Cannot establish safe report placement from incomplete path fields.' }
        foreach ($value in @($record[0],$record[1])) {
            $p=Get-TidymovePath $value
            Assert-TidymoveAncestors $p
            if ((Test-TidymoveWithin $OutputDir $p) -or (Test-TidymoveWithin $p $OutputDir)) { throw 'Logs and data paths must be disjoint.' }
        }
    }
    if ([IO.Directory]::Exists((Get-TidymoveExtended $OutputDir)) -or [IO.File]::Exists((Get-TidymoveExtended $OutputDir))) { throw 'OutputDir must be new, to retain prior evidence.' }
    [void][IO.Directory]::CreateDirectory((Get-TidymoveExtended $OutputDir))
    $script:outputReady=$true
}
function Write-PreflightRefusal([string]$Reason) {
    $refused=New-Object 'System.Collections.Generic.List[object]'
    $row=0
    foreach ($record in @($records.ToArray() | Select-Object -Skip 1)) {
        $row++
        $mode=''; if ($record.Count -gt 2) { $mode=$record[2] }
        $refused.Add([pscustomobject]@{row=$row;source=$record[0];target=$record[1];mode=$mode;stage='preflight';status='REFUSED';reason=('Batch refused before any copy: '+$Reason);exit_code=1})
    }
    if ($row -eq 0) { $refused.Add([pscustomobject]@{row=0;source='';target='';mode='';stage='preflight';status='REFUSED';reason=$Reason;exit_code=1}) }
    $refused | Export-Csv -LiteralPath ([IO.Path]::Combine($OutputDir,'preflight.csv')) -NoTypeInformation -Encoding UTF8
    Write-Output ('Preflight CSV: '+[IO.Path]::Combine($OutputDir,'preflight.csv'))
}
function Assert-CopyFrozen([string]$Source,[string]$Target) {
    if ($FixtureRoot) {
        if (-not (Test-TidymoveWithin $Source $FixtureRoot) -or -not (Test-TidymoveWithin $Target $FixtureRoot) -or $Source -eq $FixtureRoot -or $Target -eq $FixtureRoot) { throw 'Fixture paths must be descendants of FixtureRoot.' }
        return
    }
    & "$PSScriptRoot\verify-frozen.ps1" -Root $Source | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'Source freeze not proved. Stop; do not bypass this check for real data.' }
}
function Assert-Inactive([string]$Target,[string]$Mode) {
    $cursor=$Target
    if ($Mode -eq 'file') { $cursor=[IO.Path]::GetDirectoryName($Target) }
    while ($cursor) {
        if ([IO.File]::Exists((Get-TidymoveExtended ([IO.Path]::Combine($cursor,'.tidymove-active'))))) { throw 'Destination is activated; use a new target for a separate reconciliation.' }
        $cursor=[IO.Path]::GetDirectoryName($cursor)
    }
}
function Get-TargetFile($Job,$File) {
    if ($Job.mode -eq 'file') { return $Job.target }
    return [IO.Path]::Combine($Job.target,$File.path.Substring($Job.source.TrimEnd('\').Length+1))
}
try {
    $Manifest=Get-TidymovePath $Manifest; $OutputDir=Get-TidymovePath $OutputDir
    Assert-TidymoveAncestors $Manifest; Assert-TidymoveAncestors $OutputDir
    $lockPath=$Manifest+'.tidymove-lock'
    Assert-TidymoveAncestors $lockPath
    # Import-Csv silently discards surplus fields, so validate row width first.
    Add-Type -AssemblyName Microsoft.VisualBasic
    $parser=New-Object Microsoft.VisualBasic.FileIO.TextFieldParser($Manifest,[Text.Encoding]::UTF8,$true)
    try {
        $parser.TextFieldType=[Microsoft.VisualBasic.FileIO.FieldType]::Delimited
        $parser.SetDelimiters(','); $parser.HasFieldsEnclosedInQuotes=$true
        while (-not $parser.EndOfData) {
            $fields=$parser.ReadFields()
            $records.Add($fields)
        }
        $recordsComplete=$true
    } finally { $parser.Close() }
    Initialize-PreflightOutput
    foreach ($record in $records) {
        if ($record.Count -ne 3) { throw 'Every manifest record must have exactly three CSV fields.' }
    }
    if ($FixtureRoot) {
        $FixtureRoot=Get-TidymovePath $FixtureRoot
        Assert-TidymoveAncestors $FixtureRoot
        $marker=[IO.Path]::Combine($FixtureRoot,'.tidymove-fixture')
        Assert-TidymoveAncestors $marker
        if (-not [IO.File]::Exists($marker) -or [IO.File]::ReadAllText($marker).Trim() -ne 'Synthetic tidymove test data only') { throw 'Fixture marker missing or invalid.' }
    }
    $csv=@(Import-Csv -LiteralPath $Manifest -Encoding UTF8)
    if ($csv.Count -eq 0) { throw 'Manifest is empty.' }
    if (($csv[0].PSObject.Properties.Name -join ',') -ne 'source,target,mode') { throw 'Manifest header must be exactly source,target,mode.' }
    $jobs=New-Object 'System.Collections.Generic.List[object]'
    foreach ($row in $csv) {
        if ($row.mode -notin @('folder','file')) { throw 'mode must be folder or file.' }
        $src=Get-TidymovePath $row.source; $dst=Get-TidymovePath $row.target
        Assert-TidymoveAncestors $src; Assert-TidymoveAncestors $dst
        if ((Test-TidymoveWithin $Manifest $src) -or (Test-TidymoveWithin $Manifest $dst) -or (Test-TidymoveWithin $lockPath $src) -or (Test-TidymoveWithin $lockPath $dst)) { throw 'Manifest and lock must be outside every source and target.' }
        foreach ($p in @($src,$dst)) {
            if ((Test-TidymoveWithin $OutputDir $p) -or (Test-TidymoveWithin $p $OutputDir)) { throw 'Logs and data paths must be disjoint.' }
        }
        if ((Test-TidymoveWithin $src $dst) -or (Test-TidymoveWithin $dst $src)) { throw 'Source and target overlap.' }
        if ($src.Length -eq 3 -or $dst.Length -eq 3) { throw 'Use bounded subfolders or files, not a whole drive root.' }
        if ($row.mode -eq 'folder' -and -not [IO.Directory]::Exists((Get-TidymoveExtended $src))) { throw 'Folder source absent or wrong mode.' }
        if ($row.mode -eq 'file' -and -not [IO.File]::Exists((Get-TidymoveExtended $src))) { throw 'File source absent or wrong mode.' }
        if (($row.mode -eq 'folder' -and [IO.File]::Exists((Get-TidymoveExtended $dst))) -or ($row.mode -eq 'file' -and [IO.Directory]::Exists((Get-TidymoveExtended $dst)))) { throw 'Target type conflicts with mode.' }
        $jobs.Add([pscustomobject]@{source=$src;target=$dst;mode=$row.mode;tree=$null;hashes=@{}})
    }
    for ($i=0;$i -lt $jobs.Count;$i++) {
        for ($j=0;$j -lt $jobs.Count;$j++) {
            if ((Test-TidymoveWithin $jobs[$i].target $jobs[$j].source) -or (Test-TidymoveWithin $jobs[$j].source $jobs[$i].target)) { throw 'A target overlaps a source in the manifest.' }
            if ($i -ne $j -and ((Test-TidymoveWithin $jobs[$i].target $jobs[$j].target) -or (Test-TidymoveWithin $jobs[$j].target $jobs[$i].target))) { throw 'Target rows overlap; consolidate or separate them.' }
        }
    }
    if (-not (Get-Command robocopy.exe -ErrorAction SilentlyContinue)) { throw 'robocopy is required.' }
    # Serialize this manifest BEFORE preflight. Other manifests still require an owner-enforced single writer.
    $lock=[IO.File]::Open($lockPath,[IO.FileMode]::OpenOrCreate,[IO.FileAccess]::ReadWrite,[IO.FileShare]::None)
    # Validate EVERY row before creating any destination. Never swallow denied reads.
    foreach ($job in $jobs) {
        Assert-CopyFrozen $job.source $job.target; Assert-Inactive $job.target $job.mode
        $job.tree=Get-TidymoveTree $job.source
        if ($job.tree.issues.Count) { throw ('Source has excluded/unreadable entries; split into approved ordinary-data rows. First: '+$job.tree.issues[0].path+' ('+$job.tree.issues[0].kind+')') }
        if ([IO.Directory]::Exists((Get-TidymoveExtended $job.target)) -or [IO.File]::Exists((Get-TidymoveExtended $job.target))) {
            $targetTree=Get-TidymoveTree $job.target
            if ($targetTree.issues.Count) { throw 'Destination contains an opaque, linked or unreadable entry.' }
            if (@($targetTree.files | Where-Object { [IO.Path]::GetFileName($_.path) -eq '.tidymove-active' }).Count) { throw 'Destination contains an activated subtree; use a new target.' }
        }
        $sorted=@($job.tree.files | Sort-Object path)
        $chosen=@($sorted); if ($Verify -eq 'Sample') { $chosen=@($sorted | Select-Object -First $SampleSize) }
        foreach ($f in $chosen) { $job.hashes[$f.path]=Get-TidymoveHash $f.path }
        foreach ($f in $sorted) {
            $destFile=Get-TargetFile $job $f
            Assert-TidymoveAncestors $destFile
            if ([IO.Directory]::Exists((Get-TidymoveExtended $destFile))) { throw 'A directory blocks an expected file.' }
            if ([IO.File]::Exists((Get-TidymoveExtended $destFile))) {
                if (-not $job.hashes.ContainsKey($f.path)) { $job.hashes[$f.path]=Get-TidymoveHash $f.path }
                if ((Get-TidymoveHash $destFile) -ne $job.hashes[$f.path]) { throw "Destination conflict; retained without overwrite: $destFile" }
            }
        }
    }
    # Lock file is retained; the OS releases its handle on exit.
    $index=0
    foreach ($job in $jobs) {
        $index++
        $log=[IO.Path]::Combine($OutputDir,('{0:000}.log' -f $index))
        $status='FAILED'; $message=''; $checked=0; $extra=0; $copyExit=''; $bytes=0
        try {
            Assert-CopyFrozen $job.source $job.target; Assert-Inactive $job.target $job.mode
            foreach ($f in $job.tree.files) { $bytes += $f.bytes }
            if ($job.mode -eq 'file') {
                @('Single file copy; overwrite disabled',('Source: '+$job.source),('Target: '+$job.target),('SHA-256: '+$job.hashes[$job.source]),('Execute: '+[bool]$Execute)) | Set-Content -LiteralPath $log -Encoding UTF8
                Assert-TidymoveAncestors $job.source; Assert-TidymoveAncestors $job.target
                if ($Execute) {
                    if ([IO.File]::Exists((Get-TidymoveExtended $job.target))) {
                        if ((Get-TidymoveHash $job.target) -ne $job.hashes[$job.source]) { throw 'Destination changed after preflight; retained without overwrite.' }
                        Add-Content -LiteralPath $log -Value 'Identical destination retained.'
                    } else {
                        [void][IO.Directory]::CreateDirectory((Get-TidymoveExtended ([IO.Path]::GetDirectoryName($job.target))))
                        # File.Copy(false) fails if any file appeared after preflight.
                        [IO.File]::Copy((Get-TidymoveExtended $job.source),(Get-TidymoveExtended $job.target),$false)
                        Add-Content -LiteralPath $log -Value 'Copied to explicit destination filename.'
                    }
                } else { Add-Content -LiteralPath $log -Value 'Preview only; no destination writes.' }
                $copyExit=0
            } else {
                $copyArgs=@($job.source,$job.target,'/E','/COPY:DAT','/DCOPY:DAT','/XJ','/R:2','/W:2','/Z','/XC','/XN','/XO','/NP',('/UNILOG:'+$log))
                if (-not $Execute) { $copyArgs += '/L' }
                $oldPreference=$ErrorActionPreference; $ErrorActionPreference='Continue'
                & robocopy.exe @copyArgs | Out-Null
                $copyExit=$LASTEXITCODE; $ErrorActionPreference=$oldPreference
                if ($copyExit -ge 8) { throw "robocopy exit $copyExit; inspect row log." }
            }
            if (-not $Execute) { $status='DRY-RUN'; $message='No destination writes; not verified' }
            else {
                $after=Get-TidymoveTree $job.source
                if ($after.issues.Count -or $after.files.Count -ne $job.tree.files.Count -or $after.directories.Count -ne $job.tree.directories.Count) { throw 'Source enumeration changed during copy.' }
                $beforeMap=@{}; foreach ($f in $job.tree.files) { $beforeMap[$f.path]=$f }
                foreach ($f in $after.files) {
                    if (-not $beforeMap.ContainsKey($f.path) -or $beforeMap[$f.path].bytes -ne $f.bytes -or $beforeMap[$f.path].modified -ne $f.modified) { throw 'Source metadata changed during copy.' }
                }
                foreach ($f in $job.tree.files) {
                    $destFile=Get-TargetFile $job $f
                    Assert-TidymoveAncestors $destFile
                    if (-not [IO.File]::Exists((Get-TidymoveExtended $destFile))) { throw "Missing destination file: $destFile" }
                    $df=New-Object IO.FileInfo((Get-TidymoveExtended $destFile))
                    if ($df.Length -ne $f.bytes) { throw "Size mismatch: $destFile" }
                    if ($job.hashes.ContainsKey($f.path)) {
                        if ((Get-TidymoveHash $destFile) -ne $job.hashes[$f.path] -or (Get-TidymoveHash $f.path) -ne $job.hashes[$f.path]) { throw "SHA-256 mismatch or source changed: $destFile" }
                        $checked++
                    }
                }
                if ($job.mode -eq 'folder') {
                    foreach ($dir in $job.tree.directories) {
                        $relative=$dir.Substring($job.source.Length).TrimStart('\')
                        if (-not [IO.Directory]::Exists((Get-TidymoveExtended ([IO.Path]::Combine($job.target,$relative))))) { throw 'Missing destination directory.' }
                    }
                    $finalTree=Get-TidymoveTree $job.target
                    if ($finalTree.issues.Count) { throw 'Destination scan incomplete.' }
                    if ($finalTree.files.Count -lt $job.tree.files.Count) { throw 'Destination file count is smaller than the selected source set.' }
                    $extra=$finalTree.files.Count-$job.tree.files.Count
                }
                Assert-CopyFrozen $job.source $job.target
                $status='VERIFIED-ALL'; if ($Verify -eq 'Sample') { $status='VERIFIED-SAMPLE' }
                $message='Every expected path and size checked; extra target files retained; activation is separate'
            }
        } catch { $message=$_.Exception.Message }
        $results.Add([pscustomobject]@{row=$index;source=$job.source;target=$job.target;mode=$job.mode;status=$status;files=$job.tree.files.Count;bytes=$bytes;sha256_checked=$checked;extra_files=$extra;copy_exit=$copyExit;checked_utc=[DateTime]::UtcNow.ToString('o');log=$log;message=$message})
        $results | Export-Csv -LiteralPath ([IO.Path]::Combine($OutputDir,'verification.csv')) -NoTypeInformation -Encoding UTF8
        Write-Output ('Row {0}: {1}; files={2}; SHA256={3}' -f $index,$status,$job.tree.files.Count,$checked)
        if ($status -eq 'FAILED') { throw $message }
    }
    Write-Output ('Verification CSV: '+[IO.Path]::Combine($OutputDir,'verification.csv'))
    exit 0
} catch {
    $reason=$_.Exception.Message
    if ($results.Count -eq 0) {
        try {
            if (-not $outputReady) {
                if (-not $recordsComplete) { throw 'Manifest paths could not be established safely.' }
                Initialize-PreflightOutput
            }
            Write-PreflightRefusal $reason
        } catch { Write-Output ('REPORT NOT WRITTEN: '+$_.Exception.Message+' Choose a fresh, disjoint output path and retain this console refusal.') }
    }
    Write-Output ('STOP: '+$reason); exit 1
}
finally { if ($null -ne $lock) { $lock.Dispose() } }
