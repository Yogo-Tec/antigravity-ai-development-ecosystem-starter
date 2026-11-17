---
name: api-development
description: Design API contracts, validation, authentication, authorization, rate limits, pagination, idempotency and error formats.
---

# API Development

## Overview & Objectives
The API Development skill governs the contract design, documentation, and standardisation of application programming interfaces (REST, GraphQL, RPC). It establishes rigorous contract-first specifications (OpenAPI 3.1), uniform error envelopes (RFC 7807), resilient pagination, idempotency controls, and rate-limiting protocols.

## Step-by-Step Specialized Workflow

### 1. Contract-First API Specification
- Define API contracts in OpenAPI 3.1 or GraphQL schema before writing endpoint logic.
- Standardize RESTful URI resource naming: plural nouns (`/v1/orders`), nested resources (`/v1/orders/{orderId}/items`).
- Use standard HTTP methods correctly: `GET` (safe/idempotent), `POST` (non-idempotent create), `PUT` (idempotent replace), `PATCH` (partial update), `DELETE` (idempotent remove).

### 2. Standardization of Payloads & Envelopes
- Use consistent casing convention across JSON payloads (e.g., `camelCase` or `snake_case`).
- Format all temporal values as ISO 8601 UTC strings (`2026-11-17T16:40:00Z`).
- Format monetary values with integer amounts in the smallest currency unit (e.g., `cents: 4500` for $45.00).

### 3. Pagination, Sorting & Filtering Standards
- Standardize on cursor-based pagination for high-volume or dynamic datasets:
  `GET /v1/products?limit=20&starting_after=prod_987`
- Provide metadata in response headers or meta envelopes (`has_more`, `next_cursor`, `total_count`).
- Implement deterministic sorting (`sort=created_at:desc,id:desc`) to prevent cursor pagination skipping.

### 4. Idempotency Protocol for Mutating Requests
- Support `Idempotency-Key` header on all critical POST and mutation requests.
- Store idempotency key, request fingerprint, and cached response in an atomic store (Redis) with TTL (e.g., 24 hours).
- Return the cached response with an `Idempotent-Replayed: true` header if a duplicate request arrives.

### 5. Rate Limiting & Abuse Prevention
- Enforce token-bucket or sliding-window rate limiting on public and authenticated endpoints.
- Return standard rate-limiting headers:
  - `X-RateLimit-Limit`: Maximum requests permitted per window.
  - `X-RateLimit-Remaining`: Remaining request quota.
  - `X-RateLimit-Reset`: Unix timestamp when the window resets.
- Return HTTP `429 Too Many Requests` with a `Retry-After` header when quotas are exceeded.

### 6. Standardized Error Handling (RFC 7807 Problem Details)
- Return error responses adhering to the RFC 7807 standard:
  `{ type, title, status, detail, instance, invalid_params }`.

### 7. Automated Contract Testing
- Execute automated contract testing against OpenAPI specs using tools like Prism or Dredd to detect contract drift.

## Practical Examples

### RFC 7807 Problem Details Error Envelope
```json
{
  "type": "https://api.example.com/errors/invalid-order-payload",
  "title": "Invalid Request Parameters",
  "status": 422,
  "detail": "Two fields failed validation constraints during order submission.",
  "instance": "/v1/orders/req_abc123",
  "invalid_params": [
    {
      "name": "items[0].quantity",
      "reason": "Quantity must be an integer greater than zero",
      "value": 0
    },
    {
      "name": "shippingAddress.postalCode",
      "reason": "Invalid postal code format for country US",
      "value": "invalid-zip"
    }
  ]
}
```

## Verification Checklist
- [ ] API endpoints are fully documented in an OpenAPI 3.1 or GraphQL schema.
- [ ] Mutating endpoints support the `Idempotency-Key` header.
- [ ] Cursor-based pagination is implemented for all list endpoints.
- [ ] Rate-limit headers are emitted and 429 status returned when limits are breached.
- [ ] Errors strictly follow the RFC 7807 schema.
- [ ] Automated contract tests verify that implementation matches the OpenAPI specification.

## Expected Outputs & Deliverables
1. **OpenAPI Specification (`docs/openapi.yaml`)**: Versioned, machine-readable contract.
2. **API Route Handlers**: Controllers implementing validation, rate limiting, and business logic.
3. **Contract Test Suite**: Automated tests verifying endpoint adherence to spec.