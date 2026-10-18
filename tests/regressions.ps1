#requires -Version 5.1
param([Parameter(Mandatory=$true)][string]$WorkDir)
$ErrorActionPreference='Stop'
$scripts=Join-Path (Split-Path -Parent $PSScriptRoot) 'skills\tidymove\scripts'
. (Join-Path $scripts 'inventory.ps1') -Library
function Check([bool]$Condition,[string]$Message) { if (-not $Condition) { throw $Message } }
function Fixture([string]$Path,[string]$Text) {
    [void][IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($Path))
    [IO.File]::WriteAllText($Path,$Text)
}
function Copy-Case([string]$Manifest,[string]$Output,[int]$Expected,[switch]$Execute) {
    $argsCopy=@('-NoProfile','-File',(Join-Path $scripts 'copy-verify.ps1'),'-Manifest',$Manifest,'-OutputDir',$Output,'-FixtureRoot',$WorkDir)
    if ($Execute) { $argsCopy+='-Execute' }
    $messages=& powershell.exe @argsCopy
    Check ($LASTEXITCODE -eq $Expected) ($messages -join [Environment]::NewLine)
}
if (Test-Path -LiteralPath $WorkDir) { throw 'Regression WorkDir must be new.' }
Fixture (Join-Path $WorkDir '.tidymove-fixture') 'Synthetic tidymove test data only'
$cases=[ordered]@{}
$cases['F01 explicit file destinations']={
    $a=Join-Path $WorkDir 'rename\a\notes.txt'; $b=Join-Path $WorkDir 'rename\b\notes.txt'
    Fixture $a 'first note'; Fixture $b 'other note'
    $dest=Join-Path $WorkDir 'rename\out'
    $da=Join-Path $dest 'first.txt'; $db=Join-Path $dest 'second.txt'
    $manifest=Join-Path $WorkDir 'rename.csv'
    @([pscustomobject]@{source=$a;target=$da;mode='file'},[pscustomobject]@{source=$b;target=$db;mode='file'}) | Export-Csv -LiteralPath $manifest -NoTypeInformation
    Copy-Case $manifest (Join-Path $WorkDir 'rename-dry') 0
    Check (-not (Test-Path -LiteralPath $dest)) 'Rename preview wrote target data'
    Copy-Case $manifest (Join-Path $WorkDir 'rename-copy') 0 -Execute
    Check ((Get-TidymoveHash $a) -eq (Get-TidymoveHash $da) -and (Get-TidymoveHash $b) -eq (Get-TidymoveHash $db)) 'Renamed content differs'
    Check (-not (Test-Path -LiteralPath (Join-Path $dest 'notes.txt'))) 'Unrequested basename was created'
    $rows=@(Import-Csv -LiteralPath (Join-Path $WorkDir 'rename-copy\verification.csv'))
    Check ($rows.Count -eq 2 -and @($rows | Where-Object { $_.status -ne 'VERIFIED-ALL' -or $_.sha256_checked -ne '1' }).Count -eq 0) 'Rename hashes were not recorded'
    Check ((Test-Path -LiteralPath (Join-Path $WorkDir 'rename-copy\001.log')) -and (Test-Path -LiteralPath (Join-Path $WorkDir 'rename-copy\002.log'))) 'Rename logs absent'
    $stamp=(Get-Item -LiteralPath $da).LastWriteTimeUtc
    Copy-Case $manifest (Join-Path $WorkDir 'rename-identical') 0 -Execute
    Check ((Get-Item -LiteralPath $da).LastWriteTimeUtc -eq $stamp) 'Identical destination was rewritten'
    Fixture $db 'corruption'
    $conflictHash=Get-TidymoveHash $db
    Copy-Case $manifest (Join-Path $WorkDir 'rename-conflict') 1 -Execute
    Check ((Get-TidymoveHash $db) -eq $conflictHash) 'Rename conflict overwritten'
    Check ([IO.File]::ReadAllText($a) -eq 'first note' -and [IO.File]::ReadAllText($b) -eq 'other note') 'Original changed'
    # The new target name is subject to the same opaque, link and activation checks.
    foreach ($case in @('opaque','link','active')) {
        $bad=Join-Path $WorkDir ('rename-'+$case+'-target')
        if ($case -eq 'opaque') { $bad=Join-Path $bad 'passwords-old.txt' }
        if ($case -eq 'link') {
            [void](New-Item -ItemType Junction -Path $bad -Target $dest)
            $bad=Join-Path $bad 'new-name.txt'
        }
        if ($case -eq 'active') { Fixture (Join-Path $bad '.tidymove-active') 'Active fixture'; $bad=Join-Path $bad 'new-name.txt' }
        $m=Join-Path $WorkDir ('rename-'+$case+'.csv')
        [pscustomobject]@{source=$a;target=$bad;mode='file'} | Export-Csv -LiteralPath $m -NoTypeInformation
        Copy-Case $m (Join-Path $WorkDir ('rename-'+$case+'-log')) 1 -Execute
        Check (-not (Test-Path -LiteralPath $bad)) ('Unsafe renamed target created: '+$case)
    }
}
$cases['F02 opaque names stay unread']={
    $src=Join-Path $WorkDir 'names'
    $names=@('passwords-old.txt','password.txt','passwd.bak','secret backup.txt','secrets-old.txt','credentials.csv','token backup.txt','private key.txt','id_ed25519.old','wallet.dat','recovery codes.txt','backup-codes.txt','seed-phrase.txt','privateXkey.txt','recoveryXcode.txt')
    $handles=New-Object 'System.Collections.Generic.List[object]'
    try {
        foreach ($name in $names) {
            $path=Join-Path $src $name; Fixture $path 'Synthetic noncredential fixture'
            $handles.Add([IO.File]::Open($path,[IO.FileMode]::Open,[IO.FileAccess]::ReadWrite,[IO.FileShare]::None))
        }
        $out=Join-Path $WorkDir 'names.csv'
        $messages=& powershell.exe -NoProfile -File (Join-Path $scripts 'inventory.ps1') -Root $src -OutputCsv $out -AllowLiveScan
        Check ($LASTEXITCODE -eq 0) ($messages -join ' ')
        $rows=@(Import-Csv -LiteralPath $out | Where-Object kind -eq 'secret-name')
        Check ($rows.Count -eq $names.Count) 'Conservative names were not all flagged'
        foreach ($name in $names) { Check (Test-TidymoveSecret $name) ('Missing name pattern: '+$name) }
    } finally { foreach ($handle in $handles) { $handle.Dispose() } }
}
$cases['F05 preflight refusal evidence']={
    $src=Join-Path $WorkDir 'evidence-source'; Fixture (Join-Path $src 'a.txt') 'original'
    foreach ($case in @('missing','conflict','overlap','malformed','opaque','active')) {
        $s=$src; $d=Join-Path $WorkDir ('evidence-target-'+$case)
        if ($case -eq 'missing') { $s=Join-Path $WorkDir 'absent' }
        if ($case -eq 'conflict') { Fixture (Join-Path $d 'a.txt') 'conflict' }
        if ($case -eq 'overlap') { $d=Join-Path $src 'nested' }
        if ($case -eq 'opaque') { $s=Join-Path $WorkDir 'evidence-opaque'; Fixture (Join-Path $s '.env') 'Synthetic noncredential fixture' }
        if ($case -eq 'active') { Fixture (Join-Path $d '.tidymove-active') 'Active fixture' }
        $m=Join-Path $WorkDir ('evidence-'+$case+'.csv'); $out=Join-Path $WorkDir ('evidence-'+$case+'-log')
        @([pscustomobject]@{source=$s;target=$d;mode='folder'},[pscustomobject]@{source=$src;target=(Join-Path $WorkDir ('unexecuted-'+$case));mode='folder'}) | Export-Csv -LiteralPath $m -NoTypeInformation
        if ($case -eq 'malformed') { Fixture $m ('source,target,mode'+[Environment]::NewLine+'"'+$s+'","'+$d+'",folder,extra') }
        Copy-Case $m $out 1 -Execute
        Check (Test-Path -LiteralPath (Join-Path $out 'preflight.csv')) ('Missing refusal CSV: '+$case)
        $rows=@(Import-Csv -LiteralPath (Join-Path $out 'preflight.csv'))
        $expected=2; if ($case -eq 'malformed') { $expected=1 }
        Check ($rows.Count -eq $expected -and @($rows | Where-Object { $_.status -ne 'REFUSED' -or $_.stage -ne 'preflight' -or -not $_.reason -or $_.exit_code -ne '1' }).Count -eq 0) ('Incomplete refusal rows: '+$case)
        Check (-not (Test-Path -LiteralPath (Join-Path $WorkDir ('unexecuted-'+$case)))) 'Preflight copied a later row'
    }
    # Logging must never weaken disjointness or replace old evidence.
    $m=Join-Path $WorkDir 'unsafe-evidence.csv'
    [pscustomobject]@{source=$src;target=(Join-Path $WorkDir 'safe-target');mode='folder'} | Export-Csv -LiteralPath $m -NoTypeInformation
    Copy-Case $m (Join-Path $src 'unsafe-log') 1 -Execute
    Check (-not (Test-Path -LiteralPath (Join-Path $src 'unsafe-log'))) 'Refusal logging wrote inside source'
    $alias=Join-Path $WorkDir 'evidence-alias'
    [void](New-Item -ItemType Junction -Path $alias -Target $src)
    [pscustomobject]@{source=$alias;target=(Join-Path $WorkDir 'alias-target');mode='folder'} | Export-Csv -LiteralPath $m -NoTypeInformation
    Copy-Case $m (Join-Path $src 'alias-log') 1 -Execute
    Check (-not (Test-Path -LiteralPath (Join-Path $src 'alias-log'))) 'Refusal logging wrote inside an aliased source'
    [pscustomobject]@{source=$src;target=(Join-Path $WorkDir 'safe-target');mode='folder'} | Export-Csv -LiteralPath $m -NoTypeInformation
    $prior=Join-Path $WorkDir 'prior-evidence'; Fixture (Join-Path $prior 'preflight.csv') 'Keep prior evidence'
    Copy-Case $m $prior 1 -Execute
    Check ([IO.File]::ReadAllText((Join-Path $prior 'preflight.csv')) -eq 'Keep prior evidence') 'Prior report overwritten'
}
$cases['F06 freeze outcomes are distinct']={
    $mock=Join-Path $WorkDir 'freeze-outcomes.ps1'
    Fixture $mock @'
param([string]$Checker,[string]$Source,[string]$Case)
function Get-Partition {
    [CmdletBinding()]param([string]$DriveLetter)
    if ($Case -eq 'denied') { throw 'Access denied' }
    if ($Case -eq 'unknown') { return }
    [pscustomobject]@{DiskNumber=987}
}
function Get-Disk {
    [CmdletBinding()]param([Parameter(ValueFromPipeline=$true)]$InputObject)
    process { [pscustomobject]@{Number=987;IsReadOnly=($Case -ne 'writable');IsOffline=$false} }
}
& $Checker -Root $Source
exit $LASTEXITCODE
'@
    foreach ($case in @('frozen','writable','denied','unknown')) {
        $messages=& powershell.exe -NoProfile -File $mock -Checker (Join-Path $scripts 'verify-frozen.ps1') -Source $WorkDir -Case $case
        $expected=2; if ($case -eq 'frozen') { $expected=0 }; if ($case -eq 'writable') { $expected=1 }
        Check ($LASTEXITCODE -eq $expected) ('Freeze outcome conflated: '+$case+'; '+($messages -join ' '))
        if ($expected -eq 2) { Check (($messages -join ' ') -match 'INCONCLUSIVE:') 'Unknown state lacks reason' }
    }
}
$cases['F11 strict subtree refuses upfront']={
    foreach ($script in @('inventory.ps1','copy-verify.ps1')) {
        $out=Join-Path $WorkDir ($script+'-strict-output')
        # Deliberately nonexistent inputs prove refusal precedes path and marker reads.
        $invoke=@('-NoProfile','-File',(Join-Path $scripts $script),'-StrictSubtree')
        if ($script -eq 'inventory.ps1') { $invoke+=@('-Root','invalid-input','-OutputCsv',$out,'-AllowLiveScan') }
        else { $invoke+=@('-Manifest','invalid-input','-OutputDir',$out,'-FixtureRoot','invalid-input') }
        $messages=& powershell.exe @invoke 2>&1
        Check ($LASTEXITCODE -eq 1 -and ($messages -join ' ') -match '^STRICT SUBTREE REFUSED:') ('No explicit upfront boundary refusal: '+$script)
        Check (-not (Test-Path -LiteralPath $out)) 'Strict refusal wrote evidence'
    }
}
$failed=0
foreach ($name in $cases.Keys) {
    try { & $cases[$name]; Write-Output ('PASS '+$name) }
    catch { $failed++; Write-Output ('FAIL '+$name+': '+$_.Exception.Message) }
}
Write-Output ('REGRESSIONS: '+($cases.Count-$failed)+' passed; '+$failed+' failed')
if ($failed) { exit 1 }
exit 0
