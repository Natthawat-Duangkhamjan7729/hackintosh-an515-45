# Carve install partitions on the internal TOSHIBA HDD (replaces the USB for an UnPlugged offline install).
# Requires an elevated PowerShell. Shrinks D: (NTFS, data kept) by 44 GB, then creates:
#   FAT32 2 GB 'OCRECOVERY' for com.apple.recovery.boot (OpenCore ScanPolicy 0 scans it)
#   exFAT ~42 GB 'UnPlugged' (allocation unit 128 KB) for InstallAssistant.pkg and UnPlugged.command
# Aborts unless model, size, bus and partition layout match the disk recorded on 2026-10-13.
# Usage: powershell -ExecutionPolicy Bypass -File Prepare-HDD-Install.ps1 [-DryRun]
param([switch]$DryRun)
$ErrorActionPreference = 'Stop'
$id = [Security.Principal.WindowsIdentity]::GetCurrent()
if (-not ([Security.Principal.WindowsPrincipal]$id).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { throw 'Run from an elevated (Administrator) PowerShell.' }

$model = 'TOSHIBA MQ01ABD100'
$size = 1000204886016
$shrink = 44GB

$d = Get-Disk | Where-Object { $_.FriendlyName -eq $model -and $_.Size -eq $size -and $_.BusType -eq 'SATA' }
if (@($d).Count -ne 1) { throw "Expected exactly one SATA disk '$model' of $size bytes; found $(@($d).Count). Nothing changed." }
if ($d.IsBoot -or $d.IsSystem) { throw 'Matched disk is a boot/system disk. Nothing changed.' }
if ($d.PartitionStyle -ne 'GPT') { throw "Expected GPT, found $($d.PartitionStyle). Nothing changed." }
$n = $d.Number

if (Get-Volume | Where-Object { $_.FileSystemLabel -in 'OCRECOVERY', 'UnPlugged' }) { throw 'A volume labelled OCRECOVERY or UnPlugged already exists. Nothing changed.' }
$parts = @(Get-Partition -DiskNumber $n)
if ($parts.Count -ne 1 -or $parts[0].DriveLetter -ne 'D') { throw "Expected a single partition D: on disk $n; found $($parts.Count). Nothing changed." }
$p = $parts[0]
if ((Get-Volume -DriveLetter D).FileSystem -ne 'NTFS') { throw 'D: is not NTFS. Nothing changed.' }

$sup = Get-PartitionSupportedSize -DiskNumber $n -PartitionNumber $p.PartitionNumber
$new = [math]::Floor(($p.Size - $shrink) / 1MB) * 1MB
Write-Host ("Disk {0} {1}: D: {2:N2} GB -> {3:N2} GB (minimum allowed {4:N2} GB)" -f $n, $model, ($p.Size / 1GB), ($new / 1GB), ($sup.SizeMin / 1GB))
if ($new -lt $sup.SizeMin) { throw 'Windows cannot shrink D: that far (unmovable files). Nothing changed.' }
if ($DryRun) { Write-Host 'DryRun: checks passed, nothing changed.'; Read-Host 'Press Enter to close'; return }

Resize-Partition -DiskNumber $n -PartitionNumber $p.PartitionNumber -Size $new
$basic = '{ebd0a0a2-b9e5-4433-87c0-68b6b72699c7}'
$p1 = New-Partition -DiskNumber $n -Size 2GB -GptType $basic -AssignDriveLetter
Format-Volume -Partition $p1 -FileSystem FAT32 -NewFileSystemLabel 'OCRECOVERY' -Confirm:$false | Out-Null
$p2 = New-Partition -DiskNumber $n -UseMaximumSize -GptType $basic -AssignDriveLetter
Format-Volume -Partition $p2 -FileSystem exFAT -NewFileSystemLabel 'UnPlugged' -AllocationUnitSize 131072 -Confirm:$false | Out-Null

Get-Partition -DiskNumber $n | Select-Object PartitionNumber, DriveLetter, Offset, Size, GptType | Format-Table -AutoSize
Get-Volume | Where-Object { $_.DriveLetter -eq 'D' -or $_.FileSystemLabel -in 'OCRECOVERY', 'UnPlugged' } |
    Select-Object DriveLetter, FileSystem, FileSystemLabel, Size, AllocationUnitSize | Format-Table -AutoSize
Write-Host 'Done. Tell Claude the partitioning finished; files are copied in a separate step.'
Read-Host 'Press Enter to close'
