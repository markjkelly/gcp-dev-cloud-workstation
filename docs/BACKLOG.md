# Project Backlog — Cloud Workstation

**Maintained by:** TPM
**Last updated:** 2026-06-29

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
| F-0002 | Scratch E2E Integration Test | docs/specs/F-0002-scratch-e2e-test.md | P0 | in-progress | PE | feature/scratch-e2e-test | F-0001 | Implemented python helper to avoid invalid gcloud add-iam-policy-binding commands |
