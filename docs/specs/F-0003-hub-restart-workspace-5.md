# F-0003: Align Hub Launchers to Workspace 5

**Type:** Bug
**Priority:** P1
**Status:** Done
**Requested by:** PO
**Date:** 2026-06-30

## Problem

The Antigravity Hub is supposed to reside on Workspace 5 (`ws5`) under Sway window management rules, but the manual launcher scripts `hub-restart` and `hub-start` contain legacy Workspace 1 (`ws1`) references, which forces active display focus to `ws1` instead of `ws5` when executed.

## Requirements

1. `hub-restart` must switch to Workspace 5 (`swaymsg workspace number 5`) and report workspace 5 on success.
2. `hub-start` must switch to Workspace 5 (`swaymsg workspace number 5`) and report workspace 5 on success.
3. Integration tests must verify `hub-restart` and `hub-start` contain Workspace 5 references.

## Acceptance Criteria

- [x] Running `hub-restart` switches active viewport/workspace to Workspace 5.
- [x] Running `hub-start` switches active viewport/workspace to Workspace 5.
- [x] Integration tests in `10-tests.sh` pass.

## Out of Scope

- Modifying actual window placement rules in Sway (already correctly set to Workspace 5).
- Restoring automatic startup on boot (intentionally disabled in F-0124).

## Dependencies

- None

## Open Questions

- None
