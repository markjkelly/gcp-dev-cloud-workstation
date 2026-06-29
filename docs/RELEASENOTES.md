# Release Notes — Cloud Workstation

## v1.1.3 — IAM Binding Target Resource Fix (2026-06-29)

### Fixed
- **Workstation User IAM Binding** — Changed the target resource for `roles/workstations.user` from the workstation config to the workstation instance itself in `cloud-build-setup.sh`, fixing an `INVALID_ARGUMENT` error during Cloud Build setup.

## v1.1.2 — IAM Binding Bugfix (2026-06-29)

### Fixed
- **Cloud Build SSH Timeout** — Replaced invalid `gcloud workstations configs add-iam-policy-binding` commands with a python helper function to correctly modify workstation IAM policies, fixing the SSH timeout during workstation setup.

## v1.1.1 — E2E Test & Setup Script Fixes (2026-06-29)

### Added
- **HTTPS Git Clone Fallback** — Added logic in `scripts/ws.sh` to dynamically convert `git@github.com:` SSH clone URLs to `https://github.com/` format to allow Cloud Build to clone the repository natively without requiring SSH keys.

### Changed
- **Default Region** — Updated default region and `_REGION` fallback in `scripts/ws.sh` to `us-central1`.

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
