# GitHub Issues Breakdown - Inavor Shuttle

This document maps the comprehensive implementation plan into atomic GitHub issues that can be completed in 3 days or less.

**Total Issues**: ~80-100 across 3 phases
**Estimated Timeline**: 12 months
**Organization**: By phase and component

---

## Issue ID Naming Convention

- `PHASE-{X}-{COMPONENT}-{SEQUENCE}`: e.g., `PHASE-1-AUTH-001`
- Labels: `phase-1`, `phase-2`, `phase-3`, `component-auth`, `component-db`, etc.
- Milestones: `Phase 1 MVP`, `Phase 2 Launch`, `Phase 3 Scale`

---

## Phase 1: MVP (Months 1-3, ~45 issues)

### Week 1-2: Infrastructure & Authentication

#### PHASE-1-INFRA-001: AWS Account & CDK Project Setup
- **Description**: Initialize AWS CDK project with TypeScript, set up IAM roles, configure credentials
- **Acceptance Criteria**:
  - CDK project initialized with TypeScript configuration
  - IAM roles created for Lambda, App Runner, DynamoDB access
  - AWS credentials configured for local dev
  - CDK synth works without errors
- **Dependencies**: None
- **Estimated Effort**: 1 day
- **Labels**: `phase-1`, `infrastructure`, `aws`

#### PHASE-1-INFRA-002: DynamoDB Table Creation & Configuration
- **Description**: Create DynamoDB tables via CDK with proper partition/sort keys and GSIs
- **Acceptance Criteria**:
  - Single-table design with PK, SK, GSI1, GSI2
  - Encryption enabled (AWS-managed keys)
  - Point-in-time recovery enabled
  - Local development with docker-compose DynamoDB
  - Unit tests for table schema
- **Dependencies**: PHASE-1-INFRA-001
- **Estimated Effort**: 2 days
- **Labels**: `phase-1`, `database`, `aws`

#### PHASE-1-INFRA-003: S3 Bucket Setup with Lifecycle Policies
- **Description**: Create S3 bucket with folder structure, encryption, lifecycle policies
- **Acceptance Criteria**:
  - S3 bucket with versioning enabled
  - Bucket policy denying public access
  - Server-side encryption enabled (AES-256)
  - Lifecycle policies for imports, logs, exports
  - Folder structure created (imports/, logs/, exports/, schemas/)
  - CDK stack deployable to test/staging/prod
- **Dependencies**: PHASE-1-INFRA-001
- **Estimated Effort**: 1 day
- **Labels**: `phase-1`, `storage`, `aws`

#### PHASE-1-INFRA-004: SQS Queue Setup (FIFO + DLQ)
- **Description**: Create SQS FIFO queue for imports and dead letter queue via CDK
- **Acceptance Criteria**:
  - FIFO queue with message deduplication enabled
  - Dead letter queue configured
  - Queue policies set (Lambda can receive)
  - Local testing with docker-compose or LocalStack
  - CloudWatch alarms for DLQ messages
- **Dependencies**: PHASE-1-INFRA-001
- **Estimated Effort**: 1 day
- **Labels**: `phase-1`, `queue`, `aws`

#### PHASE-1-AUTH-001: Shopify OAuth Implementation
- **Description**: Implement Shopify OAuth flow with secure session management
- **Acceptance Criteria**:
  - OAuth callback endpoint working
  - Access token stored securely (encrypted with AWS KMS)
  - Session cookies set (HTTP-only, secure, 24-hour lifetime)
  - Shop metadata persisted in DynamoDB
  - Logout functionality
  - Unit tests for OAuth flow
  - Integration test with dev store
- **Dependencies**: PHASE-1-INFRA-002 (DynamoDB)
- **Estimated Effort**: 2 days
- **Labels**: `phase-1`, `authentication`, `security`

#### PHASE-1-AUTH-002: Embedded App Authentication Verification
- **Description**: Verify Shopify embedded app credentials in every request
- **Acceptance Criteria**:
  - Middleware to verify JWT in embedded app context
  - Check scopes and permissions
  - Reject unauthorized requests
  - Unit tests for verification logic
  - Error handling for invalid tokens
