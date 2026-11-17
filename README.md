# Antigravity AI Development Ecosystem

Central, modular, human-controlled library of 17 Agent Skills, project configuration templates, profiles, workflows, and vetted resources for Google Antigravity.

---

## Architecture Overview

This ecosystem employs a robust, two-tier architecture designed for reliable Antigravity discovery and predictable project management:

1. **Source Library (`skills/`)**: The central repository and source of truth containing all 17 specialized skills with full instructions, examples, checklists, and expected outputs.
2. **Workspace Discovery (`.agents/skills/`)**: The active project directory where Antigravity automatically discovers and loads skills into agent context via progressive disclosure.
3. **Project Configuration (`PROJECT_SKILLS.md`)**: Project-level template declaring active skills, tech stacks, dependencies, and autonomy constraints.
4. **Governing Policy (`AGENTS.md` & `.agents/rules/`)**: Immutable master instructions and approval guardrails enforcing controlled autonomy.

---

## 17 Specialized Skills

| Skill ID | Lifecycle Phase | Focus & Deliverables |
| :--- | :--- | :--- |
| **`project-discovery`** | Discovery | Stakeholder interviews, scope boundaries, fact vs. assumption analysis (`docs/DISCOVERY.md`). |
| **`product-requirements`** | Requirements | PRDs, user stories, Gherkin acceptance criteria, NFR targets (`docs/PRD.md`). |
| **`software-architecture`** | Architecture | Module decomposition, data flows, trust zones, ADR records (`docs/ARCHITECTURE.md`, `docs/adr/`). |
| **`ui-ux-review`** | UX/Design | Visual hierarchy, touch targets, WCAG 2.1 AA accessibility audit (`docs/UI_UX_REVIEW.md`). |
| **`design-system`** | UX/Design | 3-tier semantic design tokens, light/dark themes, component specs (`tokens/tokens.json`). |
| **`frontend-development`** | Implementation | Strictly typed components, form validation with Zod, complete UI state lifecycle. |
| **`backend-development`** | Implementation | Input validation at boundaries, tenant isolation, ACID transactions, structured JSON logs. |
| **`database-engineering`** | Implementation | Normalized schemas, indexing, expand-and-contract zero-downtime migrations. |
| **`api-development`** | Implementation | OpenAPI 3.1 contracts, RFC 7807 error envelopes, cursor pagination, idempotency keys. |
| **`browser-testing`** | Testing | Playwright E2E suites, Page Object Models, auto-waiting, embedded Axe accessibility scans. |
| **`code-review`** | Review | Evidence-based diff reviews categorized by priority (`[P1 - Blocker]` to `[Nit]`). |
| **`debugging`** | Debugging | Deterministic reproduction, 5-Whys root cause analysis, automated regression test authoring. |
| **`security-review`** | Security | OWASP Top 10 audits, BOLA/IDOR prevention, SSRF defense, secrets and CVE scans. |
| **`performance-optimization`** | Optimization | Profiling flamegraphs, Core Web Vitals, N+1 query batching, caching strategies. |
| **`monitoring`** | Observability | Four Golden Signals telemetry, `/health/live` & `/health/ready` probes, Prometheus alert rules. |
| **`deployment`** | Release | Build verification, pre-flight checks, smoke tests, mandatory human approval gate for prod. |
| **`documentation`** | Operations | Clean setup guides, ADR indices, operational runbooks, Keep a Changelog governance. |

---

## Project Profiles

Pre-configured profiles in `profiles/` bundle the optimal skill subset for specific archetypes:
- **`all`**: All 17 skills for full-lifecycle systems.
- **`website`**: Discovery, requirements, architecture, UX, design system, frontend, backend, database, API, browser testing, code review, debugging, security, performance, monitoring, deployment, documentation.
- **`ecommerce`**: Full suite with high emphasis on transactions, payments idempotency, security, and performance.
- **`community`**: User-centric social platforms, authz isolation, and responsive frontend.
- **`office-club`**: Business systems, database transactions, reporting, and operational runbooks.
- **`mobile`**: Mobile-focused backend APIs, auth, security, performance, and monitoring.
- **`plugin`**: Lightweight SDK/developer tool development.
- **`core`**: Baseline discovery, requirements, architecture, code review, debugging, security, performance, monitoring, documentation.

---

## Quick Start & Installation

### 1. Install a Profile into a Target Project
Run the PowerShell installer to copy selected skills into the target project's `.agents/skills/`:
```powershell
.\scripts\install-profile.ps1 -ProjectPath "C:\Projects\MyNewApp" -Profile website
```

### 2. Configure the Project
Copy and customize `PROJECT_SKILLS.md` in the target project root:
```powershell
Copy-Item "PROJECT_SKILLS.md" "C:\Projects\MyNewApp\PROJECT_SKILLS.md"
```

### 3. Open in Antigravity
Open `C:\Projects\MyNewApp` in Google Antigravity. The agent will read `AGENTS.md` and `PROJECT_SKILLS.md`, discovering only active skills.

---

## Validation Tooling

Verify ecosystem integrity across both `skills/` and `.agents/skills/`:

### Using PowerShell (Windows Native):
```powershell
.\scripts\validate-skills.ps1
```

### Using Python:
```bash
python scripts/validate-skills.py
```

The validator checks:
1. Presence of `SKILL.md` in every skill folder.
2. Valid YAML frontmatter delimiters (`---`).
3. Skill `name` attribute matching folder name.
4. No duplicate skill names.
5. Presence and descriptive validity of `description`.
6. Non-empty markdown body with workflows and examples.
7. Integrity of `registry/skills-registry.json` and all `profiles/*.json` manifests.
