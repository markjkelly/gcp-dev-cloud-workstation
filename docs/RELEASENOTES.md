# Release Notes — Cloud Workstation

## v1.3.2 — Antigravity Hub Documentation in README (2026-07-23)

### Added
- **Antigravity Hub Subsection** — Added `### Antigravity Hub (hub-restart)` subsection under `Desktop & Workspace Access` in `README.md` explaining the rationale for not auto-launching on boot, step-by-step usage of `hub-restart` from Workspace 3 terminal, and process lifecycle management (process termination, singleton lock clearing, Wayland display attachment on `:20`, and automatic placement onto Workspace 5 with display focus).
- **Boot Test Verification** — Added test check in `10-tests.sh` verifying that `README.md` references the `hub-restart` command.

### Changed
- **Out-of-the-Box Antigravity Hub Highlight** — Updated `README.md` introductory paragraph to change "Antigravity Hub integration" to "Antigravity Hub", emphasizing its preinstalled OOTB presence.
- **What's Included Table Update** — Updated "AI Developer Tools" in `README.md` to explicitly list "Antigravity Hub, Antigravity CLI".

## v1.3.1 — Beautify README (2026-07-23)

### Added
- **Tokyo Night Hero SVG** — Created `assets/readme/hero.svg` (1200x380 SVG viewBox) featuring Tokyo Night color palette, solid dark `#1a1b26` background fill, and a container bootstrap workflow schematic.
- **Audit Compliance** — Added `<title>` and alt attribute compatibility verified by `audit_readme.py`.
- **Boot Integration Tests** — Added automated assertions in `10-tests.sh` to verify `hero.svg` existence and `README.md` image embed link.

### Changed
- **README Redesign** — Re-architected `README.md` structure with centered hero SVG, detailed bootstrap pipeline breakdown, Path A / Path B quick start instructions, Sway keyboard shortcuts table, architecture overview table, language version management details, boot test verification guide, and teardown instructions.
- **Value Proposition & OOTB Focus** — Updated the introductory paragraph of `README.md` to clearly answer WHY users should choose this environment over standard cloud VMs, explicitly detailing out-of-the-box (OOTB) capabilities: pre-configured Sway (Wayland) tiling desktop, Nix store persistence, Antigravity Hub, `agy` CLI, and pre-installed VS Code.
- **Optimized Section Placement** — Re-ordered `README.md` to place "What's Included" immediately below the main introductory paragraph, placing it ABOVE "How It Works" for instant technical component discovery.

## v1.3.0 — Align Terraform and Setup Script for Full E2E Coverage (2026-06-30)


### Changed
- **Terraform Variable Defaults** — Updated `cluster_id` from `main-cluster` → `workstation-cluster`, `workstation_config_id` from `sway-config` → `ws-config`, `workstation_id` from `sway-workstation` → `dev-workstation`. Both Terraform and `cloud-build-setup.sh` now target the same test workstation by default.
- **Generic Resource Names** — Renamed all `sway_*` Terraform resource identifiers to generic names (`workstation`, `main`, `workstation_sa_ar_reader`, `scheduler_user`, `stop_workstation`). The "sway" prefix was an implementation detail that shouldn't appear in infrastructure resource names.
- **Service Account** — Renamed from `sway-workstation-sa` / `Sway Workstation VM Service Account` to `workstation-sa` / `Workstation VM Service Account`.
- **Scheduler Job** — Renamed from `stop-sway-workstation-8pm-central` to `stop-workstation-8pm-central`.
- **Output Renamed** — `sway_service_account_email` → `workstation_service_account_email`.
- **README Setup Paths** — Added Setup Paths section documenting Path A (`ws.sh setup`, fully automated) and Path B (Terraform + Cloud Build).

### Added
- **API Enablement** — Added `google_project_service` resources for `workstations.googleapis.com`, `artifactregistry.googleapis.com`, `compute.googleapis.com`, and `cloudscheduler.googleapis.com` with `depends_on` chains. Terraform can now bootstrap from a completely fresh project.
- **Snapshot Policy in Setup Script** — Added Step 18b to `cloud-build-setup.sh` creating a `workstation-home-daily-snapshots` disk snapshot schedule policy (daily at 04:00, 7-day retention) and attaching it to workstation disks. Both operations are idempotent.

