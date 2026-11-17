from pathlib import Path
import re, sys
root = Path(__file__).resolve().parents[1] / "skills"
errors = []
folders = [p for p in root.iterdir() if p.is_dir()]
for folder in folders:
    f = folder / "SKILL.md"
    if not f.exists():
        errors.append(f"{folder.name}: missing SKILL.md")
        continue
    text = f.read_text(encoding="utf-8")
    m = re.match(r"^---\s*\n(.*?)\n---", text, re.S)
    if not m:
        errors.append(f"{folder.name}: invalid/missing frontmatter")
        continue
    if not re.search(r"^name:\s*" + re.escape(folder.name) + r"\s*$", m.group(1), re.M):
        errors.append(f"{folder.name}: name must match folder")
    if not re.search(r"^description:\s*.+", m.group(1), re.M):
        errors.append(f"{folder.name}: description is required")
if errors:
    print("\n".join(errors)); sys.exit(1)
print(f"Validated {len(folders)} skill folders.")
