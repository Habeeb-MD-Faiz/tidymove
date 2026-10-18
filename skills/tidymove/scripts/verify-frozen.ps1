#requires -Version 5.1
<# Check disk flags only. Never create a test file. A read-only FILE attribute is insufficient.
   Exit 0: proved frozen; 1: proved writable; 2: inconclusive. No elevation or mutation.
#>
[CmdletBinding()]
param([Parameter(Mandatory=$true)][string]$Root)
try {
    $ErrorActionPreference='Stop'
    . "$PSScriptRoot\inventory.ps1" -Library -Root $Root
    $path=Get-TidymovePath $Root
    Assert-TidymoveAncestors $path
    if (-not ([IO.Directory]::Exists((Get-TidymoveExtended $path)) -or [IO.File]::Exists((Get-TidymoveExtended $path)))) { throw 'Source is absent.' }
    $partition=@(Get-Partition -DriveLetter $path.Substring(0,1) -ErrorAction Stop)
    if ($partition.Count -ne 1) { throw 'Cannot identify exactly one partition.' }
    $disk=@($partition[0] | Get-Disk -ErrorAction Stop)
    if ($disk.Count -ne 1 -or $disk[0].IsOffline -ne $false -or $null -eq $disk[0].IsReadOnly) { throw 'Exactly one online disk with a known read-only flag is required.' }
    if ($disk[0].IsReadOnly -eq $false) {
        Write-Output 'NOT FROZEN: The mapped online disk is writable.'
        exit 1
    }
    if ($disk[0].IsReadOnly -ne $true) { throw 'Unknown read-only flag.' }
    [pscustomobject]@{root=$path;disk_number=$disk[0].Number;read_only=$disk[0].IsReadOnly;online=(-not $disk[0].IsOffline);checked_utc=[DateTime]::UtcNow.ToString('o');evidence='Current OS disk flags; persistence after replug requires a second check'}
    exit 0
} catch { Write-Output ('INCONCLUSIVE: '+$_.Exception.Message); exit 2 }
