# F-0015: Environment and Identity Configuration via Git-ignored .env file

**Type:** Refactor/Enhancement
**Priority:** P1
**Status:** Draft
**Requested by:** PO
**Date:** 2026-07-23

## Problem

Environment-specific configuration and developer identity settings (such as GCP project IDs, developer git identity, workstation cluster names, and workstation instance names) are currently hardcoded, derived via implicit heuristics, or passed via CLI arguments. This introduces risk of targeting the wrong GCP environment (e.g. live vs test clusters), creates configuration drift, and lacks a uniform fail-fast mechanism when environment variables are missing.

## Requirements

1. **Git-Ignored `.env` Configuration File**:
   - Establish a `.env` file at the root of the repository as the explicit single source of truth for environment and developer identity configuration.
   - Enforce `.env` inclusion in `.gitignore` to prevent committing local environment or identity settings.
   - Provide a checked-in template file `.env.example` containing descriptive variable names, default schema, and usage comments.

2. **Required Environment & Identity Variables**:
   - `GCP_PROJECT_ID`: Target GCP project ID for infrastructure operations and Cloud Build execution.
   - `DEVELOPER_GIT_NAME`: Developer's Git author display name (e.g., "Mark Kelly").
   - `DEVELOPER_GIT_EMAIL`: Developer's Git author email address.
   - `LIVE_CLUSTER_ID`: Identifier for the live workstation cluster (e.g., `main-cluster`).
   - `LIVE_WORKSTATION_ID`: Identifier for the live workstation instance (e.g., `sway-workstation`).
   - `TEST_CLUSTER_ID`: Identifier for the test workstation cluster (e.g., `workstation-cluster`).
   - `TEST_WORKSTATION_ID`: Identifier for the test workstation instance (e.g., `dev-workstation`).

3. **No Heuristics or Guesses**:
   - Remove dynamic fallback heuristics, default fallback strings, or implicit domain/user guesses in workstation management scripts (`scripts/ws.sh`, `scripts/cloud-build-setup.sh`, etc.).
   - All management and setup scripts must explicitly source configuration from `.env` or process environment.

4. **Fail-Fast Abort Rules**:
   - Infrastructure and management scripts must validate the presence of `.env` and all required variables before executing any GCP or build actions.
   - If `.env` is missing or any required variable (`GCP_PROJECT_ID`, `DEVELOPER_GIT_NAME`, `DEVELOPER_GIT_EMAIL`, `LIVE_CLUSTER_ID`, `TEST_CLUSTER_ID`, etc.) is empty or unset, scripts must abort immediately with exit code 1 and display actionable remediation instructions to copy `.env.example` to `.env` and populate required fields.

## Acceptance Criteria

- [ ] Product specification `docs/specs/F-0015-env-identity-config.md` drafted and approved.
- [ ] `.env.example` created with required schema (`GCP_PROJECT_ID`, `DEVELOPER_GIT_NAME`, `DEVELOPER_GIT_EMAIL`, `LIVE_CLUSTER_ID`, `LIVE_WORKSTATION_ID`, `TEST_CLUSTER_ID`, `TEST_WORKSTATION_ID`).
- [ ] Management scripts updated to source `.env` and execute fail-fast check rules.
- [ ] Implicit heuristics and fallbacks removed from `ws.sh` and `cloud-build-setup.sh`.
- [ ] Boot integration tests added in `10-tests.sh` to verify `.env` loading and fail-fast abort logic.

## Out of Scope

- Editing `AGENTS.md` (deferred to implementation phase).
- Modifying main workstation application code or GCP resources during the spec & backlog phase.

## Dependencies

- F-0001 (Port agent context, skills, and docs)
- F-0010 (Align Terraform and Setup Script for Full E2E Coverage)

## Open Questions

- None.
