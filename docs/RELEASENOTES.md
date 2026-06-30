# Release Notes — Cloud Workstation

## v1.1.6 — Remove Proprietary Fonts (2026-06-30)

### Changed
- **Fonts Verification** — Replaced proprietary Operator Mono font checks with verification for deployed open-source custom developer fonts (FiraCodeiScript and CaskaydiaCove).
- **Fonts Setup Boot Script** — Updated boot/04-fonts.sh to use generic directory/file existence checking.

### Removed
- **Operator Mono** — Removed proprietary font deployment block and comments.

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
