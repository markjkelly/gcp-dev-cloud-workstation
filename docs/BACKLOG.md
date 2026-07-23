# Project Backlog — Cloud Workstation

**Maintained by:** TPM
**Last updated:** 2026-06-30

---

## How to Read This Backlog

- **ID:** Unique feature identifier (`F-0001`, `F-0002`, etc.) — sequential across all milestones, never reused
- **Priority:** P0 (critical path), P1 (important), P2 (nice to have)
- **Status:** `backlog` | `in-progress` | `in-review` | `done` | `blocked` | `superseded`
- **Owner:** Assigned team member
- **Branch:** Git feature branch
- **Dependencies:** Other feature IDs that must complete first
- **Feedback:** Review notes, blockers, decisions — updated as work progresses

---

## Milestone 1: Initial Setup

| ID | Feature | Spec | Priority | Status | Owner | Branch | Dependencies | Feedback |
|----|---------|------|----------|--------|-------|--------|--------------|----------|
| F-0001 | Port agent context, skills, and docs | — | P0 | done | SWE-1 | main | — | Initial port from private cloud-workstation repository |
| F-0002 | Scratch E2E Integration Test | docs/specs/F-0002-scratch-e2e-test.md | P0 | done | PE | feature/scratch-e2e-test | F-0001 | Implemented python helper to avoid invalid gcloud add-iam-policy-binding commands |
| F-0003 | Align Hub Launchers to Workspace 5 | docs/specs/F-0003-hub-restart-workspace-5.md | P1 | done | SWE-1 | feature/hub-restart-workspace-5 | F-0002 | Legacy Workspace 1 references forced focus to ws1 instead of ws5 when run |
| F-0004 | Dynamic Boot Sync Repo Clone | docs/specs/F-0004-dynamic-boot-sync-clone.md | P1 | done | SWE-1 | feature/dynamic-boot-sync-clone | F-0002 | Dynamically clone repo if missing on boot and update tests to agy |
| F-0005 | Remove Proprietary Font Reference | docs/specs/F-0005-remove-proprietary-fonts.md | P1 | done | SWE | feature/remove-proprietary-fonts | F-0001 | Remove Operator Mono and verify custom fonts |
| F-0006 | Remove Tailscale | — | P1 | backlog | — | — | — | Remove Tailscale client, boot script (06a-tailscale.sh), all config references, and related tests |
| F-0007 | Fix Boot Test Failures on Fresh Workstation | docs/specs/F-0007-fix-boot-test-failures.md | P0 | done | SWE | feature/fix-boot-test-failures | F-0002 | Fixes race condition, font deployment, stale assertions, over-delete guards (GH #15, #16, #17, #18) |
| F-0008 | Remove Profile/Module System | — | P1 | backlog | — | — | F-0006 | Remove PROFILE_MODULES, ws_module_enabled, ws-modules.sh, ws-modules.conf. Always run all scripts — no conditional gating. Simplifies setup.sh, 10-tests.sh, cloud-build-setup.sh, deploy-configs.sh |
| F-0009 | Update Antigravity IDE to v2.1.1 | docs/specs/F-0009-update-antigravity-ide.md | P1 | done | SWE | feature/update-antigravity-ide | F-0136 | Version-aware upgrade logic: detect installed version from product.json ideVersion field, backup old install, download new version. QA verified on dev-workstation: 193 PASS, 0 FAIL |
| F-0010 | Align Terraform and Setup Script for Full E2E Coverage | docs/specs/F-0010-align-terraform-setup.md | P1 | done | SWE | feature/align-terraform-setup | F-0002 | Terraform defaults aligned to test workstation, sway_* resources renamed to generic, API enablement added, snapshot policy in setup script, both setup paths documented. QA: terraform validate + plan confirmed. |
| F-0011 | Decommission Interconnect Project | — | P1 | backlog | — | — | — | Decommission prj-b-net-interconnect-2p82 |
| F-0012 | Isolated E2E Testing Environment | docs/specs/F-0012-isolated-e2e-env.md | P0 | in-progress | SWE | feature/isolated-e2e-env | F-0010 | Create dedicated GCP project for safe E2E testing |
| F-0013 | Beautify README | docs/specs/F-0013-beautify-readme.md | P1 | done | SWE | feature/beautify-readme | — | High-contrast Tokyo Night SVG hero, structured README hierarchy, audit checks & boot tests |
| F-0014 | Antigravity Hub Documentation in README | docs/specs/F-0014-readme-hub-docs.md | P1 | done | SWE | feature/readme-hub-docs | F-0003 | Document preinstalled Antigravity Hub, hub-restart utility, Wayland display rationale, and ws5 mapping in README |


