# F-0015: Upgrade Antigravity Suite (CLI, IDE, Hub) to Latest Versions

**Type:** Enhancement
**Priority:** P1 (important)
**Status:** In Progress
**Requested by:** PO
**Date:** 2026-08-17

## Problem

The Antigravity development tools suite on Cloud Workstation consists of the Antigravity CLI (`agy`), Antigravity IDE (`antigravity-ide`), and Antigravity Hub (`antigravity-hub`).

1. **Antigravity CLI**: The official release manifest at `https://antigravity-cli-auto-updater-974169037036.us-central1.run.app/manifests/linux_amd64.json` publishes version `1.1.13`. However, the CLI bootstrap script (`curl -fsSL https://antigravity.google/cli/install.sh | bash`) inspects `$BINARY_PATH` (`~/.local/bin/agy`) and terminates early if the binary exists, skipping updates. As a result, workstations remain on older CLI versions (such as `1.1.12`) on subsequent boots despite `07-apps.sh` running.
2. **Antigravity Hub**: The Hub installation logic in `07-apps.sh` only checked if `~/.local/share/antigravity-hub` existed. Unlike the IDE (which has version-aware detection and backup handling), the Hub lacked version-aware upgrade logic and could not self-upgrade when a new version or URL was specified.
3. **Antigravity IDE**: IDE is configured for v2.1.1. Verification and tests must ensure all three Antigravity tools have cohesive version-aware lifecycle management, testing, and persistence across boots.

## Requirements

1. **CLI Upgrade Awareness in `07-apps.sh`**:
   - Query the release manifest (or compare installed `agy` version against the latest manifest version) during boot.
   - If an update is available or if `~/.local/bin/agy` needs upgrading, remove the existing binary before running `install.sh` so the installer performs the complete download, sha512 verification, extraction, and installation of the latest version (v1.1.13+).
   - Gracefully handle network unavailability (fail-open / keep installed binary if offline).
2. **Hub Version-Aware Upgrade in `07-apps.sh`**:
   - Define `HUB_EXPECTED_VERSION="2.0.10"`.
   - Inspect the installed Hub version from `app.asar` if the directory exists.
   - If version matches, skip re-download. If version is older or missing, back up old directory to `antigravity-hub.bak.<epoch>` and download/extract the new version.
   - Automatically clean up old Hub backups older than 7 days.
3. **IDE Version Management**:
   - Verify `IDE_EXPECTED_VERSION="2.1.1"` in `07-apps.sh` and ensure existing version-aware upgrade logic functions properly.
4. **Integration Test Suite Updates (`10-tests.sh`)**:
   - Assert `agy` version is >= `1.1.13`.
   - Assert Antigravity Hub installed version matches `2.0.10`.
   - Assert Antigravity IDE installed version matches `2.1.1`.
   - Ensure all boot integration tests pass with 0 failures.
5. **Persistence**:
   - Deploy updated scripts to `~/boot/` and ensure idempotency on reboot and re-runs.

## Acceptance Criteria

- [ ] `07-apps.sh` successfully upgrades `agy` to latest manifest version (v1.1.13) and does not get blocked by `install.sh` early-exit.
- [ ] `07-apps.sh` supports version-aware detection, backup, and upgrade for Antigravity Hub v2.0.10.
- [ ] `07-apps.sh` maintains version-aware upgrade logic for Antigravity IDE v2.1.1.
- [ ] `10-tests.sh` verifies `agy` version >= 1.1.13, Hub version 2.0.10, and IDE version 2.1.1.
- [ ] `bash workstation-image/boot/10-tests.sh` executes with 0 failures and 0 warnings.
- [ ] `~/boot/` scripts and repo source are synchronized and identical.

## Out of Scope

- Changing Sway workspace placement rules (IDE on ws1, Terminal on ws3, Chrome on ws4, Hub on ws5).
- Modifying IDE / Hub wrapper arguments (`--ozone-platform=wayland`).

## Dependencies

- F-0009 (Antigravity IDE v2.1.1 version-aware upgrade)
- F-0003 (Hub workspace 5 launcher alignment)

## Open Questions

- None.