- **Dependencies**: PHASE-1-AUTH-001
- **Estimated Effort**: 1 day
- **Labels**: `phase-1`, `authentication`

#### PHASE-1-AUTH-003: Shop Install/Uninstall Webhook Handlers
- **Description**: Handle Shopify install/uninstall events
- **Acceptance Criteria**:
  - Webhook handler for `app/installed` event
  - Webhook handler for `app/uninstalled` event
  - Create shop record on install with FREE plan
  - Update `uninstalledAt` timestamp on uninstall
  - Schedule 30-day deletion job
  - Unit tests for webhook handling
  - HMAC verification for webhook authenticity
- **Dependencies**: PHASE-1-INFRA-002 (DynamoDB)
- **Estimated Effort**: 2 days
- **Labels**: `phase-1`, `webhooks`, `backend`

### Week 3-4: JSON Schema & Validation

#### PHASE-1-SCHEMA-001: Define Import JSON Schema v1.0.0
- **Description**: Create JSON schema for product imports with metafields/metaobjects
- **Acceptance Criteria**:
  - Schema file: `/schemas/import-schema-v1.0.0.json`
  - Covers: products, variants, metafields, metaobjects
  - Schema validation using Zod TypeScript
  - TypeScript types generated from schema
  - Documentation for schema structure
  - Examples (basic, advanced with metafields, metaobjects)
- **Dependencies**: None
- **Estimated Effort**: 2 days
- **Labels**: `phase-1`, `schema`, `validation`

#### PHASE-1-SCHEMA-002: Schema Validation Engine (JSON + Type Checking)
- **Description**: Build validation library to check imports against schema
- **Acceptance Criteria**:
  - Zod-based validator
  - Check JSON structure
  - Validate data types
  - Check required fields
  - Return detailed errors with line numbers
  - Unit tests (80%+ coverage)
  - Performance: <500ms for 10,000 product JSON
- **Dependencies**: PHASE-1-SCHEMA-001
- **Estimated Effort**: 2 days
- **Labels**: `phase-1`, `validation`, `backend`

#### PHASE-1-UI-001: File Upload Component (Drag-and-Drop)
- **Description**: Build file upload UI with drag-and-drop, progress, size limits
- **Acceptance Criteria**:
  - Drag-and-drop file upload
  - File size validation (max 50MB)
  - File type validation (JSON only)
  - Progress indicator
  - Error display
  - Polaris-based UI components
  - Unit tests for component
  - Accessibility: ARIA labels, keyboard navigation
- **Dependencies**: None (UI-only)
- **Estimated Effort**: 1 day
- **Labels**: `phase-1`, `ui`, `frontend`

#### PHASE-1-SCHEMA-003: Metafield Introspection Queries
- **Description**: Query Shopify API for metafield and metaobject definitions
- **Acceptance Criteria**:
  - GraphQL query for metafield definitions
  - GraphQL query for metaobject definitions
  - Handle pagination for large catalogs
  - Cache results (5-minute TTL)
  - Unit tests with mocked Shopify API
  - Error handling for API failures
- **Dependencies**: PHASE-1-AUTH-001 (need access token)
- **Estimated Effort**: 2 days
- **Labels**: `phase-1`, `shopify-api`, `backend`

#### PHASE-1-SCHEMA-004: Metafield/Metaobject Validation Engine
- **Description**: Validate import data against Shopify metafield/metaobject definitions
- **Acceptance Criteria**:
  - Check namespace exists
  - Check key matches definition
  - Validate type matches
  - Validate value for type
  - Check required fields in metaobjects
  - Handle "shopify" namespace
  - Generate validation report
  - Unit tests (85%+ coverage)
  - Detailed error messages with field paths
- **Dependencies**: PHASE-1-SCHEMA-003 (introspection)
- **Estimated Effort**: 3 days
- **Labels**: `phase-1`, `validation`, `backend`

#### PHASE-1-UI-002: Schema Documentation Page
- **Description**: In-app documentation showing schema structure and examples
- **Acceptance Criteria**:
  - Interactive schema browser
  - Example JSON templates
  - Download sample files
  - Explanations for each field
  - Link to full API documentation
  - Polaris UI components
  - Responsive design
