# Install or update OpenCore on the Apacer EFI System Partition (dual-boot disk). Requires elevated PowerShell.
# - Touches only \EFI\OC on the ESP. \EFI\Microsoft and \EFI\BOOT (Windows) are never modified.
# - Backs up the whole ESP to D:\Backup-ESP-<timestamp> before any write; an existing \EFI\OC is kept as \EFI\OC.bak-<timestamp>.
# - Verifies every copied file by SHA256.
# - First install only: adds a firmware boot entry "OpenCore" -> \EFI\OC\OpenCore.efi at the END of the boot order,
#   so Windows Boot Manager stays the default. Choose OpenCore via F12, or pass -MakeDefault.
# Usage: powershell -ExecutionPolicy Bypass -File Install-OpenCore-ESP.ps1 [-Source <dir containing OC>] [-MakeDefault] [-WhatIf]
param(
    [string]$Source = (Join-Path (Split-Path -Parent $PSScriptRoot) 'candidate-v4\EFI\OC'),
    [switch]$MakeDefault,
    [switch]$WhatIf
)
$ErrorActionPreference = 'Stop'
$id = [Security.Principal.WindowsIdentity]::GetCurrent()
if (-not ([Security.Principal.WindowsPrincipal]$id).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { throw 'Run from an elevated (Administrator) PowerShell.' }

# Source sanity
foreach ($f in 'OpenCore.efi', 'config.plist') { if (-not (Test-Path (Join-Path $Source $f))) { throw "Source missing $f : $Source" } }
$ocv = Join-Path (Split-Path -Parent $PSScriptRoot) 'packages\OpenCore-1.0.8-DEBUG\Utilities\ocvalidate\ocvalidate.exe'
$val = & $ocv (Join-Path $Source 'config.plist') 2>&1 | Out-String
if ($val -notmatch 'No issues found') { throw "ocvalidate did not pass:`n$val" }
Write-Host "Source: $Source (ocvalidate 1.0.8: No issues found)"

# Locate the Apacer ESP strictly
$disk = Get-Disk | Where-Object { $_.FriendlyName -eq 'Apacer AS2280P4 512GB' -and $_.PartitionStyle -eq 'GPT' }
if (@($disk).Count -ne 1) { throw 'Expected exactly one GPT disk "Apacer AS2280P4 512GB".' }
$esp = Get-Partition -DiskNumber $disk.Number | Where-Object { $_.GptType -eq '{c12a7328-f81f-11d2-ba4b-00a0c93ec93b}' }
if (@($esp).Count -ne 1) { throw 'Expected exactly one EFI System Partition on the Apacer.' }
$letter = 'S'
if (Test-Path "${letter}:\") { throw "Drive ${letter}: is already in use; free it first." }
Add-PartitionAccessPath -DiskNumber $disk.Number -PartitionNumber $esp.PartitionNumber -AccessPath "${letter}:\"
try {
    $root = "${letter}:\"
    if (-not (Test-Path "${root}EFI\Microsoft\Boot\bootmgfw.efi")) { throw 'This ESP has no Windows Boot Manager; refusing to continue.' }
    $vol = Get-Volume -DriveLetter $letter
    $need = (Get-ChildItem $Source -Recurse -File | Measure-Object Length -Sum).Sum
    Write-Host ("ESP free {0:N1} MB, OpenCore needs {1:N1} MB" -f ($vol.SizeRemaining/1MB), ($need/1MB))
    if ($vol.SizeRemaining -lt ($need * 2 + 5MB)) { throw 'Not enough free space on the ESP for OpenCore plus a backup copy.' }
    Get-ChildItem "${root}EFI" -Force | Select-Object Name, LastWriteTime | Format-Table -AutoSize

    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    if ($WhatIf) { Write-Host 'WhatIf: no changes made.'; return }

    # 1. Backup the whole ESP
    $bk = "D:\Backup-ESP-$stamp"
    # The live BCD hive and its BCD.LOG* transaction logs are locked by Windows, so they are excluded here and exported with bcdedit instead.
    $log = "$bk.robocopy.log"
    robocopy $root $bk /E /COPY:DAT /R:1 /W:1 /NP /XD 'System Volume Information' /XF BCD 'BCD.LOG*' /LOG:$log | Out-Null
    $rc = $LASTEXITCODE
    if ($rc -ge 8) {
        Get-Content $log | Select-String -Pattern 'ERROR' -Context 0,1 | Out-Host
        throw "ESP backup failed (robocopy $rc); see $log"
    }
    bcdedit /export (Join-Path $bk 'BCD-export') | Out-Null
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path (Join-Path $bk 'BCD-export'))) { throw 'bcdedit /export of the BCD store failed' }
    Write-Host "ESP backed up to $bk (BCD exported as BCD-export)"

    # 2. Keep previous OC, copy new OC
    $dst = "${root}EFI\OC"
    $first = -not (Test-Path $dst)
    if (-not $first) { Rename-Item $dst "OC.bak-$stamp"; Write-Host "Previous OpenCore kept as EFI\OC.bak-$stamp" }
    robocopy $Source $dst /E /COPY:DAT /R:1 /W:1 /NP /NFL /NDL | Out-Null
    if ($LASTEXITCODE -ge 8) { throw "Copy failed (robocopy $LASTEXITCODE)" }

    # 3. Verify by hash
    $bad = 0
    Get-ChildItem $Source -Recurse -File | ForEach-Object {
        $rel = $_.FullName.Substring($Source.Length)
        $t = Join-Path $dst $rel
        if (-not (Test-Path $t) -or (Get-FileHash $_.FullName).Hash -ne (Get-FileHash $t).Hash) { $bad++; Write-Warning "Mismatch: $rel" }
    }
    if ($bad) { throw "$bad file(s) failed verification; previous OpenCore (if any) is in EFI\OC.bak-$stamp, full ESP backup in $bk" }
    Write-Host 'All OpenCore files verified (SHA256).'

    # 4. Report older OC.bak-* copies (not deleted automatically; each is also in D:\Backup-ESP-*)
    $baks = @(Get-ChildItem "${root}EFI" -Directory -Filter 'OC.bak-*')
    if ($baks.Count -gt 1) { Write-Warning "$($baks.Count) OC.bak-* folders on the ESP; you may delete older ones yourself to save space." }

    # 5. Firmware boot entry (first install only)
    $existing = (bcdedit /enum firmware) -join "`n"
    if ($existing -notmatch '\\EFI\\OC\\OpenCore\.efi') {
        $out = bcdedit /copy '{bootmgr}' /d 'OpenCore'
        $guid = [regex]::Match(($out -join ' '), '\{[0-9a-fA-F-]{36}\}').Value
        if (-not $guid) { throw "bcdedit /copy failed: $out" }
        bcdedit /set $guid path '\EFI\OC\OpenCore.efi' | Out-Null
        if ($MakeDefault) { bcdedit /set '{fwbootmgr}' displayorder $guid /addfirst | Out-Null } else { bcdedit /set '{fwbootmgr}' displayorder $guid /addlast | Out-Null }
        Write-Host "Firmware boot entry 'OpenCore' created: $guid"
    } else { Write-Host 'Firmware boot entry for \EFI\OC\OpenCore.efi already exists; left unchanged.' }
    bcdedit /enum firmware | Select-String -Pattern 'identifier|description|path' | Out-Host
}
finally {
    Remove-PartitionAccessPath -DiskNumber $disk.Number -PartitionNumber $esp.PartitionNumber -AccessPath "${letter}:\" -ErrorAction SilentlyContinue
}
Write-Host 'Done. ESP unmounted. Reboot, press F12, choose OpenCore (keep the USB in as a fallback for the first test).'
