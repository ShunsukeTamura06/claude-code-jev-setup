param(
  [string]$ConfigFile = "$PSScriptRoot\config.env"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $ConfigFile)) {
  throw "Config not found: $ConfigFile. Copy config.example.env to config.env and edit JEV_MCP_URL."
}

$config = @{}
Get-Content $ConfigFile | ForEach-Object {
  $line = $_.Trim()
  if ($line -and -not $line.StartsWith("#") -and $line.Contains("=")) {
    $parts = $line.Split("=", 2)
    $config[$parts[0].Trim()] = $parts[1].Trim()
  }
}

$url = $config["JEV_MCP_URL"]
if (-not $url) { throw "JEV_MCP_URL is required" }
$name = $config["JEV_MCP_NAME"]
if (-not $name) { $name = "jev" }
$header = $config["JEV_MCP_HEADER"]

if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
  throw "Claude Code CLI ('claude') was not found in PATH."
}

$rulesDir = Join-Path $HOME ".claude\rules"
New-Item -ItemType Directory -Force -Path $rulesDir | Out-Null
Copy-Item "$PSScriptRoot\rules\jev.md" (Join-Path $rulesDir "jev.md") -Force

try { claude mcp remove $name --scope user | Out-Null } catch {}

$args = @("mcp", "add", "--transport", "http", "--scope", "user", $name, $url)
if ($header) { $args += @("--header", $header) }
& claude @args

Write-Host ""
Write-Host "Jev integration installed."
Write-Host "Rule: $rulesDir\jev.md"
Write-Host "MCP:  $name -> $url"
Write-Host "Verify with: claude mcp list"
