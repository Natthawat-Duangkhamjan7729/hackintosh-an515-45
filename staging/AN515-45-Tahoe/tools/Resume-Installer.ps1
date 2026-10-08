$ErrorActionPreference = 'Stop'
$stage = Split-Path -Parent $PSScriptRoot
$target = Join-Path $stage 'installer\Sequoia-15.8.1-24H32'
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
Get-FileHash -LiteralPath $complete -Algorithm SHA256 | ConvertTo-Json |
    Set-Content (Join-Path $target 'sha256.json')
Write-Host 'Installer size matches Apple catalog; SHA256 recorded. Package signature/extraction still needs verification.'
