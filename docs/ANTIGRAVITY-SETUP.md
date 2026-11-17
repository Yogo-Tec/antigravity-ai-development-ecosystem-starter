# Antigravity setup

1. Clone the central repository to a stable local folder.
2. Create a project folder.
3. Run the Windows PowerShell profile installer.
4. Open the target folder in Antigravity.
5. Ask Antigravity to inspect AGENTS.md and `.agents/skills/`, then list the skills it actually discovers.
6. Review the plan before implementation.

Example:
```powershell
git clone https://github.com/YOUR-USERNAME/antigravity-ai-development-ecosystem.git C:\AI\antigravity-ai-development-ecosystem
cd C:\AI\antigravity-ai-development-ecosystem
.\scripts\install-profile.ps1 -ProjectPath C:\Projects\MyWebsite -Profile website
```

This kit copies selected skills into the project instead of relying on unverified `skills.json` inheritance. Global discovery paths, custom agent formats and MCP config locations must be checked against current official Antigravity documentation.
