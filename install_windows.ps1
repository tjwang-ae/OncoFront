param(
    [string]$PythonPath = '',
    [string]$InstallDir = '',
    [string]$IndexUrl = 'https://pypi.org/simple',
    [switch]$SkipDemo
)
$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
if (-not $InstallDir) { $InstallDir = Join-Path $env:LOCALAPPDATA 'OncoFront/v1.0' }
$InstallDir = [IO.Path]::GetFullPath($InstallDir)
if (-not ([Uri]$IndexUrl).Scheme.Equals('https')) { throw 'The package index must use HTTPS.' }

# Prefer an explicit interpreter; otherwise look for a registered Python 3.10.
if (-not $PythonPath) {
    $launcher = Get-Command py.exe -ErrorAction SilentlyContinue
    if ($launcher) {
        $found = & $launcher.Source -3.10 -c 'import sys; print(sys.executable)' 2>$null
        if ($LASTEXITCODE -eq 0) { $PythonPath = ($found | Select-Object -Last 1).Trim() }
    }
}
if (-not $PythonPath) {
    $candidate = Get-Command python.exe -ErrorAction SilentlyContinue
    if ($candidate) { $PythonPath = $candidate.Source }
}
if (-not $PythonPath) { throw 'Install Python 3.10 x64, or supply -PythonPath with its python.exe path.' }
$version = & $PythonPath -c 'import sys, struct; print(str(sys.version_info.major)+"."+str(sys.version_info.minor)+" "+str(struct.calcsize("P")*8))'
if ($LASTEXITCODE -ne 0 -or $version.Trim() -ne '3.10 64') { throw 'This installer requires Python 3.10 x64.' }

# Verify all packaged installation files before installing or loading them.
$checksPath = Join-Path $root 'INSTALL_CHECKSUMS.json'
if (-not (Test-Path -LiteralPath $checksPath)) { throw 'Installation checksum list missing.' }
$checks = Get-Content -LiteralPath $checksPath -Raw | ConvertFrom-Json
foreach ($item in $checks.PSObject.Properties) {
    $path = [IO.Path]::GetFullPath((Join-Path $root $item.Name))
    if (-not $path.StartsWith([IO.Path]::GetFullPath($root) + [IO.Path]::DirectorySeparatorChar)) { throw 'Unsafe checksum path.' }
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Missing installation file: $($item.Name)" }
    $got = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($got -ne $item.Value) { throw "Checksum failed: $($item.Name)" }
}

$venv = Join-Path $InstallDir 'venv'
$python = Join-Path $venv 'Scripts/python.exe'
if (Test-Path -LiteralPath $venv) { throw 'Installation directory already contains an environment. Choose a new directory; existing files will not be deleted.' }
New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
& $PythonPath -m venv $venv
if ($LASTEXITCODE -ne 0) { throw 'Creating the isolated environment failed.' }
& $python -m pip install --disable-pip-version-check --index-url $IndexUrl -r (Join-Path $root 'requirements-windows.txt')
if ($LASTEXITCODE -ne 0) { throw 'Dependency installation failed. Check internet access and the package index.' }
& $python -m pip install --disable-pip-version-check --no-deps (Join-Path $root 'package/oncofront-1.0-cp310-cp310-win_amd64.whl')
if ($LASTEXITCODE -ne 0) { throw 'Installing the native package failed.' }
& $python -m pip check
if ($LASTEXITCODE -ne 0) { throw 'Dependency consistency check failed.' }

$command = Join-Path $venv 'Scripts/oncofront.exe'
$assetRoot = Join-Path $InstallDir 'data'
$env:ONCOFRONT_HOME = $assetRoot
& $command --version
if ($LASTEXITCODE -ne 0) { throw 'Native module version check failed.' }
& $command self-test
if ($LASTEXITCODE -ne 0) { throw 'Native module self-test failed.' }
foreach ($file in @('OncoFront_models_v1.0.zip','OncoFront_demo_v1.0.zip')) {
    & $command install-assets (Join-Path $root "assets/$file") --root $assetRoot
    if ($LASTEXITCODE -ne 0) { throw "Installing asset failed: $file" }
}
& $command verify-assets --root $assetRoot
if ($LASTEXITCODE -ne 0) { throw 'Installed model or demo verification failed.' }
if (-not $SkipDemo) {
    & $command demo --root $assetRoot --output (Join-Path $InstallDir 'demo_result')
    if ($LASTEXITCODE -ne 0) { throw 'Demo inference failed.' }
}

# Store only the local data path, not credentials or server addresses.
$launcherPath = Join-Path $InstallDir 'OncoFront.cmd'
$launcherText = '@echo off' + "`r`n" + 'set "ONCOFRONT_HOME=' + $assetRoot + '"' + "`r`n" + '"' + $command + '" %*' + "`r`n"
[IO.File]::WriteAllText($launcherPath, $launcherText, [Text.Encoding]::Default)
Write-Output "Installation completed: $InstallDir"
Write-Output "Run: `"$launcherPath`" --help"
