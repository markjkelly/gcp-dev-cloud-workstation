# F-0007: Fix Boot Test Failures on Fresh Workstation

**Type:** Bug
**Priority:** P0 (critical)
**Status:** In Progress
**Requested by:** PO
**Date:** 2026-06-30

## Problem

When a fresh workstation is built from scratch via `cloud-build-setup.sh`, several boot tests in `10-tests.sh` fail due to:

1. **Race condition:** `ws-boot-tests.service` (10-tests.sh) runs before `ws-app-updates.service` (07-apps.sh) completes, causing tests that depend on app installation to fail intermittently.
2. **Missing fonts:** Custom developer fonts (FiraCodeiScript, CaskaydiaCove, CascadiaCode) are not deployed during `cloud-build-setup.sh`, so `fc-list` checks in 10-tests.sh fail on fresh builds.
3. **Stale assertions:** F-0125 cleanup tests assert the absence of IDE dirs that were intentionally removed in F-0136, causing false FAILs.
4. **Over-deletion guards fail on fresh builds:** Anti-over-delete checks for Hub userData and agy CLI directories FAIL on fresh workstations where those apps haven't been installed yet.
5. **Duplicate font directory:** `dev-fonts/dev-fonts/` is a stale nested duplicate of FiraCode fonts that should be removed.

These issues are tracked as GitHub issues #15, #16, #17, #18.

## Requirements

1. The system must ensure `ws-boot-tests.service` runs only after both `ws-autolaunch.service` AND `ws-app-updates.service` have completed.
2. The system must deploy custom developer fonts during `cloud-build-setup.sh` Step 12 and rebuild the font cache.
3. The system must rebuild the font cache in `04-fonts.sh` after copying fonts.
4. The system must remove stale F-0125 cleanup assertions from `10-tests.sh` that test for side-effects of code removed in F-0136.
5. The system must change anti-over-delete guards to SKIP when the checked application hasn't been installed yet on the workstation.
6. The system must remove the stale `dev-fonts/dev-fonts/` duplicate directory.

## Acceptance Criteria

- [x] `ws-boot-tests.service` has `After=ws-autolaunch.service ws-app-updates.service`
- [x] `cloud-build-setup.sh` Step 12 deploys fonts and runs `fc-cache -f`
- [x] `04-fonts.sh` rebuilds font cache after font copy
- [x] Stale F-0125 IDE cleanup assertions removed from `10-tests.sh`
- [x] Anti-over-delete guards SKIP when application not installed
- [x] `dev-fonts/dev-fonts/` directory deleted from repo
- [x] Boot tests produce 0 FAIL on fresh workstation

## Out of Scope

- Modifying the font list or adding new fonts
- Changes to the live `sway-workstation` (test-only targeting `dev-workstation`)

## Dependencies

- F-0002 (Scratch E2E Infrastructure)

## Open Questions

- None
