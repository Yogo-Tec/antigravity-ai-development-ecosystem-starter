---
name: product-requirements
description: Create PRDs with personas, journeys, functional and non-functional requirements, acceptance criteria, exclusions and milestones. Do not invent requirements.
---

# Product Requirements

## Overview & Objectives
The Product Requirements skill governs the translation of high-level discovery findings into a formal, unambiguous Product Requirements Document (PRD). It produces actionable user stories, verifiable acceptance criteria (Given-When-Then), robust non-functional requirements (NFRs), and clear milestone boundaries without inventing unconfirmed features.

## Step-by-Step Specialized Workflow

### 1. Persona & Journey Modeling
- Define detailed user personas including goals, technical proficiency, permissions, and accessibility needs.
- Map end-to-end user journeys from initial entry point to task completion, including alternative and failure paths.

### 2. Functional Requirements Decomposition
- Break down product capabilities into granular, numbered functional requirements (`FR-001`, `FR-002`).
- Ensure each requirement specifies *what* the system must do, avoiding premature implementation details.
- Prioritize using the MoSCoW framework (Must have, Should have, Could have, Won't have).

### 3. Non-Functional Requirements (NFR) Specification
- Quantify performance criteria: Time to First Byte (TTFB), Largest Contentful Paint (LCP), p95/p99 API response latencies.
- Define availability, reliability, and disaster recovery targets (e.g., 99.9% uptime, RPO < 15 min, RTO < 1 hr).
- Specify security and accessibility constraints (e.g., WCAG 2.1 Level AA compliance, zero plain-text secrets).

### 4. Acceptance Criteria Definition (Given-When-Then / Gherkin)
- Formulate acceptance criteria for every functional requirement using standard Gherkin syntax.
- Cover positive paths, boundary conditions, validation failures, and network interruption scenarios.

### 5. Edge Cases & Exclusions
- Document boundary conditions: character limits, concurrent edits, session expiration during form submission, empty search queries, and special unicode inputs.
- Maintain an explicit "Exclusions" section stating what will not be implemented in this release.

### 6. Traceability & Milestone Mapping
- Map each requirement to its parent discovery objective and child architecture/implementation tasks.
- Group requirements into deliverable milestone releases (Phase 1 MVP, Phase 2 Beta, Phase 3 Scale).

## Practical Examples

### User Story with Gherkin Acceptance Criteria
```gherkin
Feature: Secure Customer Checkout
  As an authenticated customer
  I want to pay for items in my cart using a saved credit card
  So that I can complete my order without re-entering payment details

  Scenario: Successful payment with valid default card
    Given the user is authenticated and has items totaling $45.00 in the cart
    And has a valid default card on file ending in "4242"
    When the user clicks "Complete Order"
    Then an authorization request is sent to the payment gateway with idempotency key
    And the user is redirected to the Order Confirmation page within 2 seconds
    And an order receipt email is queued for dispatch

  Scenario: Payment declined due to insufficient funds
    Given the user's card triggers a decline code "card_declined"
    When the user clicks "Complete Order"
    Then the checkout button is re-enabled
    And a user-friendly error message is displayed: "Your card was declined. Please try another card."
    And the cart contents remain intact
    And no order record is created in the finalized state
```

## Verification Checklist
- [ ] Every requirement has a unique, persistent identifier (e.g., `FR-001`).
- [ ] Acceptance criteria are written in verifiable, testable Given-When-Then syntax.
- [ ] Non-functional requirements (latency, uptime, accessibility) have quantifiable targets.
- [ ] All error and failure scenarios are explicitly detailed.
- [ ] Exclusions and deferred features are documented to prevent scope drift.

## Expected Outputs & Deliverables
1. **Product Requirements Document (`docs/PRD.md`)**: Structured document encompassing personas, functional stories, NFRs, and acceptance criteria.
2. **Requirements Traceability Matrix**: Mapping discovery objectives to requirement IDs.
3. **Gherkin Test Scenarios**: Verifiable specification ready for handover to testing and development teams.