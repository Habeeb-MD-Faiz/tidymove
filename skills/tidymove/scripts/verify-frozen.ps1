#requires -Version 5.1
<# Check disk flags only. Never create a test file. A read-only FILE attribute is insufficient.
   Exit 0: mapped local disk is online and read-only; 1: not proved. No elevation or mutation.
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
    if ($disk.Count -ne 1 -or -not $disk[0].IsReadOnly -or $disk[0].IsOffline) { throw 'Online, read-only disk state is not proved.' }
    [pscustomobject]@{root=$path;disk_number=$disk[0].Number;read_only=$disk[0].IsReadOnly;online=(-not $disk[0].IsOffline);checked_utc=[DateTime]::UtcNow.ToString('o');evidence='Current OS disk flags; persistence after replug requires a second check'}
    exit 0
} catch { Write-Output ('NOT PROVED: '+$_.Exception.Message); exit 1 }
