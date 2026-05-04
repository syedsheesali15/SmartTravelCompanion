# Downloads gradle-*-all.zip into the Gradle wrapper cache so Flutter does not stall on flaky wrapper downloads.
# Run from repo root once (or anytime you see ExclusiveFileAccessManager / Connection reset).
# Requires: curl.exe (Windows 10+) in PATH.

$ErrorActionPreference = 'Stop'

$gradlePropsPath = Join-Path $PSScriptRoot '..\android\gradle\wrapper\gradle-wrapper.properties' | Resolve-Path
$content = Get-Content -LiteralPath $gradlePropsPath -Raw

if (-not ($content -match 'distributionUrl\s*=\s*(\S+)')) {
    throw "Could not find distributionUrl in $gradlePropsPath"
}

# Properties file escapes with backslashes; strip them (e.g. https\://...)
$distributionUrlRaw = $matches[1].Trim()
$url = ($distributionUrlRaw -replace '\\', '')

# Wrapper uses a subdirectory per URL fingerprint (stable for our two known mirrors).
function Get-WrapperDistSubdir([string]$u) {
    if ($u -like '*mirrors.cloud.tencent.com*') { return '8mguqc37c200i71ledpgw8n5m' }
    if ($u -like '*services.gradle.org*') { return 'c2qonpi39x1mddn7hk5gh9iqj' }
    throw "Extend scripts/preload_gradle.ps1: add wrapper dist folder for:`n $u"
}

$versionMarker = [regex]::Match($url, 'gradle-(\d+\.\d+)-all\.zip').Groups[1].Value
if (-not $versionMarker) {
    throw "Could not infer Gradle version from URL: $url"
}

$distsVerDir = Join-Path $env:USERPROFILE ".gradle/wrapper/dists/gradle-${versionMarker}-all"
$hashDirName = Get-WrapperDistSubdir $url
$targetDir = Join-Path $distsVerDir $hashDirName
$zipPath = Join-Path $targetDir "gradle-${versionMarker}-all.zip"

$mirrors = @(
    $url
    'https://mirrors.cloud.tencent.com/gradle/gradle-8.14-all.zip'
    'https://services.gradle.org/distributions/gradle-8.14-all.zip'
) | Sort-Object -Unique

Write-Host "Target: $zipPath"

Stop-Process -Name java -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
Remove-Item -Force -ErrorAction SilentlyContinue @(
    (Join-Path $targetDir '*.lck'),
    (Join-Path $targetDir '*.part')
)

if (Test-Path $zipPath) {
    $len = (Get-Item -LiteralPath $zipPath).Length
    if ($len -gt 200000000) {
        Write-Host "Zip already OK ($([math]::Round($len / 1MB)) MB)."
        exit 0
    }
    Remove-Item -Force $zipPath -ErrorAction SilentlyContinue
}

foreach ($mirror in $mirrors) {
    Write-Host "`nDownloading from:`n $mirror"
    $args = @(
        '-fL', '--retry', '25', '--retry-delay', '4', '--connect-timeout', '60',
        '--continue-at', '-', '-o', $zipPath, $mirror
    )
    & curl.exe @args
    $ok = ($LASTEXITCODE -eq 0) -and (Test-Path $zipPath) -and ((Get-Item -LiteralPath $zipPath).Length -gt 200000000)
    if ($ok) {
        Write-Host "Done ($([math]::Round((Get-Item -LiteralPath $zipPath).Length / 1MB)) MB). Now run: flutter run -d emulator-5554"
        exit 0
    }
    Remove-Item -Force -ErrorAction SilentlyContinue $zipPath
}

Write-Error "Could not finish Gradle ${versionMarker}-all download. Try hotspot/VPN/DNS."
exit 1
