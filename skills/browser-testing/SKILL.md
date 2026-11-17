---
name: browser-testing
description: Create end-to-end tests for critical journeys, responsive states, accessibility-relevant interactions and failure paths.
---

# Browser Testing

## Overview & Objectives
The Browser Testing skill automates cross-browser, end-to-end (E2E) testing for critical user workflows. Utilizing frameworks like Playwright, it enforces resilient selector strategies, handles dynamic asynchronous states without flaky arbitrary sleeps, validates responsive viewports, integrates automated accessibility scans, and captures diagnostic traces on failure.

## Step-by-Step Specialized Workflow

### 1. Critical User Journey Identification
- Identify core business paths that must never fail: user signup/login, onboarding flow, product search, checkout, and account settings.
- Model tests based on user-observable behaviour rather than internal implementation details.

### 2. Page Object Model (POM) & Harness Architecture
- Encapsulate page-specific selectors and interaction methods inside Page Objects.
- Keep test specifications clean, readable, and focused on business assertions.

### 3. Resilient Selector Strategy
- Prioritize user-facing, accessible locators:
  1. `page.getByRole('button', { name: 'Submit' })`
  2. `page.getByLabel('Email address')`
  3. `page.getByPlaceholder('Search products')`
  4. `page.getByTestId('unique-action-id')` (last resort fallback)
- **Strictly Ban**: Brittle CSS/XPath selectors (e.g., `div > div.col-md-4:nth-child(2) > span`).
- **Strictly Ban**: Arbitrary sleeps (e.g., `page.waitForTimeout(3000)`). Rely exclusively on web-first auto-waiting assertions.

### 4. Accessibility Testing Integration (Axe-core)
- Embed automated accessibility testing into browser runs using `@axe-core/playwright`.
- Scan core views after initial load and after major state mutations to catch WCAG regressions automatically.

### 5. Multi-Device & Cross-Browser Verification
- Run tests against Chromium, Firefox, and WebKit rendering engines.
- Test against standard mobile and desktop viewport profiles (e.g., Pixel 7, iPhone 14, Desktop HD 1440x900).

### 6. Diagnostics, Artifacts & CI Optimization
- Configure Playwright to capture video, screenshots, and full execution traces on failure.
- Ensure test suites run concurrently with test isolation (independent database fixtures).

## Practical Examples

### Playwright E2E Test with Page Object Model & Axe Accessibility Scan
```typescript
import { test, expect } from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';

class LoginPage {
  constructor(private page: import('@playwright/test').Page) {}

  async goto() {
    await this.page.goto('/login');
  }

  async login(email: string, pass: string) {
    await this.page.getByLabel('Email address').fill(email);
    await this.page.getByLabel('Password').fill(pass);
    await this.page.getByRole('button', { name: 'Sign in' }).click();
  }
}

test.describe('Authentication Journey', () => {
  test('logs in successfully and passes accessibility audit', async ({ page }) => {
    const loginPage = new LoginPage(page);
    await loginPage.goto();

    // 1. Accessibility Scan on Login Page
    const accessibilityScanResults = await new AxeBuilder({ page })
      .withTags(['wcag2a', 'wcag2aa'])
      .analyze();
    expect(accessibilityScanResults.violations).toEqual([]);

    // 2. Perform Login Action
    await loginPage.login('user@example.com', 'SecureP@ss123');

    // 3. Web-first assertion (auto-waits for navigation and element appearance)
    await expect(page.getByRole('heading', { name: 'Dashboard' })).toBeVisible();
    await expect(page.getByTestId('user-avatar')).toBeVisible();
  });

  test('displays accessible error message on invalid credentials', async ({ page }) => {
    const loginPage = new LoginPage(page);
    await loginPage.goto();

    await loginPage.login('invalid@example.com', 'wrongpassword');

    const alert = page.getByRole('alert');
    await expect(alert).toBeVisible();
    await expect(alert).toContainText('Invalid email or password');
  });
});
```

## Verification Checklist
- [ ] Tests use resilient role-based locators (`getByRole`, `getByLabel`).
- [ ] No arbitrary sleeps (`waitForTimeout`) exist in the test suite.
- [ ] Axe-core accessibility scans pass on all critical views.
- [ ] Tests execute and pass across Chromium, Firefox, and WebKit.
- [ ] Failures capture screenshots, console logs, and Playwright trace archives.

## Expected Outputs & Deliverables
1. **Test Suites (`tests/e2e/*.spec.ts`)**: Modular, resilient end-to-end specifications.
2. **Page Object Models (`tests/pages/*.page.ts`)**: Reusable UI harnesses.
3. **Playwright Configuration (`playwright.config.ts`)**: Multi-browser, reporter, and artifact settings.
4. **HTML Test Report**: Visual execution summary detailing passed, failed, and accessibility results.