# Release Notes — Cloud Workstation

## v1.1.5 — Dynamic Boot Sync & Repository Renaming (2026-06-30)

### Added
- **Dynamic Repository Cloning** — Automatically clones `gcp-dev-cloud-workstation` repository on workstation boot if directory is missing.
- **SSH-to-HTTPS Fallback** — Attempts SSH clone if keys exist, falling back to HTTPS clone.
- **Ownership Correction** — Automatically resets ownership of the cloned repository to user UID/GID `1000:1000`.

### Changed
- **Repository Rename** — Re-targeted boot sync script and integration tests from `cloud-workstation` to `gcp-dev-cloud-workstation`.
- **Antigravity CLI Verification** — Updated integration tests to assert correct name and paths for `agy` CLI binary instead of outdated `antigravity-cli`.

## v1.1.0 — Tooling Cleanups & Deployment Simplification (2026-06-29)

### Added
- **Cody CLI** — Integrated as the standard AI CLI companion instead of Claude Code.
- **Antigravity CLI** — Verified presence in AI tools.

### Removed
- **Unused IDEs** — Removed Cursor, Zed, and IntelliJ IDEA configurations and keybindings.
- **Unused AI Tools** — Removed Claude Code, Gemini CLI, Codex CLI, pi-coding-agent, Aider, and OpenCode.
- **Profiles** — Removed the `--profile` flag option from deployment scripts. All deployments now configure the remaining base tools by default.
- **Helper Scripts** — Removed `claude-tmux` and `tmux-debug` scripts.

## v1.0.0 — Initial Repository Porting (2026-06-29)

### Added
- **Unified Agent Instruction File** (`AGENTS.md`) — Combined infrastructure context with the development pipeline instructions, rules, and roles.
- **Gemini Agent and Skill Configurations** — Ported definitions from `.claude` to `.gemini` folder, re-targeting to the `gemini-3.5-flash` model.
- **Reference Documentation** — Copied over `SETUP.md`, `STARTUP_SCRIPTS.md`, and `PIPELINE.md`.
- **Project Tracking Templates** — Initialized clean templates for `BACKLOG.md`, `PROGRESS.md`, and `RELEASENOTES.md`, and added PM spec template `TEMPLATE.md`.
