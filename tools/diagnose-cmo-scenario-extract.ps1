param(
  [Parameter(Mandatory = $true, Position = 0)]
  [string]$ScenarioPath,

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

function Write-Diag([string]$Name, [object]$Value) {
  Write-Output ("{0}: {1}" -f $Name, $Value)
}

$ScenarioPath = Resolve-FullPath $ScenarioPath
Write-Diag 'ScenarioPath' $ScenarioPath

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

$scenarioInfo = Get-Item -LiteralPath $ScenarioPath
Write-Diag 'ScenarioBytes' $scenarioInfo.Length
Write-Diag 'ScenarioLastWriteUtc' $scenarioInfo.LastWriteTimeUtc.ToString('o')

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
Write-Diag 'CacheCopy' $cachedScenario

$topText = [System.IO.File]::ReadAllText($ScenarioPath)
$title = [regex]::Match($topText, '<ScenTitle(?:\s[^>]*)?>([\s\S]*?)</ScenTitle>', 'IgnoreCase')
$db = [regex]::Match($topText, '<DBVersion(?:\s[^>]*)?>([\s\S]*?)</DBVersion>', 'IgnoreCase')
$build = [regex]::Match($topText, '<BuildNumber(?:\s[^>]*)?>([\s\S]*?)</BuildNumber>', 'IgnoreCase')
$compressed = [regex]::Match($topText, '<Scenario_Compressed(?:\s[^>]*)?>([\s\S]*?)</Scenario_Compressed>', 'IgnoreCase')
$wrapperTitle = ''
if ($title.Success) {
  $wrapperTitle = [System.Net.WebUtility]::HtmlDecode($title.Groups[1].Value.Trim())
}
$wrapperDbVersion = ''
if ($db.Success) {
  $wrapperDbVersion = $db.Groups[1].Value.Trim()
}
$wrapperBuildNumber = ''
if ($build.Success) {
  $wrapperBuildNumber = $build.Groups[1].Value.Trim()
}
$compressedChars = 0
if ($compressed.Success) {
  $compressedChars = ($compressed.Groups[1].Value -replace '\s+', '').Length
}
Write-Diag 'WrapperTitle' $wrapperTitle
Write-Diag 'WrapperDbVersion' $wrapperDbVersion
Write-Diag 'WrapperBuildNumber' $wrapperBuildNumber
Write-Diag 'CompressedPresent' $compressed.Success
Write-Diag 'CompressedChars' $compressedChars

foreach ($preload in @('LZ4.dll', 'Microsoft.IO.RecyclableMemoryStream.dll', 'Newtonsoft.Json.dll')) {
  $preloadPath = Join-Path $CmoRoot $preload
  if (Test-Path -LiteralPath $preloadPath) {
    [void][System.Reflection.Assembly]::LoadFrom($preloadPath)
    Write-Diag 'Preloaded' $preload
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
Write-Diag 'ContainerType' $containerType.FullName
Write-Diag 'HasLoadFromFile' ($null -ne $loadMethod)
Write-Diag 'HasGetScenarioObject_AsXML' ($null -ne $xmlMethod)

if ($null -eq $loadMethod -or $null -eq $xmlMethod) {
  throw 'Required CMO ScenContainer methods were not found.'
}

$container = $loadMethod.Invoke($null, [object[]]@([string]$cachedScenario))
Write-Diag 'ContainerNull' ($null -eq $container)
if ($null -eq $container) {
  return
}

Write-Diag 'ContainerRuntimeType' $container.GetType().FullName
$xmlObject = $xmlMethod.Invoke($container, [object[]]@())
Write-Diag 'XmlObjectNull' ($null -eq $xmlObject)
$xmlObjectType = ''
if ($null -ne $xmlObject) {
  $xmlObjectType = $xmlObject.GetType().FullName
}
Write-Diag 'XmlObjectType' $xmlObjectType

$xml = [string]$xmlObject
Write-Diag 'XmlLength' ($xml.Length)
Write-Diag 'XmlStartsWithScenario' ($xml.StartsWith('<Scenario'))
Write-Diag 'XmlPreview' ($xml.Substring(0, [Math]::Min(500, $xml.Length)) -replace "`r|`n", ' ')
