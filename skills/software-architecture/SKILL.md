---
name: software-architecture
description: Design modules, data flows, API contracts, database design, security boundaries, scalability and failure handling. Explain trade-offs.
---

# Software Architecture

## Overview & Objectives
The Software Architecture skill defines the structural foundations of the application. It governs module boundaries, data flow topologies, API contracts, persistence strategies, trust zones, and resilience patterns. Every architectural decision must articulate trade-offs, operational consequences, and alignment with the requirements.

## Step-by-Step Specialized Workflow

### 1. Domain Modeling & Module Boundaries
- Decompose the problem domain into bounded contexts with clear separation of concerns (Domain-Driven Design).
- Establish cohesion and coupling guidelines: high internal cohesion, loose external coupling via typed contracts.
- Define dependency rules (e.g., domain logic must not depend on transport or database implementations).

### 2. Data Flow & Communication Topology
- Select appropriate communication models: synchronous RPC/REST/GraphQL vs. asynchronous event-driven messaging (Kafka/RabbitMQ/Redis PubSub).
- Diagram end-to-end data flows covering read-heavy, write-heavy, and background processing pipelines.
- Define transactional boundaries and consistency models (ACID vs. Eventual Consistency).

### 3. Architecture Decision Records (ADRs)
- Document every significant architectural decision in an immutable ADR.
- Record: Context, Decision, Alternatives Considered, Trade-offs, and Consequences.

### 4. Security & Trust Boundaries
- Delineate security perimeters: public internet, API gateway, internal microservices, private database subnets.
- Define authentication verification points, token validation strategies, and service-to-service mTLS or signed headers.
- Specify zero-trust principles: never trust inputs from clients or internal network segments without validation.

### 5. Scalability & Performance Strategy
- Design for stateless application tier to allow horizontal auto-scaling.
- Define multi-tier caching architectures (client-side, CDN edge, reverse-proxy, distributed in-memory cache).
- Formulate database read/write splitting, partitioning, or sharding plans when scale necessitates.

### 6. Resilience & Failure Mode Analysis
- Design circuit breakers, timeouts, retry policies with jittered exponential backoff, and fallback degradation strategies.
- Formulate disaster recovery and business continuity plans (RTO, RPO, backup verification).

## Practical Examples

### Architecture Decision Record (ADR-001)
```markdown
# ADR-001: Asynchronous Event-Driven Order Processing

## Status
Accepted

## Context
During peak flash sales, incoming order volume exceeds the capacity of our third-party fulfillment ERP. Synchronous REST calls to the ERP during checkout create bottleneck timeouts (p99 > 8s) and result in checkout failures.

## Decision
Decouple the checkout transaction from ERP synchronization.
1. The Checkout API writes the order to PostgreSQL in an ACID transaction with status `PENDING_FULFILLMENT`.
2. An Outbox pattern records the `OrderPlaced` event in the same transaction.
3. A background worker polls/streams the outbox and publishes the event to RabbitMQ.
4. An ERP Consumer service consumes events with rate limiting and exponential backoff.

## Trade-offs & Consequences
- **Pros**:
  - Checkout API response time reduced from 2.4s to 120ms.
  - Zero order drops if ERP experiences downtime.
- **Cons**:
  - Introduces eventual consistency: customer sees order as "Processing" rather than "Confirmed with Fulfillment".
  - Requires maintaining RabbitMQ infrastructure and dead-letter queues (DLQ).
```

## Verification Checklist
- [ ] Domain boundaries and module responsibilities are clearly documented.
- [ ] End-to-end data flows are diagrammed for core read and write operations.
- [ ] All architectural choices include an ADR detailing trade-offs and alternatives.
- [ ] Trust zones and security boundaries are defined.
- [ ] Failure modes, timeouts, circuit breakers, and retry strategies are specified.

## Expected Outputs & Deliverables
1. **Architecture Specification (`docs/ARCHITECTURE.md`)**: Comprehensive system topology, data flows, and component specs.
2. **Architecture Decision Records (`docs/adr/ADR-xxx.md`)**: Versioned rationale for foundational choices.
3. **Data Flow & Sequence Diagrams**: Visual flows documenting system behavior.