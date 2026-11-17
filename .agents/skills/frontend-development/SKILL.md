---
name: frontend-development
description: Build reusable typed frontend components, follow project conventions, handle all UI states, ensure responsive accessibility and add tests.
---

# Frontend Development

## Overview & Objectives
The Frontend Development skill guides the engineering of performant, maintainable, typed client-side components. It enforces strict TypeScript typing, separation of presentation and business logic, comprehensive handling of all UI lifecycle states, responsive design, and robust automated testing.

## Step-by-Step Specialized Workflow

### 1. Component Architecture & State Management
- Determine component classification: Presentational (pure, stateless) vs. Container/Smart (data-fetching, stateful).
- Apply server/client component boundaries correctly in SSR frameworks (Next.js/Nuxt).
- Scope state appropriately: local state (`useState`/`ref`) -> compound state (`useReducer`) -> global/server cache (`React Query`/`Zustand`/`Pinia`).

### 2. Strict Type Safety & Contracts
- Write explicit TypeScript interfaces/types for all component props, emitting zero unvetted `any`.
- Utilize discriminated unions for complex UI state configurations to prevent impossible states.

### 3. Exhaustive UI Lifecycle State Handling
- Explicitly implement and render:
  - **Idle / Initial**: Clean starting state.
  - **Loading**: Accessible skeleton states preserving layout dimensions to prevent Cumulative Layout Shift (CLS).
  - **Empty**: Contextual guidance when lists/queries return zero results.
  - **Error**: Graceful error boundaries with actionable retry mechanisms.
  - **Success**: Clear confirmation and transition.

### 4. Accessible & Robust Forms
- Pair all form inputs with explicit `<label>` elements or `aria-label`.
- Integrate client-side validation libraries (e.g., Zod, Yup) for real-time, accessible validation feedback.
- Wire validation errors to inputs using `aria-invalid="true"` and `aria-describedby="error-id"`.

### 5. Performance & Asset Optimization
- Implement code-splitting and dynamic imports for heavy non-critical components.
- Optimize images using modern formats (WebP, AVIF) with explicit width/height dimensions.
- Prevent unnecessary re-renders using memoization (`useMemo`, `useCallback`) strategically where profiling indicates necessity.

### 6. Automated Component Verification
- Write unit tests using React Testing Library, Vitest, or Jest asserting user-centric behaviour (`getByRole`, `getByLabelText`).
- Test user interactions (typing, clicking, keyboard navigation) and verify DOM state updates.

## Practical Examples

### Typed Component with State Handling & Zod Form Validation
```tsx
import React, { useState } from 'react';
import { z } from 'zod';

const NewsletterSchema = z.object({
  email: z.string().email('Please enter a valid email address'),
});

type NewsletterInput = z.infer<typeof NewsletterSchema>;

interface NewsletterFormProps {
  onSubscribe: (data: NewsletterInput) => Promise<void>;
}

export const NewsletterForm: React.FC<NewsletterFormProps> = ({ onSubscribe }) => {
  const [email, setEmail] = useState('');
  const [status, setStatus] = useState<'idle' | 'loading' | 'success' | 'error'>('idle');
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setErrorMessage(null);

    const validation = NewsletterSchema.safeParse({ email });
    if (!validation.success) {
      setErrorMessage(validation.error.errors[0]?.message ?? 'Invalid input');
      return;
    }

    try {
      setStatus('loading');
      await onSubscribe(validation.data);
      setStatus('success');
      setEmail('');
    } catch (err) {
      setStatus('error');
      setErrorMessage(err instanceof Error ? err.message : 'Subscription failed. Please try again.');
    }
  };

  return (
    <form onSubmit={handleSubmit} noValidate className="space-y-4">
      <div>
        <label htmlFor="newsletter-email" className="block text-sm font-medium text-gray-700">
          Work Email
        </label>
        <input
          id="newsletter-email"
          type="email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          aria-invalid={errorMessage ? 'true' : 'false'}
          aria-describedby={errorMessage ? 'newsletter-error' : undefined}
          disabled={status === 'loading'}
          className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
          placeholder="name@company.com"
        />
        {errorMessage && (
          <p id="newsletter-error" role="alert" className="mt-1 text-sm text-red-600">
            {errorMessage}
          </p>
        )}
      </div>

      <button
        type="submit"
        disabled={status === 'loading'}
        className="inline-flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 disabled:opacity-50"
      >
        {status === 'loading' ? 'Subscribing...' : 'Subscribe'}
      </button>

      {status === 'success' && (
        <p role="status" className="text-sm text-green-600 font-medium">
          Thank you for subscribing!
        </p>
      )}
    </form>
  );
};
```

## Verification Checklist
- [ ] Strict TypeScript typing with no unvalidated `any`.
- [ ] All inputs have associated labels and accessible error descriptors.
- [ ] Loading, error, empty, and success states are visually represented.
- [ ] Images and fonts specify dimensions to eliminate layout shifts (CLS = 0).
- [ ] Unit tests cover validation rules, user actions, and error handling.

## Expected Outputs & Deliverables
1. **Component Source Files (`src/components/...`)**: Fully typed, production-ready components.
2. **Unit Test Suite (`src/components/...*.test.tsx`)**: Automated tests validating behaviour and accessibility.
3. **Storybook Story or Demo Harness**: Visual fixture demonstrating all component states.