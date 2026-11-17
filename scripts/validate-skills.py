#!/usr/bin/env python3
"""
validate-skills.py - Validation utility for Antigravity AI Development Ecosystem.

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
"""

from pathlib import Path
import json
import re
import sys

def parse_frontmatter(content: str):
    """Parses simple YAML frontmatter delimited by ---."""
    match = re.match(r"^---\s*\r?\n(.*?)\r?\n---\s*\r?\n(.*)$", content, re.DOTALL)
    if not match:
        return None, None
    raw_fm, body = match.group(1), match.group(2)
    fm = {}
    current_key = None
    for line in raw_fm.splitlines():
        line_clean = line.rstrip()
        if not line_clean or line_clean.startswith("#"):
            continue
        key_val = re.match(r"^([a-zA-Z0-9_-]+):\s*(.*)$", line_clean)
        if key_val:
            current_key = key_val.group(1)
            fm[current_key] = key_val.group(2).strip().strip("\"'")
        elif current_key and line.startswith(("  ", "\t")):
            fm[current_key] += " " + line.strip().strip("\"'")
    return fm, body.strip()

def validate_directory(dir_path: Path, dir_label: str):
    """Validates all skill directories inside a target folder."""
    errors = []
    warnings = []
    seen_names = set()
    validated_count = 0

    if not dir_path.exists():
        errors.append(f"[{dir_label}] Directory does not exist: {dir_path}")
        return errors, warnings, validated_count

    skill_folders = [p for p in sorted(dir_path.iterdir()) if p.is_dir()]
    if not skill_folders:
        errors.append(f"[{dir_label}] No skill folders found in {dir_path}")
        return errors, warnings, validated_count

    for folder in skill_folders:
        folder_name = folder.name
        skill_file = folder / "SKILL.md"

        # 1. Missing file check
        if not skill_file.exists():
            errors.append(f"[{dir_label}] {folder_name}: Missing SKILL.md")
            continue

        try:
            content = skill_file.read_text(encoding="utf-8")
        except Exception as e:
            errors.append(f"[{dir_label}] {folder_name}: Failed to read SKILL.md ({e})")
            continue

        # 2. Frontmatter validity
        fm, body = parse_frontmatter(content)
        if fm is None:
            errors.append(f"[{dir_label}] {folder_name}: Invalid or missing YAML frontmatter (must start and end with ---)")
            continue

        # 3. Name check & folder matching
        name = fm.get("name")
        if not name:
            errors.append(f"[{dir_label}] {folder_name}: Missing 'name' in frontmatter")
        elif name != folder_name:
            errors.append(f"[{dir_label}] {folder_name}: Frontmatter name '{name}' does not match folder name '{folder_name}'")

        # 4. Duplicate name check
        if name:
            if name in seen_names:
                errors.append(f"[{dir_label}] {folder_name}: Duplicate skill name '{name}' detected in {dir_label}")
            else:
                seen_names.add(name)

        # 5. Description check
        desc = fm.get("description")
        if not desc or not desc.strip():
            errors.append(f"[{dir_label}] {folder_name}: Missing or empty 'description' in frontmatter")
        elif len(desc.strip()) < 15:
            warnings.append(f"[{dir_label}] {folder_name}: Description is very short ({len(desc.strip())} chars)")

        # 6. Body check
        if not body or len(body) < 50:
            errors.append(f"[{dir_label}] {folder_name}: SKILL.md body is empty or too short (< 50 chars)")

        validated_count += 1

    return errors, warnings, validated_count

def validate_registry_and_profiles(root: Path):
    """Validates skills-registry.json and profiles/*.json."""
    errors = []
    skills_dir = root / "skills"

    # Check skills-registry.json
    registry_file = root / "registry" / "skills-registry.json"
    if not registry_file.exists():
        errors.append("Missing registry/skills-registry.json")
    else:
        try:
            data = json.loads(registry_file.read_text(encoding="utf-8"))
            included = data.get("skills", [])
            for item in included:
                skill_id = item.get("id")
                rel_path = item.get("path")
                if not (root / rel_path).exists():
                    errors.append(f"[Registry] Referenced skill path does not exist: {rel_path} (id: {skill_id})")
                if not (skills_dir / skill_id).exists():
                    errors.append(f"[Registry] Included skill '{skill_id}' missing in skills/ directory")
        except Exception as e:
            errors.append(f"[Registry] Failed to parse skills-registry.json: {e}")

    # Check profiles/*.json
    profiles_dir = root / "profiles"
    if profiles_dir.exists():
        for pfile in sorted(profiles_dir.glob("*.json")):
            try:
                pdata = json.loads(pfile.read_text(encoding="utf-8"))
                for sid in pdata.get("skills", []):
                    if not (skills_dir / sid / "SKILL.md").exists():
                        errors.append(f"[Profile: {pfile.name}] References missing skill '{sid}'")
            except Exception as e:
                errors.append(f"[Profile: {pfile.name}] JSON parse error: {e}")

    return errors

def main():
    repo_root = Path(__file__).resolve().parents[1]
    all_errors = []
    all_warnings = []
    total_validated = 0

    print("==================================================")
    print(" Antigravity AI Development Ecosystem Validator   ")
    print("==================================================")

    # 1. Validate skills/ (Source Library)
    skills_path = repo_root / "skills"
    errs, warns, count = validate_directory(skills_path, "skills/")
    all_errors.extend(errs)
    all_warnings.extend(warns)
    total_validated += count
    print(f"[*] skills/ (source): {count} skill folders inspected.")

    # 2. Validate .agents/skills/ (Workspace Discovery)
    agents_skills_path = repo_root / ".agents" / "skills"
    if agents_skills_path.exists():
        errs, warns, count = validate_directory(agents_skills_path, ".agents/skills/")
        all_errors.extend(errs)
        all_warnings.extend(warns)
        total_validated += count
        print(f"[*] .agents/skills/ (workspace): {count} skill folders inspected.")
    else:
        all_warnings.append("[.agents/skills/] Directory does not exist yet. Run install-profile.ps1 to populate it.")

    # 3. Cross-validate Registry and Profiles
    reg_errs = validate_registry_and_profiles(repo_root)
    all_errors.extend(reg_errs)
    print(f"[*] Registry & Profiles cross-validation completed.")

    print("--------------------------------------------------")

    if all_warnings:
        print(f"\n[WARNINGS] ({len(all_warnings)}):")
        for w in all_warnings:
            print(f"  - {w}")

    if all_errors:
        print(f"\n[FAILURES] ({len(all_errors)} error(s) found):")
        for e in all_errors:
            print(f"  [X] {e}")
        print("\nValidation FAILED.")
        sys.exit(1)

    print(f"\nSUCCESS: All {total_validated} skill instances and manifests validated cleanly.")
    sys.exit(0)

if __name__ == "__main__":
    main()
