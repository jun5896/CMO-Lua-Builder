param([ValidateSet('run','build','smoke')][string]$Action = 'run')
$ErrorActionPreference = 'Stop'
$desktopRepoRoot = Split-Path -Parent $PSScriptRoot
$desktopProject = Join-Path $desktopRepoRoot 'desktop\CmoWorkbench\CmoWorkbench.csproj'
$desktopOutput = Join-Path $desktopRepoRoot 'desktop-dist'
if (-not (Get-Command dotnet -ErrorAction SilentlyContinue)) { throw '.NET 8 SDK is required. See docs/desktop-workbench.md.' }
if (-not (Get-Command node -ErrorAction SilentlyContinue)) { throw 'Node.js 24 is required.' }
& dotnet publish $desktopProject -c Release --self-contained false -o $desktopOutput --nologo
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
$desktopExecutable = Join-Path $desktopOutput 'CmoWorkbench.exe'
if ($Action -eq 'smoke') {
    $desktopSmokeOutput = Join-Path $desktopRepoRoot '.cache\desktop-smoke'
    $desktopSmokeArguments = @('--smoke-test', ('"' + $desktopSmokeOutput + '"'))
    $desktopProcess = Start-Process -FilePath $desktopExecutable -ArgumentList $desktopSmokeArguments -WindowStyle Hidden -Wait -PassThru
    if ($desktopProcess.ExitCode -ne 0) { throw 'Native smoke test failed. See %TEMP%\cmo-desktop-smoke-error.txt.' }
    Get-Content -LiteralPath (Join-Path $desktopSmokeOutput 'result.json')
} elseif ($Action -eq 'run') {
    # This is the explicitly requested interactive desktop window.
    Start-Process -FilePath $desktopExecutable
} else {
    Write-Output $desktopExecutable
}
