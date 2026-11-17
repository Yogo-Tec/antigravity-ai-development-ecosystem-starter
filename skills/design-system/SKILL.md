---
name: design-system
description: Define reusable design tokens, color roles, typography, spacing, components, states, responsive rules and accessibility constraints.
---

# Design System

## Overview & Objectives
The Design System skill establishes a single source of visual truth across applications. It specifies semantic design tokens (colors, typography, spacing, elevation, motion), component architectures, interactive state variants, and accessibility constraints to ensure brand consistency, development velocity, and maintenance scalability.

## Step-by-Step Specialized Workflow

### 1. Semantic Token Architecture
- Organize tokens into a three-tiered hierarchy:
  1. **Global / Primitive Tokens**: Raw values (e.g., `blue-500: #3b82f6`, `space-4: 16px`).
  2. **Semantic / Alias Tokens**: Purpose-driven roles (e.g., `color-brand-primary: var(--blue-500)`, `surface-card: var(--white)`).
  3. **Component-Specific Tokens**: Local overrides (e.g., `button-primary-bg: var(--color-brand-primary)`).
- Enforce semantic tokens across all UI code; ban hardcoded raw hex colors or arbitrary pixel values.

### 2. Theming & Dark/Light Mode Integration
- Structure theme variables using CSS custom properties or token abstractions.
- Ensure high-contrast parity between light and dark themes.
- Prevent Flash of Unstyled Theme (FOUT) / Flash of Incorrect Theme (FOIT) with script-level theme resolution before initial paint.

### 3. Component Primitive Hierarchy
- Build an atomic component library: Buttons, Inputs, Checkboxes, Radios, Toggles, Badges, Modals, Drawers, Cards, Tooltips.
- Design variant sets covering visual emphasis (Primary, Secondary, Ghost, Destructive) and sizes (SM, MD, LG).

### 4. Interactive State Machine Modeling
- Implement exhaustive interactive states for all actionable components:
  - `default`, `hover`, `active`, `focus-visible`, `disabled`, `loading`, `invalid`.
- Ensure `disabled` states maintain readability and provide tooltip explanations when an action is unavailable.

### 5. Layout & Spacing Grid Constraints
- Standardize on an 8-point spatial system (with 4-point micro-adjustments for typography and icons).
- Define standardized container widths (`max-w-7xl`, etc.) and breakpoint scales.

### 6. Documentation & Governance
- Document usage guidelines: when to use a component, anti-patterns, and composition examples.
- Implement versioning and deprecation strategies for design system components.

## Practical Examples

### CSS Semantic Token Specification
```css
:root {
  /* Primitive Spacing (8pt grid) */
  --space-1: 4px;
  --space-2: 8px;
  --space-3: 12px;
  --space-4: 16px;
  --space-6: 24px;
  --space-8: 32px;

  /* Primitive Colors */
  --palette-gray-50: #f9fafb;
  --palette-gray-900: #111827;
  --palette-blue-600: #2563eb;
  --palette-red-600: #dc2626;

  /* Semantic Roles (Light Theme) */
  --bg-canvas: var(--palette-gray-50);
  --bg-surface: #ffffff;
  --text-primary: var(--palette-gray-900);
  --text-muted: #6b7280;
  --color-interactive: var(--palette-blue-600);
  --color-destructive: var(--palette-red-600);
  --focus-ring: 0 0 0 3px rgba(37, 99, 235, 0.4);
}

[data-theme="dark"] {
  /* Semantic Roles (Dark Theme) */
  --bg-canvas: #0f172a;
  --bg-surface: #1e293b;
  --text-primary: #f8fafc;
  --text-muted: #94a3b8;
  --color-interactive: #60a5fa;
  --color-destructive: #f87171;
  --focus-ring: 0 0 0 3px rgba(96, 165, 250, 0.5);
}
```

## Verification Checklist
- [ ] All components consume semantic tokens rather than raw values.
- [ ] Both light and dark theme modes satisfy WCAG 2.1 AA contrast requirements.
- [ ] Focus-visible rings are present and visually distinct across all themes.
- [ ] Components implement all standard states (hover, active, focus, disabled, loading).
- [ ] Spacing values adhere strictly to the 8pt/4pt grid.

## Expected Outputs & Deliverables
1. **Design Tokens Catalog (`tokens/tokens.json` or `tokens.css`)**: Complete machine-readable token taxonomy.
2. **Component Library Specification**: API signatures, variant matrices, and state tables.
3. **Usage & Governance Documentation (`docs/DESIGN_SYSTEM.md`)**: Guidelines, best practices, and anti-patterns.