- **Dependencies**: PHASE-1-SCHEMA-001
- **Estimated Effort**: 2 days
- **Labels**: `phase-1`, `ui`, `documentation`

### Week 5-6: Core Job Processing

#### PHASE-1-LAMBDA-001: Lambda Job Processor Skeleton
- **Description**: Create Lambda function structure for processing import jobs
- **Acceptance Criteria**:
  - Lambda handler configured
  - SQS event source mapping
  - Polling logic working
  - Logging setup (CloudWatch)
  - Local testing with SAM or serverless framework
  - Basic error handling
  - Unit tests
- **Dependencies**: PHASE-1-INFRA-004 (SQS)
- **Estimated Effort**: 1 day
- **Labels**: `phase-1`, `lambda`, `backend`

#### PHASE-1-JOB-001: Job Data Model & CRUD Operations
- **Description**: Create job entity in DynamoDB with create/read/update operations
- **Acceptance Criteria**:
  - Job record structure matches schema (id, status, progress, etc.)
  - Create job function (with validation)
  - Get job function
  - Update job progress function
  - Query jobs by shop and status
  - Unit tests with mocked DynamoDB
  - Integration tests with local DynamoDB
- **Dependencies**: PHASE-1-INFRA-002 (DynamoDB)
- **Estimated Effort**: 1 day
- **Labels**: `phase-1`, `database`, `backend`

#### PHASE-1-JOB-002: File Upload & S3 Storage
- **Description**: Handle file upload from UI, save to S3, return upload metadata
- **Acceptance Criteria**:
  - File upload endpoint (multipart form data)
  - Save to S3 with proper path structure
  - Generate upload ID for tracking
  - Return presigned download URLs
  - File size and type validation
  - Unit tests for endpoint
  - Integration test with S3
  - Error handling for S3 failures
- **Dependencies**: PHASE-1-INFRA-003 (S3)
- **Estimated Effort**: 2 days
- **Labels**: `phase-1`, `backend`, `storage`

#### PHASE-1-JOB-003: Import Job Submission & Queuing
- **Description**: Accept import request, validate, create job, queue for processing
- **Acceptance Criteria**:
  - API endpoint to submit import
  - Validate file path is in S3
  - Create job record in DynamoDB
  - Check usage limits before queuing
  - Send job to SQS queue
  - Return job ID and initial status
  - Unit tests with mocked dependencies
  - Integration tests end-to-end
- **Dependencies**: PHASE-1-JOB-001, PHASE-1-JOB-002, PHASE-1-SCHEMA-002
- **Estimated Effort**: 2 days
- **Labels**: `phase-1`, `backend`, `queue`

#### PHASE-1-LAMBDA-002: Job Processor - Load & Validate
- **Description**: Lambda processes queued job, loads file, validates against schema
- **Acceptance Criteria**:
  - Lambda receives SQS message
  - Load JSON from S3
  - Run schema validation
  - Run metafield validation
  - Generate validation report
  - Update job status to validation results
  - Handle validation errors gracefully
  - Unit tests for validation steps
  - Integration test with real/mocked S3 and DynamoDB
- **Dependencies**: PHASE-1-LAMBDA-001, PHASE-1-SCHEMA-002, PHASE-1-SCHEMA-004
- **Estimated Effort**: 2 days
- **Labels**: `phase-1`, `lambda`, `backend`

#### PHASE-1-SHOPIFY-001: Shopify GraphQL Client Wrapper
- **Description**: Create wrapper for Shopify Admin API GraphQL calls
- **Acceptance Criteria**:
  - Client configured with access token
  - Execute GraphQL queries/mutations
  - Handle Shopify API errors
  - Rate limit detection (check response headers)
  - Retry logic for transient errors
  - Logging of API calls
  - Unit tests with mocked HTTP
  - Integration tests with real Shopify API (optional, slower)
- **Dependencies**: PHASE-1-AUTH-001 (access tokens)
- **Estimated Effort**: 2 days
- **Labels**: `phase-1`, `shopify-api`, `backend`

