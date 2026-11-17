# Project Skills Configuration (`PROJECT_SKILLS.md`)

> **Antigravity Instructions**:
> - Read this file at the start of any new task or project iteration.
> - Select the smallest relevant skill set needed for the current objective.
> - Read only the specific `SKILL.md` files corresponding to active skills required for the task.
> - Verify that any external tools, runtimes, or MCP servers mentioned are actually available before proceeding.

---

## 1. Project Overview

| Attribute | Value / Description |
| :--- | :--- |
| **Project Name** | `[Project Name]` |
| **Repository** | `[Repository URL or Local Path]` |
| **Project Archetype** | `[website / webapp / ecommerce / mobile / plugin / service / custom]` |
| **Active Profile** | `all` *(Options: `core`, `website`, `ecommerce`, `mobile`, `community`, `office-club`, `plugin`, `all`)* |
| **Primary Tech Stack** | `[e.g., TypeScript, React, Node.js / Express, PostgreSQL, Tailwind CSS, Playwright]` |
| **Lead / Maintainer** | `[Engineering Team / Maintainer Name]` |

---

## 2. Active Skills Manifest

Configure which skills are actively enabled for this project. Agents will only reference and activate skills marked as **Active**.

| Skill ID | Status | Primary Responsibility in this Project | Key Artifacts |
| :--- | :---: | :--- | :--- |
| `project-discovery` | `Active` | Stakeholder goals, constraints, fact vs. assumption analysis | `docs/DISCOVERY.md` |
| `product-requirements` | `Active` | PRDs, user stories, Gherkin acceptance criteria | `docs/PRD.md` |
| `software-architecture` | `Active` | System topology, module boundaries, ADR records | `docs/ARCHITECTURE.md`, `docs/adr/` |
| `ui-ux-review` | `Active` | Visual hierarchy, navigation, WCAG 2.1 AA a11y audits | `docs/UI_UX_REVIEW.md` |
| `design-system` | `Active` | Semantic design tokens, theme variables, component specs | `tokens/tokens.json`, `docs/DESIGN_SYSTEM.md` |
| `frontend-development` | `Active` | Typed UI components, form validation, state lifecycle | `src/components/`, `*.test.tsx` |
| `backend-development` | `Active` | Boundary validation, authz, transactions, structured logs | `src/services/`, `src/controllers/` |
| `database-engineering` | `Active` | Schemas, indexing, zero-downtime migrations | `migrations/`, `docs/ERD.md` |
| `api-development` | `Active` | OpenAPI 3.1 contracts, RFC 7807 errors, idempotency | `docs/openapi.yaml`, `src/api/` |
| `browser-testing` | `Active` | E2E user journeys, cross-browser Playwright tests, a11y | `tests/e2e/`, `playwright.config.ts` |
| `code-review` | `Active` | Static analysis, correctness, security, performance audits | `docs/CODE_REVIEW.md` |
| `debugging` | `Active` | Incident triage, 5-whys root cause analysis, regression tests | `tests/regression/`, `docs/incidents/` |
| `security-review` | `Active` | OWASP Top 10, authz audit, dependency scanning, CSP | `docs/SECURITY_AUDIT.md` |
| `performance-optimization`| `Active` | Profiling, Core Web Vitals, query tuning, caching | `docs/PERFORMANCE.md` |
| `monitoring` | `Active` | Health probes, Prometheus metrics, structured alerting | `docs/MONITORING.md`, `/health/*` |
| `deployment` | `Active` | Release pre-flight, smoke tests, human approval gate | `docs/DEPLOYMENT.md`, release notes |
| `documentation` | `Active` | Developer onboarding, architecture notes, changelog | `README.md`, `CHANGELOG.md` |

---

## 3. Environment & Tool Prerequisites

List toolchains, runtimes, and local services required before executing skills.

```yaml
runtimes:
  node: ">= 20.0.0"
  pnpm: ">= 9.0.0"
  python: ">= 3.10" # Optional: for scripts/validation

databases:
  postgresql: ">= 16"
  redis: ">= 7.0"

test_frameworks:
  unit: "vitest"
  e2e: "playwright"

linters_and_checkers:
  linter: "eslint"
  typecheck: "tsc --noEmit"
  security_scan: "trivy / gitleaks"
```

---

## 4. Controlled Autonomy & Approval Gates

In accordance with [AGENTS.md](AGENTS.md) and `.agents/rules/approval-policy.md`, the agent is permitted controlled autonomy for inspecting files, drafting plans, writing documentation, implementing approved tasks, and running non-destructive local tests.

**Explicit human approval is strictly required before**:
1. Installing new system-level binaries or CLI tools.
2. Adding paid cloud services or provisioning billable infrastructure.
3. Transmitting private source code, secrets, or data outside the local sandbox.
4. Executing destructive database migrations (`DROP TABLE`, `DROP COLUMN`, truncate).
5. Altering production credentials, IAM permissions, or network ingress/egress rules.
6. Pushing directly to protected branches (`main`, `master`, `release/*`).
7. Deploying or triggering a production release.

---

## 5. Development Workflow Pipeline

```text
Discovery (project-discovery)
  │
  ▼
Requirements (product-requirements)
  │
  ▼
Architecture & Contracts (software-architecture, api-development, database-engineering)
  │
  ▼
UX & Design (ui-ux-review, design-system)
  │
  ▼
Implementation (frontend-development, backend-development)
  │
  ▼
Quality & Review (code-review, security-review)
  │
  ▼
Testing & Verification (browser-testing, debugging)
  │
  ▼
Optimization & Telemetry (performance-optimization, monitoring)
  │
  ▼
Release & Operations (deployment [Human Gate], documentation)
```
