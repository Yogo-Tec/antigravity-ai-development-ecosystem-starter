# Antigravity AI Development Ecosystem

Central, modular, human-controlled library of Agent Skills, project instructions, profiles, workflows and vetted resources for Google Antigravity.

## Windows quick start
1. Create a private GitHub repository named `antigravity-ai-development-ecosystem`.
2. Upload/push this starter kit and clone it to a stable location, e.g. `C:\AI\antigravity-ai-development-ecosystem`.
3. Run:
   `.\scripts\install-profile.ps1 -ProjectPath "C:\Projects\MyWebsite" -Profile website`
4. Open the target project in Antigravity. Ask it to inspect `AGENTS.md` and `.agents/skills/`, list discovered skills, and prepare a plan before implementation.

Profiles: core, website, ecommerce, mobile, community, office-club, plugin, all.

The central Git repository is the source of truth. The installer copies only selected skills into each project's `.agents/skills/`. This avoids depending on unverified manifest inheritance or symlink behavior.

Antigravity configuration conventions can change. Verify global skill paths, custom-agent formats, MCP configuration and other features against current official documentation before enabling them.

Review third-party skills, licenses, dependencies and scripts before execution. Ask before system-wide installs, paid services, external data sharing, destructive changes, protected-branch pushes and production deployment.
