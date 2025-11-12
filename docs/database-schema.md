# Database Schema Documentation

**Project**: Inavor Shuttle
**Version**: 1.0.0
**Last Updated**: 2025-11-10
**Status**: Phase 1 Implementation

---

## Overview

Inavor Shuttle uses a hybrid database approach:

- **DynamoDB** for production scalability (Jobs, Shops, Import History)
- **Prisma + SQLite** for local development and session management

This document describes the DynamoDB table schemas deployed via AWS CDK.

---

## DynamoDB Tables

### 1. Shops Table

**Purpose**: Store merchant/shop information for multi-tenant architecture

**Table Name**: `InavorShuttle-{environment}-shops`

**Partition Key**: `domain` (String) - Shop domain (e.g., "mystore.myshopify.com")

**Configuration**:

- Billing Mode: On-demand (PAY_PER_REQUEST)
- Encryption: AWS managed encryption at rest
- Point-in-Time Recovery: Enabled
- Removal Policy: RETAIN (table preserved on stack deletion)

**Attributes**:

| Attribute       | Type   | Description                                               | Example                                    |
| --------------- | ------ | --------------------------------------------------------- | ------------------------------------------ |
| `domain`        | String | Shop domain (primary key)                                 | `"mystore.myshopify.com"`                  |
| `name`          | String | Shop name                                                 | `"My Store"`                               |
| `accessToken`   | String | Shopify API access token (encrypted)                      | `"shpat_..."`                              |
| `plan`          | String | Billing plan                                              | `"FREE"`, `"SMALL"`, `"MEDIUM"`, `"LARGE"` |
| `installedAt`   | Number | Unix timestamp (ms) when app installed                    | `1699564800000`                            |
| `uninstalledAt` | Number | Unix timestamp (ms) when app uninstalled (null if active) | `null` or `1699564800000`                  |
| `billingStatus` | String | Current billing status                                    | `"ACTIVE"`, `"SUSPENDED"`, `"CANCELLED"`   |
| `settings`      | Map    | JSON object with shop-specific settings                   | `{"theme": "dark"}`                        |
| `createdAt`     | Number | Unix timestamp (ms) when record created                   | `1699564800000`                            |
| `updatedAt`     | Number | Unix timestamp (ms) when record last updated              | `1699564800000`                            |

**Query Patterns**:

1. Get shop by domain: `GetItem(domain)`
2. List all shops: `Scan` (use pagination for large datasets)
3. List active shops: `Scan` with filter `billingStatus = ACTIVE AND uninstalledAt = null`

**Security Considerations**:

- `accessToken` should be encrypted in production using AWS KMS
- Access restricted to App Runner and Lambda via IAM roles

---

### 2. Jobs Table

**Purpose**: Track import/export jobs and their status

**Table Name**: `InavorShuttle-{environment}-jobs`

**Partition Key**: `jobId` (String) - ULID format (time-sortable unique identifier)

**Configuration**:

- Billing Mode: On-demand (PAY_PER_REQUEST)
- Encryption: AWS managed encryption at rest
- Point-in-Time Recovery: Enabled
- Removal Policy: RETAIN
- TTL Attribute: `expiresAt` (auto-delete after 90 days)

**Global Secondary Indexes**:

#### GSI-1: `shopDomain-createdAt-index`

- **Partition Key**: `shopDomain` (String)
- **Sort Key**: `createdAt` (Number)
- **Projection**: ALL attributes
- **Purpose**: List all jobs for a specific shop, sorted by creation time

#### GSI-2: `status-createdAt-index`

- **Partition Key**: `status` (String)
- **Sort Key**: `createdAt` (Number)
- **Projection**: ALL attributes
- **Purpose**: Query jobs by status (e.g., all "PROCESSING" jobs), sorted by creation time

**Attributes**:

