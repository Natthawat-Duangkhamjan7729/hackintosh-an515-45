# Generate a private PlatformInfo identity (serial, MLB, SystemUUID, ROM) for MacBookPro16,2.
# - Uses macserial from the official OpenCore 1.0.8 package (same tool GenSMBIOS wraps).
# - Writes ONLY to staging\AN515-45-Tahoe\private\PlatformInfo.json (gitignored). Values are never printed in full.
# - ROM = MAC address of the built-in Ethernet adapter (Killer/Realtek), as Dortania suggests; falls back to random.
# Usage: powershell -ExecutionPolicy Bypass -File New-PlatformInfo.ps1 [-Force]
param([switch]$Force)
$ErrorActionPreference = 'Stop'
$stage = Split-Path -Parent $PSScriptRoot
$outDir = Join-Path $stage 'private'
$out = Join-Path $outDir 'PlatformInfo.json'
if ((Test-Path $out) -and -not $Force) { throw "$out already exists. Keep using it, or pass -Force to replace it (only before signing in to Apple services)." }

$macserial = Join-Path $stage 'packages\OpenCore-1.0.8-DEBUG\Utilities\macserial\macserial.exe'
$model = 'MacBookPro16,2'
$line = (& $macserial -m $model -n 1 | Where-Object { $_ -match '\|' } | Select-Object -First 1)
if (-not $line) { throw 'macserial did not return a serial | MLB pair.' }
$parts = $line -split '\|' | ForEach-Object { $_.Trim() }
$serial = $parts[0]; $mlb = $parts[1]
if ($serial.Length -ne 12 -or $mlb.Length -ne 17) { throw "Unexpected macserial output format (lengths $($serial.Length)/$($mlb.Length))." }

$uuid = [guid]::NewGuid().ToString().ToUpper()

$nic = Get-NetAdapter -Physical -ErrorAction SilentlyContinue | Where-Object { $_.InterfaceDescription -match 'Killer|Realtek|Ethernet' -and $_.InterfaceDescription -notmatch 'Wi-?Fi|Wireless|802\.11' } | Select-Object -First 1
if ($nic -and $nic.MacAddress) { $rom = ($nic.MacAddress -replace '[-:]', '').ToUpper(); $romSrc = "Ethernet adapter ($($nic.InterfaceDescription))" }
else { $b = New-Object byte[] 6; (New-Object Random).NextBytes($b); $b[0] = ($b[0] -band 0xFE) -bor 0x02; $rom = -join ($b | ForEach-Object { $_.ToString('X2') }); $romSrc = 'random (no Ethernet adapter found)' }

New-Item -ItemType Directory -Force $outDir | Out-Null
[ordered]@{
    SystemProductName  = $model
    SystemSerialNumber = $serial
    MLB                = $mlb
    SystemUUID         = $uuid
    ROM                = $rom
    Generated          = (Get-Date -Format s)
    Tool               = 'OpenCore 1.0.8 macserial'
} | ConvertTo-Json | Set-Content -Encoding UTF8 $out

$mask = { param($s) ('*' * ($s.Length - 3)) + $s.Substring($s.Length - 3) }
Write-Host "Saved private identity to $out"
Write-Host ("  Model {0}; serial {1}; MLB {2}; UUID ****-{3}; ROM from {4}" -f $model, (& $mask $serial), (& $mask $mlb), $uuid.Substring($uuid.Length - 4), $romSrc)
Write-Host 'Do not share these values. Optional: check the serial yourself at https://checkcoverage.apple.com - it should be reported as NOT valid (unused).'
