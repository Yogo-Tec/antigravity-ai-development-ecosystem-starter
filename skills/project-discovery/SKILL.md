---
name: project-discovery
description: Use when starting a project. Identify goals, users, scope, constraints, integrations, risks and open questions. Separate confirmed facts from assumptions.
---

# Project Discovery

## Overview & Objectives
Project Discovery is the foundational phase of software delivery. The primary objective is to de-risk delivery by establishing unambiguous problem definitions, identifying core stakeholders and user segments, mapping technical and regulatory constraints, and separating verified facts from unvalidated assumptions before any code or architectural commitments are made.

## Step-by-Step Specialized Workflow

### 1. Stakeholder & Context Assessment
- Interview key project stakeholders to establish business rationale, expected return on investment (ROI), and quantifiable target metrics.
- Identify the target user personas (primary end-users, operators, administrators, automated systems).
- Document current baseline practices and workflows that this project aims to replace or enhance.

### 2. Scope Boundary Definition (In-Scope vs. Explicitly Out-of-Scope)
- Define the minimal viable product (MVP) feature surface area required to test value propositions.
- Create an explicit "Out-of-Scope" list to prevent scope creep during early iterations.
- Distinguish non-negotiable requirements (core value) from deferred enhancements (phase 2/3).

### 3. Constraint & Environment Mapping
- Catalog all operational constraints: hosting platform (AWS, GCP, Azure, on-premises), budget limits, delivery timelines, and team capabilities.
- Identify compliance, legal, and regulatory requirements (e.g., GDPR, HIPAA, SOC 2, PCI-DSS, local data residency laws).
- Document supported hardware, browsers, minimum bandwidth expectations, and legacy platform interop requirements.

### 4. Integration & Dependency Audit
- Inventory all external APIs, third-party SaaS services, identity providers (OAuth/SAML/OIDC), payment processors, and legacy databases.
- Document dependency SLAs, rate limits, sandbox availability, licensing costs, and credential provisioning lead times.

### 5. Risk Assessment & Assumption Validation Matrix
- Systematically classify every input into one of two categories:
  - **Confirmed Facts**: Verified with documentation, live APIs, or signed contracts.
  - **Unvalidated Assumptions**: Unverified beliefs regarding user behaviour, throughput, or vendor capabilities.
- Assign an impact/probability rating to each assumption and design quick spike experiments to validate high-impact assumptions early.

### 6. Milestone Definition & Decision Gates
- Define milestone checkpoints (e.g., Discovery Sign-off, Architecture Freeze, Vertical Slice Demo, Beta, GA).
- Establish decision gates that require explicit stakeholder approval before proceeding to the next delivery phase.

## Practical Examples

### Fact vs. Assumption Classification Table

| Item | Classification | Source / Evidence | Validation Action | Impact if Invalid |
| :--- | :--- | :--- | :--- | :--- |
| Stripe supports local currency in region X | **Confirmed Fact** | Stripe docs & verified sandbox test | None required | Low |
| Daily active users will reach 50,000 at launch | **Assumption** | Marketing forecast | Stress test at 10x launch estimate | High (over/under-provisioning) |
| Target users will use mobile Safari primarily | **Assumption** | Customer survey (sample size 20) | Audit analytics from existing web properties | High (layout breakdown) |
| Third-party CRM webhook delivery SLA is < 2s | **Assumption** | Vendor sales deck | Measure latency in staging spike | Critical (data race condition) |

## Verification Checklist
- [ ] Business goals are paired with measurable Key Performance Indicators (KPIs).
- [ ] In-scope features are explicitly delineated from out-of-scope items.
- [ ] All external dependencies, rate limits, and SLAs are documented.
- [ ] Compliance, security, and data privacy constraints are identified.
- [ ] Every unvalidated assumption has an owner and a validation plan.
- [ ] Stakeholder approval gate has been formally recorded.

## Expected Outputs & Deliverables
1. **Discovery Summary Document (`docs/DISCOVERY.md`)**: Comprehensive report capturing business context, user personas, scope boundaries, and integration inventory.
2. **Assumption & Risk Log**: Structured table detailing assumptions, test experiments, and mitigation triggers.
3. **Phase Sign-Off Milestone**: Formal confirmation to proceed into Product Requirements (`product-requirements`).