| Attribute               | Type    | Description                               | Example                                                                       |
| ----------------------- | ------- | ----------------------------------------- | ----------------------------------------------------------------------------- |
| `jobId`                 | String  | Unique job identifier (ULID)              | `"01ARZ3NDEKTSV4RRFFQ69G5FAV"`                                                |
| `shopDomain`            | String  | Shop domain (for multi-tenant isolation)  | `"mystore.myshopify.com"`                                                     |
| `type`                  | String  | Job type                                  | `"IMPORT"`, `"EXPORT"`                                                        |
| `mode`                  | String  | Import mode                               | `"OVERWRITE_EXISTING"`, `"NEW_ONLY"`, `"NEW_AND_DRAFT"`, `"WIPE_AND_RESTORE"` |
| `status`                | String  | Job status                                | `"QUEUED"`, `"PROCESSING"`, `"COMPLETED"`, `"FAILED"`, `"CANCELLED"`          |
| `isDryRun`              | Boolean | Dry run flag                              | `true`, `false`                                                               |
| `totalProducts`         | Number  | Total products to process                 | `1000`                                                                        |
| `processedProducts`     | Number  | Products processed so far                 | `250`                                                                         |
| `successfulProducts`    | Number  | Successfully processed                    | `240`                                                                         |
| `failedProducts`        | Number  | Failed products                           | `10`                                                                          |
| `progressPercentage`    | Number  | Progress percentage (0-100)               | `25`                                                                          |
| `startedAt`             | Number  | Unix timestamp (ms) when job started      | `1699564800000`                                                               |
| `completedAt`           | Number  | Unix timestamp (ms) when job completed    | `1699565400000`                                                               |
| `estimatedCompletionAt` | Number  | Estimated completion time                 | `1699565600000`                                                               |
| `s3Key`                 | String  | S3 path to import file                    | `"imports/mystore.myshopify.com/01ARZ3.../source.json"`                       |
| `errorSummary`          | Map     | JSON object with error counts by type     | `{"VALIDATION_ERROR": 5, "API_ERROR": 5}`                                     |
| `shopifyApiCallsUsed`   | Number  | Shopify API calls made                    | `100`                                                                         |
| `createdBy`             | String  | User who created the job                  | `"user@example.com"`                                                          |
| `createdAt`             | Number  | Unix timestamp (ms) when job created      | `1699564800000`                                                               |
| `updatedAt`             | Number  | Unix timestamp (ms) when job last updated | `1699564900000`                                                               |
| `expiresAt`             | Number  | TTL attribute (createdAt + 90 days)       | `1707340800000`                                                               |

**Query Patterns**:

1. Get job by ID: `GetItem(jobId)`
2. List jobs for a shop: `Query GSI-1 WHERE shopDomain = "..." ORDER BY createdAt DESC`
3. List jobs by status: `Query GSI-2 WHERE status = "PROCESSING" ORDER BY createdAt DESC`
4. List recent jobs across all shops: `Scan` with filter (use pagination)

**Example Queries**:

```typescript
// Get a specific job
const job = await dynamodb.getItem({
  TableName: "InavorShuttle-dev-jobs",
  Key: { jobId: "01ARZ3NDEKTSV4RRFFQ69G5FAV" },
});

// List all jobs for a shop (most recent first)
const shopJobs = await dynamodb.query({
  TableName: "InavorShuttle-dev-jobs",
  IndexName: "shopDomain-createdAt-index",
  KeyConditionExpression: "shopDomain = :shopDomain",
  ExpressionAttributeValues: {
    ":shopDomain": "mystore.myshopify.com",
  },
  ScanIndexForward: false, // Descending order (newest first)
  Limit: 20,
});

// List all processing jobs
const processingJobs = await dynamodb.query({
  TableName: "InavorShuttle-dev-jobs",
  IndexName: "status-createdAt-index",
  KeyConditionExpression: "status = :status",
  ExpressionAttributeValues: {
    ":status": "PROCESSING",
  },
  ScanIndexForward: false,
});
```

**TTL Behavior**:

- Jobs are automatically deleted 90 days after creation
- `expiresAt` is set to `createdAt + (90 days in seconds)`
- DynamoDB's TTL process typically deletes items within 48 hours of expiration
- Before deletion, jobs are archived to `ImportHistory` table

---

### 3. Import History Table

**Purpose**: Store historical records of all imports for analytics and auditing

**Table Name**: `InavorShuttle-{environment}-import-history`

**Partition Key**: `shopDomain` (String) - Shop domain
**Sort Key**: `timestamp` (Number) - Import timestamp (Unix milliseconds)

**Configuration**:

- Billing Mode: On-demand (PAY_PER_REQUEST)
- Encryption: AWS managed encryption at rest
- Point-in-Time Recovery: Enabled
- Removal Policy: RETAIN
- TTL Attribute: `expiresAt` (auto-delete after 365 days)

**Attributes**:

