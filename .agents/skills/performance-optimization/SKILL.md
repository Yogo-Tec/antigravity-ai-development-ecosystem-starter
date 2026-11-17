---
name: performance-optimization
description: Profile, diagnose, and resolve latency, memory, rendering, and throughput bottlenecks across frontend, backend, database, and network layers.
---

# Performance Optimization

## Overview & Objectives
The Performance Optimization skill systematically identifies, profiles, diagnoses, and eliminates performance bottlenecks across the full software stack. It establishes quantitative baseline benchmarks, leverages profiling flamegraphs and metrics, applies targeted architectural and code-level enhancements, and validates gains without compromising code correctness or introducing functional regressions.

## Step-by-Step Specialized Workflow

### 1. Quantitative Baseline & Telemetry Gathering
- Establish measurable, reproducible performance baselines prior to modifying code:
  - **Frontend / Web Vitals**: Largest Contentful Paint (LCP < 2.5s), Interaction to Next Paint (INP < 200ms), Cumulative Layout Shift (CLS < 0.1), Time to First Byte (TTFB < 800ms).
  - **Backend Services**: p50, p95, and p99 request latencies, requests per second (RPS), error rates under load.
  - **Database & Storage**: Query execution duration, active connection counts, buffer cache hit ratios.
  - **System Resources**: CPU utilization, heap memory growth, garbage collection pauses, I/O wait times.

### 2. Profiling & Bottleneck Isolation
- Avoid speculative optimization; always profile first to locate the primary bottleneck:
  - Generate CPU flamegraphs to detect compute-intensive loops and inefficient algorithms.
  - Capture heap snapshots to detect memory leaks, retainers, and unbounded cache growth.
  - Inspect network waterfalls for blocking resource loads, redundant redirects, or payload bloat.
  - Run database query analysis using `EXPLAIN (ANALYZE, BUFFERS)` to detect unindexed sequential scans.

### 3. Frontend & Rendering Optimization
- Implement route-based and component-level code splitting using dynamic imports.
- Optimize web assets: convert imagery to WebP/AVIF formats, apply responsive `srcset`, specify explicit image dimensions to eliminate CLS.
- Implement asset preloading/prefetching for critical resources (`<link rel="preload">`).
- Optimize client-side reactivity: decouple state to eliminate unnecessary component re-renders.

### 4. Backend & API Throughput Tuning
- Introduce high-performance in-memory caching (Redis / Memcached) for read-heavy, low-churn datasets.
- Implement asynchronous task offloading via background queues (BullMQ, Celery, RabbitMQ) for non-blocking operations.
- Enable gzip / Brotli HTTP compression for text, JSON, and SVG responses.
- Configure connection pooling for database and external HTTP clients to eliminate connection handshake overhead.

### 5. Database & Query Optimization
- Eliminate N+1 query patterns by using eager loading, batching (`DataLoader`), or SQL joins.
- Create covering composite indexes tailored to high-frequency query filters and sorting clauses.
- Implement keyset / cursor-based pagination to replace expensive large-offset queries (`OFFSET 100000`).

### 6. Verification & Regression Benchmarking
- Re-run benchmark suites under identical test conditions to quantify performance improvements.
- Verify that 100% of functional unit, integration, and E2E tests pass, ensuring zero behavioral regressions.

## Practical Examples

### Eliminating N+1 Query Bottleneck with Batching
```typescript
// BEFORE: N+1 Database Queries (Slow: 1 query for authors + N queries for books)
// If there are 100 authors, this triggers 101 database roundtrips (~850ms)
async function getAuthorsWithBooksBefore() {
  const authors = await db('authors').select('*');
  const results = [];
  for (const author of authors) {
    const books = await db('books').where({ author_id: author.id });
    results.push({ ...author, books });
  }
  return results;
}

// AFTER: Optimized with single batch query (Fast: exactly 2 queries, ~25ms)
async function getAuthorsWithBooksAfter() {
  const authors = await db('authors').select('*');
  const authorIds = authors.map((a) => a.id);
  
  // Single query with WHERE IN
  const allBooks = await db('books').whereIn('author_id', authorIds);
  
  // Group in-memory with O(N) Map lookup
  const booksByAuthor = new Map<string, typeof allBooks>();
  for (const book of allBooks) {
    const list = booksByAuthor.get(book.author_id) || [];
    list.push(book);
    booksByAuthor.set(book.author_id, list);
  }

  return authors.map((author) => ({
    ...author,
    books: booksByAuthor.get(author.id) || [],
  }));
}
```

### Core Web Vitals Optimization Checklist
```markdown
| Metric | Target | Common Root Causes | Proven Remediation Strategy |
| :--- | :--- | :--- | :--- |
| **LCP** (Largest Contentful Paint) | < 2.5s | Slow server TTFB, render-blocking CSS/JS, slow hero image | Preload hero image; implement CDN edge caching; inline critical CSS |
| **INP** (Interaction to Next Paint) | < 200ms | Heavy JavaScript execution blocking main thread during user input | Break long tasks with `scheduler.yield()`; debounce search inputs; move work to Web Workers |
| **CLS** (Cumulative Layout Shift) | < 0.1 | Images without dimensions, dynamically injected ads/banners | Specify explicit `width` and `height` attributes; reserve layout space using CSS aspect-ratio |
| **TTFB** (Time to First Byte) | < 800ms | Uncached database queries, synchronous external API calls | Implement Redis response caching; optimize SQL queries; use streaming SSR |
```

## Verification Checklist
- [ ] Baseline performance metrics recorded before any code changes.
- [ ] Bottleneck isolated using profiling tools (flamegraphs, heap dumps, query plans).
- [ ] Core Web Vitals meet Google thresholds (LCP < 2.5s, INP < 200ms, CLS < 0.1).
- [ ] API p95/p99 latency and throughput verified under load.
- [ ] All functional test suites pass without regression.

## Expected Outputs & Deliverables
1. **Performance Audit & Benchmark Report (`docs/PERFORMANCE.md`)**: Before/after comparative metrics table, profiling evidence, and architectural explanations.
2. **Targeted Code Optimizations**: Surgical pull requests resolving isolated bottlenecks.
3. **Automated Performance Regression Tests**: CI load test scripts or Lighthouse CI assertions preventing future degradation.