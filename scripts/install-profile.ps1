param(
  [Parameter(Mandatory=$true)][string]$ProjectPath,
  [Parameter(Mandatory=$true)][ValidateSet("core","website","ecommerce","mobile","community","office-club","plugin","all")][string]$Profile
)
$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $PSScriptRoot
$Manifest = Get-Content (Join-Path $RepoRoot "profiles/$Profile.json") -Raw | ConvertFrom-Json
if (-not (Test-Path $ProjectPath)) { New-Item -ItemType Directory -Path $ProjectPath -Force | Out-Null }
$ProjectPath = (Resolve-Path $ProjectPath).Path
$Target = Join-Path $ProjectPath ".agents/skills"
New-Item -ItemType Directory -Path $Target -Force | Out-Null
foreach ($Skill in $Manifest.skills) {
  $Source = Join-Path $RepoRoot "skills/$Skill"
  if (-not (Test-Path (Join-Path $Source "SKILL.md"))) { throw "Missing or invalid skill: $Skill" }
  $Destination = Join-Path $Target $Skill
  if (Test-Path $Destination) { Write-Host "Preserving existing: $Destination" -ForegroundColor Yellow; continue }
  Copy-Item $Source $Destination -Recurse
  Write-Host "Installed: $Skill" -ForegroundColor Green
}
$Master = Join-Path $RepoRoot "AGENTS.md"
$ProjectAgents = Join-Path $ProjectPath "AGENTS.md"
if (-not (Test-Path $ProjectAgents)) { Copy-Item $Master $ProjectAgents }
else { Write-Host "Existing AGENTS.md preserved; merge manually if needed." -ForegroundColor Yellow }
Write-Host "Profile '$Profile' installed. Open the project in Antigravity and verify skill discovery."
