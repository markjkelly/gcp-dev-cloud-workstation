# F-0009: Update Antigravity IDE to v2.1.1

**Type:** Enhancement
**Priority:** P1 (important)
**Status:** In Progress
**Requested by:** PO
**Date:** 2026-06-30

## Problem

The workstation ships with Antigravity IDE v2.0.4. Version 2.1.1 is now available with bug fixes and improvements. The current install logic in `07-apps.sh` is a simple "if directory exists, skip" check — it has no concept of version upgrades. If the IDE is already installed (any version), it will never be updated.

## Requirements

1. The system must update the IDE download URL to v2.1.1.
2. The system must implement version-aware upgrade logic that compares the installed version (from `product.json`) against the expected version.
3. The system must backup the old installation before upgrading, and clean up old backups after 7 days.
4. The system must add a boot test that verifies the installed IDE version matches the expected version.

## Acceptance Criteria

- [x] `IDE_URL` in `07-apps.sh` points to the v2.1.1 release tarball.
- [x] `IDE_EXPECTED_VERSION` constant is defined as `"2.1.1"`.
- [x] Version-aware logic: fresh install if missing, upgrade if version mismatch, skip if current.
- [x] Old install directory is backed up (renamed to `.bak.<timestamp>`) before upgrade.
- [x] Backups older than 7 days are cleaned up.
- [x] Existing wrapper script, .desktop file, and symlink creation logic is unchanged.
- [x] `10-tests.sh` contains a version check test for the IDE.
- [x] QA verified on `dev-workstation`: IDE upgraded from v2.0.4 → v2.1.1 successfully.

## Out of Scope

- Upgrading Antigravity Hub or CLI.
- Changing IDE launch flags or wrapper script logic.

## Dependencies

- F-0136 (initial IDE v2 installation)

## Open Questions

- None.