#### PHASE-1-LAMBDA-003: Product Creation in Shopify (Batch Processing)
- **Description**: Lambda processes products, creates mutations for Shopify
- **Acceptance Criteria**:
  - Batch products (50 per batch initially)
  - Generate GraphQL mutations
  - Execute mutations via Shopify API
  - Track successful vs failed products
  - Update job progress in DynamoDB
  - Handle rate limits (retry with backoff)
  - Handle Shopify API errors per product
  - Write detailed logs to S3
  - Unit tests with mocked Shopify API
  - Integration test with dev store (if safe)
- **Dependencies**: PHASE-1-LAMBDA-002, PHASE-1-SHOPIFY-001, PHASE-1-JOB-001
- **Estimated Effort**: 3 days
- **Labels**: `phase-1`, `lambda`, `shopify-api`

#### PHASE-1-JOB-004: Job Status API Endpoint
- **Description**: API endpoint for UI to poll job progress in real-time
- **Acceptance Criteria**:
  - GET endpoint: `/api/job/{jobId}`
  - Return job status, progress percentage, error count
  - Handle non-existent jobs
  - Handle authorization (only shop can access own jobs)
  - Performance: <100ms response
  - Unit tests with mocked DynamoDB
  - Integration tests
- **Dependencies**: PHASE-1-JOB-001
- **Estimated Effort**: 1 day
- **Labels**: `phase-1`, `backend`, `api`

### Week 7-8: UI & Job Management

#### PHASE-1-UI-003: Dashboard Layout (Polaris)
- **Description**: Main dashboard layout with navigation
- **Acceptance Criteria**:
  - Polaris Frame and navigation components
  - Navigation: Import, Configuration, Analytics, Help
  - Welcome screen for new installs
  - Responsive design
  - Mobile-friendly
  - Accessibility
  - Unit tests for layout
- **Dependencies**: None
- **Estimated Effort**: 1 day
- **Labels**: `phase-1`, `ui`, `frontend`

#### PHASE-1-UI-004: Import Upload Page
- **Description**: Full page for uploading and previewing import files
- **Acceptance Criteria**:
  - File upload component
  - File validation feedback
  - Preview of sample products from JSON
  - Select import mode (dropdown)
  - Submit button
  - Error display
  - Loading states
  - Polaris components
  - Integration with file upload API
  - E2E test (Playwright)
- **Dependencies**: PHASE-1-UI-001, PHASE-1-JOB-002, PHASE-1-UI-003
- **Estimated Effort**: 2 days
- **Labels**: `phase-1`, `ui`, `frontend`

#### PHASE-1-UI-005: Job List Page
- **Description**: Display all import jobs for current shop
- **Acceptance Criteria**:
  - Table showing jobs (ID, date, status, product count, progress)
  - Filter by status (queued, processing, completed, failed)
  - Filter by date range
  - Sort by created date, completion date
  - Search by job ID
  - Link to job detail page
  - Pagination (50 per page)
  - Real-time status updates (polling every 2 seconds)
  - Polaris Table component
  - E2E test
- **Dependencies**: PHASE-1-JOB-004
- **Estimated Effort**: 2 days
- **Labels**: `phase-1`, `ui`, `frontend`

#### PHASE-1-UI-006: Job Detail Page
- **Description**: Detailed view of single import job with progress, errors, logs
- **Acceptance Criteria**:
  - Job header (ID, status, created date, duration)
  - Progress bar with percentage
  - Product count breakdown (total, successful, failed)
  - Error summary (grouped by error type)
  - Error details table (product ID, error message)
  - Action buttons: Cancel, Retry, Download Logs, Download Errors
  - Real-time progress updates
  - Polaris components
  - E2E test
- **Dependencies**: PHASE-1-JOB-004, PHASE-1-UI-003
- **Estimated Effort**: 2 days
- **Labels**: `phase-1`, `ui`, `frontend`

#### PHASE-1-LAMBDA-004: Dry-Run Job Processor
- **Description**: Create separate Lambda function for dry-run (validation-only) jobs
- **Acceptance Criteria**:
  - Validation without Shopify API calls
  - Generate comprehensive validation report
  - Count valid vs invalid products
  - Group errors by type
  - Estimate API calls needed
  - Write report to S3
  - Update job status
  - Handle errors gracefully
  - Unit tests
