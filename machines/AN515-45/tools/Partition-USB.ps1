# Repartition the KINGSTON USB for an UnPlugged offline install. Requires an elevated PowerShell.
# ERASES the whole USB disk. Aborts unless model, size and bus all match the disk recorded on 2026-10-09.
# Layout per corpnewt/UnPlugged README (e7e0696): FAT32 for EFI + com.apple.recovery.boot,
# exFAT (allocation unit <= 1024 KB) for InstallAssistant.pkg and UnPlugged.command.
$ErrorActionPreference = 'Stop'
$model = 'KINGSTON SV300S37A60G'
$size = 60022480896

$d = Get-Disk | Where-Object { $_.FriendlyName -eq $model -and $_.Size -eq $size -and $_.BusType -eq 'USB' }
if (@($d).Count -ne 1) { throw "Expected exactly one USB disk '$model' of $size bytes; found $(@($d).Count). Nothing changed." }
if ($d.IsBoot -or $d.IsSystem) { throw 'Matched disk is a boot/system disk. Nothing changed.' }
$n = $d.Number
Write-Host "Erasing disk $n ($model, $size bytes)..."

Clear-Disk -Number $n -RemoveData -RemoveOEM -Confirm:$false
if ((Get-Disk -Number $n).PartitionStyle -eq 'RAW') { Initialize-Disk -Number $n -PartitionStyle MBR }
$p1 = New-Partition -DiskNumber $n -Size 2GB -IsActive -MbrType FAT32 -AssignDriveLetter
Format-Volume -Partition $p1 -FileSystem FAT32 -NewFileSystemLabel 'OPENCORE' -Confirm:$false | Out-Null
$p2 = New-Partition -DiskNumber $n -UseMaximumSize -AssignDriveLetter
Format-Volume -Partition $p2 -FileSystem exFAT -NewFileSystemLabel 'UnPlugged' -AllocationUnitSize 131072 -Confirm:$false | Out-Null

Get-Partition -DiskNumber $n | Select-Object PartitionNumber, DriveLetter, Size, MbrType, IsActive | Format-Table -AutoSize
Get-Volume | Where-Object { $_.FileSystemLabel -in 'OPENCORE', 'UnPlugged' } |
    Select-Object DriveLetter, FileSystem, FileSystemLabel, Size, AllocationUnitSize | Format-Table -AutoSize
Write-Host 'Done. Tell Claude the partitioning finished; files are copied in a separate step.'
Read-Host 'Press Enter to close'
