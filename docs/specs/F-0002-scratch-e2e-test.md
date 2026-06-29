# F-0002: Scratch E2E Integration Test & Default Region Update

**Type:** Feature
**Priority:** P0 (critical)
**Status:** In Progress
**Requested by:** PO
**Date:** 2026-06-29

## Problem

We need to verify the end-to-end workstation creation and configuration process by building a fresh workstation in the GCP project `prj-c-workstations-j68o` in region `us-central1`. 
To ensure this runs smoothly, we need to:
1. Change the default region in setup configurations to `us-central1`.
2. Dynamically convert the repository origin URL in `scripts/ws.sh` from SSH format (`git@github.com:...`) to HTTPS (`https://github.com/` format). This allows Cloud Build to clone the public repository successfully without requiring SSH key setup or credentials.

## Requirements

1. **Default Region Update:**
   - In `scripts/ws.sh`, change default `REGION` variable from `us-west1` to `us-central1`.
   - In `scripts/ws.sh`, update default `_REGION` substitution in the inline Cloud Build YAML configuration to `us-central1`.

2. **Repository URL Conversion:**
   - Add logic in `scripts/ws.sh` immediately after `REPO_URL` parsing to dynamically rewrite SSH git urls (`git@github.com:markjkelly/...`) to HTTPS format (`https://github.com/markjkelly/...`).
   - Leave regular HTTPS origin URLs unchanged.

3. **E2E Validation:**
   - Run the integration test setup command (`ws.sh setup`) in the target project `prj-c-workstations-j68o`.
   - Monitor the Cloud Build job to completion.
   - Verify that the workstation is created successfully.
   - Any issues identified during setup must be tracked as GitHub issues in `markjkelly/gcp-dev-cloud-workstation`.

## Acceptance Criteria

- [ ] `scripts/ws.sh` default region is `us-central1`.
- [ ] `scripts/ws.sh` Cloud Build substitution default `_REGION` is `us-central1`.
- [ ] If `REPO_URL` starts with `git@github.com:`, it is converted to `https://github.com/` prefix dynamically in `scripts/ws.sh`.
- [ ] The command `bash scripts/ws.sh setup -p prj-c-workstations-j68o` successfully submits a Cloud Build job.
- [ ] Cloud Build job completes successfully and provisions the workstation resources in the target project `prj-c-workstations-j68o` within `us-central1`.
- [ ] Found issues, if any, are reported as GitHub issues in the repo.

## Out of Scope

- Modifying the underlying machine config or profile modules.
- Automatically setting up SSH keys inside the Cloud Build environment.

## Dependencies

- F-0001 (Port agent context, skills, and docs)

## Open Questions

- None.
