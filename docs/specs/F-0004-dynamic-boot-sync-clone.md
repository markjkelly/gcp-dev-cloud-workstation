# F-0004: Dynamic Boot Sync Repo Clone

**Type:** Enhancement
**Priority:** P1 (important)
**Status:** In Progress
**Requested by:** PO
**Date:** 2026-06-30

## Problem

Currently, `09-sync.sh` relies on a hardcoded repository directory name `cloud-workstation`. However, the repository has been renamed/ported to `gcp-dev-cloud-workstation`. Additionally, if the repository directory is missing (for example on a clean VM launch or home directory reset), the sync script will fail because it does not attempt to clone the repository. Furthermore, integration tests in `10-tests.sh` are still asserting references to `cloud-workstation` and outdated `antigravity-cli` checks.

## Requirements

1. **Rename Repository Directory**: Change hardcoded repository references from `cloud-workstation` to `gcp-dev-cloud-workstation` in `09-sync.sh` and `10-tests.sh`.
2. **Dynamic Git Clone**: In `09-sync.sh`, if `${REPO_DIR}` is missing under `/home/user/`, clone `https://github.com/markjkelly/gcp-dev-cloud-workstation` dynamically.
3. **Robust Fallback Cloning**:
   - Check if SSH key (`/home/user/.ssh/id_rsa` or similar, or just check SSH connectivity/key existence) exists and attempt SSH clone first: `git@github.com:markjkelly/gcp-dev-cloud-workstation.git`.
   - Fall back to HTTPS clone if SSH is unavailable or fails: `https://github.com/markjkelly/gcp-dev-cloud-workstation.git`.
4. **Ownership Fix**: Correct ownership of the cloned repository to `user:user` (UID/GID `1000:1000`) recursively using `chown -R 1000:1000`.
5. **Update Test Paths & CLI Checks**:
   - In `10-tests.sh`, update `REPO_PATH` from `cloud-workstation` to `gcp-dev-cloud-workstation`.
   - In `10-tests.sh`, update `antigravity-cli` checks to check for the correct `agy` executable on the `PATH` and verify relevant configuration files.

## Acceptance Criteria

- [ ] `09-sync.sh` uses `gcp-dev-cloud-workstation` as the repository name.
- [ ] If `/home/user/gcp-dev-cloud-workstation` is missing on boot, `09-sync.sh` clones it successfully.
- [ ] The clone process tries SSH first if keys exist, falling back to HTTPS.
- [ ] Cloned files are owned by `1000:1000`.
- [ ] `10-tests.sh` references `gcp-dev-cloud-workstation` and asserts `agy` command works correctly.
- [ ] All tests in `10-tests.sh` run and pass.

## Out of Scope

- Setting up SSH keys on the workstation automatically.
- Merging branches or tags automatically (handled manually by PO).

## Dependencies

- F-0002 (Scratch E2E Integration Test)
