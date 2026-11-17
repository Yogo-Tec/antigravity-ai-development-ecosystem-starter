---
name: security-review
description: Review authentication, authorization, input validation, injection, XSS, CSRF, SSRF, secrets, dependencies and data exposure. Test only authorized systems.
---

# Security Review

## Overview & Objectives
The Security Review skill conducts rigorous defensive security evaluations across application architecture, source code, dependencies, and deployment configurations. It assesses systems against the OWASP Top 10, CWE/SANS Top 25, cryptography standards, and least-privilege principles to identify and eliminate vulnerabilities before deployment.

## Step-by-Step Specialized Workflow

### 1. Threat Modeling & Attack Surface Enumeration
- Map system entry points: public APIs, webhooks, admin panels, file uploads, third-party callbacks.
- Identify sensitive assets: customer PII, payment credentials, authentication tokens, cryptographic keys.
- Diagram trust boundaries and data flow across public, application, and internal database tiers.

### 2. Authentication & Session Management Audit
- Verify password hashing standards (Argon2id or bcrypt with appropriate work factor).
- Inspect token lifecycle: JWT signing algorithms (forbid `none`, enforce RS256/EdDSA or strong HMAC), expiration TTL, revocation mechanisms.
- Audit session cookies: enforce `Secure`, `HttpOnly`, and `SameSite=Strict` or `Lax` flags.

### 3. Authorization & Access Control (BOLA/IDOR Prevention)
- Inspect every endpoint for Broken Object-Level Authorization: verify that object IDs in requests are checked against the authenticated user's organization/tenant.
- Verify role-based access control (RBAC): ensure privilege escalation is impossible through parameter tampering.

### 4. Injection & Input Sanitization
- SQL/NoSQL Injection: verify 100% parameterization; ban raw string concatenation in queries.
- Cross-Site Scripting (XSS): verify output encoding, framework auto-escaping, and strict Content Security Policy (CSP).
- Server-Side Request Forgery (SSRF): validate and whitelist all outbound URLs fetched by the server; block internal RFC 1918 IPs and metadata endpoints (e.g., `169.254.169.254`).

### 5. Secrets Management & Supply Chain Audit
- Scan repository for committed secrets using tools like Gitleaks or TruffleHog.
- Audit dependencies using vulnerability scanners (Trivy, Snyk, `npm audit`) to identify known CVEs.
- Review third-party dependencies for unmaintained status, risky install scripts, or license incompatibility.

### 6. Security Headers & Transport Security
- Enforce modern HTTP security headers:
  - `Content-Security-Policy`: strict script and connect directives.
  - `Strict-Transport-Security`: `max-age=63072000; includeSubDomains; preload`.
  - `X-Content-Type-Options: nosniff`.
  - `X-Frame-Options: DENY`.
  - `Referrer-Policy: strict-origin-when-cross-origin`.

## Practical Examples

### Security Audit Finding & Remediation (SSRF Vulnerability)
```markdown
### [CRITICAL] Server-Side Request Forgery (SSRF) in Webhook Dispatcher
**Severity**: Critical (CVSS 9.1)
**Location**: `src/services/webhook.service.ts:34`
**Vulnerability**: The webhook service sends an HTTP POST request to user-supplied URLs without restricting destination IP addresses. An attacker can supply `http://169.254.169.254/latest/meta-data/` to extract cloud IAM instance credentials.

**Vulnerable Code**:
```typescript
await axios.post(userSuppliedUrl, payload);
```

**Remediation**:
Validate that the target URL resolves exclusively to public IP addresses before dispatching:
```typescript
import dns from 'dns/promises';
import ipaddr from 'ipaddr.js';

async function validateOutboundUrl(targetUrl: string): Promise<void> {
  const parsed = new URL(targetUrl);
  if (!['http:', 'https:'].includes(parsed.protocol)) {
    throw new Error('Invalid protocol');
  }

  const addresses = await dns.lookup(parsed.hostname, { all: true });
  for (const { address } of addresses) {
    const ip = ipaddr.parse(address);
    if (ip.range() !== 'unicast') {
      throw new Error(`Forbidden destination IP range: ${ip.range()}`);
    }
  }
}
```
```

## Verification Checklist
- [ ] No hardcoded secrets or credentials exist in code, configs, or git history.
- [ ] All database queries use parameterized interfaces.
- [ ] Every API endpoint enforces tenant-scoped authorization (prevents BOLA/IDOR).
- [ ] Modern security headers (CSP, HSTS, X-Content-Type-Options) are configured.
- [ ] Third-party dependencies have 0 Critical or High severity CVEs.

## Expected Outputs & Deliverables
1. **Security Audit Report (`docs/SECURITY_AUDIT.md`)**: Categorized findings with CVSS scores and remediation steps.
2. **Security Headers Configuration**: Web server or framework middleware rules.
3. **Dependency Vulnerability Report**: Scan results and remediation roadmap for third-party libraries.