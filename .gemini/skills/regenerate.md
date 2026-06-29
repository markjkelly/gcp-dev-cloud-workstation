# /regenerate — Regenerate project files from settings

## Trigger

User invokes `/regenerate` to regenerate AGENTS.md and all agent/skill files from saved settings.

## Instructions

1. **Verify settings exist** — Check that the configuration settings exist (e.g., settings.json). If they do not exist, inform the user that no saved settings were found.
2. **Run regeneration** — Execute the team's regeneration script/tooling if configured.
   This should regenerate all workspace configuration files (AGENTS.md, agent definitions, skill files, docs templates).
3. **Restore tracking files** — After regeneration, restore project-specific tracking files from git so they are not overwritten:
   ```
   git checkout -- docs/BACKLOG.md docs/PROGRESS.md docs/RELEASENOTES.md
   ```
   If any of these files have uncommitted changes, warn the user before restoring.
4. **Report results** — List all files that were regenerated and confirm the tracking files were preserved.

## Project Context

- **Project:** Cloud Workstation
- **Agent Configuration Directory:** `.gemini/`
