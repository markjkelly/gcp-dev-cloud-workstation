# F-0017: Rearrange Workspaces

**Type:** Refactor
**Priority:** P1 (important)
**Status:** In Progress
**Requested by:** PO
**Date:** 2026-08-19

## Problem

The workstation has Antigravity IDE auto-launched on Workspace 1 and Antigravity Hub on Workspace 5. The user wishes to rearrange the workspaces on the workstation to focus on a new layout, where Workspace 1 hosts the Hub, Workspace 2 hosts VS Code (and is focused on boot), Workspace 3 hosts a foot terminal, Workspace 4 hosts Chrome, and workspaces 5-8 are empty. The Antigravity IDE v2 should be completely removed from auto-launch at boot and from the Sway configuration.

## Requirements

1. **Antigravity IDE v2**:
   - Completely remove from auto-launch at boot (in `workstation-image/boot/08-workspaces.sh`).
   - Completely remove from Sway configuration (in `workstation-image/configs/sway/config`), including window placement rules and any comments.
2. **Hub**:
   - Move to Workspace 1.
   - Auto-launch Hub at boot on Workspace 1 (in `08-workspaces.sh`). Update the command flags and wait logic to match how it was launched on Workspace 1 before, or adapt it cleanly.
   - Update Sway window placement rule: `for_window [app_id="^antigravity$"] move container to workspace number 1` (in `workstation-image/configs/sway/config`).
   - Update keybindings: `$mod+h` and `$super+h` should focus Workspace 1. Keep Workspace 5 keybindings mapped to `$mod+u` and `$super+u` but it switches to an empty Workspace 5.
   - Update `workstation-image/scripts/hub-restart` and `workstation-image/scripts/hub-start` to switch/output Workspace 1 instead of Workspace 5.
3. **VS Code**:
   - Focused after boot. Make sure the boot script focuses Workspace 2 at the very end of the autostart sequence.
4. **Persistence Requirements (Non-Negotiable)**:
   - Update `workstation-image/configs/sway/config`.
   - Update `~/.config/home-manager/sway-config` to match the repo config exactly.
   - Copy the updated `08-workspaces.sh` script to `~/boot/08-workspaces.sh`.
   - Copy the updated `hub-restart` and `hub-start` scripts to `~/.local/bin/hub-restart` and `~/.local/bin/hub-start`.
5. **Test Coverage**:
   - Update `workstation-image/boot/10-tests.sh` to:
     - Remove tests checking for Antigravity IDE.
     - Update checks for Hub placement and keybindings to target Workspace 1.
     - Update checks for `hub-restart` and `hub-start` to verify they switch to Workspace 1.
     - Add any other assertions for the new workspace mapping/focus.
     - Run `bash /home/user/boot/10-tests.sh` manually and verify 100% of the tests pass.

## Acceptance Criteria

- [ ] Antigravity IDE v2 auto-launch and Sway configuration (window rules, comments) are completely removed.
- [ ] Antigravity Hub is moved to Workspace 1, auto-launched on Workspace 1, window rule updated to move it to Workspace 1, and `$mod+h`/`$super+h` focus Workspace 1.
- [ ] Workspace 5 keybindings are `$mod+u`/`$super+u` and focus Workspace 5 (which is empty).
- [ ] `hub-restart` and `hub-start` scripts target Workspace 1 instead of Workspace 5.
- [ ] VS Code is focused after boot (at the end of the boot scripts sequence).
- [ ] Repos and home configs / scripts are updated on disk to guarantee persistence.
- [ ] Test suite `10-tests.sh` updated and all tests pass on the workstation.

## Out of Scope

- Modifying the underlying versions or logic of Hub, IDE, or other apps beyond the workspace assignment and autostart focus.

## Dependencies

- None

## Open Questions

- None
