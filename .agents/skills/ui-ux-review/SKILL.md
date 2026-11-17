---
name: ui-ux-review
description: Evaluate hierarchy, navigation, user flows, responsive behavior, accessibility and usability. Provide prioritized recommendations.
---

# UI/UX Review

## Overview & Objectives
The UI/UX Review skill audits interfaces for usability, visual hierarchy, ergonomics, accessibility compliance (WCAG 2.1 AA), and responsive resilience. It ensures that user interfaces provide seamless journeys, clear affordances, complete UI state handling, and zero accessibility blockers across all target devices.

## Step-by-Step Specialized Workflow

### 1. Information Architecture & Visual Hierarchy Audit
- Verify the logical visual reading flow (F-pattern, Z-pattern) and scanning affordances.
- Ensure typography scale is consistent: distinct sizing, line-heights, and weights separating headings, body, and captions.
- Verify spacing rhythm: consistent use of spacing units to group related elements (Gestalt proximity).

### 2. Navigation & User Journey Usability
- Assess click/tap depth to complete primary workflows (aim for <= 3 interactions).
- Verify navigation predictability: breadcrumbs, persistent menus, clear active indicators, and logical back-button behavior.
- Ensure form fields have visible labels, inline guidance, and proactive input formatting.

### 3. Responsive & Ergonomic Layout Inspection
- Test responsive viewports across standard breakpoints: 320px (compact mobile), 375px, 768px (tablet), 1024px, 1440px (desktop), 1920px+.
- Inspect touch targets on mobile: minimum 44x44 CSS pixels with adequate separation to prevent accidental taps.
- Verify that content does not require horizontal scrolling on narrow viewports.

### 4. Accessibility (a11y) & WCAG 2.1 AA Verification
- Audit color contrast ratios: >= 4.5:1 for standard body text, >= 3:1 for large text (>= 18pt or bold 14pt) and UI components.
- Verify keyboard operability: entire interface operable using Tab, Enter, Space, and Escape.
- Inspect focus indicators: high-contrast visible focus rings on all interactive elements (`focus-visible`).
- Confirm non-color communication: errors, warnings, and states must not rely solely on color.

### 5. UI State Completeness Audit
- Ensure every view systematically handles six essential UI states:
  1. **Initial / Idle**: Default resting presentation.
  2. **Loading**: Content-matching skeletons (avoid blank screens or generic spinners).
  3. **Empty**: Engaging empty states providing clear calls-to-action (CTA).
  4. **Success**: Explicit confirmation of completed user actions.
  5. **Error**: User-friendly explanations with actionable recovery steps.
  6. **Partial / Offline**: Graceful degradation when network connectivity is lost.

### 6. Prioritized Findings Classification
- Categorize all issues by severity:
  - **P1 (Blocker)**: Accessibility violations preventing task completion, broken flows, inaccessible keyboard traps.
  - **P2 (High)**: Severe usability friction, confusing layout jumps, poor touch targets, low contrast.
  - **P3 (Medium)**: Inconsistent spacing, minor typographic hierarchy lapses, sub-optimal empty states.
  - **P4 (Low)**: Polish, visual alignment suggestions, micro-copy enhancements.

## Practical Examples

### UI/UX Audit Findings Matrix

| Finding ID | View / Component | Severity | Description | WCAG / Usability Rule | Recommended Fix |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **UX-001** | Checkout Form | **P1 (Blocker)** | CVV input lacks accessible name and visible label | WCAG 1.3.1 (Info & Relationships) | Add `<label for="cvv">Security Code (CVV)</label>` and `aria-describedby` helper. |
| **UX-002** | Product Filter Dropdown | **P1 (Blocker)** | Cannot open dropdown using keyboard Enter or Space | WCAG 2.1.1 (Keyboard) | Replace non-semantic `div` with `<button>` and attach standard ARIA listbox semantics. |
| **UX-003** | Primary CTA Buttons | **P2 (High)** | Gray text `#888888` on white background has 3.5:1 contrast | WCAG 1.4.3 (Contrast Minimum) | Darken text to `#595959` or adjust background to exceed 4.5:1 ratio. |
| **UX-004** | Order History List | **P2 (High)** | Shows blank white screen for 2.8s while fetching data | Usability: Perceived Performance | Introduce skeleton loader matching order card geometry. |

## Verification Checklist
- [ ] Visual hierarchy directs attention to primary actions without clutter.
- [ ] Touch targets are at least 44x44px on mobile viewports.
- [ ] Color contrast meets or exceeds WCAG 2.1 AA (4.5:1 normal, 3:1 large).
- [ ] Keyboard navigation is fully functional with visible focus indicators.
- [ ] All six UI states (idle, loading, empty, success, error, offline) are designed.

## Expected Outputs & Deliverables
1. **UI/UX Audit Report (`docs/UI_UX_REVIEW.md`)**: Comprehensive findings categorized by severity with remediation guidelines.
2. **Accessibility Compliance Scorecard**: Detailed audit against WCAG 2.1 AA standards.
3. **Annotated Remediation Plan**: Specific code/CSS adjustments for engineering handover.