| Attribute             | Type   | Description                          | Example                        |
| --------------------- | ------ | ------------------------------------ | ------------------------------ |
| `shopDomain`          | String | Shop domain (partition key)          | `"mystore.myshopify.com"`      |
| `timestamp`           | Number | Import timestamp (sort key, Unix ms) | `1699564800000`                |
| `jobId`               | String | Reference to job ID                  | `"01ARZ3NDEKTSV4RRFFQ69G5FAV"` |
| `productsImported`    | Number | Number of products imported          | `1000`                         |
| `status`              | String | Final job status                     | `"COMPLETED"`, `"FAILED"`      |
| `errorCount`          | Number | Number of errors encountered         | `5`                            |
| `mode`                | String | Import mode used                     | `"OVERWRITE_EXISTING"`         |
| `shopifyApiCallsUsed` | Number | Shopify API calls made               | `100`                          |
| `durationMs`          | Number | Job duration in milliseconds         | `300000`                       |
| `expiresAt`           | Number | TTL attribute (timestamp + 365 days) | `1731100800000`                |

**Query Patterns**:

1. Get import history for a shop: `Query WHERE shopDomain = "..." ORDER BY timestamp DESC`
2. Get recent imports for a shop: `Query WHERE shopDomain = "..." AND timestamp > 1699564800000`
3. Get imports within date range: `Query WHERE shopDomain = "..." AND timestamp BETWEEN start AND end`

**Example Queries**:

```typescript
// Get last 30 days of import history for a shop
const thirtyDaysAgo = Date.now() - 30 * 24 * 60 * 60 * 1000;
const history = await dynamodb.query({
  TableName: "InavorShuttle-dev-import-history",
  KeyConditionExpression: "shopDomain = :shopDomain AND #ts > :thirtyDaysAgo",
  ExpressionAttributeNames: {
    "#ts": "timestamp", // 'timestamp' is a reserved word
  },
  ExpressionAttributeValues: {
    ":shopDomain": "mystore.myshopify.com",
    ":thirtyDaysAgo": thirtyDaysAgo,
  },
  ScanIndexForward: false, // Newest first
  Limit: 100,
});
```

**TTL Behavior**:

- Import history records are kept for 365 days
- `expiresAt` is set to `timestamp + (365 days in seconds)`
- After expiration, records are permanently deleted

---

## Data Lifecycle

### Job Processing Flow

1. **Job Creation**:
   - User uploads import file via UI
   - File saved to S3
   - Job record created in `Jobs` table with status `QUEUED`
   - `createdAt` and `expiresAt` (createdAt + 90 days) set
   - Message sent to SQS queue

2. **Job Processing**:
   - Lambda function polls SQS queue
   - Job status updated to `PROCESSING`
   - Products processed in batches
   - `processedProducts` and `progressPercentage` updated after each batch
   - Errors logged in `errorSummary`

3. **Job Completion**:
   - Job status updated to `COMPLETED` or `FAILED`
   - `completedAt` timestamp set
   - Import history record created in `ImportHistory` table
   - CloudWatch metrics emitted

4. **Job Expiration** (90 days later):
   - DynamoDB TTL deletes job record
   - S3 lifecycle policy moves import file to Glacier (then deletes)
   - Import history record remains for 365 days

### Shop Lifecycle

1. **App Installation**:
   - Shopify OAuth flow completes
   - Shop record created with `installedAt` timestamp
   - `plan` set to `FREE` by default
   - `billingStatus` set to `ACTIVE`

2. **App Usage**:
   - Shop domain used to filter all queries (multi-tenant isolation)
   - `accessToken` used for Shopify API calls
   - `settings` updated as user changes preferences

3. **App Uninstallation**:
   - Webhook received from Shopify
   - `uninstalledAt` timestamp set
   - `billingStatus` set to `CANCELLED`
   - Shop record retained for analytics (GDPR: delete after 30 days if requested)

---

## Performance Optimization

### Indexing Strategy

- **Jobs Table**: Two GSIs enable efficient queries by shop domain and status
- **Import History Table**: Composite key (shopDomain + timestamp) enables range queries

### Cost Optimization

- **On-demand billing**: Auto-scales with usage, no idle costs
- **TTL**: Automatically deletes old data, reducing storage costs
- **Projection Type**: GSIs use `ALL` projection for read performance (acceptable for Phase 1)

### Read/Write Patterns

- **Hot Keys**: Shop domain is frequently accessed; consider sharding for high-traffic shops
- **Write Amplification**: Each GSI doubles write costs; acceptable for Phase 1 scale
- **Eventually Consistent Reads**: GSIs are eventually consistent (millisecond lag)

