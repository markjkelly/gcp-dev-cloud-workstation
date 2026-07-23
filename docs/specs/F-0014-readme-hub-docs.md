# F-0014: Antigravity Hub Documentation in README

**Type:** Enhancement
**Priority:** P1
**Status:** In Progress
**Requested by:** PO
**Date:** 2026-07-23

## Problem

The workstation's `README.md` documentation lacks detailed instructions explaining how to launch and manage the preinstalled Antigravity Hub desktop application. Users connecting via Chrome Remote Desktop need clear guidance on using the `hub-restart` utility script to safely launch the Hub without encountering Wayland display context or blank-screen rendering issues.

## Requirements

1. **Introductory Paragraph Update:**
   - Modify the introductory paragraph in `README.md` to change "Antigravity Hub integration" to "Antigravity Hub", explicitly emphasizing that it is included and preinstalled out-of-the-box.

2. **What's Included Table Update:**
   - Update the "AI Developer Tools" row in the "What's Included" table to list "Antigravity Hub, Antigravity CLI" instead of just "Antigravity CLI".

3. **Desktop & Workspace Access Section Extension:**
   - Add a dedicated subsection titled `Antigravity Hub (hub-restart)` directly below `Chrome Remote Desktop (CRD) Setup`.
   - Explain that Antigravity Hub is preinstalled but deliberately not auto-launched on system boot to prevent blank-screen rendering failures before an active user session/display is established.
   - Explain how to start the Hub once connected via Chrome Remote Desktop by switching to Workspace 3 (terminal) and executing `hub-restart`.
   - Document what `hub-restart` accomplishes: terminates stuck Hub processes, clears singleton locks, relaunches the Hub inside the active Wayland session, and places the Hub window onto Workspace 5 (`ws5`) where display focus is set.

4. **README Audit Validation:**
   - Run `python3 /home/user/.gemini/config/skills/beautify-github-readme/scripts/audit_readme.py /home/user/dev/git/gcp-dev-cloud-workstation/README.md` to verify markdown hierarchy, formatting, and zero errors/warnings.

5. **Automated Boot Tests:**
   - Update `workstation-image/boot/10-tests.sh` to include a test check verifying that `README.md` references the `hub-restart` command.
   - Execute `10-tests.sh` to ensure all 190+ boot integration tests pass cleanly.

6. **Documentation & Release Tracking:**
   - Mark F-0014 as `done` in `docs/BACKLOG.md`.
   - Record session details in `docs/PROGRESS.md` under Session 13.
   - Update `docs/RELEASENOTES.md` releasing version `v1.3.2`.

## Acceptance Criteria

- [ ] `README.md` introductory paragraph specifies "Antigravity Hub" as preinstalled.
- [ ] `README.md` "What's Included" table lists "Antigravity Hub, Antigravity CLI" under AI Developer Tools.
- [ ] `README.md` includes `### Antigravity Hub (hub-restart)` subsection under `Desktop & Workspace Access` with complete rationale, execution steps, and process lifecycle details.
- [ ] `audit_readme.py` passes with zero errors/warnings on `README.md`.
- [ ] `workstation-image/boot/10-tests.sh` contains a passing test verifying `README.md` references `hub-restart`.
- [ ] All boot tests in `10-tests.sh` pass.
- [ ] `docs/BACKLOG.md`, `docs/PROGRESS.md`, and `docs/RELEASENOTES.md` are fully updated for `v1.3.2`.
- [ ] Branch `feature/readme-hub-docs` pushed to `origin` and `internal` remotes with PRs created against `main`.

## Out of Scope

- Modifying the behavior of the `hub-restart` binary itself or Sway window management logic.

## Dependencies

- F-0003 (Align Hub Launchers to Workspace 5)

## Open Questions

- None.