- **Dependencies**: PHASE-1-LAMBDA-002, PHASE-1-SCHEMA-004
- **Estimated Effort**: 2 days
- **Labels**: `phase-1`, `lambda`, `backend`

#### PHASE-1-UI-007: Dry-Run Results Display
- **Description**: UI to display dry-run validation results
- **Acceptance Criteria**:
  - Show validation success/failure
  - List errors with line numbers
  - Group errors by type
  - Show estimated API calls
  - Show products that would be created/updated
  - Button to proceed with actual import
  - Button to download report
  - Polaris components
  - E2E test
- **Dependencies**: PHASE-1-LAMBDA-004, PHASE-1-UI-006
- **Estimated Effort**: 2 days
- **Labels**: `phase-1`, `ui`, `frontend`

### Week 9-10: Import Modes & Job Management

#### PHASE-1-IMPORT-001: Import Mode Implementation (Overwrite, New Only, etc.)
- **Description**: Implement logic for different import modes
- **Acceptance Criteria**:
  - OVERWRITE_EXISTING: Update products matching SKU/handle
  - NEW_ONLY: Skip existing, create new
  - NEW_AND_DRAFT: Create new, overwrite draft products
  - WIPE_AND_RESTORE: Delete all products, then import
  - Shopify API queries for each mode
  - Unit tests for each mode logic
  - Integration tests with dev store (optional)
  - Documentation
- **Dependencies**: PHASE-1-SHOPIFY-001, PHASE-1-LAMBDA-003
- **Estimated Effort**: 3 days
- **Labels**: `phase-1`, `backend`, `shopify-api`

#### PHASE-1-UI-008: Import Mode Selection UI
- **Description**: UI to select and explain import modes
- **Acceptance Criteria**:
  - Radio button group or tabs for each mode
  - Clear description of each mode
  - Warnings for destructive modes (Wipe & Restore)
  - Confirmation dialog for Wipe & Restore
  - Shop name confirmation input for Wipe & Restore
  - Polaris components
  - Accessibility
  - E2E test
- **Dependencies**: PHASE-1-UI-004, PHASE-1-IMPORT-001
- **Estimated Effort**: 2 days
- **Labels**: `phase-1`, `ui`, `frontend`

#### PHASE-1-JOB-005: Job Cancellation
- **Description**: Allow users to cancel running import jobs
- **Acceptance Criteria**:
  - Cancel button on job detail page
  - Update job status to CANCELLED
  - Stop processing gracefully (finish current batch)
  - Return partial results
  - Unit tests
  - Integration test
  - Error handling
- **Dependencies**: PHASE-1-UI-006, PHASE-1-JOB-001
- **Estimated Effort**: 1 day
- **Labels**: `phase-1`, `backend`, `job-management`

#### PHASE-1-UI-009: Download Logs & Error Reports
- **Description**: Generate and download job logs and error reports
- **Acceptance Criteria**:
  - Download logs as text file
  - Download errors as JSON
  - Download errors as CSV
  - Presigned S3 URLs for download
  - File expiration after 24 hours
  - Unit tests
  - Integration test
- **Dependencies**: PHASE-1-JOB-004, PHASE-1-UI-006
- **Estimated Effort**: 1 day
- **Labels**: `phase-1`, `ui`, `backend`

#### PHASE-1-CONFIG-001: Basic Shop Configuration Page
- **Description**: Settings page for shop configuration
- **Acceptance Criteria**:
  - Display shop name, domain, plan
  - Edit notification email
  - Display metafield definitions (read-only)
  - Polaris Form components
  - Save settings to DynamoDB
  - Unit tests
- **Dependencies**: PHASE-1-JOB-001, PHASE-1-UI-003
- **Estimated Effort**: 1 day
- **Labels**: `phase-1`, `ui`, `backend`

### Week 11-12: Feature Gating & Analytics

