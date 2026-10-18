#requires -Version 5.1
<# Synthetic tests only. Retain every fixture and log; never delete or clean up.
   Default is inside the repo, because an agent sandbox may deny the system temp folder.
#>
[CmdletBinding()]
param([string]$WorkDir)
$ErrorActionPreference='Stop'
$skipped=0
$repo=Split-Path -Parent $PSScriptRoot
$scripts=Join-Path $repo 'skills\tidymove\scripts'
if (-not $WorkDir) { $WorkDir=Join-Path $repo ('runs\smoke-'+(Get-Date -Format 'yyyyMMdd-HHmmss')+'-'+[guid]::NewGuid().ToString('N').Substring(0,8)) }
. (Join-Path $scripts 'inventory.ps1') -Library
$WorkDir=Get-TidymovePath $WorkDir
function Assert-Test([bool]$Condition,[string]$Message) { if (-not $Condition) { throw $Message }; Write-Output ('PASS '+$Message) }
function Write-Fixture([string]$Path,[string]$Text) {
    [void][IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName((Get-TidymoveExtended $Path)))
    [IO.File]::WriteAllText((Get-TidymoveExtended $Path),$Text,(New-Object Text.UTF8Encoding($false)))
}
function Run-Copy([string]$Csv,[string]$Out,[switch]$Real,[int]$Expected=0,[string]$HashMode='All',[int]$SampleCount=20) {
    $invoke=@('-NoProfile','-File',(Join-Path $scripts 'copy-verify.ps1'),'-Manifest',$Csv,'-OutputDir',$Out,'-FixtureRoot',$WorkDir,'-Verify',$HashMode,'-SampleSize',$SampleCount)
    if ($Real) { $invoke += '-Execute' }
    & powershell.exe @invoke
    $rc=$LASTEXITCODE
    Assert-Test ($rc -eq $Expected) ('copy process exit '+$Expected)
}
try {
    Assert-TidymoveAncestors $WorkDir
    if (Test-Path -LiteralPath $WorkDir) { throw 'WorkDir must be new; existing test data is retained.' }
    [void][IO.Directory]::CreateDirectory($WorkDir)
    Write-Fixture (Join-Path $WorkDir '.tidymove-fixture') 'Synthetic tidymove test data only'
    & powershell.exe -NoProfile -File (Join-Path $PSScriptRoot 'regressions.ps1') -WorkDir (Join-Path $WorkDir 'regressions')
    Assert-Test ($LASTEXITCODE -eq 0) 'confirmed defect regressions'
    $source=Join-Path $WorkDir 'source with spaces'
    $target=Join-Path $WorkDir 'target with spaces'
    Write-Fixture (Join-Path $source 'root.txt') 'alpha'
    Write-Fixture (Join-Path $source 'nested\data,one.txt') 'beta'
    $unicodeName=([string][char]0x0935)+([string][char]0x093F)+'.txt'
    Write-Fixture (Join-Path $source $unicodeName) 'unicode path'
    $longRel=('deep-folder-'*5)+'\'+('nested-path-'*5)+'\'+('last-folder-'*5)+'\long.txt'
    Write-Fixture (Join-Path $source $longRel) 'long path'
    [void][IO.Directory]::CreateDirectory((Get-TidymoveExtended (Join-Path $source 'empty directory')))
    $before=@{}; foreach ($f in (Get-TidymoveTree $source).files) { $before[$f.path]=Get-TidymoveHash $f.path }
    $manifest=Join-Path $WorkDir 'manifest.csv'
    [pscustomobject]@{source=$source;target=$target;mode='folder'} | Export-Csv -LiteralPath $manifest -NoTypeInformation -Encoding UTF8
    $inventory=Join-Path $WorkDir 'inventory.csv'
    & powershell.exe -NoProfile -File (Join-Path $scripts 'inventory.ps1') -Root $source -OutputCsv $inventory -AllowLiveScan
    Assert-Test ($LASTEXITCODE -eq 0) 'inventory exit 0'
    $scan=@(Import-Csv -LiteralPath $inventory)
    Assert-Test ((($scan | Where-Object kind -eq 'folder' | Measure-Object file_count -Sum).Sum) -eq $before.Count) 'inventory counts include root, nested, Unicode and long paths'
    Run-Copy $manifest (Join-Path $WorkDir 'dry')
    Assert-Test (-not (Test-Path -LiteralPath $target)) 'dry run creates no target'
    Assert-Test ((Import-Csv -LiteralPath (Join-Path $WorkDir 'dry\verification.csv')).status -eq 'DRY-RUN') 'dry run is not called verified'
    Write-Fixture (Join-Path $target 'keep-extra.txt') 'keep this'
    $extraHash=Get-TidymoveHash (Join-Path $target 'keep-extra.txt')
    Run-Copy $manifest (Join-Path $WorkDir 'real') -Real
    foreach ($srcFile in $before.Keys) {
        $dstFile=Join-Path $target $srcFile.Substring($source.Length+1)
        Assert-Test ((Get-TidymoveHash $dstFile) -eq $before[$srcFile]) 'destination SHA-256 matches'
        Assert-Test ((Get-TidymoveHash $srcFile) -eq $before[$srcFile]) 'source SHA-256 unchanged'
    }
    Assert-Test ((Get-TidymoveTree $source).files.Count -eq $before.Count) 'source file count unchanged'
    Assert-Test ((Get-TidymoveHash (Join-Path $target 'keep-extra.txt')) -eq $extraHash) 'extra destination file retained unchanged'
    $report=Join-Path $WorkDir 'real\verification.csv'
    Assert-Test (Test-Path -LiteralPath $report) 'verification CSV present'
    $row=Import-Csv -LiteralPath $report
    Assert-Test ($row.status -eq 'VERIFIED-ALL' -and [int]$row.sha256_checked -eq $before.Count -and [int]$row.extra_files -eq 1) 'all-file verification records hash scope and extras'
    Run-Copy $manifest (Join-Path $WorkDir 'rerun') -Real
    Run-Copy $manifest (Join-Path $WorkDir 'sample') -Real -HashMode Sample
    Assert-Test ((Import-Csv -LiteralPath (Join-Path $WorkDir 'sample\verification.csv')).status -eq 'VERIFIED-SAMPLE') 'sample result is labelled'
    $sampleManifest=Join-Path $WorkDir 'sample-fresh.csv'
    [pscustomobject]@{source=$source;target=(Join-Path $WorkDir 'sample-target');mode='folder'} | Export-Csv -LiteralPath $sampleManifest -NoTypeInformation -Encoding UTF8
    Run-Copy $sampleManifest (Join-Path $WorkDir 'sample-fresh-log') -Real -HashMode Sample -SampleCount 1
    Assert-Test ((Import-Csv -LiteralPath (Join-Path $WorkDir 'sample-fresh-log\verification.csv')).sha256_checked -eq '1') 'sample hashes only the declared subset on a fresh target'
    # Same-length corruption must stop BEFORE overwrite, even if timestamps match.
    Write-Fixture (Join-Path $target 'root.txt') 'wrong'
    Run-Copy $manifest (Join-Path $WorkDir 'conflict') -Real -Expected 1
    Assert-Test ([IO.File]::ReadAllText((Join-Path $target 'root.txt')) -eq 'wrong') 'conflicting destination retained'
    Assert-Test ((Get-TidymoveHash (Join-Path $source 'root.txt')) -eq $before[(Join-Path $source 'root.txt')]) 'conflict leaves source unchanged'
    $missing=Join-Path $WorkDir 'missing.csv'
    [pscustomobject]@{source=(Join-Path $WorkDir 'absent');target=(Join-Path $WorkDir 'missing-target');mode='folder'} | Export-Csv -LiteralPath $missing -NoTypeInformation -Encoding UTF8
    Run-Copy $missing (Join-Path $WorkDir 'missing-log') -Real -Expected 1
    $overlap=Join-Path $WorkDir 'overlap.csv'
    [pscustomobject]@{source=$source;target=(Join-Path $source 'nested-target');mode='folder'} | Export-Csv -LiteralPath $overlap -NoTypeInformation -Encoding UTF8
    Run-Copy $overlap (Join-Path $WorkDir 'overlap-log') -Real -Expected 1
    Assert-Test (-not (Test-Path -LiteralPath (Join-Path $source 'nested-target'))) 'overlap rejected without source writes'
    $fileManifest=Join-Path $WorkDir 'file.csv'
    $fileTarget=Join-Path $WorkDir 'file-target\root.txt'
    [pscustomobject]@{source=(Join-Path $source 'root.txt');target=$fileTarget;mode='file'} | Export-Csv -LiteralPath $fileManifest -NoTypeInformation -Encoding UTF8
    Run-Copy $fileManifest (Join-Path $WorkDir 'file-log') -Real
    Write-Fixture (Join-Path $WorkDir 'file-target\.tidymove-active') 'Activated fixture'
    Run-Copy $fileManifest (Join-Path $WorkDir 'active-log') -Real -Expected 1
    $opaque=Join-Path $WorkDir 'opaque-source'
    Write-Fixture (Join-Path $opaque '.env') 'Synthetic noncredential fixture'
    $opaqueManifest=Join-Path $WorkDir 'opaque.csv'
    [pscustomobject]@{source=$opaque;target=(Join-Path $WorkDir 'opaque-target');mode='folder'} | Export-Csv -LiteralPath $opaqueManifest -NoTypeInformation -Encoding UTF8
    Run-Copy $opaqueManifest (Join-Path $WorkDir 'opaque-log') -Real -Expected 1
    Assert-Test (-not (Test-Path -LiteralPath (Join-Path $WorkDir 'opaque-target'))) 'opaque file names block the entire row'
    $malformed=Join-Path $WorkDir 'malformed.csv'
    Write-Fixture $malformed ('source,target,mode'+[Environment]::NewLine+'"'+$source+'","'+(Join-Path $WorkDir 'bad-target')+'",folder,extra')
    Run-Copy $malformed (Join-Path $WorkDir 'malformed-log') -Real -Expected 1
    Assert-Test (-not (Test-Path -LiteralPath (Join-Path $WorkDir 'bad-target'))) 'surplus CSV fields stop before copying'
    $linkSource=Join-Path $WorkDir 'link-source'
    [void][IO.Directory]::CreateDirectory($linkSource)
    [void](New-Item -ItemType Junction -Path (Join-Path $linkSource 'linked') -Target $source)
    $linkManifest=Join-Path $WorkDir 'links.csv'
    [pscustomobject]@{source=$linkSource;target=(Join-Path $WorkDir 'link-target');mode='folder'} | Export-Csv -LiteralPath $linkManifest -NoTypeInformation -Encoding UTF8
    Run-Copy $linkManifest (Join-Path $WorkDir 'link-log') -Real -Expected 1
    $linkScan=Join-Path $WorkDir 'links-inventory.csv'
    & powershell.exe -NoProfile -File (Join-Path $scripts 'inventory.ps1') -Root $linkSource -OutputCsv $linkScan -AllowLiveScan
    Assert-Test ($LASTEXITCODE -eq 0 -and @(Import-Csv -LiteralPath $linkScan | Where-Object kind -eq 'link-or-cloud').Count -eq 1) 'inventory records links without following them'
    $repoFixture=Join-Path $WorkDir 'repository-fixture'
    [void][IO.Directory]::CreateDirectory($repoFixture)
    & git -C $repoFixture init --quiet
    Assert-Test ($LASTEXITCODE -eq 0) 'synthetic Git fixture initialized without commits'
    Write-Fixture (Join-Path $repoFixture 'README.md') 'Synthetic untracked work'
    $repoScan=Join-Path $WorkDir 'repo-inventory.csv'
    & powershell.exe -NoProfile -File (Join-Path $scripts 'inventory.ps1') -Root $repoFixture -OutputCsv $repoScan -AllowLiveScan
    Assert-Test ($LASTEXITCODE -eq 0) 'repository inventory completes'
    Assert-Test (@(Import-Csv -LiteralPath $repoScan | Where-Object { $_.repo -eq 'repository' -and $_.dirty -eq 'needs-checking' }).Count -eq 1) 'inventory detects repository without reading contents or running Git'
    Assert-Test (Test-TidymoveSecret '.env.example') 'example suffix cannot bypass secret-name boundary'
    Assert-Test (Test-TidymoveSecret 'private.key.sample') 'sample suffix cannot bypass secret-name boundary'
    foreach ($opaqueName in @('.env.example','service.key.sample','secrets.json','.npmrc','.pypirc','Cookies','Login Data','passwords.kdbx')) {
        $opaqueCase=Join-Path $WorkDir ('opaque-case-'+[guid]::NewGuid().ToString('N'))
        Write-Fixture (Join-Path $opaqueCase $opaqueName) 'Synthetic noncredential fixture'
        $caseManifest=$opaqueCase+'.csv'
        [pscustomobject]@{source=$opaqueCase;target=($opaqueCase+'-target');mode='folder'} | Export-Csv -LiteralPath $caseManifest -NoTypeInformation -Encoding UTF8
        Run-Copy $caseManifest ($opaqueCase+'-log') -Real -Expected 1
        Assert-Test (-not (Test-Path -LiteralPath ($opaqueCase+'-target'))) ('opaque preflight blocks '+$opaqueName)
    }
    foreach ($reserved in @('NUL','CON.txt','COM1','LPT9.txt')) {
        $rejected=$false
        try { [void](Get-TidymovePath (Join-Path $WorkDir $reserved)) } catch { $rejected=$true }
        Assert-Test $rejected ('reserved device name refused: '+$reserved)
    }
    $nestedActiveTarget=Join-Path $WorkDir 'nested-active-target'
    Write-Fixture (Join-Path $nestedActiveTarget 'live\.tidymove-active') 'Activated fixture'
    $nestedActiveManifest=Join-Path $WorkDir 'nested-active.csv'
    [pscustomobject]@{source=$source;target=$nestedActiveTarget;mode='folder'} | Export-Csv -LiteralPath $nestedActiveManifest -NoTypeInformation -Encoding UTF8
    Run-Copy $nestedActiveManifest (Join-Path $WorkDir 'nested-active-log') -Real -Expected 1
    Assert-Test (-not (Test-Path -LiteralPath (Join-Path $nestedActiveTarget 'root.txt'))) 'nested activation stops before target copy'
    $lockOverlapManifest=Join-Path $WorkDir 'lock-overlap.csv'
    [pscustomobject]@{source=$source;target=($lockOverlapManifest+'.tidymove-lock');mode='folder'} | Export-Csv -LiteralPath $lockOverlapManifest -NoTypeInformation -Encoding UTF8
    Run-Copy $lockOverlapManifest (Join-Path $WorkDir 'lock-overlap-log') -Real -Expected 1
    Assert-Test (-not (Test-Path -LiteralPath ($lockOverlapManifest+'.tidymove-lock'))) 'lock path cannot overlap destination'
    # Simulate disk flags without changing any real disk. Exercise positive and failure gates.
    $mock=Join-Path $WorkDir 'frozen-mock.ps1'
    Write-Fixture $mock @'
param([string]$Checker,[string]$Source,[string]$Case)
function Get-Partition {
    [CmdletBinding()]param([string]$DriveLetter)
    if ($Case -eq 'missing') { return }
    [pscustomobject]@{DiskNumber=987}
    if ($Case -eq 'ambiguous') { [pscustomobject]@{DiskNumber=988} }
}
function Get-Disk {
    [CmdletBinding()]param([Parameter(ValueFromPipeline=$true)]$InputObject)
    process { [pscustomobject]@{Number=987;IsReadOnly=($Case -ne 'writable');IsOffline=($Case -eq 'offline')} }
}
& $Checker -Root $Source
exit $LASTEXITCODE
'@
    foreach ($case in @('frozen','writable','offline','missing','ambiguous')) {
        & powershell.exe -NoProfile -File $mock -Checker (Join-Path $scripts 'verify-frozen.ps1') -Source $source -Case $case
        $expected=2; if ($case -eq 'frozen') { $expected=0 }; if ($case -eq 'writable') { $expected=1 }
        Assert-Test ($LASTEXITCODE -eq $expected) ('simulated freeze gate '+$case)
    }
    # A live fixture should not pass the production disk-read-only check.
    $freezeOutput=@(& powershell.exe -NoProfile -File (Join-Path $scripts 'verify-frozen.ps1') -Root $source)
    $freezeExit=$LASTEXITCODE
    if ($freezeExit -eq 0) { throw 'Real fixture disk unexpectedly proved frozen; writable-disk assertion failed.' }
    elseif ($freezeExit -eq 1 -and ($freezeOutput -join ' ') -match '^NOT FROZEN:') {
        Assert-Test $true 'real fixture disk proved writable'
    } else {
        $skipped++
        Write-Output ('SKIPPED real writable-disk assertion: inconclusive (exit '+$freezeExit+'); '+($freezeOutput -join ' '))
    }
    Write-Output ('SMOKE PASS: all executed assertions passed; '+$skipped+' skipped. A skipped real disk check is not proof of disk protection.')
    Write-Output ('Verification CSV: '+$report)
    Write-Output ('Retained fixtures: '+$WorkDir)
    exit 0
} catch { Write-Output ('SMOKE FAIL: '+$_.Exception.Message); Write-Output ('Retained fixtures: '+$WorkDir); exit 1 }
