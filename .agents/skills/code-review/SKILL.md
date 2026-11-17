---
name: code-review
description: Review correctness, maintainability, security, performance, accessibility and regression risks. Prioritize findings with evidence.
---

# Code Review

## Overview & Objectives
The Code Review skill performs comprehensive, objective code inspection on proposed pull requests and code modifications. It evaluates correctness, security vulnerabilities, performance regressions, maintainability, architectural alignment, accessibility, and test completeness. All review comments must provide concrete evidence and actionable solutions.

## Step-by-Step Specialized Workflow

### 1. Scope & Context Comprehension
- Read the linked issue, PR description, and relevant architecture decision records (ADRs).
- Verify that the diff accomplishes the stated intent without introducing unrequested scope changes.

### 2. Correctness & Logic Verification
- Check for off-by-one errors, null/undefined pointer dereferences, race conditions, and unhandled promise rejections.
- Verify boundary conditions: empty arrays, zero values, extreme inputs, timezone discrepancies.

### 3. Security & Vulnerability Audit
- Inspect all input ingestion points for SQL injection, command injection, XSS, and path traversal risks.
- Ensure proper authorization checks precede business logic (prevent IDOR/BOLA).
- Verify that no credentials, tokens, secret keys, or private customer data are committed.

### 4. Performance & Resource Footprint
- Identify N+1 database queries, missing index requirements, or unbounded in-memory collection processing.
- Inspect frontend diffs for unnecessary heavy bundle imports, missing image dimensions, or render looping.

### 5. Architectural Alignment & Maintainability
- Ensure changes adhere to project module boundaries and layering rules.
- Flag code duplication (DRY) while guarding against premature or convoluted abstractions.
- Verify clear naming, self-documenting code, and helpful inline comments on non-obvious logic.

### 6. Test Adequacy & Coverage
- Ensure bug fixes include a regression test reproducing the original failure.
- Ensure new features include unit, integration, or E2E tests validating both positive and failure paths.

### 7. Prioritized Feedback Synthesis
- Structure review findings using standard priority prefixes:
  - **[P1 - Blocker]**: Security vulnerability, data loss risk, regression, critical logic bug. Must be resolved before merge.
  - **[P2 - Important]**: Performance bottleneck, missing test coverage, poor error handling, architectural deviation. Strongly recommended before merge.
  - **[P3 - Suggestion]**: Refactoring opportunity, minor maintainability improvement. Optional for current PR.
  - **[Nit]**: Typo, code style convention. Non-blocking.

## Practical Examples

### Exemplary Constructive Code Review Findings

```markdown
### [P1 - Blocker] Potential IDOR Vulnerability in Document Fetch
**Location**: `src/controllers/document.controller.ts:42`
**Issue**: The document query retrieves records using only `req.params.documentId` without verifying that the document belongs to the requesting user's organization. Any authenticated user can view any document by guessing or enumerating IDs.
```typescript
// Current vulnerable code:
const doc = await db('documents').where({ id: req.params.documentId }).first();

// Recommended fix:
const doc = await db('documents')
  .where({ id: req.params.documentId, tenant_id: req.user.tenantId })
  .first();
```

---

### [P2 - Important] N+1 Query in Order Items Serialization
**Location**: `src/services/order.service.ts:88`
**Issue**: An asynchronous map triggers an individual SQL query for each order item inside a loop. For orders with 50 items, this generates 51 database roundtrips.
```typescript
// Recommended fix:
// Batch load item details using a single WHERE IN query or an eager join:
const itemIds = order.items.map(i => i.id);
const details = await db('item_details').whereIn('item_id', itemIds);
```
```

## Verification Checklist
- [ ] Review covers correctness, security, performance, accessibility, and tests.
- [ ] Every finding includes line numbers, exact explanation of impact, and recommended fix.
- [ ] Findings are categorized by severity ([P1 - Blocker], [P2 - Important], [P3 - Suggestion], [Nit]).
- [ ] Review states an unambiguous verdict: `APPROVE`, `REQUEST_CHANGES`, or `COMMENT`.

## Expected Outputs & Deliverables
1. **Code Review Report (`docs/CODE_REVIEW.md` or PR Comments)**: Structured, prioritized review feedback.
2. **Action Item Checklist**: Clear list of items required before merge approval.