---

## Migration Strategy

### Phase 1 (Current)

- **Sessions**: Stored in Prisma/SQLite for local development
- **Jobs, Shops, History**: DynamoDB for production scalability

### Phase 2 (Future)

- Consider migrating Sessions to DynamoDB for unified storage
- Add DynamoDB Streams for event-driven processing
- Implement single-table design for better cost efficiency

### Phase 3 (Future)

- Add DynamoDB Accelerator (DAX) for read-heavy workloads
- Implement Global Tables for multi-region support

---

## Monitoring & Alerts

### CloudWatch Metrics

- **Table Metrics**: Read/write capacity, throttled requests, consumed capacity
- **GSI Metrics**: Read/write capacity per index
- **TTL Metrics**: Items deleted by TTL

### Recommended Alarms

1. **High Throttling**: Alert if throttled requests > 10 in 5 minutes
2. **High Latency**: Alert if read latency > 100ms (p99)
3. **Failed Writes**: Alert if failed writes > 5 in 1 minute
4. **Table Size**: Alert if table size > 80% of expected quota

---

## Security Best Practices

### Access Control

- **IAM Roles**: Lambda and App Runner have least-privilege access
- **Resource ARNs**: Policies grant access to specific tables only
- **GSI Access**: Policies include `{tableArn}/index/*` for GSI queries

### Encryption

- **At Rest**: AWS managed encryption (future: consider KMS for enhanced security)
- **In Transit**: All API calls over HTTPS/TLS
- **Access Tokens**: Shopify access tokens should be encrypted with KMS before storage

### Multi-Tenancy

- **Data Isolation**: All queries MUST filter by `shopDomain`
- **Validation**: Always validate shop domain from session before queries
- **Logging**: Log shop domain with all operations for audit trail

---

## Testing Strategy

### Unit Tests

- Not applicable for CDK infrastructure (tables are declarative)

### Integration Tests

1. **Table Creation**: Verify tables exist after CDK deployment
2. **GSI Creation**: Verify indexes are active and queryable
3. **TTL Configuration**: Verify TTL attribute is set correctly
4. **PITR Enabled**: Verify point-in-time recovery is enabled

### Manual Testing Checklist

- [ ] Deploy stack: `cdk deploy InavorShuttle-dev`
- [ ] Verify table creation: `aws dynamodb describe-table --table-name InavorShuttle-dev-shops`
- [ ] Insert test data: `aws dynamodb put-item --table-name InavorShuttle-dev-shops --item ...`
- [ ] Query by primary key: `aws dynamodb get-item --table-name InavorShuttle-dev-jobs --key ...`
- [ ] Query GSI: `aws dynamodb query --table-name InavorShuttle-dev-jobs --index-name shopDomain-createdAt-index ...`
- [ ] Verify TTL: Check that `expiresAt` attribute exists on job records
- [ ] Test PITR: Restore table to a previous point in time (if safe to test)

---

## Appendix

### ULID Format

- **U**niversally **L**unique **L**exicographically Sortable **ID**entifier
- 26 characters, case-insensitive, URL-safe
- Encodes timestamp in first 10 characters (sortable by time)
- Example: `01ARZ3NDEKTSV4RRFFQ69G5FAV`
- Library: `ulid` npm package

### Reserved Words in DynamoDB

The following attributes require `ExpressionAttributeNames` when querying:

- `timestamp`, `status`, `name`, `data`, `time`, `type`, etc.
- See full list: https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/ReservedWords.html

### CDK Outputs

After deployment, the following outputs are available:

```bash
cdk deploy InavorShuttle-dev

# Outputs:
# InavorShuttle-dev.ShopsTableName = InavorShuttle-dev-shops
# InavorShuttle-dev.ShopsTableArn = arn:aws:dynamodb:us-east-2:123456789:table/InavorShuttle-dev-shops
# InavorShuttle-dev.JobsTableName = InavorShuttle-dev-jobs
# InavorShuttle-dev.JobsTableArn = arn:aws:dynamodb:us-east-2:123456789:table/InavorShuttle-dev-jobs
# InavorShuttle-dev.ImportHistoryTableName = InavorShuttle-dev-import-history
# InavorShuttle-dev.ImportHistoryTableArn = arn:aws:dynamodb:us-east-2:123456789:table/InavorShuttle-dev-import-history
```

---

**Document Version**: 1.0.0
**Last Updated**: 2025-11-10
**Next Review**: After Phase 1 completion
