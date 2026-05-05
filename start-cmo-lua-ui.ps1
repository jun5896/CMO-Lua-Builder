param(
    [switch]$Silent
)

$ErrorActionPreference = "Stop"

$UiRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$HostAddress = "127.0.0.1"
$Port = 5173
$Url = "http://${HostAddress}:${Port}/"
$LogRoot = Join-Path $UiRoot "logs"
$LauncherLog = Join-Path $LogRoot "launcher.log"
$ServerLog = Join-Path $LogRoot "vite-server.log"

New-Item -ItemType Directory -Force -Path $LogRoot | Out-Null

function Write-LauncherLog {
    param([string]$Message)

    $line = "[{0}] {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Message
    Add-Content -LiteralPath $LauncherLog -Value $line -Encoding UTF8

    if (-not $Silent) {
        Write-Host $Message
    }
}

function Show-LauncherNotice {
    param(
        [string]$Message,
        [string]$Level = "Info"
    )

    Write-LauncherLog $Message

    if (-not $Silent) {
        if ($Level -eq "Warning") {
            Write-Host $Message -ForegroundColor Yellow
        }
        return
    }

    try {
        $icon = if ($Level -eq "Warning") { 48 } else { 64 }
        $shell = New-Object -ComObject WScript.Shell
        $null = $shell.Popup($Message, 8, "CMO Lua UI", $icon)
    }
    catch {
        # Silent launchers must never wait for console input.
    }
}

function Test-LocalPort {
    param(
        [string]$Address,
        [int]$PortNumber
    )

    try {
        $client = [System.Net.Sockets.TcpClient]::new()
        $async = $client.BeginConnect($Address, $PortNumber, $null, $null)
        $connected = $async.AsyncWaitHandle.WaitOne(300, $false)
        if ($connected) {
            $client.EndConnect($async)
        }
        $client.Close()
        return $connected
    }
    catch {
        return $false
    }
}

function Find-Browser {
    $chromeCandidates = @(
        (Join-Path $env:ProgramFiles "Google\Chrome\Application\chrome.exe"),
        (Join-Path ${env:ProgramFiles(x86)} "Google\Chrome\Application\chrome.exe"),
        (Join-Path $env:LOCALAPPDATA "Google\Chrome\Application\chrome.exe")
    )

    foreach ($candidate in $chromeCandidates) {
        if ($candidate -and (Test-Path -LiteralPath $candidate)) {
            return @{ Name = "Chrome"; Path = $candidate }
        }
    }

    $edgeCandidates = @(
        (Join-Path $env:ProgramFiles "Microsoft\Edge\Application\msedge.exe"),
        (Join-Path ${env:ProgramFiles(x86)} "Microsoft\Edge\Application\msedge.exe"),
        (Join-Path $env:LOCALAPPDATA "Microsoft\Edge\Application\msedge.exe")
    )

    foreach ($candidate in $edgeCandidates) {
        if ($candidate -and (Test-Path -LiteralPath $candidate)) {
            return @{ Name = "Edge"; Path = $candidate }
        }
    }

    return $null
}

Write-LauncherLog "CMO Lua UI launcher"
Write-LauncherLog "UI root: $UiRoot"

if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Show-LauncherNotice "Node.js was not found. Install Node.js LTS, then run this launcher again." "Warning"
    exit 1
}

if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
    Show-LauncherNotice "npm was not found. Install Node.js LTS or check your PATH." "Warning"
    exit 1
}

if (-not (Test-Path -LiteralPath (Join-Path $UiRoot "package.json"))) {
    Show-LauncherNotice "package.json was not found. Run this launcher from the cmo-lua-ui root." "Warning"
    exit 1
}

if (-not (Test-Path -LiteralPath (Join-Path $UiRoot "node_modules"))) {
    Show-LauncherNotice "node_modules was not found. Run npm install in this folder first." "Warning"
    exit 1
}

if (-not (Test-LocalPort -Address $HostAddress -PortNumber $Port)) {
    $escapedRoot = $UiRoot.Replace("'", "''")
    $escapedServerLog = $ServerLog.Replace("'", "''")
    $serverCommand = "Set-Location -LiteralPath '$escapedRoot'; `$env:BROWSER='none'; npm run dev -- --host $HostAddress --port $Port *> '$escapedServerLog'"
    Start-Process `
        -FilePath "powershell.exe" `
        -ArgumentList @("-NoProfile", "-ExecutionPolicy", "Bypass", "-WindowStyle", "Hidden", "-Command", $serverCommand) `
        -WorkingDirectory $UiRoot `
        -WindowStyle Hidden
    Write-LauncherLog "Started the Vite dev server hidden. Log: $ServerLog"

    $ready = $false
    for ($i = 0; $i -lt 40; $i++) {
        Start-Sleep -Milliseconds 500
        if (Test-LocalPort -Address $HostAddress -PortNumber $Port) {
            $ready = $true
            break
        }
    }

    if (-not $ready) {
        Show-LauncherNotice "Server startup timed out. Check logs\vite-server.log in the cmo-lua-ui folder." "Warning"
    }
}
else {
    Write-LauncherLog "Server is already running at $Url"
}

$browser = Find-Browser
if ($browser) {
    Write-LauncherLog "Opening $Url in $($browser.Name)."
    Start-Process -FilePath $browser.Path -ArgumentList $Url
}
else {
    Show-LauncherNotice "Chrome or Edge was not found. Install Chrome or Edge, then open $Url." "Warning"
}
