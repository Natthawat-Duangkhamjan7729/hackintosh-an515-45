# Remove OpenCore and macOS from the Apacer dual-boot disk, leaving Windows Boot Manager only. Requires elevated PowerShell.
# - Backs up the whole ESP to D:\Backup-ESP-<timestamp> (BCD exported) before any write.
# - ESP: deletes \EFI\OC and \EFI\OC.bak-*. \EFI\Microsoft is never modified. If \EFI\BOOT\BOOTx64.efi is an OpenCore
#   launcher it is replaced with a copy of \EFI\Microsoft\Boot\bootmgfw.efi (what bcdboot puts there).
# - Firmware: deletes every boot entry whose path is under \EFI\OC\ or whose description is OpenCore.
# - Deletes the APFS partition(s) (GPT type 7C3457EF) on the Apacer. This destroys macOS and its data.
# - -ExtendC grows C: into the freed space (Recovery stays after it).
# Usage: powershell -ExecutionPolicy Bypass -File Remove-OpenCore-macOS.ps1 [-ExtendC] [-WhatIf]
param(
    [switch]$ExtendC,
    [switch]$WhatIf
)
$ErrorActionPreference = 'Stop'
$id = [Security.Principal.WindowsIdentity]::GetCurrent()
if (-not ([Security.Principal.WindowsPrincipal]$id).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { throw 'Run from an elevated (Administrator) PowerShell.' }

$apfsType = '{7c3457ef-0000-11aa-aa11-00306543ecac}'
$disk = Get-Disk | Where-Object { $_.FriendlyName -eq 'Apacer AS2280P4 512GB' -and $_.PartitionStyle -eq 'GPT' }
if (@($disk).Count -ne 1) { throw 'Expected exactly one GPT disk "Apacer AS2280P4 512GB".' }
$parts = Get-Partition -DiskNumber $disk.Number
$esp = $parts | Where-Object { $_.GptType -eq '{c12a7328-f81f-11d2-ba4b-00a0c93ec93b}' }
if (@($esp).Count -ne 1) { throw 'Expected exactly one EFI System Partition on the Apacer.' }
$apfs = @($parts | Where-Object { $_.GptType -eq $apfsType })
$cPart = $parts | Where-Object { $_.DriveLetter -eq 'C' }
Write-Host 'Apacer partitions:'
$parts | Format-Table PartitionNumber, DriveLetter, @{n = 'SizeGB'; e = { [math]::Round($_.Size / 1GB, 2) } }, Type, GptType -AutoSize | Out-Host

# Free any stale access path to the ESP (e.g. left by mountvol), then mount it on a free letter
foreach ($p in @($esp.AccessPaths)) { if ($p -match '^[A-Z]:\\$') { Remove-PartitionAccessPath -DiskNumber $disk.Number -PartitionNumber $esp.PartitionNumber -AccessPath $p -ErrorAction SilentlyContinue } }
$letter = [char[]]('ZYXWVUTSRQPONM') | Where-Object { -not (Test-Path "${_}:\") } | Select-Object -First 1
if (-not $letter) { throw 'No free drive letter for the ESP.' }
Add-PartitionAccessPath -DiskNumber $disk.Number -PartitionNumber $esp.PartitionNumber -AccessPath "${letter}:\"
try {
    $root = "${letter}:\"
    $bootmgfw = "${root}EFI\Microsoft\Boot\bootmgfw.efi"
    if (-not (Test-Path $bootmgfw)) { throw 'This ESP has no Windows Boot Manager; refusing to continue.' }
    Write-Host "ESP mounted at ${letter}: - \EFI contents:"
    Get-ChildItem "${root}EFI" -Force | Select-Object Name, LastWriteTime | Format-Table -AutoSize | Out-Host

    $ocDirs = @(Get-ChildItem "${root}EFI" -Directory -Force | Where-Object { $_.Name -eq 'OC' -or $_.Name -like 'OC.bak-*' })
    $bootx64 = "${root}EFI\BOOT\BOOTx64.efi"
    $bootIsOC = $false
    if (Test-Path $bootx64) {
        $b = [IO.File]::ReadAllBytes($bootx64)
        $txt = [Text.Encoding]::ASCII.GetString($b) + [Text.Encoding]::Unicode.GetString($b)
        $bootIsOC = $txt -match 'OpenCore'
    }
    $fw = (bcdedit /enum firmware) -join "`n"
    $fwOC = @()
    foreach ($blk in ($fw -split "`n`n")) {
        if ($blk -match '(?im)^path\s+\\EFI\\OC\\' -or $blk -match '(?im)^description\s+OpenCore') {
            $g = [regex]::Match($blk, '(?im)^identifier\s+(\{[0-9a-f-]{36}\})').Groups[1].Value
            if ($g) { $fwOC += $g }
        }
    }
    $other = @(Get-ChildItem "${root}EFI" -Directory -Force | Where-Object { $_.Name -notin 'Microsoft', 'Boot', 'OC' -and $_.Name -notlike 'OC.bak-*' })

    Write-Host "Plan:"
    Write-Host ("  ESP folders to delete : " + $(if ($ocDirs) { ($ocDirs.Name -join ', ') } else { '(none)' }))
    Write-Host ("  EFI\BOOT\BOOTx64.efi  : " + $(if ($bootIsOC) { 'OpenCore -> replace with bootmgfw.efi' } elseif (Test-Path $bootx64) { 'not OpenCore, left unchanged' } else { 'absent' }))
    Write-Host ("  Firmware entries      : " + $(if ($fwOC) { ($fwOC -join ', ') } else { '(none)' }))
    Write-Host ("  APFS partitions       : " + $(if ($apfs) { ($apfs | ForEach-Object { "#$($_.PartitionNumber) ({0:N2} GB)" -f ($_.Size / 1GB) }) -join ', ' } else { '(none)' }))
    Write-Host ("  Extend C:             : " + $ExtendC)
    if ($other) { Write-Warning ("Other non-Windows folders on the ESP, left unchanged: " + ($other.Name -join ', ')) }
    if ($WhatIf) { Write-Host 'WhatIf: no changes made.'; return }

    # 1. Backup the whole ESP (live BCD is locked; exported with bcdedit instead)
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $bk = "D:\Backup-ESP-$stamp"
    $log = "$bk.robocopy.log"
    robocopy $root $bk /E /COPY:DAT /R:1 /W:1 /NP /XD 'System Volume Information' /XF BCD 'BCD.LOG*' /LOG:$log | Out-Null
    if ($LASTEXITCODE -ge 8) { throw "ESP backup failed (robocopy $LASTEXITCODE); see $log" }
    bcdedit /export (Join-Path $bk 'BCD-export') | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'bcdedit /export failed' }
    Write-Host "ESP backed up to $bk"

    # 2. ESP cleanup
    foreach ($d in $ocDirs) { Remove-Item $d.FullName -Recurse -Force; Write-Host "Deleted EFI\$($d.Name)" }
    if ($bootIsOC) {
        Copy-Item $bootmgfw $bootx64 -Force
        if ((Get-FileHash $bootmgfw).Hash -ne (Get-FileHash $bootx64).Hash) { throw 'BOOTx64.efi replacement failed verification' }
        Write-Host 'EFI\BOOT\BOOTx64.efi replaced with bootmgfw.efi (verified)'
    }

    # 3. Firmware entries
    foreach ($g in $fwOC) { bcdedit /delete $g | Out-Null; if ($LASTEXITCODE -ne 0) { Write-Warning "bcdedit /delete $g failed" } else { Write-Host "Deleted firmware entry $g" } }
    bcdedit /set '{fwbootmgr}' displayorder '{bootmgr}' /addfirst | Out-Null
}
finally {
    Remove-PartitionAccessPath -DiskNumber $disk.Number -PartitionNumber $esp.PartitionNumber -AccessPath "${letter}:\" -ErrorAction SilentlyContinue
}

# 4. APFS partitions
foreach ($p in $apfs) {
    try { Remove-Partition -DiskNumber $disk.Number -PartitionNumber $p.PartitionNumber -Confirm:$false }
    catch {
        Write-Warning "Remove-Partition failed ($($_.Exception.Message)); retrying with diskpart override"
        "select disk $($disk.Number)`nselect partition $($p.PartitionNumber)`ndelete partition override`n" | diskpart | Out-Host
    }
    Write-Host "Deleted APFS partition #$($p.PartitionNumber)"
}

# 5. Extend C:
if ($ExtendC -and $apfs) {
    $max = (Get-PartitionSupportedSize -DriveLetter C).SizeMax
    Resize-Partition -DriveLetter C -Size $max
    Write-Host ("C: extended to {0:N1} GB" -f ($max / 1GB))
}

Write-Host 'Result:'
Get-Partition -DiskNumber $disk.Number | Format-Table PartitionNumber, DriveLetter, @{n = 'SizeGB'; e = { [math]::Round($_.Size / 1GB, 2) } }, Type -AutoSize | Out-Host
bcdedit /enum firmware | Select-String -Pattern 'identifier|description|path' | Out-Host
Write-Host 'Done.'
