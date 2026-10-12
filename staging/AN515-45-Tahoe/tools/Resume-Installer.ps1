param([string]$Target = 'Tahoe-26.7.1-25G241')
$ErrorActionPreference = 'Stop'
$stage = Split-Path -Parent $PSScriptRoot
$target = Join-Path $stage (Join-Path 'installer' $Target)
$entry = Get-Content (Join-Path $target 'apple-product.json') -Raw | ConvertFrom-Json
$partial = Join-Path $target 'InstallAssistant.pkg.partial'
$complete = Join-Path $target 'InstallAssistant.pkg'
if (-not (Test-Path -LiteralPath $complete)) {
    & curl.exe -L --fail --show-error --continue-at - --output $partial $entry.packages[0].URL
    if ($LASTEXITCODE -ne 0) { throw 'Download interrupted. Run this script again to resume.' }
    if ((Get-Item -LiteralPath $partial).Length -ne $entry.packages[0].Size) {
        throw 'Downloaded size differs from Apple catalog. File remains partial.'
    }
    Rename-Item -LiteralPath $partial -NewName 'InstallAssistant.pkg'
}
if ((Get-Item -LiteralPath $complete).Length -ne $entry.packages[0].Size) {
    throw 'Installer size does not match the Apple catalog.'
}
# The catalog Digest is the SHA-1 of the xar TOC (not of the whole file); verify_pkg.py checks it and every payload SHA-1
if ($entry.packages[0].Digest) {
    & py -3.12 -I (Join-Path $PSScriptRoot 'verify_pkg.py') $complete $entry.packages[0].Digest
    if ($LASTEXITCODE -ne 0) { throw 'Package failed TOC/payload checksum verification.' }
}
Get-FileHash -LiteralPath $complete -Algorithm SHA256 | ConvertTo-Json |
    Set-Content (Join-Path $target 'sha256.json')
Write-Host 'Installer size matches Apple catalog; SHA256 recorded. Package signature/extraction still needs verification.'
