# Antigravity Setup & Onboarding Guide

## 1. Setup Architecture
1. **Central Repository**: Maintain this repository in a stable directory (e.g., `C:\AI\antigravity-ai-development-ecosystem`).
2. **Project Target**: Create or identify your application directory (e.g., `C:\Projects\MyApplication`).
3. **Profile Installation**: Run `install-profile.ps1` to populate `.agents/skills/` and copy `AGENTS.md`.
4. **Project Declaration**: Copy `PROJECT_SKILLS.md` into the target project root and configure active skills.
5. **Open in Antigravity**: Antigravity automatically discovers skills situated inside `.agents/skills/`.

---

## 2. Installation Command Example
```powershell
cd C:\AI\antigravity-ai-development-ecosystem
.\scripts\install-profile.ps1 -ProjectPath "C:\Projects\MyApplication" -Profile website
Copy-Item "PROJECT_SKILLS.md" "C:\Projects\MyApplication\PROJECT_SKILLS.md"
```

---

## 3. Verifying Discovery in Antigravity
When you launch Antigravity on your target folder:
1. Prompt Antigravity:
   > *"Inspect AGENTS.md, PROJECT_SKILLS.md and .agents/skills/. List discovered skills and summarize active project instructions."*
2. Verify that Antigravity lists only the skills installed for your active profile.
3. Review the proposed plan before authorizing code implementation.

---

## 4. Integrity Validation
Before committing or updating skills, execute the validator:
```powershell
.\scripts\validate-skills.ps1
```
Or with Python:
```bash
python scripts/validate-skills.py
```
Both `skills/` (source) and `.agents/skills/` (workspace) will be verified for valid frontmatter, non-empty workflows, and manifest integrity.
