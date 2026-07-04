param(
  [Parameter(Mandatory = $true, Position = 0)]
  [string]$ScenarioPath,

  [Parameter(Mandatory = $true)]
  [string]$OutXml,

  [string]$CmoRoot = ''
)

$ErrorActionPreference = 'Stop'

if (-not $CmoRoot) {
  if ($env:CMO_ROOT) {
    $CmoRoot = $env:CMO_ROOT
  } else {
    $cmoCandidates = @(
      'C:\Program Files (x86)\Steam\steamapps\common\Command - Modern Operations'
    )
    foreach ($drive in @('C', 'D', 'E', 'F')) {
      $cmoCandidates += ('{0}:\SteamLibrary\steamapps\common\Command - Modern Operations' -f $drive)
    }
    $CmoRoot = $cmoCandidates[0]
    foreach ($candidate in $cmoCandidates) {
      if (Test-Path (Join-Path $candidate 'Command.exe')) {
        $CmoRoot = $candidate
        break
      }
    }
  }
}

function Resolve-FullPath([string]$PathValue) {
  return [System.IO.Path]::GetFullPath($PathValue)
}

function Get-InnermostException([System.Exception]$Exception) {
  $current = $Exception
  while ($null -ne $current.InnerException) {
    $current = $current.InnerException
  }
  return $current
}

