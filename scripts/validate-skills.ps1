<#
.SYNOPSIS
  validate-skills.ps1 - Native PowerShell validator for Antigravity AI Development Ecosystem.
.DESCRIPTION
  Validates:
  1. Both skills/ and .agents/skills/ directories (if present).
  2. Presence of SKILL.md in every skill directory.
  3. Valid YAML frontmatter (enclosed by ---).
  4. Skill 'name' attribute matches folder name exactly.
  5. Uniqueness of skill names (no duplicate definitions).
  6. Presence and validity of 'description' attribute.
  7. Non-empty markdown body with instructions.
  8. Cross-reference consistency with registry/skills-registry.json.
  9. Cross-reference consistency with profiles/*.json manifests.
#>

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $PSScriptRoot

$Errors = [System.Collections.Generic.List[string]]::new()
$Warnings = [System.Collections.Generic.List[string]]::new()
$TotalValidated = 0

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " Antigravity AI Development Ecosystem Validator   " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

function Validate-SkillDirectory {
    param(
        [string]$Path,
        [string]$Label
    )

    if (-not (Test-Path $Path)) {
        $Errors.Add("[$Label] Directory does not exist: $Path")
        return 0
    }

    $Folders = Get-ChildItem -Path $Path -Directory | Sort-Object Name
    if ($Folders.Count -eq 0) {
        $Errors.Add("[$Label] No skill folders found in $Path")
        return 0
    }

    $SeenNames = [System.Collections.Generic.HashSet[string]]::new()
    $Count = 0

    foreach ($Folder in $Folders) {
        $FolderName = $Folder.Name
        $SkillFile = Join-Path $Folder.FullName "SKILL.md"

        # 1. Missing file check
        if (-not (Test-Path $SkillFile)) {
            $Errors.Add("[$Label] $($FolderName) - Missing SKILL.md")
            continue
        }

        $RawText = Get-Content $SkillFile -Raw -Encoding utf8
        if ([string]::IsNullOrWhiteSpace($RawText)) {
            $Errors.Add("[$Label] $($FolderName) - SKILL.md is completely empty")
            continue
        }

        # 2. Frontmatter validity
        if ($RawText -match "^---\s*`r?`n([\s\S]*?)`r?`n---\s*`r?`n([\s\S]*)$") {
            $FmText = $Matches[1]
            $BodyText = $Matches[2].Trim()

            # 3. Name check
            $Name = $null
            if ($FmText -match "(?m)^name:\s*(.+)$") {
                $Name = $Matches[1].Trim().Trim('"').Trim("'")
            }

            if ([string]::IsNullOrWhiteSpace($Name)) {
                $Errors.Add("[$Label] $($FolderName) - Missing 'name' in frontmatter")
            } elseif ($Name -ne $FolderName) {
                $Errors.Add("[$Label] $($FolderName) - Frontmatter name '$Name' does not match folder name '$FolderName'")
            }

            # 4. Duplicate name check
            if ($Name) {
                if ($SeenNames.Contains($Name)) {
                    $Errors.Add("[$Label] $($FolderName) - Duplicate skill name '$Name' detected in $Label")
                } else {
                    $null = $SeenNames.Add($Name)
                }
            }

            # 5. Description check
            $Desc = $null
            if ($FmText -match "(?m)^description:\s*(.+)$") {
                $Desc = $Matches[1].Trim().Trim('"').Trim("'")
            }

            if ([string]::IsNullOrWhiteSpace($Desc)) {
                $Errors.Add("[$Label] $($FolderName) - Missing or empty 'description' in frontmatter")
            } elseif ($Desc.Length -lt 15) {
                $Warnings.Add("[$Label] $($FolderName) - Description is very short ($($Desc.Length) chars)")
            }

            # 6. Body check
            if ($BodyText.Length -lt 50) {
                $Errors.Add("[$Label] $($FolderName) - SKILL.md body is empty or too short (< 50 chars)")
            }

            $Count++
        } else {
            $Errors.Add("[$Label] $($FolderName) - Invalid or missing YAML frontmatter (must start and end with ---)")
        }
    }

    return $Count
}

# 1. Validate skills/
$SkillsPath = Join-Path $RepoRoot "skills"
$Count1 = Validate-SkillDirectory -Path $SkillsPath -Label "skills/"
$TotalValidated += $Count1
Write-Host "[*] skills/ (source): $Count1 skill folders inspected."

# 2. Validate .agents/skills/
$AgentsSkillsPath = Join-Path $RepoRoot ".agents/skills"
if (Test-Path $AgentsSkillsPath) {
    $Count2 = Validate-SkillDirectory -Path $AgentsSkillsPath -Label ".agents/skills/"
    $TotalValidated += $Count2
    Write-Host "[*] .agents/skills/ (workspace): $Count2 skill folders inspected."
} else {
    $Warnings.Add("[.agents/skills/] Directory does not exist yet. Run install-profile.ps1 to populate it.")
}

# 3. Cross-validate Registry and Profiles
$RegistryPath = Join-Path $RepoRoot "registry/skills-registry.json"
if (-not (Test-Path $RegistryPath)) {
    $Errors.Add("Missing registry/skills-registry.json")
} else {
    try {
        $RegData = Get-Content $RegistryPath -Raw | ConvertFrom-Json
        foreach ($Item in $RegData.skills) {
            $RelPath = $Item.path
            $SkillId = $Item.id
            if (-not (Test-Path (Join-Path $RepoRoot $RelPath))) {
                $Errors.Add("[Registry] Referenced skill path does not exist: $RelPath (id: $SkillId)")
            }
            if (-not (Test-Path (Join-Path $SkillsPath $SkillId))) {
                $Errors.Add("[Registry] Included skill '$SkillId' missing in skills/ directory")
            }
        }
    } catch {
        $Errors.Add("[Registry] Failed to parse skills-registry.json: $_")
    }
}

$ProfilesPath = Join-Path $RepoRoot "profiles"
if (Test-Path $ProfilesPath) {
    $ProfileFiles = Get-ChildItem -Path $ProfilesPath -Filter "*.json" | Sort-Object Name
    foreach ($PFile in $ProfileFiles) {
        try {
            $PData = Get-Content $PFile.FullName -Raw | ConvertFrom-Json
            foreach ($Sid in $PData.skills) {
                if (-not (Test-Path (Join-Path $SkillsPath "$Sid\SKILL.md"))) {
                    $Errors.Add("[Profile: $($PFile.Name)] References missing skill '$Sid'")
                }
            }
        } catch {
            $Errors.Add("[Profile: $($PFile.Name)] JSON parse error: $_")
        }
    }
}
Write-Host "[*] Registry & Profiles cross-validation completed."
Write-Host "--------------------------------------------------"

if ($Warnings.Count -gt 0) {
    Write-Host "`n[WARNINGS] ($($Warnings.Count)):" -ForegroundColor Yellow
    foreach ($W in $Warnings) {
        Write-Host "  - $W" -ForegroundColor Yellow
    }
}

if ($Errors.Count -gt 0) {
    Write-Host "`n[FAILURES] ($($Errors.Count) error(s) found):" -ForegroundColor Red
    foreach ($E in $Errors) {
        Write-Host "  [X] $E" -ForegroundColor Red
    }
    Write-Host "`nValidation FAILED." -ForegroundColor Red
    exit 1
}

Write-Host "`nSUCCESS: All $TotalValidated skill instances and manifests validated cleanly." -ForegroundColor Green
exit 0