#### PHASE-1-BILLING-001: Plan & Feature Definitions
- **Description**: Define plan tiers and feature limits
- **Acceptance Criteria**:
  - Plan definitions (FREE, SMALL, MEDIUM, LARGE)
  - Feature flags per plan
  - DynamoDB schema for plans
  - TypeScript types
  - Documentation
- **Dependencies**: None
- **Estimated Effort**: 1 day
- **Labels**: `phase-1`, `billing`, `backend`

#### PHASE-1-BILLING-002: Usage Tracking (Daily & Monthly)
- **Description**: Track product imports, storage, API calls per shop
- **Acceptance Criteria**:
  - Daily usage record creation
  - Monthly usage aggregation job (scheduled)
  - Track: imports count, products imported, API calls, storage
  - DynamoDB queries
  - Unit tests
  - Integration test with scheduled EventBridge rule
- **Dependencies**: PHASE-1-INFRA-002, PHASE-1-BILLING-001
- **Estimated Effort**: 2 days
- **Labels**: `phase-1`, `billing`, `backend`

#### PHASE-1-BILLING-003: Limit Enforcement
- **Description**: Check usage limits before allowing jobs
- **Acceptance Criteria**:
  - Check plan limits before job submission
  - Block job if over limit
  - Clear error message with upgrade prompt
  - Handle concurrent job limits
  - Unit tests
  - Integration tests
- **Dependencies**: PHASE-1-BILLING-002, PHASE-1-JOB-003
- **Estimated Effort**: 1 day
- **Labels**: `phase-1`, `billing`, `backend`

#### PHASE-1-UI-010: Analytics Dashboard (Merchant View)
- **Description**: In-app analytics for individual merchants
- **Acceptance Criteria**:
  - Total products imported (lifetime, monthly)
  - Import history chart (products over time)
  - Success rate percentage
  - Storage usage
  - Recent jobs list
  - Polaris components
  - Responsive design
  - E2E test
- **Dependencies**: PHASE-1-BILLING-002, PHASE-1-UI-003
- **Estimated Effort**: 2 days
- **Labels**: `phase-1`, `ui`, `analytics`

#### PHASE-1-MONITORING-001: CloudWatch Dashboards & Alarms
- **Description**: Set up monitoring dashboards and critical alarms
- **Acceptance Criteria**:
  - CloudWatch dashboard creation via CDK
  - Job processing metrics
  - Lambda error rates
  - DynamoDB performance
  - Shopify API rate limits
  - Critical alarms (Lambda errors >5%, DLQ messages >5)
  - Warning alarms (Lambda duration >10s)
  - Alert to SNS topic
  - CDK stack deployable
- **Dependencies**: PHASE-1-INFRA-001, PHASE-1-LAMBDA-001
- **Estimated Effort**: 2 days
- **Labels**: `phase-1`, `monitoring`, `aws`

#### PHASE-1-TESTING-001: Unit & Integration Test Suite for Phase 1
- **Description**: Comprehensive test coverage for core functionality
- **Acceptance Criteria**:
  - Unit tests: >80% coverage for critical modules
  - Integration tests: full import flow with mocked Shopify API
  - Integration test: multi-tenant isolation
  - Integration test: usage limit enforcement
  - Test all error cases
  - Use Vitest framework
  - All tests passing
  - CI/CD pipeline runs tests on PR
- **Dependencies**: All Phase 1 features
- **Estimated Effort**: 2 days
- **Labels**: `phase-1`, `testing`, `qa`

#### PHASE-1-DOCS-001: User Documentation & Help
- **Description**: In-app help content and user guide
- **Acceptance Criteria**:
  - In-app help page (Polaris)
  - JSON schema documentation
  - FAQ section
  - Troubleshooting guide
  - API documentation (markdown)
  - Examples for each import mode
  - Screenshots/diagrams
  - Link to external resources
- **Dependencies**: All Phase 1 features
- **Estimated Effort**: 2 days
- **Labels**: `phase-1`, `documentation`

#### PHASE-1-DEPLOY-001: Deploy to Staging Environment
- **Description**: Deploy Phase 1 MVP to staging for testing
- **Acceptance Criteria**:
  - AWS infrastructure deployed via CDK
  - Shopify app configured for staging
  - Shopify CLI integration
  - Environment variables configured
  - Database migrated
  - Smoke tests passing
  - Load test (100 products) successful
