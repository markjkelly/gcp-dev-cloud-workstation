# F-0010: Align Terraform and Setup Script for Full E2E Coverage

**Type:** Enhancement
**Priority:** P1 (important)
**Status:** In Progress
**Requested by:** PO
**Date:** 2026-06-30

## Problem

The Terraform configuration and the `cloud-build-setup.sh` script target different resource names. Terraform uses `main-cluster`, `sway-config`, and `sway-workstation` (matching the live workstation), while `cloud-build-setup.sh` correctly targets `workstation-cluster`, `ws-config`, and `dev-workstation` (the test workstation). This divergence means:

1. **Terraform can't be used for E2E testing** — running `terraform apply` would modify the live workstation instead of the test workstation.
2. **Resource names use "sway" prefix** — this is an implementation detail that shouldn't leak into infrastructure resource names.
3. **Required GCP APIs are not declared** — Terraform doesn't enable the APIs it depends on, causing failures on fresh projects.
4. **Snapshot policy not in setup script** — `cloud-build-setup.sh` doesn't create disk snapshot policies, leaving fresh builds without backup protection.
5. **README only documents Terraform path** — no documentation for the `ws.sh setup` automated path.

## Requirements

1. Terraform `variables.tf` defaults must target `workstation-cluster`, `ws-config`, and `dev-workstation`.
2. Terraform resource names must use generic names (not `sway_*`).
3. Terraform must declare and enable required GCP APIs (`workstations`, `artifactregistry`, `compute`, `cloudscheduler`).
4. `cloud-build-setup.sh` must create a disk snapshot policy matching the Terraform-defined policy.
5. README must document both setup paths (ws.sh and Terraform).
6. All internal references across `main.tf`, `scheduler.tf`, and `outputs.tf` must be updated consistently.

## Acceptance Criteria

- [x] `terraform validate` passes with the updated configuration.
- [x] `terraform plan` shows resources targeting `workstation-cluster`, `ws-config`, `dev-workstation`.
- [x] Service account renamed from `sway-workstation-sa` to `workstation-sa`.
- [x] All `sway_*` Terraform resource names replaced with generic names.
- [x] `google_project_service` resources added for required APIs.
- [x] `cloud-build-setup.sh` creates snapshot policy (idempotent).
- [x] README documents both setup paths.
- [x] Scheduler job renamed from `stop-sway-workstation-8pm-central` to `stop-workstation-8pm-central`.

## Out of Scope

- Migrating Terraform state for existing deployments (users must `terraform state mv` manually).
- Modifying the live workstation (`main-cluster`/`sway-config`/`sway-workstation`).
- Running `terraform apply` or `ws.sh setup` as part of this change.

## Dependencies

- F-0002 (Scratch E2E Integration Test — established the test workstation target)

## Open Questions

- None — all changes are additive or rename-only with no behavioral impact on existing deployments.
