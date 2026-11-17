---
name: monitoring
description: Design, configure, and maintain telemetry, health probes, metrics, structured alerting, dashboards, log aggregation, and error tracking.
---

# Monitoring & Observability

## Overview & Objectives
The Monitoring & Observability skill designs, implements, and maintains robust telemetry across all system components. It establishes Service Level Objectives (SLOs) based on the Four Golden Signals, implements resilient health and readiness probes, instruments custom metrics (Prometheus / OpenTelemetry), standardizes structured distributed tracing, and configures actionable, symptom-based alerting.

## Step-by-Step Specialized Workflow

### 1. Telemetry Architecture & SLI/SLO Framework
- Define Service Level Indicators (SLIs) and Service Level Objectives (SLOs) around the **Four Golden Signals**:
  1. **Latency**: Duration taken to service requests (p50, p95, p99).
  2. **Traffic**: Demand placed on the system (requests per second, concurrent connections).
  3. **Errors**: Rate of requests that fail (HTTP 5xx status codes, unhandled exceptions).
  4. **Saturation**: Utilization of constrained system resources (CPU, memory, database connection pool, disk I/O).
- Establish Error Budgets and alert when burn rate threatens SLO violation.

### 2. Multi-Stage Health Probes
- Implement distinct probe endpoints:
  - **Liveness Probe (`/health/live`)**: Lightweight check returning HTTP 200 if the process is alive. Fails only if the process is deadlocked or unrecoverable (triggers container restart).
  - **Readiness Probe (`/health/ready`)**: Verifies that the service is initialized and downstream dependencies (database, cache, queues) are reachable. Fails temporarily to shed traffic if overloaded.
  - **Startup Probe (`/health/startup`)**: Used for slow-starting applications to delay liveness checks.

### 3. Metric Instrumentation (Prometheus / OpenTelemetry)
- Instrument application code using standard metric primitives:
  - **Counters**: Monotonically increasing values (e.g., `http_requests_total`, `orders_placed_total`).
  - **Gauges**: Values that can increase and decrease (e.g., `active_websocket_connections`, `memory_heap_bytes`).
  - **Histograms**: Distribution of values across buckets (e.g., `http_request_duration_seconds_bucket`).
- Expose standardized metrics endpoint (e.g., `/metrics`) for scraping by Prometheus or OpenTelemetry Collector.

### 4. Distributed Tracing & Correlation
- Inject distributed trace headers (`traceparent`, W3C Trace Context) into all incoming and outgoing network calls.
- Correlate logs and traces by injecting `trace_id` and `span_id` into all structured JSON log entries.
- Trace asynchronous message queues by propagating trace context through message metadata headers.

### 5. Automated Error Tracking & Crash Reporting
- Integrate crash reporting frameworks (e.g., Sentry, OpenTelemetry Exceptions) across frontend and backend tiers.
- Capture actionable diagnostic context: stack traces, release versions, environment tags, user IDs (anonymized), and breadcrumb events leading to the error.
- Group errors intelligently to eliminate alert noise.

### 6. Symptom-Based Alerting & Runbook Linkage
- Configure alerts triggered by user-impacting symptoms (e.g., high error rate, elevated latency) rather than noisy low-level causes (e.g., high CPU).
- Categorize alerts by severity:
  - **P1 - Critical (Page)**: Service is down or customer-facing operations are failing. Requires immediate human response.
  - **P2 - High (Ticket/Slack)**: Degraded performance or redundancy lost. Requires investigation during working hours.
  - **P3 - Warning**: Approaching capacity limits.
- **Mandatory Policy**: Every alert must include a direct link to an actionable operational runbook (`docs/runbooks/...`).

## Practical Examples

### Robust Liveness and Readiness Probe Implementation (Node.js/Express)
```typescript
import { Router, Request, Response } from 'express';
import { db } from '../db';
import { redisClient } from '../cache';

export const healthRouter = Router();

// Liveness Probe: Quick check that process event loop is active
healthRouter.get('/health/live', (_req: Request, res: Response) => {
  res.status(200).json({ status: 'live', timestamp: new Date().toISOString() });
});

// Readiness Probe: Verifies critical downstream dependencies
healthRouter.get('/health/ready', async (_req: Request, res: Response) => {
  const checks: Record<string, 'ok' | 'failed'> = {};
  let isReady = true;

  // Check Database
  try {
    await db.raw('SELECT 1');
    checks.database = 'ok';
  } catch (err) {
    checks.database = 'failed';
    isReady = false;
  }

  // Check Cache (Redis)
  try {
    const ping = await redisClient.ping();
    checks.redis = ping === 'PONG' ? 'ok' : 'failed';
  } catch (err) {
    checks.redis = 'failed';
    isReady = false;
  }

  const statusCode = isReady ? 200 : 503;
  return res.status(statusCode).json({
    status: isReady ? 'ready' : 'unavailable',
    timestamp: new Date().toISOString(),
    dependencies: checks,
  });
});
```

### Prometheus Alerting Rule Specification
```yaml
groups:
  - name: api_service_alerts
    rules:
      - alert: HighApiErrorRate
        expr: |
          sum(rate(http_requests_total{status=~"5.."}[5m])) 
          / 
          sum(rate(http_requests_total[5m])) * 100 > 1.0
        for: 3m
        labels:
          severity: critical
          tier: backend
        annotations:
          summary: "API 5xx error rate exceeds 1% (current: {{ $value | printf \"%.2f\" }}%)"
          description: "Service {{ $labels.service }} has experienced an elevated error rate for over 3 minutes."
          runbook_url: "https://docs.example.com/runbooks/high-error-rate.html"

      - alert: ElevatedApiLatencyP95
        expr: histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket[5m])) by (le, service)) > 0.8
        for: 5m
        labels:
          severity: warning
          tier: backend
        annotations:
          summary: "API p95 latency exceeds 800ms (current: {{ $value | printf \"%.2f\" }}s)"
          runbook_url: "https://docs.example.com/runbooks/api-latency.html"
```

## Verification Checklist
- [ ] `/health/live` and `/health/ready` probe endpoints are implemented and tested.
- [ ] Readiness probe tests external dependencies (database, cache, queues).
- [ ] Metrics export endpoint (`/metrics`) provides Four Golden Signals metrics.
- [ ] Correlation IDs (`trace_id`) are injected into all structured JSON logs.
- [ ] Automated error tracking is integrated with breadcrumbs and release tags.
- [ ] Every alert definition includes severity and an actionable runbook URL.

## Expected Outputs & Deliverables
1. **Observability Architecture Guide (`docs/MONITORING.md`)**: Comprehensive telemetry design and SLO specifications.
2. **Health Probe Endpoints**: Production-tested liveness and readiness handlers.
3. **Alerting Rules & Dashboards**: Prometheus alert definitions and Grafana dashboard configurations.