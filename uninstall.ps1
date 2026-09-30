param([string]$Name = "jev")
$ErrorActionPreference = "Stop"
try { claude mcp remove $Name --scope user | Out-Null } catch {}
$rule = Join-Path $HOME ".claude\rules\jev.md"
if (Test-Path $rule) { Remove-Item $rule -Force }
Write-Host "Removed Jev MCP '$Name' and $rule"
