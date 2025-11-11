# Implementation Plan: Issue #3

PHASE-1-INFRA-002: DynamoDB Table Creation & Configuration

**Branch**: feature/PHASE-1-INFRA-002
**Created**: 2025-11-10

---

## Issue Summary

Create and configure DynamoDB tables for storing shop data, job records, and import history. Set up proper indexes, capacity modes, and backup strategies to support the Inavor Shuttle application's data storage needs.

---

## Acceptance Criteria

- [ ] DynamoDB tables defined in CDK
- [ ] Shop table with GSI for lookups
- [ ] Job table with GSI for shop-based queries and status filtering
- [ ] Import history table configured
- [ ] TTL configured for temporary data
- [ ] Backup and point-in-time recovery enabled
- [ ] Table schemas documented

---

## Technical Approach

**Key Components:**
- AWS CDK construct for DynamoDB table definitions
- Table schemas aligned with the database roadmap in CLAUDE.md
- Global Secondary Indexes (GSIs) for efficient query patterns
- Time-to-Live (TTL) configuration for automatic data expiration

**Database Tables to Create:**
1. **Shops Table** - Store merchant/shop information
2. **Jobs Table** - Track import/export jobs and their status
3. **ImportHistory Table** - Historical record of imports
4. **Sessions Table** - May already exist via Prisma, verify handling

**External Dependencies:**
- AWS CDK (`aws-cdk-lib`)
- Already installed based on Phase 1 infrastructure setup

**Query Patterns:**
- Shop lookups by domain (primary key)
- Jobs by shop domain (GSI: shopDomain)
- Jobs by status (GSI: status-createdAt)
- Import history by shop and date range

**Security Considerations:**
- Encryption at rest enabled by default
- Access via IAM roles (App Runner, Lambda)
- No direct public access to tables

---

## Implementation Steps

1. **Create DynamoDB CDK Stack/Construct**
   - Create file `cdk/lib/dynamodb-stack.ts` or add to existing infrastructure stack
   - Define table constructs with CDK L2 constructs

2. **Define Shops Table**
   - Partition key: `domain` (String)
   - Attributes: name, accessToken (encrypted), plan, installedAt, uninstalledAt, billingStatus, settings
   - GSI: None needed (domain is primary lookup)
   - Enable PITR (Point-in-Time Recovery)
   - On-demand billing mode

3. **Define Jobs Table**
   - Partition key: `jobId` (String, ULID format for time-sorting)
   - Sort key: Not needed (jobId is globally unique)
   - GSI-1: `shopDomain` (PK) + `createdAt` (SK) - for shop-based job lists
   - GSI-2: `status` (PK) + `createdAt` (SK) - for querying by status
   - Attributes: type, mode, status, isDryRun, totalProducts, processedProducts, etc.
   - TTL attribute: `expiresAt` (set to createdAt + 90 days)
   - Enable PITR
   - On-demand billing mode

4. **Define ImportHistory Table**
   - Partition key: `shopDomain` (String)
   - Sort key: `timestamp` (Number, Unix timestamp)
   - Attributes: jobId, productsImported, status, errorCount
   - TTL: `expiresAt` (365 days retention)
   - Enable PITR
   - On-demand billing mode

5. **Configure Sessions Table Handling**
   - Verify if Sessions table is managed by Prisma or should be in DynamoDB
   - For Phase 1, Sessions should stay in Prisma/SQLite (per CLAUDE.md)
   - Document decision in code comments

6. **Add Table Outputs**
   - Export table names, ARNs for use by other stacks
   - Create CDK outputs for App Runner and Lambda to reference

7. **Document Table Schemas**
   - Add markdown documentation in `docs/database-schema.md`
   - Include attribute descriptions, GSI purposes, TTL policies
   - Add example queries for each GSI

---

## Testing Strategy

**Unit Tests:**
- Not applicable for CDK infrastructure (no unit tests for table definitions)

**Integration Tests:**
- Deploy to development AWS account
- Use AWS CLI to verify:
  - `aws dynamodb describe-table --table-name Shops-dev`
  - `aws dynamodb describe-table --table-name Jobs-dev`
  - `aws dynamodb describe-table --table-name ImportHistory-dev`
- Verify GSI creation and status
- Check PITR is enabled
- Confirm TTL attribute configuration

**Manual Testing:**
- Insert test data using AWS CLI or DynamoDB console
- Query using GSIs to verify index performance
- Verify TTL deletes expired items (set short TTL for test)
- Test backup/restore flow (if time permits)

---

## Files to Create/Modify

- [ ] `cdk/lib/dynamodb-stack.ts` - New DynamoDB table definitions
- [ ] `cdk/bin/cdk.ts` - Import and instantiate DynamoDB stack
- [ ] `docs/database-schema.md` - Documentation of table schemas
- [ ] `README.md` - Update with DynamoDB setup instructions (if needed)

---

## Notes & Considerations

**Important Architectural Decisions:**
- Using DynamoDB for production scalability (per comprehensive plan)
- Phase 1 uses Prisma/SQLite for rapid development; DynamoDB prepares for Phase 2+
- On-demand billing prevents over-provisioning during low usage
- ULID for jobId enables time-based sorting without separate timestamp attribute

**Performance Considerations:**
- GSIs enable efficient queries without table scans
- On-demand billing auto-scales with traffic
- TTL reduces storage costs by auto-deleting old data

**Security Implications:**
- accessToken in Shops table must be encrypted (use AWS KMS in production)
- IAM roles restrict access to specific services (Lambda, App Runner)

**Known Limitations:**
- DynamoDB eventually consistent reads by default (acceptable for this use case)
- GSI eventual consistency (queries may lag by milliseconds)

**Future Improvements (Phase 2+):**
- Add DynamoDB Streams for event-driven processing
- Implement single-table design for better cost efficiency
- Add DAX (DynamoDB Accelerator) for read-heavy workloads

---

## Definition of Done

✅ All acceptance criteria met
✅ DynamoDB tables successfully deployed via CDK
✅ GSIs verified through AWS Console/CLI
✅ TTL and PITR confirmed enabled
✅ Table schemas documented in `/docs/database-schema.md`
✅ TypeScript strict mode passing (`npm run typecheck`)
✅ Code follows project conventions
✅ Incremental commits with clear messages
✅ Implementation plan deleted before PR
