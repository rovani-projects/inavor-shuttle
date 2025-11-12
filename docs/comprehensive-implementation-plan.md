# Inavor Shuttle - Comprehensive Implementation Plan

**Project**: Shopify Product Import Application  
**Company**: Rovani Projects, Inc.  
**Purpose**: Learning project & proof of concept for Shopify App Store publication  
**Primary Goal**: AWS platform mastery through production-grade Shopify app development

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Technology Stack](#technology-stack)
3. [AWS Services Deep Dive](#aws-services-deep-dive)
4. [Architecture Design](#architecture-design)
5. [Database Schema](#database-schema)
6. [Feature Breakdown](#feature-breakdown)
7. [Implementation Phases](#implementation-phases)
8. [Development Workflow](#development-workflow)
9. [Testing Strategy](#testing-strategy)
10. [Deployment Strategy](#deployment-strategy)
11. [Monitoring & Observability](#monitoring--observability)
12. [Security & Compliance](#security--compliance)
13. [Billing & Monetization](#billing--monetization)
14. [Performance Considerations](#performance-considerations)
15. [Risk Management](#risk-management)

---

## Project Overview

### Core Functionality

Inavor Shuttle enables merchants to import product catalogs into Shopify with advanced metafield and metaobject support. The application provides:

- **JSON-based import templates** with schema validation
- **Dry-run capabilities** for safe testing
- **Multiple import modes**: full catalog replacement, selective overwrites, new products only, new + draft overwrites
- **Metafield & metaobject management** including "shopify" namespace support
- **Async job processing** with real-time progress tracking
- **Feature-gated plans** with usage limits (per import, daily, per storefront)
- **Multi-tenant architecture** supporting unlimited Shopify storefronts

### Success Criteria

- Successfully handle 10,000+ product imports with complex metafield configurations
- Embedded app experience matching Shopify Polaris UX standards
- Sub-second response times for UI interactions
- 99.9% uptime for async job processing
- Public app store listing with positive merchant reviews
- Comprehensive AWS service integration demonstrating production patterns

---

## Technology Stack

### Frontend

- **Framework**: Remix.js (React-based, Shopify-owned)
- **UI Libraries**:
  - Shopify Polaris (primary component library)
  - Tailwind CSS (utility styling)
  - shadcn/ui (supplemental components)
- **State Management**: Remix loaders/actions (server-side), React hooks (client-side)
- **Build Tool**: Vite (future-proofing for full Vite+ migration)

### Backend

- **Runtime**: Node.js 20.x LTS
- **Language**: TypeScript (strict mode)
- **Framework**: Remix.js (full-stack)
- **API Client**: Shopify Admin GraphQL API (@shopify/shopify-api)

### AWS Infrastructure

- **Compute**: AWS Lambda (serverless functions) + API Gateway OR AWS App Runner (containerized Remix)
- **Database**: DynamoDB (NoSQL, serverless, auto-scaling)
- **Storage**: S3 (import files, logs, exports)
- **Queue**: SQS (async job processing) + EventBridge (job orchestration)
- **Logging**: CloudWatch Logs + CloudWatch Insights
- **Monitoring**: CloudWatch Metrics + X-Ray (distributed tracing)
- **CDN**: CloudFront (static assets)
- **IaC**: AWS CDK (TypeScript-based infrastructure as code)

### Development & Testing

- **Testing Framework**: Vitest (unit + integration)
- **E2E Testing**: Playwright
- **Code Quality**: ESLint, Prettier, TypeScript strict
- **Local Dev**: Docker Compose, Shopify CLI, ngrok
- **CI/CD**: GitHub Actions

---

## AWS Services Deep Dive

### Compute Options Analysis

#### Option A: Lambda + API Gateway (Recommended for Learning)

**Pros**:

- True serverless, pay-per-invocation
- Auto-scaling without configuration
- Forces good architectural practices (stateless, event-driven)
- Deep AWS learning (Lambda layers, cold starts, execution contexts)

**Cons**:

- Cold start latency (mitigated with provisioned concurrency)
- 15-minute execution limit (not an issue for API routes with async jobs)
- Remix requires Lambda adapter

**Use Case**: All API routes, webhook handlers, short-running functions

#### Option B: AWS App Runner (Recommended for Production)

**Pros**:

- Container-based, runs Remix natively
- Simpler deployment (just point to GitHub repo)
- Better for long-running connections
- Automatic HTTPS, load balancing

**Cons**:

- More expensive than Lambda for low traffic
- Less AWS-specific learning
- Still auto-scales but less granular than Lambda

**Use Case**: Main Remix application server

#### Hybrid Approach (Recommended)

- **App Runner**: Hosts Remix app for embedded UI and synchronous API routes
- **Lambda**: Async job processors, webhook handlers, scheduled tasks
- Best of both worlds: easy Remix deployment + serverless job processing

### DynamoDB Schema Strategy

**Why DynamoDB**:

- Serverless, no server management
- Auto-scaling read/write capacity
- Single-digit millisecond latency
- Native AWS integration
- Cost-effective at scale

**Access Patterns** (determine partition/sort keys):

1. Get storefront by shop domain
2. Get all storefronts (for admin dashboard)
3. Get all jobs for a storefront
4. Get specific job by ID
5. Get active/queued jobs for a storefront
6. Get usage stats for a storefront (daily, monthly)
7. Get import file metadata
8. Query jobs by status and date range

### S3 Bucket Structure

```
inavor-shuttle-prod/
├── imports/
│   ├── {shop-domain}/
│   │   ├── {job-id}/
│   │   │   ├── source.json (original upload)
│   │   │   ├── validated.json (post-validation)
│   │   │   ├── results.json (import results)
│   │   │   └── errors.json (detailed errors)
├── logs/
│   ├── {shop-domain}/
│   │   ├── {job-id}/
│   │   │   ├── job-{timestamp}.log
├── exports/
│   ├── {shop-domain}/
│   │   ├── {export-id}.json (catalog exports)
├── schemas/
│   ├── {shop-domain}/
│   │   ├── current-schema.json (validated metafield defs)
```

**S3 Lifecycle Policies**:

- Import files: Transition to Glacier after 90 days, delete 30 days post-uninstall
- Logs: Free plan (90 days), paid plans (retain per tier), transition to Glacier
- Exports: Delete after 30 days (user downloads)

### SQS Queue Architecture

**Queues**:

1. **import-jobs-queue.fifo**: Main import job queue (FIFO for ordering)
2. **import-jobs-dlq.fifo**: Dead letter queue for failed jobs
3. **webhook-events-queue**: Shopify webhook processing
4. **analytics-events-queue**: Usage tracking, analytics aggregation

**Why SQS**:

- Decouples API from job processing
- Built-in retry logic
- Dead letter queue for failed jobs
- Message visibility timeout for long-running jobs
- Scale queue consumers independently

### EventBridge Rules

**Scheduled Events**:

- Daily usage aggregation (midnight UTC)
- Cleanup expired logs/files (daily)
- Usage limit resets (daily/monthly)
- Health checks and monitoring

**Event-Driven Patterns**:

- Job status changes trigger notifications
- Usage threshold alerts
- Failed job alerts

### CloudWatch Strategy

**Log Groups**:

- `/aws/lambda/inavor-shuttle-job-processor`: Job execution logs
- `/aws/apprunner/inavor-shuttle-app`: Remix application logs
- `/aws/lambda/inavor-shuttle-webhooks`: Webhook handler logs

**Custom Metrics**:

- Jobs processed per minute
- Job success/failure rates
- API response times
- Shopify API rate limit remaining
- DynamoDB read/write capacity utilization
- S3 storage usage per shop

**CloudWatch Insights Queries** (pre-built):

- Top error messages by frequency
- Slow queries (>1s response time)
- Jobs by status and duration
- Usage by storefront

### X-Ray Distributed Tracing

**Instrumentation Points**:

- Remix route handlers
- Lambda function invocations
- DynamoDB queries
- S3 operations
- Shopify API calls

**Trace Analysis**:

- End-to-end request flow
- Performance bottlenecks
- Failed request debugging
- Service dependency mapping

---

## Architecture Design

### High-Level Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         Shopify Admin                           │
│                    (Embedded App Frame)                         │
└────────────────────────────┬────────────────────────────────────┘
                             │ HTTPS
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                       CloudFront CDN                            │
│                  (Static Assets + Caching)                      │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                     AWS App Runner                              │
│                   (Remix.js Application)                        │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  • Authentication (Shopify OAuth)                        │  │
│  │  • UI Routes (Polaris Components)                        │  │
│  │  • API Routes (GraphQL Proxy)                            │  │
│  │  • File Upload Handler                                   │  │
│  │  • Job Status Endpoints                                  │  │
│  └──────────────────────────────────────────────────────────┘  │
└────┬──────────────────┬──────────────────┬──────────────────────┘
     │                  │                  │
     ▼                  ▼                  ▼
┌─────────┐      ┌──────────┐      ┌──────────────┐
│DynamoDB │      │    S3    │      │     SQS      │
│         │      │          │      │              │
│ Stores: │      │ Stores:  │      │ Queues:      │
│• Shops  │      │• Imports │      │• Import Jobs │
│• Jobs   │      │• Logs    │      │• Webhooks    │
│• Usage  │      │• Exports │      │• Analytics   │
│• Config │      │• Schemas │      │              │
└─────────┘      └──────────┘      └──────┬───────┘
                                          │
                                          ▼
                 ┌──────────────────────────────────────┐
                 │      Lambda Job Processor            │
                 │  ┌────────────────────────────────┐  │
                 │  │• Poll SQS Queue                │  │
                 │  │• Validate JSON Schema          │  │
                 │  │• Check Shopify Metafield Defs  │  │
                 │  │• Process Products in Batches   │  │
                 │  │• Handle Rate Limits            │  │
                 │  │• Update Job Progress           │  │
                 │  │• Write Logs to S3              │  │
                 │  └────────────────────────────────┘  │
                 └─────────────┬────────────────────────┘
                               │
                               ▼
                    ┌────────────────────┐
                    │  Shopify Admin API │
                    │  (GraphQL)         │
                    │                    │
                    │• Products          │
                    │• Variants          │
                    │• Metafields        │
                    │• Metaobjects       │
                    └────────────────────┘
```

### Request Flow Diagrams

#### 1. App Installation & Authentication Flow

```
Merchant          Shopify          App Runner       DynamoDB
   │                 │                 │               │
   │─Install App────>│                 │               │
   │                 │─OAuth Redirect─>│               │
   │                 │                 │               │
   │                 │<─Request Scopes─│               │
   │<─Authorize─────>│                 │               │
   │                 │─OAuth Callback─>│               │
   │                 │                 │               │
   │                 │                 │─Store Shop────>│
   │                 │                 │  Domain,      │
   │                 │                 │  Access Token │
   │                 │                 │               │
   │                 │                 │<─Confirm─────│
   │                 │                 │               │
   │                 │                 │─Create Free───>│
   │                 │                 │  Plan Record  │
   │                 │                 │               │
   │<─Redirect to App─────────────────│               │
   │                 │                 │               │
```

#### 2. Import Job Submission Flow

```
Merchant     App Runner    S3      DynamoDB    SQS       Lambda
   │             │          │          │        │          │
   │─Upload JSON>│          │          │        │          │
   │             │          │          │        │          │
   │             │─Save────>│          │        │          │
   │             │  File    │          │        │          │
   │             │          │          │        │          │
   │             │──────────────Check Usage────>│          │
   │             │          │     Limits        │          │
   │             │<─────────────OK / Error──────│          │
   │             │          │          │        │          │
   │             │──────────────Create Job─────>│          │
   │             │          │     Record        │          │
   │             │          │    (QUEUED)       │          │
   │             │          │          │        │          │
   │             │──────────────────────Enqueue>│          │
   │             │          │          │  Job   │          │
   │<─Job Queued─│          │          │        │          │
   │   (Job ID)  │          │          │        │          │
   │             │          │          │        │          │
   │             │          │          │        │─Poll────>│
   │             │          │          │        │          │
   │             │          │          │        │<─Receive─│
   │             │          │          │        │   Job    │
   │             │          │          │        │          │
   │             │          │          │<─Update Status────│
   │             │          │          │  (PROCESSING)     │
   │             │          │          │                   │
   │             │          │<─Load File──────────────────│
   │             │          │                              │
   │             │          │──────[Process Products]──────│
   │             │          │                              │
   │             │          │          │<─Update Progress──│
   │             │          │          │   (25%, 50%...)   │
   │             │          │                              │
   │             │──────────────────────────Shopify API────│
   │             │          │          │   (GraphQL)       │
   │             │          │          │                   │
   │             │          │          │<─Update Status────│
   │             │          │          │  (COMPLETED)      │
   │             │          │          │                   │
   │             │          │<─Write Results──────────────│
   │             │          │   & Logs                     │
```

#### 3. Dry-Run Validation Flow

```
Merchant     App Runner    Lambda      Shopify API    S3
   │             │            │              │         │
   │─Dry Run────>│            │              │         │
   │  Request    │            │              │         │
   │             │            │              │         │
   │             │─Enqueue───>│              │         │
   │             │ Dry-Run    │              │         │
   │             │   Job      │              │         │
   │             │            │              │         │
   │<─Job Queued─│            │              │         │
   │             │            │              │         │
   │             │            │<─Start Job───│         │
   │             │            │              │         │
   │             │            │─Load File───>│         │
   │             │            │              │         │
   │             │            │─Introspect──>│         │
   │             │            │  Metafields  │         │
   │             │            │              │         │
   │             │            │<─Metafield───│         │
   │             │            │   Definitions│         │
   │             │            │              │         │
   │             │            │──[Validate]──│         │
   │             │            │  • Schema    │         │
   │             │            │  • Types     │         │
   │             │            │  • Refs      │         │
   │             │            │              │         │
   │             │            │─Write Report>│         │
   │             │            │              │         │
   │             │<─Dry-Run Complete─────────│         │
   │   (Success/Errors)       │              │         │
```

### Metafield & Metaobject Validation Flow

```
┌─────────────────────────────────────────────────────────┐
│              Validation Pipeline                        │
└─────────────────────────────────────────────────────────┘
                         │
                         ▼
         ┌───────────────────────────────┐
         │  1. JSON Schema Validation    │
         │  • Valid JSON structure       │
         │  • Required fields present    │
         │  • Correct data types         │
         └──────────┬────────────────────┘
                    │
                    ▼
         ┌───────────────────────────────┐
         │  2. Shopify API Introspection │
         │  • Query metafield defs       │
         │  • Query metaobject defs      │
         │  • Cache for 5 minutes        │
         └──────────┬────────────────────┘
                    │
                    ▼
         ┌───────────────────────────────┐
         │  3. Metafield Validation      │
         │  • Namespace exists?          │
         │  • Key defined?               │
         │  • Type matches?              │
         │  • Value valid for type?      │
         └──────────┬────────────────────┘
                    │
                    ▼
         ┌───────────────────────────────┐
         │  4. Metaobject Validation     │
         │  • Definition exists?         │
         │  • All required fields?       │
         │  • Field types match?         │
         │  • References valid?          │
         └──────────┬────────────────────┘
                    │
                    ▼
         ┌───────────────────────────────┐
         │  5. Auto-Create Missing       │
         │  • "shopify" namespace OK     │
         │  • Create metafield defs      │
         │  • Create metaobject defs     │
         │  • Log all creations          │
         └──────────┬────────────────────┘
                    │
                    ▼
         ┌───────────────────────────────┐
         │  6. Generate Report           │
         │  • Valid products count       │
         │  • Errors by type/field       │
         │  • Auto-created definitions   │
         │  • Estimated API calls        │
         └───────────────────────────────┘
```

---

## Database Schema

### DynamoDB Table Design

**Single Table Design** (recommended for DynamoDB):

- Table Name: `inavor-shuttle-prod`
- Partition Key: `PK` (String)
- Sort Key: `SK` (String)
- GSI1: `GSI1PK` (String), `GSI1SK` (String) - for queries by status/date
- GSI2: `GSI2PK` (String), `GSI2SK` (String) - for usage tracking

#### Entity Patterns

```typescript
// Storefront/Shop
{
  PK: "SHOP#store.myshopify.com",
  SK: "METADATA",
  EntityType: "Shop",
  shopDomain: "store.myshopify.com",
  shopName: "My Store",
  accessToken: "encrypted-token", // Encrypted at rest
  plan: "FREE" | "SMALL" | "MEDIUM" | "LARGE",
  installedAt: "2025-01-15T10:30:00Z",
  uninstalledAt: null | "2025-03-15T10:30:00Z",
  billingStatus: "ACTIVE" | "SUSPENDED" | "CANCELLED",
  features: {
    maxProductsPerImport: 100,
    maxDailyImports: 5,
    maxMonthlyImports: 100,
    allowConcurrentJobs: false,
    logRetentionDays: 90
  },
  settings: {
    allowWipeAllStaff: false, // If false, only shop owner can wipe
    notificationEmail: "admin@store.com"
  },
  GSI1PK: "SHOPS",
  GSI1SK: "2025-01-15T10:30:00Z", // For listing all shops by install date
  createdAt: "2025-01-15T10:30:00Z",
  updatedAt: "2025-01-15T10:30:00Z"
}

// Import Job
{
  PK: "SHOP#store.myshopify.com",
  SK: "JOB#01HQZXYZ123456",
  EntityType: "Job",
  jobId: "01HQZXYZ123456", // ULID for time-ordered IDs
  shopDomain: "store.myshopify.com",
  type: "IMPORT",
  mode: "OVERWRITE_EXISTING" | "NEW_ONLY" | "WIPE_AND_RESTORE" | "NEW_AND_DRAFT",
  status: "QUEUED" | "PROCESSING" | "COMPLETED" | "FAILED" | "CANCELLED",
  isDryRun: false,
  s3Key: "imports/store.myshopify.com/01HQZXYZ123456/source.json",
  totalProducts: 1500,
  processedProducts: 750,
  successfulProducts: 700,
  failedProducts: 50,
  progressPercentage: 50,
  startedAt: "2025-01-15T11:00:00Z",
  completedAt: null,
  estimatedCompletionAt: "2025-01-15T11:45:00Z",
  errorSummary: {
    "INVALID_METAFIELD_TYPE": 25,
    "MISSING_REQUIRED_FIELD": 15,
    "SHOPIFY_API_ERROR": 10
  },
  shopifyApiCallsUsed: 1250,
  createdBy: "admin@store.com",
  GSI1PK: "SHOP#store.myshopify.com",
  GSI1SK: "STATUS#PROCESSING#2025-01-15T11:00:00Z", // For querying jobs by status
  createdAt: "2025-01-15T10:50:00Z",
  updatedAt: "2025-01-15T11:30:00Z"
}

// Daily Usage Tracking
{
  PK: "SHOP#store.myshopify.com",
  SK: "USAGE#DAILY#2025-01-15",
  EntityType: "UsageDaily",
  shopDomain: "store.myshopify.com",
  date: "2025-01-15",
  importsCount: 3,
  productsImported: 4500,
  shopifyApiCalls: 5000,
  storageUsedBytes: 52428800, // 50 MB
  GSI2PK: "USAGE_DAILY",
  GSI2SK: "2025-01-15#store.myshopify.com", // For aggregating all shops on a date
  createdAt: "2025-01-15T00:00:00Z",
  updatedAt: "2025-01-15T23:59:59Z"
}

// Monthly Usage Tracking (for billing)
{
  PK: "SHOP#store.myshopify.com",
  SK: "USAGE#MONTHLY#2025-01",
  EntityType: "UsageMonthly",
  shopDomain: "store.myshopify.com",
  yearMonth: "2025-01",
  importsCount: 45,
  productsImported: 67500,
  shopifyApiCalls: 75000,
  storageUsedBytes: 1048576000, // 1 GB
  GSI2PK: "USAGE_MONTHLY",
  GSI2SK: "2025-01#store.myshopify.com",
  createdAt: "2025-01-01T00:00:00Z",
  updatedAt: "2025-01-31T23:59:59Z"
}

// Schema Definition (per shop)
{
  PK: "SHOP#store.myshopify.com",
  SK: "SCHEMA#CURRENT",
  EntityType: "Schema",
  shopDomain: "store.myshopify.com",
  version: "1.0.0", // Inavor Shuttle schema version
  metafieldDefinitions: [
    {
      namespace: "custom",
      key: "product_material",
      type: "single_line_text_field",
      ownerType: "PRODUCT",
      shopifyId: "gid://shopify/MetafieldDefinition/123456"
    }
  ],
  metaobjectDefinitions: [
    {
      type: "size_chart",
      displayName: "Size Chart",
      shopifyId: "gid://shopify/MetaobjectDefinition/789012",
      fieldDefinitions: [
        {
          key: "measurements",
          type: "list.dimension",
          required: true
        }
      ]
    }
  ],
  lastValidatedAt: "2025-01-15T10:00:00Z",
  createdAt: "2025-01-15T10:00:00Z",
  updatedAt: "2025-01-15T10:00:00Z"
}

// App Configuration (global)
{
  PK: "CONFIG",
  SK: "APP#CURRENT",
  EntityType: "AppConfig",
  version: "1.0.0",
  jsonSchemaUrl: "s3://inavor-shuttle-schemas/v1.0.0/import-schema.json",
  shopifyApiVersion: "2025-01",
  rateLimitBuffer: 10, // Keep 10% buffer from Shopify rate limits
  defaultRetryAttempts: 3,
  defaultRetryBackoffMs: 1000,
  updatedAt: "2025-01-15T09:00:00Z"
}
```

#### Access Patterns & Queries

```typescript
// 1. Get shop by domain
{
  KeyConditionExpression: "PK = :pk AND SK = :sk",
  ExpressionAttributeValues: {
    ":pk": "SHOP#store.myshopify.com",
    ":sk": "METADATA"
  }
}

// 2. Get all jobs for a shop
{
  KeyConditionExpression: "PK = :pk AND begins_with(SK, :sk)",
  ExpressionAttributeValues: {
    ":pk": "SHOP#store.myshopify.com",
    ":sk": "JOB#"
  }
}

// 3. Get specific job
{
  KeyConditionExpression: "PK = :pk AND SK = :sk",
  ExpressionAttributeValues: {
    ":pk": "SHOP#store.myshopify.com",
    ":sk": "JOB#01HQZXYZ123456"
  }
}

// 4. Get all processing jobs for a shop (using GSI1)
{
  IndexName: "GSI1",
  KeyConditionExpression: "GSI1PK = :pk AND begins_with(GSI1SK, :sk)",
  ExpressionAttributeValues: {
    ":pk": "SHOP#store.myshopify.com",
    ":sk": "STATUS#PROCESSING"
  }
}

// 5. Get all shops (using GSI1)
{
  IndexName: "GSI1",
  KeyConditionExpression: "GSI1PK = :pk",
  ExpressionAttributeValues: {
    ":pk": "SHOPS"
  }
}

// 6. Get daily usage for a shop
{
  KeyConditionExpression: "PK = :pk AND SK = :sk",
  ExpressionAttributeValues: {
    ":pk": "SHOP#store.myshopify.com",
    ":sk": "USAGE#DAILY#2025-01-15"
  }
}

// 7. Get all daily usage across shops (using GSI2, for admin dashboard)
{
  IndexName: "GSI2",
  KeyConditionExpression: "GSI2PK = :pk AND begins_with(GSI2SK, :date)",
  ExpressionAttributeValues: {
    ":pk": "USAGE_DAILY",
    ":date": "2025-01-15"
  }
}
```

---

## Feature Breakdown

### Phase 1: MVP (Core Features)

#### 1.1 Authentication & Multi-Tenant Setup

- [ ] Shopify OAuth implementation
- [ ] Access token encryption (AWS KMS)
- [ ] Session management (secure cookies)
- [ ] Shop installation webhook handler
- [ ] Shop uninstallation webhook handler (30-day retention trigger)
- [ ] Embedded app authentication verification
- [ ] Multi-tenant data isolation

#### 1.2 JSON Import Template & Schema

- [ ] Define v1.0.0 JSON schema (products, variants, metafields, metaobjects)
- [ ] Schema validation library (Zod or AJV)
- [ ] File upload UI (drag-and-drop, file size limits)
- [ ] Schema documentation page (in-app)
- [ ] Example template generator (downloadable JSON samples)

#### 1.3 Metafield & Metaobject Validation

- [ ] Shopify Admin API introspection queries
  - [ ] Metafield definitions query
  - [ ] Metaobject definitions query
- [ ] Validation engine
  - [ ] Check namespaces exist
  - [ ] Verify types match
  - [ ] Validate required fields
  - [ ] Check metaobject references
- [ ] Auto-creation of missing definitions (with confirmation)
- [ ] "shopify" namespace support
- [ ] Validation report generation

#### 1.4 Dry-Run Functionality

- [ ] Dry-run job processor (validation only, no Shopify writes)
- [ ] Detailed validation report
  - [ ] Valid product count
  - [ ] Errors grouped by type
  - [ ] Line numbers for errors in JSON
  - [ ] Suggested fixes
  - [ ] Estimated API call count
- [ ] Dry-run results UI (table/list view with filtering)

#### 1.5 Import Modes

- [ ] **Overwrite Existing**: Update products that match by SKU/handle
- [ ] **New Only**: Skip existing products, import new ones
- [ ] **New + Overwrite Drafts**: Import new, overwrite draft-status products
- [ ] **Wipe & Restore**: Delete all products, then import
  - [ ] Confirmation UI (type shop name to confirm)
  - [ ] Permission check (admin-only or all-staff setting)
  - [ ] Bulk delete using productDeleteAsync mutation
  - [ ] Progress tracking for wipe phase

#### 1.6 Async Job Processing

- [ ] SQS queue setup (FIFO for ordering)
- [ ] Lambda job processor
  - [ ] Poll SQS queue
  - [ ] Load import file from S3
  - [ ] Validate against schema + Shopify
  - [ ] Process products in batches (50-100 per batch)
  - [ ] Shopify API rate limit handling (dynamic backoff)
  - [ ] Update job progress in DynamoDB
  - [ ] Write detailed logs to S3
  - [ ] Handle errors gracefully (partial success)
- [ ] Job status polling API endpoint
- [ ] Real-time progress UI (percentage, products processed, estimated time remaining)

#### 1.7 Job Management UI

- [ ] Job list page (all jobs for current shop)
  - [ ] Filter by status, date range
  - [ ] Sort by created date, completion date
  - [ ] Search by job ID
- [ ] Job detail page
  - [ ] Progress indicator
  - [ ] Error summary
  - [ ] Action buttons: cancel, retry failed items, download logs
- [ ] Cancel job mid-flight
  - [ ] Update status to CANCELLED
  - [ ] Stop processing gracefully (finish current batch)
- [ ] Download detailed error report (JSON or CSV)
- [ ] Download job logs

#### 1.8 Feature Gating & Usage Limits

- [ ] Plan definition in DynamoDB (FREE, SMALL, MEDIUM, LARGE)
- [ ] Usage tracking
  - [ ] Products imported (daily, monthly, per storefront)
  - [ ] Imports count (daily, monthly)
  - [ ] Storage used (S3 file sizes)
- [ ] Limit enforcement
  - [ ] Check before job creation
  - [ ] Block job if over limit
  - [ ] Display clear error message with upgrade prompt
- [ ] Limits persist across uninstall/reinstall
  - [ ] Check shop domain on reinstall
  - [ ] Load previous usage data
- [ ] Concurrent job gating (higher plans only)

#### 1.9 Observability (Admin & Customer)

- [ ] CloudWatch dashboard setup
  - [ ] Jobs processed per hour
  - [ ] Success/failure rates
  - [ ] Average job duration
  - [ ] API response times
  - [ ] Error counts by type
- [ ] In-app analytics for merchants
  - [ ] Total products imported (lifetime, monthly)
  - [ ] Import history chart
  - [ ] Success rate
  - [ ] Storage usage
- [ ] In-app analytics for Rovani Projects (admin)
  - [ ] Total shops installed
  - [ ] Active shops (imported in last 30 days)
  - [ ] Plan distribution
  - [ ] Top error types across all shops
  - [ ] Revenue metrics (once billing enabled)

#### 1.10 Core UI/UX

- [ ] Polaris-based dashboard
  - [ ] Welcome screen for new installs
  - [ ] Quick start guide
- [ ] Navigation structure
  - [ ] Import (upload, jobs list)
  - [ ] Configuration (metafield setup, shop settings)
  - [ ] Analytics (usage, history)
  - [ ] Help (docs, support contact)
- [ ] Responsive design (desktop primary, tablet/mobile support)
- [ ] Loading states, error states, empty states
- [ ] Confirmation modals for destructive actions
- [ ] Toast notifications for success/error

### Phase 2: Enhanced Features

#### 2.1 API Endpoint for Imports

- [ ] REST API endpoint: `POST /api/import`
- [ ] API key generation (per shop)
- [ ] API key management UI
- [ ] Rate limiting on API endpoint
- [ ] Webhook for job completion notifications

#### 2.2 Advanced Metafield Types

- [ ] Support for all Shopify metafield types
  - [ ] list.\* types (list of products, variants, etc.)
  - [ ] file_reference (images, videos, PDFs)
  - [ ] json
  - [ ] dimension, volume, weight
  - [ ] rating, color
- [ ] File upload handling for file_reference metafields
- [ ] Validation for complex types

#### 2.3 Metaobject Management UI

- [ ] Visual metaobject definition creator
- [ ] Edit existing metaobject definitions
- [ ] Metaobject instance browser
- [ ] Bulk create metaobject instances from JSON

#### 2.4 Job Scheduling

- [ ] Schedule imports for future time
- [ ] Recurring imports (daily, weekly, monthly)
- [ ] Calendar view of scheduled imports

#### 2.5 Import Templates Library

- [ ] Save custom import configurations as templates
- [ ] Share templates across team (if multi-user)
- [ ] Public template marketplace (community-submitted)

#### 2.6 Catalog Export

- [ ] Export current catalog to Inavor Shuttle JSON format
- [ ] Export with filters (collection, product type, vendor)
- [ ] Schedule automated exports

#### 2.7 Advanced Analytics

- [ ] Cost analysis (Shopify API calls, storage)
- [ ] Performance trends over time
- [ ] Comparison reports (before/after imports)
- [ ] Custom report builder

### Phase 3: Enterprise & Optimization

#### 3.1 Team Collaboration

- [ ] Role-based access control (RBAC)
  - [ ] Admin: Full access
  - [ ] Editor: Can run imports, view analytics
  - [ ] Viewer: Read-only access
- [ ] Activity log (who did what, when)
- [ ] Team notifications

#### 3.2 Billing & Monetization

- [ ] Shopify Billing API integration
- [ ] Plan upgrade/downgrade flow
- [ ] Usage-based billing (optional add-ons)
- [ ] Invoice generation
- [ ] Payment failure handling

#### 3.3 Performance Optimization

- [ ] Caching layer (Redis or ElastiCache)
  - [ ] Cache Shopify metafield definitions (5-minute TTL)
  - [ ] Cache shop configuration
- [ ] Batch optimization (tune batch sizes based on performance)
- [ ] Parallel processing (multiple Lambda workers per job)
- [ ] Job priority queue (paid plans get priority)

#### 3.4 Advanced Error Handling

- [ ] Automatic retry for transient Shopify API errors
- [ ] Partial import resume (restart from last successful batch)
- [ ] Smart error grouping and suggestions
- [ ] Integration with external logging (Sentry, Datadog)

#### 3.5 Internationalization

- [ ] Multi-language support (English, Spanish, French, German)
- [ ] Localized date/time formats
- [ ] Currency formatting per region

#### 3.6 Integration Ecosystem

- [ ] Webhook subscriptions for external systems
- [ ] Zapier integration
- [ ] Integration with external data sources (Google Sheets, Airtable)

---

## Implementation Phases

### Phase 1: Foundation & MVP (Months 1-3)

**Month 1: Infrastructure & Authentication**

Week 1-2:

- [ ] AWS account setup, IAM roles, CDK project initialization
- [ ] DynamoDB table creation with GSIs
- [ ] S3 bucket setup with lifecycle policies
- [ ] SQS queues setup (main + DLQ)
- [ ] Remix app scaffold with Polaris
- [ ] Shopify Partner account, dev store creation

Week 3-4:

- [ ] Shopify OAuth implementation
- [ ] Session management
- [ ] Embedded app authentication
- [ ] Shop install/uninstall webhooks
- [ ] Basic multi-tenant data model
- [ ] CloudWatch logging setup

**Month 2: Core Import Functionality**

Week 5-6:

- [ ] JSON schema definition (v1.0.0)
- [ ] File upload UI and S3 storage
- [ ] Schema validation engine
- [ ] Metafield introspection queries
- [ ] Validation engine (metafields + metaobjects)

Week 7-8:

- [ ] Lambda job processor (basic structure)
- [ ] SQS polling logic
- [ ] Shopify product creation (GraphQL mutations)
- [ ] Batch processing logic
- [ ] Rate limit handling (basic)
- [ ] Job progress tracking

**Month 3: Job Management & UI Polish**

Week 9-10:

- [ ] All import modes implementation
- [ ] Dry-run functionality
- [ ] Job status API endpoints
- [ ] Job management UI (list, detail, cancel)
- [ ] Real-time progress updates

Week 11-12:

- [ ] Feature gating implementation
- [ ] Usage tracking (daily, monthly)
- [ ] Limit enforcement
- [ ] Analytics UI (basic)
- [ ] Documentation and help content
- [ ] End-to-end testing with 1000+ products

**Deliverables**:

- Functional embedded app installable on dev stores
- Import up to 1000 products with metafields
- Dry-run validation
- Basic observability
- Free plan only (no billing yet)

### Phase 2: Enhancement & Public Launch (Months 4-6)

**Month 4: Advanced Features**

Week 13-14:

- [ ] API endpoint for imports
- [ ] API key management
- [ ] Advanced metafield type support
- [ ] File upload for file_reference metafields

Week 15-16:

- [ ] Metaobject management UI
- [ ] Catalog export functionality
- [ ] Import templates library
- [ ] Performance optimization (caching, tuning)

**Month 5: Billing & Analytics**

Week 17-18:

- [ ] Shopify Billing API integration
- [ ] Plan upgrade/downgrade flows
- [ ] Payment webhook handling
- [ ] Invoice generation

Week 19-20:

- [ ] Advanced analytics (merchant-facing)
- [ ] Admin dashboard (Rovani Projects analytics)
- [ ] Cost tracking and reporting
- [ ] Usage alerts and notifications

**Month 6: Testing & Launch Prep**

Week 21-22:

- [ ] Comprehensive E2E testing (Playwright)
- [ ] Load testing (10,000+ products)
- [ ] Security audit
- [ ] Performance benchmarking
- [ ] Bug fixes and polish

Week 23-24:

- [ ] App Store listing preparation
  - [ ] Screenshots, videos
  - [ ] Marketing copy
  - [ ] Privacy policy, terms of service
- [ ] Submit to Shopify for review
- [ ] Beta testing with 5-10 real merchants
- [ ] Public launch

**Deliverables**:

- Live app in Shopify App Store
- Billing enabled (FREE, SMALL, MEDIUM, LARGE plans)
- Support for 10,000+ product imports
- Comprehensive documentation
- Production-ready monitoring and alerts

### Phase 3: Scale & Optimize (Months 7-12)

**Focus Areas**:

- [ ] Team collaboration features (RBAC)
- [ ] Job scheduling and automation
- [ ] Advanced error handling and retry logic
- [ ] Internationalization
- [ ] Integration ecosystem (Zapier, webhooks)
- [ ] Performance optimization for 50,000+ product catalogs
- [ ] Customer feedback implementation
- [ ] Continuous improvement based on usage analytics

---

## Development Workflow

### Local Development Setup

```bash
# Prerequisites
- Node.js 20.x LTS
- pnpm (package manager)
- Docker Desktop
- AWS CLI v2
- Shopify CLI
- ngrok account (for HTTPS tunnel)

# Initial setup
git clone git@github.com:rovaniprojects/inavor-shuttle.git
cd inavor-shuttle
pnpm install

# AWS credentials
aws configure
# Set up AWS profile for inavor-shuttle-dev

# Environment variables
cp .env.example .env.local
# Fill in:
# - SHOPIFY_API_KEY
# - SHOPIFY_API_SECRET
# - SHOPIFY_SCOPES
# - AWS_REGION
# - DYNAMODB_TABLE_NAME
# - S3_BUCKET_NAME
# - SQS_QUEUE_URL

# Start local DynamoDB (Docker)
docker-compose up -d dynamodb

# Create local DynamoDB tables
pnpm run db:setup:local

# Start Remix dev server
pnpm run dev

# In separate terminal, start ngrok tunnel
shopify app tunnel start

# Update Shopify app URLs to ngrok URL
# In Partner Dashboard > App > Configuration
```

### Project Structure

```
inavor-shuttle/
├── app/                          # Remix app
│   ├── routes/                   # Route handlers
│   │   ├── _index.tsx           # Dashboard
│   │   ├── auth.callback.tsx    # OAuth callback
│   │   ├── import.upload.tsx    # File upload
│   │   ├── import.jobs.tsx      # Job list
│   │   ├── import.jobs.$id.tsx  # Job detail
│   │   ├── config.tsx           # Configuration
│   │   ├── analytics.tsx        # Analytics
│   │   └── api.import.tsx       # API endpoint
│   ├── components/               # React components
│   │   ├── JobList.tsx
│   │   ├── JobProgress.tsx
│   │   ├── FileUploader.tsx
│   │   └── ...
│   ├── lib/                      # Shared utilities
│   │   ├── shopify.server.ts    # Shopify API client
│   │   ├── db.server.ts         # DynamoDB client
│   │   ├── s3.server.ts         # S3 client
│   │   ├── sqs.server.ts        # SQS client
│   │   ├── validation.ts        # Schema validation
│   │   └── auth.server.ts       # Authentication
│   ├── types/                    # TypeScript types
│   │   ├── shop.ts
│   │   ├── job.ts
│   │   ├── import-schema.ts
│   │   └── ...
│   └── root.tsx                  # App root
├── lambda/                       # Lambda functions
│   ├── job-processor/
│   │   ├── index.ts             # Main handler
│   │   ├── processor.ts         # Job processing logic
│   │   ├── shopify-client.ts    # Shopify API wrapper
│   │   ├── rate-limiter.ts      # Rate limiting
│   │   └── validator.ts         # Validation logic
│   ├── webhook-handler/
│   │   ├── index.ts
│   │   └── handlers/
│   │       ├── shop-uninstall.ts
│   │       └── ...
│   └── usage-aggregator/
│       └── index.ts             # Daily/monthly aggregation
├── infrastructure/               # AWS CDK
│   ├── bin/
│   │   └── inavor-shuttle.ts    # CDK app entry
│   ├── lib/
│   │   ├── app-stack.ts         # Main stack
│   │   ├── database-stack.ts    # DynamoDB
│   │   ├── storage-stack.ts     # S3
│   │   ├── compute-stack.ts     # Lambda, App Runner
│   │   └── monitoring-stack.ts  # CloudWatch
│   └── cdk.json
├── schemas/                      # JSON schemas
│   └── import-schema-v1.0.0.json
├── tests/
│   ├── unit/
│   ├── integration/
│   └── e2e/
├── docs/                         # Documentation
│   ├── API.md
│   ├── SCHEMA.md
│   ├── DEPLOYMENT.md
│   └── USER_GUIDE.md
├── package.json
├── tsconfig.json
├── vitest.config.ts
├── playwright.config.ts
└── README.md
```

### Git Workflow

**Branching Strategy**:

- `main`: Production-ready code
- `develop`: Integration branch for features
- `feature/*`: Feature development
- `fix/*`: Bug fixes
- `release/*`: Release preparation

**Commit Convention**: Conventional Commits

```
feat: add dry-run functionality
fix: resolve rate limit backoff issue
docs: update API documentation
test: add unit tests for validator
chore: update dependencies
```

### Code Review Checklist

- [ ] TypeScript strict mode compliance
- [ ] Unit tests written (>80% coverage)
- [ ] Error handling implemented
- [ ] Logging added for debugging
- [ ] UI components use Polaris
- [ ] Mobile responsive (if UI change)
- [ ] Documentation updated
- [ ] No secrets in code
- [ ] Performance considerations addressed

---

## Testing Strategy

### Unit Testing (Vitest)

**Coverage Goals**: >80% overall, >90% for critical paths

**Test Suites**:

```typescript
// Example: Validator tests
describe("import-validator", () => {
  describe("validateJSONSchema", () => {
    it("should pass valid import file", () => {});
    it("should fail on missing required fields", () => {});
    it("should fail on invalid data types", () => {});
  });

  describe("validateMetafields", () => {
    it("should validate existing metafield definitions", () => {});
    it("should detect missing metafield definitions", () => {});
    it("should validate metafield value types", () => {});
    it("should handle shopify namespace correctly", () => {});
  });

  describe("validateMetaobjects", () => {
    it("should validate metaobject references", () => {});
    it("should detect missing metaobject definitions", () => {});
    it("should validate required fields in metaobjects", () => {});
  });
});

// Example: Job processor tests
describe("job-processor", () => {
  describe("processImportJob", () => {
    it("should process valid import successfully", () => {});
    it("should handle Shopify API errors gracefully", () => {});
    it("should respect rate limits", () => {});
    it("should update progress correctly", () => {});
    it("should write logs to S3", () => {});
  });

  describe("rate-limiter", () => {
    it("should back off when rate limit approached", () => {});
    it("should resume after backoff period", () => {});
    it("should use dynamic backoff based on headers", () => {});
  });
});
```

### Integration Testing

**Test Scenarios**:

1. **Full Import Flow**
   - Upload JSON file
   - Validate schema
   - Queue job
   - Process job (mocked Shopify API)
   - Verify job completion
   - Download results

2. **Dry-Run Flow**
   - Upload JSON file
   - Run dry-run validation
   - Verify validation report
   - Ensure no products created in Shopify

3. **Multi-Tenant Isolation**
   - Create two shops
   - Import products for shop A
   - Verify shop B cannot access shop A's data

4. **Usage Limits**
   - Set low limit for test shop
   - Attempt to exceed limit
   - Verify job blocked with clear error

5. **Job Cancellation**
   - Start long-running job
   - Cancel mid-flight
   - Verify partial import results
   - Verify job marked as CANCELLED

### End-to-End Testing (Playwright)

**User Scenarios**:

```typescript
test.describe("Import Flow", () => {
  test("complete product import as new merchant", async ({ page }) => {
    // Navigate to app
    // Complete OAuth
    // Upload JSON file
    // Submit import
    // Monitor progress
    // Verify success message
    // Check products in Shopify admin
  });

  test("dry-run validation with errors", async ({ page }) => {
    // Upload invalid JSON
    // Run dry-run
    // Verify error report displayed
    // Fix errors in JSON
    // Re-run dry-run
    // Verify success
  });

  test("catalog wipe with confirmation", async ({ page }) => {
    // Go to import page
    // Select "Wipe & Restore" mode
    // Enter shop name in confirmation
    // Submit
    // Verify wipe progress
    // Verify import progress
    // Check products replaced
  });
});
```

### Load Testing

**Tool**: k6 or Artillery

**Scenarios**:

1. **Concurrent Imports**
   - Simulate 10 shops importing simultaneously
   - Each import: 1000 products
   - Measure: job completion time, error rate, Lambda concurrency

2. **Large Catalog Import**
   - Single import: 10,000 products
   - Measure: total time, memory usage, API call efficiency

3. **API Endpoint Load**
   - 100 requests/second to import API endpoint
   - Measure: response time, error rate, throttling

4. **Dashboard Load**
   - 50 concurrent users browsing dashboard
   - Measure: page load times, API response times

### Testing in AWS

**Test Environment**: `inavor-shuttle-test`

- Separate AWS account or isolated environment
- DynamoDB on-demand pricing (cost-effective for testing)
- S3 with short lifecycle policies
- Lambda with lower concurrency limits

**Staging Environment**: `inavor-shuttle-staging`

- Production-like setup
- Test with real Shopify dev stores
- Full monitoring and alerting

---

## Deployment Strategy

### Environments

1. **Local Development**
   - Local DynamoDB (Docker)
   - Local S3 (LocalStack or direct to AWS dev bucket)
   - ngrok tunnel for Shopify
   - Hot reloading

2. **Test Environment** (`inavor-shuttle-test`)
   - Full AWS infrastructure (minimal capacity)
   - Automated deployments from `develop` branch
   - Integration test suite runs post-deployment

3. **Staging Environment** (`inavor-shuttle-staging`)
   - Production-like infrastructure
   - Manual deployments from `release/*` branches
   - Final QA and smoke tests

4. **Production Environment** (`inavor-shuttle-prod`)
   - Full production infrastructure
   - Manual deployments from `main` branch
   - Blue-green or canary deployment strategy
   - Rollback capability

### AWS CDK Deployment

**Stack Structure**:

```typescript
// infrastructure/bin/inavor-shuttle.ts
const app = new cdk.App();

const env = {
  account: process.env.CDK_DEFAULT_ACCOUNT,
  region: "us-east-2", // or preferred region
};

// Stacks
new DatabaseStack(app, "DatabaseStack", { env });
new StorageStack(app, "StorageStack", { env });
new ComputeStack(app, "ComputeStack", { env });
new MonitoringStack(app, "MonitoringStack", { env });
```

**Deployment Commands**:

```bash
# Deploy all stacks to test environment
cd infrastructure
pnpm run cdk deploy --all --profile inavor-shuttle-test

# Deploy specific stack
pnpm run cdk deploy ComputeStack --profile inavor-shuttle-prod

# Review changes before deploy
pnpm run cdk diff --profile inavor-shuttle-prod
```

### CI/CD Pipeline (GitHub Actions)

```yaml
# .github/workflows/deploy-test.yml
name: Deploy to Test

on:
  push:
    branches: [develop]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '20'
      - run: pnpm install
      - run: pnpm test
      - run: pnpm run build

  deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID_TEST }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY_TEST }}
          aws-region: us-east-2
      - run: pnpm install
      - run: cd infrastructure && pnpm run cdk deploy --all --require-approval never

# .github/workflows/deploy-prod.yml
name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '20'
      - run: pnpm install
      - run: pnpm test
      - run: pnpm run build
      - run: pnpm run test:e2e

  deploy:
    needs: test
    runs-on: ubuntu-latest
    environment: production # Requires manual approval
    steps:
      - uses: actions/checkout@v3
      - uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID_PROD }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY_PROD }}
          aws-region: us-east-2
      - run: pnpm install
      - run: cd infrastructure && pnpm run cdk deploy --all --require-approval never

  smoke-test:
    needs: deploy
    runs-on: ubuntu-latest
    steps:
      - run: curl -f https://inavor-shuttle.rovaniprojects.com/health || exit 1
```

### Rollback Strategy

**Automated Rollback Triggers**:

- Error rate >5% for 5 minutes
- Average response time >2s for 5 minutes
- Lambda function errors >10 in 1 minute

**Manual Rollback**:

```bash
# Revert to previous CDK stack version
cd infrastructure
pnpm run cdk deploy --previous-version

# Or deploy specific git commit
git checkout <previous-commit>
pnpm run cdk deploy --all
```

### Database Migration Strategy

**DynamoDB Schema Changes**:

- Backwards-compatible changes only (add fields, never remove)
- Migration scripts for data transformations
- Version field in entities for gradual rollout

**Example Migration**:

```typescript
// migration-scripts/add-concurrent-jobs-feature.ts
// Adds 'features.allowConcurrentJobs' to all shops

import { DynamoDB } from "aws-sdk";

const ddb = new DynamoDB.DocumentClient();

async function migrate() {
  const shops = await getAllShops();

  for (const shop of shops) {
    if (!shop.features.hasOwnProperty("allowConcurrentJobs")) {
      await ddb
        .update({
          TableName: "inavor-shuttle-prod",
          Key: { PK: shop.PK, SK: shop.SK },
          UpdateExpression: "SET features.allowConcurrentJobs = :val",
          ExpressionAttributeValues: { ":val": false },
        })
        .promise();
    }
  }
}

migrate();
```

---

## Monitoring & Observability

### CloudWatch Dashboard

**Dashboard Name**: `Inavor-Shuttle-Production`

**Widgets**:

1. **Application Health**
   - App Runner/Lambda invocation count
   - Error rate (%)
   - Average response time (ms)
   - Concurrent executions

2. **Job Processing**
   - Jobs queued (SQS messages)
   - Jobs processing (active Lambda invocations)
   - Jobs completed per hour
   - Job success rate (%)
   - Average job duration (minutes)

3. **Shopify API**
   - API calls per minute
   - API error rate
   - Rate limit remaining (tracked from headers)
   - Average API response time

4. **Database Performance**
   - DynamoDB read/write capacity units consumed
   - Throttled requests
   - Average query latency

5. **Storage**
   - S3 bucket size (GB)
   - S3 request count
   - Average S3 operation latency

6. **Business Metrics**
   - Active shops (imported in last 30 days)
   - Total products imported today
   - Revenue (if billing enabled)

### CloudWatch Alarms

**Critical Alarms** (PagerDuty/SMS):

- Lambda error rate >5% for 5 minutes
- DynamoDB throttling >10 requests in 1 minute
- SQS DLQ messages >5
- App Runner unhealthy target count >0
- Job processing stopped (no completions in 30 minutes during business hours)

**Warning Alarms** (Email):

- Lambda average duration >10s
- S3 bucket size >80% of plan limit
- API call rate approaching Shopify limit
- Unusual spike in job failures (>10% increase)

### Logging Strategy

**Log Levels**:

- `ERROR`: Unrecoverable errors, job failures
- `WARN`: Recoverable errors, rate limit approaching
- `INFO`: Job lifecycle events, important state changes
- `DEBUG`: Detailed execution flow (disabled in production)

**Structured Logging** (JSON format):

```typescript
logger.info("Job started", {
  jobId: "01HQZXYZ123456",
  shopDomain: "store.myshopify.com",
  mode: "OVERWRITE_EXISTING",
  totalProducts: 1500,
  timestamp: new Date().toISOString(),
});
```

**Log Retention**:

- Lambda logs: 30 days (CloudWatch Logs)
- Job logs (S3): Plan-dependent (90 days to forever)
- Audit logs: Forever (compliance)

### X-Ray Tracing

**Instrumented Services**:

- Remix app routes
- Lambda functions
- DynamoDB calls
- S3 operations
- Shopify API requests

**Trace Annotations**:

```typescript
import AWSXRay from "aws-xray-sdk-core";

const subsegment = AWSXRay.getSegment().addNewSubsegment("shopify-api-call");
subsegment.addAnnotation("shop", shopDomain);
subsegment.addAnnotation("operation", "productCreate");

try {
  const result = await shopifyClient.product.create(data);
  subsegment.addMetadata("result", result);
  subsegment.close();
} catch (error) {
  subsegment.addError(error);
  subsegment.close();
  throw error;
}
```

### Custom Metrics

**Business Metrics** (Published to CloudWatch):

```typescript
import { CloudWatch } from "aws-sdk";

const cw = new CloudWatch();

await cw
  .putMetricData({
    Namespace: "InavorsShuttle",
    MetricData: [
      {
        MetricName: "ProductsImported",
        Value: productsCount,
        Unit: "Count",
        Dimensions: [
          { Name: "Shop", Value: shopDomain },
          { Name: "Plan", Value: "FREE" },
        ],
        Timestamp: new Date(),
      },
    ],
  })
  .promise();
```

**Metrics to Track**:

- Products imported (per shop, per plan)
- Job duration (by product count buckets: <100, 100-1000, 1000-10000, >10000)
- Error types (by error code)
- Storage usage (per shop)
- API call efficiency (products per API call)

### Health Checks

**Endpoints**:

```typescript
// app/routes/health.tsx
export async function loader() {
  const checks = {
    database: await checkDynamoDB(),
    storage: await checkS3(),
    queue: await checkSQS(),
    shopify: await checkShopifyAPI(),
  };

  const healthy = Object.values(checks).every((c) => c.healthy);

  return json(
    { status: healthy ? "healthy" : "unhealthy", checks },
    { status: healthy ? 200 : 503 },
  );
}
```

**Monitoring**: External uptime monitor (UptimeRobot, Pingdom)

- Check `/health` endpoint every 5 minutes
- Alert if 3 consecutive failures

---

## Security & Compliance

### Authentication & Authorization

**Shopify OAuth Scopes Required**:

```
read_products, write_products,
read_product_listings,
read_metaobject_definitions, write_metaobject_definitions,
read_metaobjects, write_metaobjects
```

**Session Management**:

- Secure, HTTP-only cookies
- 24-hour session lifetime
- CSRF protection (built into Remix)

**API Key Security** (for API endpoint):

- API keys stored hashed in DynamoDB (bcrypt)
- Rotation capability
- Scoped to shop (cannot access other shops)

### Data Security

**Encryption**:

- **At Rest**:
  - DynamoDB encryption enabled (AWS-managed keys)
  - S3 bucket encryption (AES-256)
  - Shopify access tokens encrypted with AWS KMS
- **In Transit**:
  - HTTPS everywhere (TLS 1.2+)
  - Certificate management via ACM

**Access Control**:

- **IAM Roles**: Principle of least privilege
  - Lambda execution role: DynamoDB, S3, SQS, CloudWatch only
  - App Runner role: DynamoDB, S3, KMS only
- **DynamoDB**: Row-level security via partition key (shop domain)
- **S3 Bucket Policies**: Deny public access

### Data Retention & Deletion

**GDPR/CCPA Compliance**:

**Shopify App Uninstall**:

1. Webhook received: `app/uninstalled`
2. Update shop record: `uninstalledAt` timestamp
3. Schedule deletion job (30 days later)
4. Deletion job:
   - Delete all jobs for shop
   - Delete all usage records
   - Delete all S3 files for shop
   - Delete shop record
   - Logs redacted (replace shop domain with `<redacted>`)

**User Data Request** (GDPR):

- Endpoint: `/api/gdpr/data-request`
- Verify Shopify HMAC signature
- Export all shop data (jobs, usage, config) as JSON
- Return download link

**User Data Deletion** (GDPR):

- Endpoint: `/api/gdpr/data-deletion`
- Verify Shopify HMAC signature
- Immediate deletion (bypass 30-day retention)

### Secrets Management

**AWS Secrets Manager**:

- Shopify API key/secret
- Database credentials (if using RDS in future)
- Third-party API keys

**Environment Variables** (encrypted in AWS):

```bash
# Never commit these
SHOPIFY_API_KEY=<from Secrets Manager>
SHOPIFY_API_SECRET=<from Secrets Manager>
KMS_KEY_ID=<for access token encryption>
```

### Security Auditing

**Regular Tasks**:

- [ ] Dependency vulnerability scanning (Snyk, npm audit)
- [ ] IAM permission review (quarterly)
- [ ] Access log review (monthly)
- [ ] Penetration testing (annually)

**Incident Response Plan**:

1. Detect (alarms, logs, reports)
2. Contain (disable affected component)
3. Investigate (logs, traces, DB queries)
4. Remediate (fix, deploy, verify)
5. Communicate (affected merchants, Shopify if needed)
6. Post-mortem (root cause analysis, prevention)

---

## Billing & Monetization

### Shopify Billing API Integration

**Subscription Plans**:

```typescript
// lib/billing.server.ts
export const PLANS = {
  FREE: {
    name: "Free",
    price: 0,
    features: {
      maxProductsPerImport: 100,
      maxDailyImports: 5,
      maxMonthlyImports: 100,
      allowConcurrentJobs: false,
      logRetentionDays: 90,
      support: "Community",
    },
  },
  SMALL: {
    name: "Small",
    price: 19.99,
    features: {
      maxProductsPerImport: 1000,
      maxDailyImports: 20,
      maxMonthlyImports: 500,
      allowConcurrentJobs: false,
      logRetentionDays: 180,
      support: "Email",
    },
  },
  MEDIUM: {
    name: "Medium",
    price: 49.99,
    features: {
      maxProductsPerImport: 5000,
      maxDailyImports: 50,
      maxMonthlyImports: 1500,
      allowConcurrentJobs: true,
      logRetentionDays: 365,
      support: "Priority Email",
    },
  },
  LARGE: {
    name: "Large",
    price: 99.99,
    features: {
      maxProductsPerImport: 20000,
      maxDailyImports: 100,
      maxMonthlyImports: 3000,
      allowConcurrentJobs: true,
      logRetentionDays: -1, // Forever
      support: "Chat + Email",
    },
  },
};
```

**Subscription Creation**:

```typescript
// When merchant clicks "Upgrade to Small"
const subscription = await shopify.billing.request({
  app_subscription: {
    name: "Inavor Shuttle - Small Plan",
    price: 19.99,
    currency: "USD",
    interval: "every_30_days",
    return_url: `https://app.inavor-shuttle.com/billing/confirm`,
  },
});

// Redirect merchant to confirmation_url
return redirect(subscription.confirmation_url);
```

**Webhook Handling**:

```typescript
// app/routes/webhooks.app-subscription.tsx
export async function action({ request }: ActionArgs) {
  const payload = await request.json();

  // Verify HMAC
  const isValid = verifyShopifyWebhook(request.headers, payload);
  if (!isValid) return json({ error: "Invalid webhook" }, 401);

  const { id, shop, status, plan_name } = payload;

  if (status === "ACTIVE") {
    // Update shop record with new plan
    await db.updateShop(shop, {
      plan: getPlanFromName(plan_name),
      billingStatus: "ACTIVE",
    });
  } else if (status === "CANCELLED") {
    // Downgrade to free
    await db.updateShop(shop, {
      plan: "FREE",
      billingStatus: "CANCELLED",
    });
  }

  return json({ success: true });
}
```

### Usage-Based Add-Ons (Future)

**Optional Add-Ons**:

- Extra storage: $5/GB/month
- API access: $10/month (if not on Large plan)
- Priority processing: $20/month (jump to front of queue)

### Revenue Tracking

**Metrics**:

- MRR (Monthly Recurring Revenue)
- Churn rate
- Plan distribution
- Upgrade/downgrade trends
- Customer lifetime value (LTV)

**Admin Dashboard**:

- Revenue chart (daily, monthly)
- Active subscriptions by plan
- Trial conversion rate
- Churn analysis

---

## Performance Considerations

### Optimization Strategies

#### 1. Batch Size Tuning

**Current Approach**: 50 products per batch

**Optimization**:

- Profile actual Shopify API response times
- Measure Lambda execution time per batch size
- Test batch sizes: 25, 50, 100, 200
- Find optimal balance (throughput vs memory usage)

**Target**: Process 10,000 products in <30 minutes

#### 2. Parallel Processing

**Lambda Concurrency**:

- Allow multiple Lambda instances per job
- Split import into chunks (e.g., 10 chunks of 1000 products)
- Each chunk processed by separate Lambda
- Coordinator Lambda tracks overall progress

**Trade-offs**:

- Faster processing
- Higher cost
- More complex coordination
- Need to manage Shopify rate limits globally

#### 3. Caching

**Metafield Definitions Cache**:

- Cache for 5 minutes (in-memory or ElastiCache)
- Reduces API calls
- Refresh on cache miss

**Shop Configuration Cache**:

- Cache plan limits, settings
- TTL: 1 hour
- Invalidate on shop update

#### 4. Database Optimization

**DynamoDB Best Practices**:

- Use single-table design (reduces latency)
- Batch write operations (up to 25 items)
- Use consistent reads only when necessary
- Partition key design to distribute load evenly

**Query Optimization**:

- Use GSIs for complex queries
- Avoid scans (use queries instead)
- Limit result set size with pagination

#### 5. S3 Performance

**Multipart Upload**:

- For files >5MB, use multipart upload
- Parallel upload of parts
- Faster upload times

**S3 Transfer Acceleration**:

- Enable for large files
- Uses CloudFront edge locations
- Faster uploads from distant regions

### Performance Monitoring

**Key Metrics**:

- Lambda cold start duration (target: <1s)
- Lambda warm execution duration (target: <500ms)
- Shopify API call latency (target: <200ms)
- DynamoDB query latency (target: <10ms)
- End-to-end job duration (target: 10,000 products in <30 min)

**Alerts**:

- Lambda duration >10s for 5 minutes
- DynamoDB query latency >50ms for 5 minutes
- Job duration exceeds 2x estimated time

---

## Risk Management

### Technical Risks

| Risk                                     | Impact   | Likelihood | Mitigation                                                           |
| ---------------------------------------- | -------- | ---------- | -------------------------------------------------------------------- |
| Shopify API rate limits blocking imports | High     | Medium     | Dynamic backoff, queue management, progress tracking                 |
| DynamoDB throttling on high load         | High     | Low        | On-demand pricing, proper partition key design, caching              |
| Lambda cold starts causing timeouts      | Medium   | Medium     | Provisioned concurrency for critical functions, optimize bundle size |
| S3 costs exceeding budget                | Medium   | Low        | Lifecycle policies, compression, usage monitoring                    |
| Security breach exposing access tokens   | Critical | Low        | Encryption (KMS), IAM policies, secrets rotation, audit logs         |
| Shopify API schema changes breaking app  | Medium   | Low        | Versioned API usage, comprehensive tests, monitor Shopify changelog  |

### Business Risks

| Risk                                  | Impact | Likelihood | Mitigation                                                                   |
| ------------------------------------- | ------ | ---------- | ---------------------------------------------------------------------------- |
| Low merchant adoption                 | High   | Medium     | Free plan, great UX, marketing, Shopify App Store optimization               |
| High churn rate                       | High   | Medium     | Excellent onboarding, responsive support, continuous improvement             |
| Competitors offering similar features | Medium | High       | Unique value props (metaobject focus, best-in-class UX), constant innovation |
| Shopify policy changes affecting app  | High   | Low        | Stay updated on Shopify policies, maintain flexibility in architecture       |

### Operational Risks

| Risk                             | Impact   | Likelihood | Mitigation                                                                  |
| -------------------------------- | -------- | ---------- | --------------------------------------------------------------------------- |
| Prolonged downtime during outage | High     | Low        | Multi-AZ deployment, health checks, automated recovery, rollback capability |
| Loss of AWS account access       | Critical | Very Low   | Backup credentials, multi-region backup, documentation                      |
| Key team member unavailable      | Medium   | Medium     | Documentation, knowledge sharing, cross-training                            |
| Budget overrun on AWS costs      | Medium   | Medium     | Cost alerts, budget caps, regular cost review, optimize resources           |

### Contingency Plans

**Shopify API Outage**:

- Queue jobs, display clear status to merchants
- Retry failed jobs automatically when API recovers
- Communicate status via in-app banner

**AWS Service Outage**:

- Most services have automatic failover (S3, DynamoDB)
- Lambda/App Runner: Rely on AWS SLA, no manual action needed
- Monitor AWS status page, communicate to merchants if extended

**Data Loss**:

- DynamoDB Point-in-Time Recovery enabled
- S3 versioning enabled (for critical buckets)
- Regular backups of critical data (weekly exports)

**Security Incident**:

- Incident response plan (see Security section)
- Communication plan (affected merchants, Shopify)
- Post-incident review and remediation

---

## Success Metrics

### MVP Success Criteria (End of Phase 1)

- [ ] 5 dev stores successfully importing 1000+ products
- [ ] Zero critical bugs in 2-week testing period
- [ ] <5 second average response time for API routes
- [ ] > 90% test coverage for core modules
- [ ] Complete AWS infrastructure deployed via CDK
- [ ] Comprehensive documentation (API, user guide)

### Public Launch Success Criteria (End of Phase 2)

- [ ] 50+ active merchants in first 3 months
- [ ] > 80% free-to-paid conversion rate (of those hitting limits)
- [ ] <5% churn rate
- [ ] > 4.5 star rating in Shopify App Store
- [ ] 99.9% uptime
- [ ] <30 min processing time for 10,000 product imports

### Long-Term Success Criteria (12 months)

- [ ] 500+ active merchants
- [ ] $10,000+ MRR
- [ ] <10% churn rate
- [ ] Top 3 product import app in Shopify App Store (by rating/reviews)
- [ ] 99.95% uptime
- [ ] Established reputation in Shopify ecosystem

---

## Next Steps

### Immediate Actions (Week 1)

1. **AWS Account Setup**
   - [ ] Create dedicated AWS account (or use organization)
   - [ ] Set up IAM users and roles
   - [ ] Configure billing alerts
   - [ ] Create S3 buckets (dev, test, prod)

2. **Shopify Partner Setup**
   - [ ] Create Partner account (if not exists)
   - [ ] Create dev stores (3-5 for testing)
   - [ ] Create app in Partner Dashboard
   - [ ] Configure OAuth scopes and URLs

3. **Project Initialization**
   - [ ] Create GitHub repository
   - [ ] Initialize Remix project
   - [ ] Set up AWS CDK project
   - [ ] Configure ESLint, Prettier, TypeScript
   - [ ] Set up CI/CD skeleton

4. **Learning Resources**
   - [ ] AWS Free Tier exploration (Lambda, DynamoDB, S3)
   - [ ] Shopify Admin API documentation review
   - [ ] CDK TypeScript examples
   - [ ] Remix documentation deep dive

### Phase 1 Kickoff (Week 2)

1. **Sprint 1: Authentication & Multi-Tenant Foundation**
   - Implement Shopify OAuth
   - Create DynamoDB tables
   - Build basic Remix routes
   - Set up local development workflow

2. **Sprint 2: JSON Import & Validation**
   - Define import schema
   - Build file upload UI
   - Implement schema validation
   - Create metafield introspection

3. **Sprint 3: Async Job Processing**
   - Set up SQS queues
   - Build Lambda job processor
   - Implement progress tracking
   - Create job management UI

4. **Sprint 4: Import Modes & Testing**
   - Implement all import modes
   - Build dry-run functionality
   - Comprehensive testing
   - Documentation

---

## Appendix

### Glossary

- **Embedded App**: Shopify app that runs inside the Shopify admin iframe
- **Metafield**: Custom data attached to Shopify resources (products, variants, etc.)
- **Metaobject**: Reusable custom data structure in Shopify
- **Dry-Run**: Validation-only mode that doesn't create/modify data
- **ULID**: Universally Unique Lexicographically Sortable Identifier (time-ordered IDs)

### Resources

**Shopify**:

- [Shopify Admin API](https://shopify.dev/api/admin-graphql)
- [Shopify App Development](https://shopify.dev/apps)
- [Shopify Polaris](https://polaris.shopify.com/)
- [Shopify CLI](https://shopify.dev/apps/tools/cli)

**AWS**:

- [AWS CDK Documentation](https://docs.aws.amazon.com/cdk/)
- [DynamoDB Best Practices](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/best-practices.html)
- [Lambda Best Practices](https://docs.aws.amazon.com/lambda/latest/dg/best-practices.html)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)

**Remix**:

- [Remix Documentation](https://remix.run/docs)
- [Remix Shopify App Template](https://github.com/Shopify/shopify-app-template-remix)

**TypeScript**:

- [TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/intro.html)
- [TypeScript Best Practices](https://www.typescriptlang.org/docs/handbook/declaration-files/do-s-and-don-ts.html)

**Testing**:

- [Vitest Documentation](https://vitest.dev/)
- [Playwright Documentation](https://playwright.dev/)

### Contact & Support

**Project Owner**: David Rovani (david@rovaniprojects.com)  
**Company**: Rovani Projects, Inc.  
**Project Repository**: (To be created)

---

**Document Version**: 1.0  
**Last Updated**: 2025-01-15  
**Status**: Approved for Implementation

---

_This document is a living plan and will be updated as the project evolves. All team members should refer to this document for architectural decisions, implementation guidance, and project scope._
