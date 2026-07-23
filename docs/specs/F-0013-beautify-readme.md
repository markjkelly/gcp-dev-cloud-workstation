# F-0013: Beautify README

**Type:** Enhancement
**Priority:** P1
**Status:** In Progress
**Requested by:** PO
**Date:** 2026-07-23

## Problem

The repository README lacks visual polish and a cohesive design system matching the workstation's Tokyo Night aesthetic. A high-quality hero SVG, structured layout, clear tables, and verified Markdown hierarchy are needed to make the repository project-native, clear, and compelling.

## Requirements

1. **Design visual system & hero SVG:**
   - Create `assets/readme/hero.svg` (1200x380 SVG viewBox, width 100%).
   - Theme: Tokyo Night palette (`#1a1b26`, `#7aa2f7`, `#bb9af7`, `#7dcfff`, `#9ece6a`, `#c0caf5`).
   - Include solid dark background fill for universal dark/light GitHub rendering.
   - Left section: Project title, tagline, badge tokens (GCP, Sway/Wayland, Nix, 190+ Boot Tests).
   - Right section: Container bootstrap workflow diagram (Nix Persist -> Services -> Boot Scripts -> 190+ Tests passing).
2. **Redesign README.md:**
   - Center hero SVG at top of README.
   - Craft a compelling introductory paragraph highlighting WHY users should choose this environment over standard cloud instances, detailing out-of-the-box (OOTB) capabilities: pre-configured Sway (Wayland) tiling desktop, Nix persistence across container rebuilds, Antigravity Hub, `agy` CLI, and pre-installed VS Code.
   - Restructure sections: Overview/Description, How It Works, Quick Start, Keyboard Shortcuts (table), Included Architecture/Tools (table), Language Version Management, Automated Boot Tests, Troubleshooting, Teardown.
   - Ensure `python3 /home/user/.gemini/config/skills/beautify-github-readme/scripts/audit_readme.py` passes all checks.
3. **Automated Boot Tests:**
   - Add test assertion in `workstation-image/boot/10-tests.sh` ensuring `assets/readme/hero.svg` exists and `README.md` embeds `hero.svg`.
4. **Documentation & Release Tracking:**
   - Update `docs/BACKLOG.md` to track F-0013.
   - Log session details in `docs/PROGRESS.md`.
   - Record version entry in `docs/RELEASENOTES.md`.

## Acceptance Criteria

- [ ] `assets/readme/hero.svg` is authored with solid dark background fill (`#1a1b26`) and technical Tokyo Night styling.
- [ ] `README.md` introductory paragraph highlights OOTB value proposition (Sway, Nix persistence, Antigravity Hub, `agy` CLI, VS Code).
- [ ] `README.md` embeds hero image and features updated structure, tables, and commands.
- [ ] `python3 /home/user/.gemini/config/skills/beautify-github-readme/scripts/audit_readme.py` passes with zero errors/warnings.
- [ ] `workstation-image/boot/10-tests.sh` includes test checks for `hero.svg` and README embed.
- [ ] `docs/BACKLOG.md`, `docs/PROGRESS.md`, and `docs/RELEASENOTES.md` updated.
- [ ] Git branch `feature/beautify-readme` pushed and PR created against `main`.

## Out of Scope

- Changing GCP setup scripts or infrastructure provisioning code beyond boot tests and README updates.

## Dependencies

- None.

## Open Questions

- None.
