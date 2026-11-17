---
name: backend-development
description: Build backend services with input validation, authorization, error handling, structured logging and tests. Never trust client-side validation alone.
---

# Backend Development

## Overview & Objectives
The Backend Development skill enforces high-integrity, resilient server-side engineering. It mandates multi-layered defense: strict input validation at system boundaries, mandatory authentication and authorization checks on every operation, robust transaction management, normalized error handling (RFC 7807), structured JSON logging with correlation IDs, and comprehensive test coverage.

## Step-by-Step Specialized Workflow

### 1. Boundary Defense & Input Validation
- Validate every incoming request payload at the controller layer before invoking business logic.
- Utilize strict schema validation libraries (e.g., Zod, Joi, Pydantic, class-validator).
- Reject extraneous unexpected fields (strict schema mode) and sanitize text inputs against injection attacks.

### 2. Authentication & Context Propagation
- Extract and verify identity tokens (JWT, session cookies) at middleware level.
- Attach the authenticated user principal (User ID, Tenant ID, Roles) to the execution context / request object.
- Ensure correlation IDs (`X-Correlation-ID`) are generated or propagated across all downstream calls.

### 3. Authorization & Tenant Isolation
- Execute authorization policies (RBAC, ABAC) explicitly before executing business operations.
- Enforce multi-tenant data boundaries: every database query must scope by `tenant_id` / `user_id` to prevent Insecure Direct Object References (IDOR/BOLA).

### 4. Business Logic & Transaction Management
- Keep domain business logic decoupled from HTTP transport frameworks.
- Wrap multi-step mutations in ACID transactions to ensure data consistency.
- Implement idempotency keys for non-idempotent mutation operations (payments, order creation).

### 5. Normalized Error Handling & RFC 7807
- Catch internal exceptions and map them to standardized, clean API error envelopes.
- Never leak database connection strings, stack traces, or internal error details to client responses.

### 6. Structured JSON Logging & Observability
- Output all logs in structured JSON format with standard fields: `timestamp`, `level`, `correlation_id`, `user_id`, `service`, `message`, `duration_ms`.
- Redact sensitive data (passwords, payment details, access tokens, PII) before writing to logs.

### 7. Automated Testing Strategy
- Write unit tests for core domain logic using mocked dependencies.
- Write integration tests against ephemeral databases (e.g., Testcontainers) validating transactions and boundary schemas.

## Practical Examples

### Controller & Service Handler with Validation, Transaction & Logging
```typescript
import { Request, Response, NextFunction } from 'express';
import { z } from 'zod';
import { logger } from '../utils/logger';
import { db } from '../db';

const CreateInvoiceSchema = z.object({
  customerId: z.string().uuid(),
  amountCents: z.number().int().positive(),
  currency: z.enum(['USD', 'EUR', 'GBP']),
  description: z.string().max(255).optional(),
});

export async function createInvoiceHandler(req: Request, res: Response, next: NextFunction) {
  const correlationId = req.headers['x-correlation-id'] as string;
  const user = req.user; // Injected by auth middleware

  // 1. Strict Boundary Validation
  const parseResult = CreateInvoiceSchema.safeParse(req.body);
  if (!parseResult.success) {
    return res.status(400).json({
      type: 'https://api.example.com/errors/validation-failed',
      title: 'Validation Error',
      status: 400,
      detail: 'Invalid invoice payload',
      errors: parseResult.error.flatten().fieldErrors,
      correlationId,
    });
  }

  const { customerId, amountCents, currency, description } = parseResult.data;

  // 2. Authorization Check (Tenant Scoping)
  if (!user.permissions.includes('invoices:create')) {
    logger.warn({ correlationId, userId: user.id }, 'Unauthorized invoice creation attempt');
    return res.status(403).json({
      type: 'https://api.example.com/errors/forbidden',
      title: 'Forbidden',
      status: 403,
      detail: 'Insufficient permissions to create invoices',
      correlationId,
    });
  }

  // 3. Transaction Execution
  try {
    const invoice = await db.transaction(async (trx) => {
      // Verify customer belongs to the user's tenant
      const customer = await trx('customers')
        .where({ id: customerId, tenant_id: user.tenantId })
        .first();

      if (!customer) {
        throw new Error('CustomerNotFound');
      }

      const [newInvoice] = await trx('invoices')
        .insert({
          customer_id: customerId,
          tenant_id: user.tenantId,
          amount_cents: amountCents,
          currency,
          description,
          status: 'ISSUED',
          created_at: new Date(),
        })
        .returning('*');

      return newInvoice;
    });

    logger.info({ correlationId, invoiceId: invoice.id, tenantId: user.tenantId }, 'Invoice created successfully');
    return res.status(201).json(invoice);
  } catch (error) {
    if (error instanceof Error && error.message === 'CustomerNotFound') {
      return res.status(404).json({
        type: 'https://api.example.com/errors/not-found',
        title: 'Resource Not Found',
        status: 404,
        detail: 'The specified customer was not found in your organization',
        correlationId,
      });
    }

    logger.error({ correlationId, error }, 'Unhandled error in createInvoiceHandler');
    return next(error);
  }
}
```

## Verification Checklist
- [ ] Every endpoint validates inputs against an explicit schema before processing.
- [ ] Queries enforce tenant and user isolation parameters (prevent IDOR).
- [ ] Mutating operations use database transactions.
- [ ] Sensitive fields (passwords, tokens, PII) are redacted in log outputs.
- [ ] Error responses follow standard error schemas without exposing stack traces.
- [ ] Integration tests verify database persistence, rollback on failure, and auth rejection.

## Expected Outputs & Deliverables
1. **Service & Controller Modules (`src/services/...`, `src/controllers/...`)**: Production-ready backend logic.
2. **Middleware Implementations**: Authentication, authorization, validation, and error-handling layers.
3. **Integration Test Suite**: Automated tests validating API contracts and transactional integrity.