---
name: debugging
description: Reproduce failures, inspect logs and code, identify root cause, make a safe fix, add regression tests and rerun checks.
---

# Debugging

## Overview & Objectives
The Debugging skill applies a rigorous, scientific methodology to diagnosing and resolving software defects. It mandates systematic reproduction, comprehensive diagnostic data collection, Five-Whys root cause analysis, surgical minimal remediation, automated regression test creation, and post-mortem documentation.

## Step-by-Step Specialized Workflow

### 1. Incident Triage & Information Gathering
- Collect exact error messages, stack traces, environment details, user inputs, and relevant timestamps.
- Check recent commits, configuration changes, migrations, and third-party service statuses to isolate recent changes.

### 2. Deterministic Reproduction
- Formulate a minimal, reproducible test case in an isolated environment before touching production code.
- Write a failing unit, integration, or E2E test that reliably triggers the failure.
- **Rule**: If a bug cannot be reproduced, gather more diagnostic logging before attempting code changes.

### 3. Diagnostic Tracing & Observability Analysis
- Trace execution flows using correlation IDs across structured application logs.
- Inspect database slow query logs, connection pool states, and transaction isolation locks.
- Utilize debuggers or targeted diagnostic logging to inspect state variables leading up to the failure point.

### 4. Root Cause Analysis (5-Whys Methodology)
- Distinguish the immediate symptom from the fundamental systemic defect.
- Apply the 5-Whys technique to identify architectural, validation, or lifecycle flaws.

### 5. Surgical Remediation
- Formulate the minimal safe patch that eliminates the root cause without introducing side-effects.
- Avoid large-scale refactoring during urgent defect remediation.

### 6. Automated Regression Prevention
- Commit the reproducible test created in Step 2 as a permanent part of the test suite.
- Verify that the test fails before applying the patch and passes cleanly after the patch is applied.

### 7. Post-Mortem & Preventative Hardening
- Document what broke, how it was caught, what the root cause was, and how similar issues will be prevented in the future.

## Practical Examples

### Root Cause Analysis & 5-Whys Case Study
```markdown
# Incident Post-Mortem: Intermittent Double Charge on Checkout

## Symptom
Customers reported being charged twice when clicking the "Pay Now" button on unstable mobile connections.

## 5-Whys Root Cause Analysis
1. **Why was the customer charged twice?**
   Two separate payment authorization requests were sent to Stripe for the same cart within 400ms.
2. **Why were two requests sent?**
   The user tapped the "Pay Now" button twice in rapid succession.
3. **Why did two taps trigger two requests?**
   The client-side button click handler did not disable the button until after the first asynchronous network call resolved.
4. **Why did the server process both requests as unique charges?**
   The checkout endpoint did not require or enforce an `Idempotency-Key` header.
5. **Why was there no idempotency protection?**
   The payment API was implemented before the API idempotency standard was established, and no backend contract test enforced it.

## Remediation Plan
1. **Immediate Patch**: Client-side button disables immediately on first tap and shows loading spinner.
2. **Systemic Fix**: Backend payment handler generates/validates a unique `Idempotency-Key` based on Cart ID. Second request returns cached response.
3. **Regression Test**: Added automated integration test sending concurrent duplicate requests; verified only 1 charge is recorded.
```

## Verification Checklist
- [ ] Failure is reproduced reliably with a deterministic test case.
- [ ] Root cause is isolated using logs, metrics, or traces (not guesswork).
- [ ] Fix is minimal, surgical, and avoids unnecessary refactoring.
- [ ] Automated regression test is added and passes.
- [ ] All existing regression and unit test suites pass without regression.

## Expected Outputs & Deliverables
1. **Surgical Code Patch**: Focused fix resolving the root cause.
2. **Automated Regression Test**: Test case proving the bug is resolved and preventing recurrence.
3. **Incident Diagnostic Report (`docs/incidents/YYYY-MM-DD-issue.md`)**: Summary of root cause, fix, and preventative actions.