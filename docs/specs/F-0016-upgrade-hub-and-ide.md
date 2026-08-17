# F-0016: Upgrade Antigravity Hub to v2.8.1 and Antigravity IDE to v2.5.5

**Type:** Enhancement
**Priority:** P1 (important)
**Status:** In Progress
**Requested by:** PO
**Date:** 2026-08-17

## Problem

The workstation currently runs Antigravity Hub v2.0.10 and Antigravity IDE v2.1.1. Newer stable releases of both tools are now available from official download distribution channels:
- Antigravity Hub v2.8.1 (`2.8.1-6512087774658560`)
- Antigravity IDE v2.5.5 (`2.5.5-4923483625488384`)

Additionally, while `07-apps.sh` had version-aware upgrade logic for Antigravity IDE (implemented in F-0009), the Antigravity Hub installation logic was still a one-time "if directory exists, skip" check. The Hub installer needs version-aware upgrade logic that detects the currently installed Hub version from `app.asar` (or `package.json`), backs up outdated versions, extracts the new release, updates symlinks and desktop entries, and cleans up old backups.

## Requirements

1. The system must update `IDE_URL` to point to the Antigravity IDE v2.5.5 release tarball (`https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/2.5.5-4923483625488384/linux-x64/Antigravity%20IDE.tar.gz`) and set `IDE_EXPECTED_VERSION="2.5.5"`.
2. The system must update `HUB_URL` to point to the Antigravity Hub v2.8.1 release tarball (`https://storage.googleapis.com/antigravity-public/antigravity-hub/2.8.1-6512087774658560/linux-x64/Antigravity.tar.gz`) and set `HUB_EXPECTED_VERSION="2.8.1"`.
3. The system must implement robust, version-aware install and upgrade logic for Antigravity Hub in `07-apps.sh`:
   - Inspect the installed Hub version from `resources/app.asar` or `package.json`.
   - If missing or version does not match `HUB_EXPECTED_VERSION`, backup the old install directory (e.g. `antigravity-hub.bak.<timestamp>`), download and extract the new tarball to `~/.local/share/antigravity-hub`, update symlink `~/.local/bin/antigravity-hub`, extract the tray icon, and deploy the `.desktop` file.
   - Clean up old Hub backups older than 7 days.
4. The system must update boot verification tests in `workstation-image/boot/10-tests.sh` to assert that Antigravity Hub is at v2.8.1 and Antigravity IDE is at v2.5.5.
5. The system must execute the upgrade on the live machine and verify that all test assertions in `10-tests.sh` pass cleanly.
6. The updated boot scripts must be synced to `/home/user/boot/` to satisfy persistence requirements across reboots.

## Acceptance Criteria

- [ ] `docs/specs/F-0016-upgrade-hub-and-ide.md` created with complete requirements and criteria.
- [ ] `docs/BACKLOG.md` updated with F-0016 entry under Milestone 1.
- [ ] `07-apps.sh` updated with `IDE_URL` (v2.5.5), `IDE_EXPECTED_VERSION="2.5.5"`, `HUB_URL` (v2.8.1), and `HUB_EXPECTED_VERSION="2.8.1"`.
- [ ] `07-apps.sh` version-aware upgrade logic implemented for Antigravity Hub with backup rotation and icon extraction.
- [ ] Live machine upgraded to Antigravity Hub v2.8.1 and Antigravity IDE v2.5.5.
- [ ] Updated boot scripts synced to `/home/user/boot/`.
- [ ] `10-tests.sh` updated to assert version == 2.8.1 for Hub and version == 2.5.5 for IDE.
- [ ] Test suite (`10-tests.sh`) passes cleanly with 0 FAIL.
- [ ] `docs/PROGRESS.md` and `docs/RELEASENOTES.md` updated.
- [ ] PR created against `main`.

## Out of Scope

- Antigravity CLI version upgrades (managed via `https://antigravity.google/cli/install.sh`).
- Modifying Sway workspace mappings or window rules.

## Dependencies

- F-0009 (Antigravity IDE version-aware installer)
- F-0136 (Antigravity IDE v2 workspace integration)
- F-0140 (Antigravity Hub icon extraction and desktop integration)

## Open Questions

- None.