- **Dependencies**: All Phase 1 features
- **Estimated Effort**: 2 days
- **Labels**: `phase-1`, `deployment`, `devops`

---

## Phase 2: Enhancement & Launch (Months 4-6, ~25 issues)

Will be created after Phase 1 completion. Key areas:
- API endpoint for imports
- Advanced metafield types
- Metaobject management UI
- Catalog export
- Shopify Billing API integration
- Enhanced analytics
- Load testing & optimization

---

## Phase 3: Enterprise & Scale (Months 7-12, ~20 issues)

Will be created after Phase 2 completion. Key areas:
- Team collaboration (RBAC)
- Job scheduling
- Advanced error handling
- Internationalization
- Integration ecosystem

---

## Priority Order for Phase 1

1. **Weeks 1-2**: Infrastructure & Auth (PHASE-1-INFRA-*)
2. **Weeks 3-4**: Schema & Validation (PHASE-1-SCHEMA-*, PHASE-1-UI-001/002)
3. **Weeks 5-6**: Job Processing (PHASE-1-LAMBDA-*, PHASE-1-JOB-*, PHASE-1-SHOPIFY-001)
4. **Weeks 7-8**: UI & Dry-Run (PHASE-1-UI-003/004/005/006/007)
5. **Weeks 9-10**: Import Modes (PHASE-1-IMPORT-*, PHASE-1-UI-008/009)
6. **Weeks 11-12**: Billing & Analytics (PHASE-1-BILLING-*, PHASE-1-UI-010, PHASE-1-MONITORING-*)

---

## Dependencies Graph Summary

```
PHASE-1-INFRA-001 (AWS Setup)
  ├─> PHASE-1-INFRA-002 (DynamoDB)
  ├─> PHASE-1-INFRA-003 (S3)
  ├─> PHASE-1-INFRA-004 (SQS)
  └─> PHASE-1-AUTH-001 (OAuth) [depends on DynamoDB]
        ├─> PHASE-1-AUTH-002 (Embedded Auth)
        └─> PHASE-1-AUTH-003 (Webhooks)

PHASE-1-SCHEMA-001 (JSON Schema)
  ├─> PHASE-1-SCHEMA-002 (Validation)
  ├─> PHASE-1-SCHEMA-003 (Introspection)
  └─> PHASE-1-SCHEMA-004 (Metafield Validation)

PHASE-1-SHOPIFY-001 (API Client)
  └─> PHASE-1-LAMBDA-003 (Product Creation)

PHASE-1-LAMBDA-001 (Skeleton)
  ├─> PHASE-1-LAMBDA-002 (Load & Validate)
  ├─> PHASE-1-LAMBDA-003 (Product Creation)
  └─> PHASE-1-LAMBDA-004 (Dry-Run)

PHASE-1-JOB-001 (Data Model)
  ├─> PHASE-1-JOB-002 (File Upload)
  ├─> PHASE-1-JOB-003 (Submission)
  ├─> PHASE-1-JOB-004 (Status API)
  └─> PHASE-1-JOB-005 (Cancellation)

PHASE-1-UI-001 (File Upload)
  └─> PHASE-1-UI-004 (Upload Page)

PHASE-1-UI-003 (Dashboard)
  ├─> PHASE-1-UI-004 (Upload)
  ├─> PHASE-1-UI-005 (Job List)
  └─> PHASE-1-CONFIG-001 (Config)

PHASE-1-IMPORT-001 (Modes)
  └─> PHASE-1-UI-008 (Mode Selection)
```

---

## Creating Issues in Batches

**Batch 1** (Week 1 start): PHASE-1-INFRA-* (5 issues)
**Batch 2** (Week 2 start): PHASE-1-AUTH-* (3 issues)
**Batch 3** (Week 3 start): PHASE-1-SCHEMA-* (4 issues)
**Batch 4** (Week 4 start): PHASE-1-LAMBDA-*, PHASE-1-JOB-* (8 issues)
... and so on

---

**This document serves as a master breakdown. Use it to create issues incrementally.**
