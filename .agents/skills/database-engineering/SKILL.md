---
name: database-engineering
description: Design schemas, indexes, transactions, migrations, backup and recovery. Require approval for destructive production migrations.
---

# Database Engineering

## Overview & Objectives
The Database Engineering skill governs data modeling, query optimization, transaction management, schema migrations, and disaster recovery. It enforces zero-downtime migration standards, optimal indexing patterns, foreign key referential integrity, and strict human approval gates before executing destructive production changes.

## Step-by-Step Specialized Workflow

### 1. Conceptual, Logical & Physical Data Modeling
- Design normalized schemas (3NF) for transactional systems; apply denormalization deliberately and document rationale.
- Select appropriate data types: UUIDv7 or BIGINT for primary keys, TIMESTAMPTZ for temporal values, NUMERIC for financial values.
- Enforce foreign keys and cascade rules explicitly to prevent orphaned records.

### 2. Indexing Strategy & Query Optimization
- Index all foreign key columns to eliminate table scan locks during joins and deletions.
- Design composite indexes with optimal column ordering: Equality columns first, followed by Range columns (`WHERE status = 'ACTIVE' AND created_at > ...`).
- Analyze queries using `EXPLAIN (ANALYZE, BUFFERS)` to diagnose sequential scans and excessive buffer allocations.

### 3. Transaction Isolation & Concurrency Control
- Choose appropriate isolation levels (Read Committed default, Serializable for financial ledgers).
- Prevent race conditions using optimistic locking (`version` column) or explicit pessimistic row locking (`SELECT ... FOR UPDATE`).
- Order lock acquisition consistently across transactions to prevent deadlocks.

### 4. Zero-Downtime Migration Engineering
- Follow the expand-and-contract pattern for schema migrations:
  - Step 1: Add new nullable column / new table.
  - Step 2: Deploy application code writing to both old and new columns.
  - Step 3: Backfill historical data in background batches.
  - Step 4: Deploy application code reading exclusively from new column.
  - Step 5: Drop old column in a final migration.
- Always provide backward-compatible `down` migrations.

### 5. Destructive Migration Guardrails
- Identify destructive operations: `DROP TABLE`, `DROP COLUMN`, changing column types, truncating data.
- **Mandatory Approval Policy**: Halt execution and request explicit human approval before running any destructive migration in staging or production.

### 6. Backup, Archival & Disaster Recovery
- Formulate Point-In-Time Recovery (PITR) strategy with Write-Ahead Log (WAL) archiving.
- Implement partition pruning for high-volume historical logs or time-series data.

## Practical Examples

### Safe Expand-and-Contract Migration Script (PostgreSQL)
```sql
-- Migration: 20261117_001_add_user_full_name.up.sql
-- Step 1 of Expand/Contract: Add new column without locking table
ALTER TABLE users ADD COLUMN full_name VARCHAR(255) NULL;

-- Create index concurrently to prevent table read/write locks
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_users_full_name 
ON users (full_name) 
WHERE full_name IS NOT NULL;

-- Migration: 20261117_001_add_user_full_name.down.sql
DROP INDEX CONCURRENTLY IF EXISTS idx_users_full_name;
ALTER TABLE users DROP COLUMN IF EXISTS full_name;
```

### EXPLAIN ANALYZE Optimization Analysis
```text
-- Before Optimization:
Seq Scan on orders  (cost=0.00..1845.00 rows=125 width=72) (actual time=0.042..14.321 rows=120 loops=1)
  Filter: ((customer_id = 9482) AND (status = 'PENDING'::text))
  Buffers: shared hit=1240

-- Fix: CREATE INDEX idx_orders_customer_status ON orders (customer_id, status);

-- After Optimization:
Index Scan using idx_orders_customer_status on orders  (cost=0.42..8.45 rows=125 width=72) (actual time=0.021..0.065 rows=120 loops=1)
  Index Cond: ((customer_id = 9482) AND (status = 'PENDING'::text))
  Buffers: shared hit=4
```

## Verification Checklist
- [ ] Foreign keys have supporting indexes.
- [ ] Time-series and monetary fields use appropriate precise types (`TIMESTAMPTZ`, `NUMERIC`).
- [ ] Migrations are zero-downtime compatible and include verified rollback scripts.
- [ ] Destructive schema changes are gated by mandatory human approval.
- [ ] Query performance verified using `EXPLAIN ANALYZE` on production-scale datasets.

## Expected Outputs & Deliverables
1. **Migration Files (`migrations/YYYYMMDD_*.up.sql`, `*.down.sql`)**: Tested, idempotent migration scripts.
2. **Schema Entity-Relationship Diagram (ERD)**: Complete visual relational schema mapping.
3. **Query Performance Benchmarks**: Query execution plans before and after index tuning.