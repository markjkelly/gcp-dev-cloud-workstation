# F-0005: Remove Proprietary Font Reference

**Type:** Refactor
**Priority:** P1 (important)
**Status:** In Progress
**Requested by:** PO
**Date:** 2026-06-30

## Problem

The workstation configuration contains references to proprietary fonts (specifically "Operator Mono"). To avoid any potential licensing or distribution issues, we must remove all references to Operator Mono from the codebase and setup scripts. We should replace the verification check with a check for the custom fonts we actually deploy (FiraCodeiScript and CaskaydiaCove).

## Requirements

1. **Remove Operator Mono from cloud build setup:**
   - Edit `scripts/cloud-build-setup.sh` to remove the Operator Mono font deployment block.
   - Update verification block in `scripts/cloud-build-setup.sh` to look for custom developer fonts (FiraCodeiScript or CaskaydiaCove) instead of Operator Mono.

2. **Refactor Font Setup Boot Script:**
   - Edit `workstation-image/boot/04-fonts.sh` to remove the specific `operator mono` check and replace it with a generic directory/file existence check in `$FONT_DST`.

3. **Clean Up Terminal Configuration:**
   - Edit `workstation-image/configs/foot/foot.ini` to remove any comments or configuration lines referencing Operator Mono.

## Acceptance Criteria

- [ ] Product spec created at `docs/specs/F-0005-remove-proprietary-fonts.md`.
- [ ] `scripts/cloud-build-setup.sh` has the Operator Mono deployment block removed.
- [ ] `scripts/cloud-build-setup.sh` setup verification updated to check for custom developer fonts (FiraCodeiScript / CaskaydiaCove).
- [ ] `workstation-image/boot/04-fonts.sh` checks for directory/file presence in `$FONT_DST` instead of searching for `operator mono`.
- [ ] `workstation-image/configs/foot/foot.ini` contains no references to Operator Mono.
- [ ] Branch pushed, and PR created against `main` (not merged).

## Out of Scope

- Setting up or provisioning actual new fonts beyond what is already part of the repository's `dev-fonts` package.

## Dependencies

- F-0001 (Port agent context, skills, and docs)

## Open Questions

- None.