function Test-IsLegacyCmanoPath([string]$PathValue) {
  return $PathValue.IndexOf('\Standalone Scenarios_CMANO\', [System.StringComparison]::OrdinalIgnoreCase) -ge 0
}

function Write-DecoderErrorSidecar(
  [string]$Code,
  [string]$Message,
  [System.Exception]$Exception,
  [bool]$Actionable = $true
) {
  $errorPath = "$OutXml.error.json"
  $errorDir = Split-Path -Parent $errorPath
  if ($errorDir) {
    New-Item -ItemType Directory -Force -Path $errorDir | Out-Null
  }

  $inner = $null
  if ($null -ne $Exception) {
    $inner = Get-InnermostException $Exception
  }

  $payload = [ordered]@{
    code = $Code
    message = $Message
    timestamp = [System.DateTime]::UtcNow.ToString('o')
    scenarioPath = $ScenarioPath
    outXml = $OutXml
    detail = [ordered]@{
      innerExceptionType = if ($null -ne $inner) { $inner.GetType().FullName } else { '' }
      innerExceptionMessage = if ($null -ne $inner) { $inner.Message } else { '' }
      folderHint = if (Test-IsLegacyCmanoPath $ScenarioPath) { 'Standalone Scenarios_CMANO' } else { '' }
      actionable = $Actionable
    }
  }

  $json = $payload | ConvertTo-Json -Depth 8
  $utf8NoBom = New-Object System.Text.UTF8Encoding $false
  [System.IO.File]::WriteAllText($errorPath, $json, $utf8NoBom)
  Write-Output "Decoder error sidecar: $errorPath"
}

$ScenarioPath = Resolve-FullPath $ScenarioPath
$OutXml = Resolve-FullPath $OutXml

if (-not (Test-Path -LiteralPath $ScenarioPath)) {
  throw "Scenario file not found: $ScenarioPath"
}

if (-not (Test-Path -LiteralPath $CmoRoot)) {
  throw "CMO root not found: $CmoRoot"
}

$commandExe = Join-Path $CmoRoot 'Command.exe'
if (-not (Test-Path -LiteralPath $commandExe)) {
  throw "Command.exe not found: $commandExe"
}

# CMO's internal loader may be denied direct access to Workshop/Program Files paths
# under Codex sandboxing, so feed it a read-only working copy in the project cache.
$cacheRoot = Join-Path (Split-Path -Parent $PSScriptRoot) '.scenario-extract-cache'
New-Item -ItemType Directory -Force -Path $cacheRoot | Out-Null
$sha1 = [System.Security.Cryptography.SHA1]::Create()
try {
  $pathBytes = [System.Text.Encoding]::UTF8.GetBytes($ScenarioPath.ToLowerInvariant())
  $pathHash = ([System.BitConverter]::ToString($sha1.ComputeHash($pathBytes)) -replace '-', '').Substring(0, 8).ToLowerInvariant()
} finally {
  $sha1.Dispose()
}
$cacheName = ([System.IO.Path]::GetFileNameWithoutExtension($ScenarioPath) -replace '[^A-Za-z0-9_.-]+', '_') + '_' + $pathHash + '.scen'
$cachedScenario = Join-Path $cacheRoot $cacheName
[System.IO.File]::WriteAllBytes($cachedScenario, [System.IO.File]::ReadAllBytes($ScenarioPath))

try {
foreach ($preload in @('LZ4.dll', 'Microsoft.IO.RecyclableMemoryStream.dll', 'Newtonsoft.Json.dll', 'SevenZipSharp.dll')) {
  $preloadPath = Join-Path $CmoRoot $preload
  if (Test-Path -LiteralPath $preloadPath) {
    [void][System.Reflection.Assembly]::LoadFrom($preloadPath)
  }
}

$sevenZipNativePath = Join-Path $CmoRoot '7z.dll'
if (Test-Path -LiteralPath $sevenZipNativePath) {
  $sevenZipBaseType = [System.Type]::GetType('SevenZip.SevenZipBase, SevenZipSharp', $false)
  if ($null -ne $sevenZipBaseType) {
    $setLibraryPath = $sevenZipBaseType.GetMethod('SetLibraryPath', [type[]]@([string]))
    if ($null -ne $setLibraryPath) {
      [void]$setLibraryPath.Invoke($null, [object[]]@([string]$sevenZipNativePath))
    }
  }
}

[System.AppDomain]::CurrentDomain.add_AssemblyResolve({
  param($sender, $args)
  $name = New-Object System.Reflection.AssemblyName($args.Name)
  if ($name.Name -eq 'Command') {
    return $null
  }

  foreach ($dir in @($CmoRoot, (Join-Path $CmoRoot 'x64'), (Join-Path $CmoRoot 'x86'))) {
    $candidate = Join-Path $dir ($name.Name + '.dll')
    if (Test-Path -LiteralPath $candidate) {
      try {
        return [System.Reflection.Assembly]::LoadFrom($candidate)
      } catch {
        return $null
      }
    }
  }

  return $null
})

$assembly = [System.Reflection.Assembly]::Load([System.IO.File]::ReadAllBytes($commandExe))
$containerType = $assembly.GetType('Command_Core.ScenContainer', $true)
$loadMethod = $containerType.GetMethod('LoadFromFile', [System.Reflection.BindingFlags]'Public,Static')
$xmlMethod = $containerType.GetMethod('GetScenarioObject_AsXML', [System.Reflection.BindingFlags]'Public,Instance')

if ($null -eq $loadMethod -or $null -eq $xmlMethod) {
  throw 'Required CMO ScenContainer methods were not found. The current CMO build may have changed internals.'
}

try {
  $container = $loadMethod.Invoke($null, [object[]]@([string]$cachedScenario))
} catch {
  $inner = Get-InnermostException $_.Exception
  if ((Test-IsLegacyCmanoPath $ScenarioPath) -and $inner.GetType().FullName -eq 'System.NullReferenceException') {
    $message = 'Modern ScenContainer.LoadFromFile cannot deserialize legacy CMANO scenario format.'
    Write-DecoderErrorSidecar 'decoderLegacyCmano' $message $_.Exception $false
    throw "decoderLegacyCmano: $message"
  }

  $message = "CMO ScenContainer.LoadFromFile failed: $($inner.Message)"
  Write-DecoderErrorSidecar 'decoderInvokeFailed' $message $_.Exception $true
  throw "decoderInvokeFailed: $message"
}

if ($null -eq $container) {
  Write-DecoderErrorSidecar 'decoderContainerNull' 'CMO ScenContainer.LoadFromFile returned null.' $null $true
  throw 'CMO ScenContainer.LoadFromFile returned null.'
}

try {
  $xml = [string]$xmlMethod.Invoke($container, [object[]]@())
} catch {
  $inner = Get-InnermostException $_.Exception
  if ((Test-IsLegacyCmanoPath $ScenarioPath) -and $inner.GetType().FullName -eq 'System.NullReferenceException') {
    $message = 'Modern ScenContainer.GetScenarioObject_AsXML cannot serialize legacy CMANO scenario format.'
    Write-DecoderErrorSidecar 'decoderLegacyCmano' $message $_.Exception $false
    throw "decoderLegacyCmano: $message"
  }

  $message = "CMO GetScenarioObject_AsXML failed: $($inner.Message)"
  Write-DecoderErrorSidecar 'decoderInvokeFailed' $message $_.Exception $true
  throw "decoderInvokeFailed: $message"
}

$isSupportedRoot = $false
if (-not [string]::IsNullOrWhiteSpace($xml)) {
  $trimmedXml = $xml.TrimStart()
  $isSupportedRoot = $trimmedXml.StartsWith('<Scenario') -or $trimmedXml.StartsWith('<ContentScenario')
}

if (-not $isSupportedRoot) {
  Write-DecoderErrorSidecar 'decoderNoXml' 'CMO internal loader did not return Scenario XML.' $null $true
  throw 'CMO internal loader did not return Scenario XML.'
}

$outDir = Split-Path -Parent $OutXml
if ($outDir) {
  New-Item -ItemType Directory -Force -Path $outDir | Out-Null
}

[System.IO.File]::WriteAllText($OutXml, $xml, [System.Text.Encoding]::UTF8)
$errorSidecar = "$OutXml.error.json"
if (Test-Path -LiteralPath $errorSidecar) {
  Remove-Item -LiteralPath $errorSidecar -Force
}

$title = ''
$titleMatch = [regex]::Match($xml, '<Title>(.*?)</Title>')
if ($titleMatch.Success) {
  $title = [System.Net.WebUtility]::HtmlDecode($titleMatch.Groups[1].Value)
}

Write-Output "Extracted Scenario XML"
Write-Output "Source: $ScenarioPath"
Write-Output "Output: $OutXml"
Write-Output "Title: $title"
Write-Output "XmlChars: $($xml.Length)"
if ($xml.TrimStart().StartsWith('<ContentScenario')) {
  Write-Output 'RootTag: ContentScenario'
} else {
  Write-Output 'RootTag: Scenario'
}
Write-Output "CacheCopy: $cachedScenario"
} finally {
  if ($cachedScenario -and (Test-Path -LiteralPath $cachedScenario)) {
    Remove-Item -LiteralPath $cachedScenario -Force -ErrorAction SilentlyContinue
  }
}