### Migration Note
- Existing Terraform users with state referencing the old resource names must run `terraform state mv` to map old names to new ones before applying. For example: `terraform state mv google_service_account.sway_workstation google_service_account.workstation`.

## v1.2.1 — Update Antigravity IDE to v2.1.1 (2026-06-30)

### Changed
- **Antigravity IDE v2.1.1** — Updated IDE download URL from v2.0.4 to v2.1.1 (`2.1.1-6123990880747520`).
- **Version-Aware Upgrade Logic** — Replaced simple directory-exists check with intelligent version comparison. On each boot, `07-apps.sh` reads `ideVersion` from `product.json` and compares against the expected version. Fresh install if missing, backup + re-download if version mismatch, skip if current.
- **Automatic Backup & Cleanup** — Old IDE installations are backed up as `.bak.<epoch>` before upgrade. Backups older than 7 days are automatically cleaned up.

### Fixed
- **Version Field Correction** — Uses `ideVersion` field from `product.json` (not `version`, which tracks the upstream VS Code engine version) for accurate IDE version detection.

### Added
- **Boot Test: IDE Version Check** — New F-0009 test in `10-tests.sh` verifies the installed IDE version matches the expected version on every boot.

## v1.2.0 — Fix Boot Test Failures on Fresh Workstation (2026-06-30)

### Fixed
- **Systemd Race Condition** — `ws-boot-tests.service` now waits for both `ws-autolaunch.service` AND `ws-app-updates.service` before running `10-tests.sh`, preventing test failures caused by apps not yet installed. (Closes #15)
- **Font Deployment on Fresh Builds** — `cloud-build-setup.sh` Step 12 now deploys CascadiaCode, CaskaydiaCove, and FiraCodeiScript fonts to `~/boot/fonts/` and runs `fc-cache -f` so custom fonts appear in `fc-list` immediately. Font verification upgraded from `test_warn` to `test_fail`. (Closes #16)
- **Font Cache Rebuild** — Added `fc-cache -f` fallback in `04-fonts.sh` that works without Nix profile being sourced.
- **Stale F-0125 Test Assertions** — Removed 4 IDE cleanup assertions that tested for side-effects of cleanup code intentionally removed in F-0136. (Closes #17)
- **Anti-Over-Delete Guards** — Hub userData and agy CLI directory guards now SKIP instead of FAIL when the application hasn't been installed yet on the workstation. agy CLI config check accepts both `~/.gemini/agy` and `~/.gemini/antigravity-cli` paths. (Closes #18)

### Removed
- **Duplicate Font Directory** — Deleted stale `dev-fonts/dev-fonts/` nested duplicate of FiraCode fonts.

## v1.1.4 — Align Hub Launchers to Workspace 5 (2026-06-30)

### Changed
- **Hub Launchers Alignment** — Updated `hub-restart` and `hub-start` utility scripts to switch Sway focus to Workspace 5 (`ws5`) instead of Workspace 1 (`ws1`) upon launch, matching the Sway window placement rule.
- **Integration Test Coverage** — Added assertions in `10-tests.sh` to verify both `hub-restart` and `hub-start` contain Workspace 5 references.

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
## v1.1.5 — Dynamic Boot Sync & Repository Renaming (2026-06-30)

### Added
- **Dynamic Repository Cloning** — Automatically clones `gcp-dev-cloud-workstation` repository on workstation boot if directory is missing.
- **SSH-to-HTTPS Fallback** — Attempts SSH clone if keys exist, falling back to HTTPS clone.
- **Ownership Correction** — Automatically resets ownership of the cloned repository to user UID/GID `1000:1000`.

### Changed
- **Repository Rename** — Re-targeted boot sync script and integration tests from `cloud-workstation` to `gcp-dev-cloud-workstation`.
- **Antigravity CLI Verification** — Updated integration tests to assert correct name and paths for `agy` CLI binary instead of outdated `antigravity-cli`.
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
