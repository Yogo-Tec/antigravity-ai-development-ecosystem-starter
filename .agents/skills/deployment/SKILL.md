---
name: deployment
description: Verify builds, tests, migrations, secrets, backups, monitoring and rollback. Production deployment requires explicit human approval.
---

# Deployment

## Overview & Objectives
The Deployment skill governs the reliable, zero-downtime release of software into staging and production environments. It enforces automated pre-flight verifications, database migration safety checks, environment configuration validation, blue-green or canary release strategies, automated health probes, and mandatory human approval gates before touching production.

## Step-by-Step Specialized Workflow

### 1. Pre-Flight Verification & Build Artifacts
- Verify that the target commit passes 100% of automated unit, integration, and E2E test suites.
- Confirm that static analysis, linters, and typecheckers pass with zero blocking errors.
- Build immutable, reproducible release artifacts (e.g., container images tagged with git SHA).

### 2. Environment & Secrets Validation
- Verify that all required environment variables and secrets are present in the target environment secret manager.
- Ensure that staging and production secrets are strictly isolated and credentials are not reused across environments.

### 3. Database Migration Pre-Flight
- Review migrations intended for execution: verify that they are zero-downtime and non-destructive.
- Take and verify an automated snapshot/backup of the database immediately prior to running migrations.

### 4. Staging Deployment & Smoke Testing
- Deploy release candidate to the staging environment.
- Execute synthetic smoke test scripts verifying critical user journeys and external integrations.

### 5. Mandatory Human Approval Gate for Production
- **Mandatory Policy**: Production deployment requires explicit human approval.
- Present a deployment release briefing containing:
  - Git commit hash, release version, and summary of changes.
  - Risk assessment and affected components.
  - Verification results from staging smoke tests.
  - Step-by-step rollback plan with estimated Time-to-Rollback (< 5 minutes).
- Await formal human confirmation before proceeding.

### 6. Production Rollout (Blue-Green / Rolling Canary)
- Execute rollout strategy: deploy new version alongside old version (Blue-Green) or incrementally shift traffic (Canary 10% -> 50% -> 100%).
- Continuously monitor health check endpoints, error rates, and latency metrics during the rollout window.

### 7. Post-Deployment Verification & Rollback Trigger
- Execute post-deployment smoke tests on production endpoints.
- If error rate exceeds 0.5% or latency increases by > 25%, immediately trigger automated rollback to the previous stable release artifact.

## Practical Examples

### Pre-Deployment Verification & Release Briefing
```markdown
# Production Deployment Request: v2.4.0

## Release Details
- **Target Git SHA**: `a1b2c3d4e5f67890`
- **Container Image**: `registry.example.com/api:v2.4.0`
- **Environment**: Production (`us-east-1`)

## Change Summary
- Added cursor-based pagination to Orders API (#142)
- Added full-text search indexing on Customer table (#145)
- Upgraded Node.js base image to v24.18.0 (#150)

## Pre-Flight Check Results
- [x] All 324 automated tests passed in CI (100% green)
- [x] Security vulnerability scan passed (0 High/Critical CVEs)
- [x] Staging smoke tests passed without error
- [x] PostgreSQL database snapshot completed (`snap-prod-20261117-001`)
- [x] Zero-downtime migration verified (`20261117_add_search_idx.sql`)

## Rollback Procedure
If p95 latency exceeds 500ms or error rate > 0.5% during canary:
1. Re-route 100% traffic to Green pool: `kubectl rollout undo deployment/api`
2. Rollback migration if applied: `./scripts/migrate.sh down 1`
3. Estimated recovery time: < 90 seconds.

## Approval Request
Please reply with **"Approved"** to execute production release.
```

## Verification Checklist
- [ ] All automated tests, linting, and builds pass cleanly.
- [ ] Target environment secrets are verified in the secret store.
- [ ] Database backup snapshot confirmed prior to schema updates.
- [ ] Staging deployment and synthetic smoke tests verified.
- [ ] Explicit human approval received before executing production rollout.
- [ ] Automated health probes and instant rollback procedures verified.

## Expected Outputs & Deliverables
1. **Deployment Runbook (`docs/DEPLOYMENT.md`)**: Step-by-step procedures and rollback triggers.
2. **Release Briefing**: Formal change manifest with risk assessment and human sign-off.
3. **Smoke Test Execution Log**: Verification output confirming post-release health.