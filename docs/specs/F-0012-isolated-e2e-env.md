# F-0012: Isolated E2E Testing Environment

**Type:** Enhancement
**Priority:** P0 (critical)
**Status:** Draft
**Requested by:** PO
**Date:** 2026-07-01

## Problem

Testing the `gcp-dev-cloud-workstation` repository within a shared GCP project (`prj-c-workstations-j68o`) poses a high risk to other developers' workloads. A recent incident almost resulted in the deletion of a shared cluster. Furthermore, corrupted environments (e.g., failed Nix installations) can leave stale resources that affect subsequent test runs. To ensure reliable and safe testing, all E2E validation must occur in a dedicated, isolated project that can be completely torn down without impacting production or shared resources.

## Requirements

1. Create a dedicated GCP project (e.g., `prj-c-ws-e2e`) specifically for E2E testing.
2. The isolated environment must include its own VPC, Cloud NAT, Workstation Cluster, and Artifact Registry.
3. Update `ws.sh` to make teardown safer by default, specifically protecting the cluster from accidental deletion in shared environments.
4. Parameterize all scripts to easily target the new E2E project.
5. Demonstrate a successful E2E flow (setup, config deployment, verification, and teardown) in the isolated environment.

## Acceptance Criteria

- [ ] Dedicated E2E project created and configured.
- [ ] `ws.sh` updated with `--include-cluster` flag; default teardown no longer deletes clusters.
- [ ] Successful workstation deployment in the new project.
- [ ] Successful configuration deployment (`deploy-configs.sh`) in the new project.
- [ ] Desktop environment (VNC) verified as accessible and functional in the new project.
- [ ] Full teardown of the E2E project completed successfully with no orphaned resources.

## Out of Scope

- Migration of existing production workstations to the new project.
- Permanent infrastructure for the E2E project (it should be treated as disposable).

## Dependencies

- F-0010 (Align Terraform and Setup Script)
- Access to create/manage a new GCP project in the Argolis org.

## Open Questions

- Should the E2E project be created via the Foundation pipeline or manually?
- Should the `ws.sh` script automatically detect if it's in a "production" project and add extra guards?
