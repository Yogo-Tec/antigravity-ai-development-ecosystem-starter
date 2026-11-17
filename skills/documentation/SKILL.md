---
name: documentation
description: Create reproducible setup guides, architecture notes, API docs, changelogs and runbooks. Distinguish implemented behavior from plans.
---

# Documentation

## Overview & Objectives
The Documentation skill guarantees that system knowledge is captured, reproducible, and perpetually accurate. It produces developer onboarding guides, architecture decision records, API documentation, operational runbooks, and standardized changelogs, while rigorously separating verified reality from proposed future plans.

## Step-by-Step Specialized Workflow

### 1. Audience & Scope Analysis
- Identify the target reader: onboarding engineer, API consumer, system operator, or security auditor.
- Structure documentation logically: Quickstart (under 10 minutes) -> Conceptual Architecture -> Detailed Reference -> Operational Runbooks.

### 2. Reproducible Local Setup Guides
- Document all software prerequisites with exact version requirements (Node.js, Docker, Python).
- Provide copy-pasteable command sequences verified in clean containerized environments.
- Maintain `.env.example` documenting every configuration key with dummy defaults and descriptions.

### 3. Architecture & System Topologies
- Document system component interactions and domain boundaries.
- Maintain an index of Architecture Decision Records (`docs/adr/`) explaining the rationale for technical choices.

### 4. API & Integration Reference
- Provide accurate, tested endpoint documentation with request parameters, authentication schemes, and concrete payload examples.
- Document response status codes, error formats, and rate-limiting headers.

### 5. Operational Runbooks & Troubleshooting
- Write step-by-step operational runbooks for recurring procedures: database restores, certificate rotation, manual re-indexing.
- Create troubleshooting guides indexing common error messages, diagnostic commands, and recovery procedures.

### 6. Standardized Changelog Governance
- Maintain a versioned `CHANGELOG.md` adhering to the "Keep a Changelog" standard.
- Categorize entries: `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, `Security`.

### 7. Fact vs. Plan Separation
- Strictly distinguish implemented features from roadmapped intentions.
- Use explicit visual callouts (e.g., `> [!NOTE] Implemented in v1.2` vs. `> [!IMPORTANT] Planned for v2.0`).

## Practical Examples

### Keep a Changelog Format (`CHANGELOG.md`)
```markdown
# Changelog
All notable changes to this project will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2026-11-17
### Added
- Cursor-based pagination on `/v1/orders` endpoint for improved scalability (#142).
- Prometheus metrics exporter at `/metrics` tracking request duration histograms (#155).
- Integration test suite for multi-tenant invoice generation (#158).

### Changed
- Standardized all API error responses to conform to RFC 7807 Problem Details (#160).
- Upgraded PostgreSQL driver to v8.11 with automatic connection pooling (#163).

### Fixed
- Resolved race condition in cart checkout when user double-clicks payment button (#165).
- Fixed memory leak in WebSocket notification dispatcher under high connection counts (#168).

### Security
- Enabled strict Content Security Policy (CSP) headers across all web pages (#170).
```

## Verification Checklist
- [ ] Local setup instructions tested and verified from a completely clean environment.
- [ ] `.env.example` documents every active environment variable.
- [ ] Architecture diagrams and API references match current codebase reality.
- [ ] Operational runbooks include diagnostic steps and recovery actions.
- [ ] Implemented capabilities are clearly demarcated from planned enhancements.

## Expected Outputs & Deliverables
1. **Developer Setup Guide (`README.md` or `docs/SETUP.md`)**: Reproducible onboarding instructions.
2. **Architecture Documentation (`docs/ARCHITECTURE.md`, `docs/adr/`)**: System topology and decision records.
3. **Operational Runbooks (`docs/RUNBOOKS.md`)**: Step-by-step incident response and maintenance procedures.
4. **Project Changelog (`CHANGELOG.md`)**: Structured history of releases and modifications.