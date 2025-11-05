# CLAUDE.md - Inavor Shuttle Implementation Guide

**Project**: Inavor Shuttle - Shopify Product Import Application
**Company**: Rovani Projects, Inc.
**Status**: Early Stage - Foundation Phase (Phase 1 MVP)
**Last Updated**: 2025-11-05

---

## Quick Reference

### Current Tech Stack
- **Frontend/Backend**: React Router 7.9+ (Node.js 20.x+)
- **Database**: SQLite (dev) → PostgreSQL/DynamoDB (production)
- **Session**: Prisma + @shopify/shopify-app-session-storage-prisma
- **Language**: TypeScript (strict mode)
- **UI**: Shopify Polaris + Tailwind CSS
- **App Framework**: @shopify/shopify-app-react-router

### Key Directories
```
app/
├── routes/                 # React Router file-based routing
├── db.server.ts            # Prisma client initialization
├── shopify.server.ts       # Shopify API configuration
├── entry.server.tsx        # Server entry point
└── root.tsx               # Root layout

prisma/
├── schema.prisma          # Database schema (currently Session model only)
├── migrations/            # Database migrations
└── dev.sqlite            # Local SQLite database

docs/
├── comprehensive-implementation-plan.md    # 2,362 lines - full technical spec
├── github-issues-breakdown.md              # 697 lines - all issue specs (85+ issues, 3 phases)
├── phase-1-issues-summary.md               # 334 lines - quick reference for Phase 1 (40 issues)
├── phase-2-3-issues-template.md            # 1,000+ lines - templates for Phases 2 & 3 (~45 issues)
├── ISSUES-INDEX.md                         # 417 lines - master index and navigation
└── COMPLETION-SUMMARY.md                   # 405 lines - status and execution guide
```

### Existing Prisma Models
Currently only **Session** model exists (for Shopify session management):
- `id`, `shop`, `state`, `isOnline`, `scope`, `expires`
- `accessToken`, `userId`, `firstName`, `lastName`, `email`
- `accountOwner`, `locale`, `collaborator`, `emailVerified`

---

## Documentation Files Overview

### 1. Comprehensive Implementation Plan (`/docs/comprehensive-implementation-plan.md`)
**Length**: 2,362 lines
**Purpose**: Complete technical specification and architecture guide
**Key Sections**:
- Project overview & success criteria
- Technology stack & AWS services deep dive
- Architecture design with diagrams
- Database schema (single-table DynamoDB design)
- Feature breakdown across 3 phases
- Implementation phases with detailed timelines
- Testing strategy (unit, integration, E2E, load testing)
- Deployment strategy with CI/CD
- Monitoring & observability setup
- Security & compliance requirements
- Billing & monetization strategy
- Performance optimization guidelines
- Risk management & contingency plans

**When to Use**: Architecture decisions, understanding "why" behind design choices, AWS service details

---

### 2. GitHub Issues Breakdown (`/docs/github-issues-breakdown.md`)
**Length**: 697 lines
**Purpose**: Detailed specifications for ALL 85+ GitHub issues across 3 phases
**Key Sections**:
- Issue ID naming convention
- Phase 1 MVP (45 issues, broken down by week)
- Phase 2 Enhancement & Launch (~25 issues)
- Phase 3 Enterprise & Scale (~20 issues)
- Priority ordering for Phase 1
- Dependencies graph summary
- Batch creation guide

**When to Use**: Writing PRs, understanding full scope of features, checking detailed issue specs

---

### 3. Phase 1 Issues Summary (`/docs/phase-1-issues-summary.md`)
**Length**: 334 lines
**Purpose**: Quick reference guide for all 40 Phase 1 MVP issues
**Key Sections**:
- Issue listing by week (6 weeks worth)
- Quick links to GitHub issues
- Development workflow
- Issue dependencies
- Labels reference
- Test coverage goals

**When to Use**: Daily work, viewing issue URLs, understanding progress, checking dependencies

---

### 4. Phase 2 & 3 Issues Template (`/docs/phase-2-3-issues-template.md`)
**Length**: 1,000+ lines
**Purpose**: Ready-to-use templates for Phases 2 & 3 issues
**Key Sections**:
- Phase 2 templates (~25 issues) for months 4-6
- Phase 3 templates (~20 issues) for months 7-12
- Usage instructions for creating issues

**When to Use**: After Phase 1 completion, to create Phase 2 and Phase 3 issues

---

### 5. Issues Index (`/docs/ISSUES-INDEX.md`)
**Length**: 417 lines
**Purpose**: Master index and navigation guide for the project
**Key Sections**:
- Quick navigation by phase
- Documentation files reference
- Phase 1 issues overview with table
- Project statistics & effort distribution
- Labels used throughout project
- Development workflow
- Dependency graph (simplified)
- When to create Phase 2 issues
- GitHub issue best practices
- Tracking progress
- Support & questions

**When to Use**: Finding things, understanding project structure, learning best practices

---

### 6. Completion Summary (`/docs/COMPLETION-SUMMARY.md`)
**Length**: 405 lines
**Purpose**: Status of documentation creation and execution guide
**Key Sections**:
- What was accomplished
- Phase status (Phase 1 complete, Phase 2-3 templates ready)
- Documentation created (5 docs, ~3,500 lines total)
- All Phase 1 issues at a glance
- How to use the issues
- Issue quality standards
- Key features of breakdown
- Next steps (weekly timeline)
- Statistics & success metrics

**When to Use**: Understanding project status, next steps, team coordination

---

## Phase 1 Implementation Overview

### Total Scope
- **40 GitHub Issues** (#2-#41)
- **69 Person-Days of Effort**
- **12 Weeks Duration** (with team can parallelize)
- **Status**: ✅ All issues created and ready for development

### Issues by Week

| Week | Component | Issues | Effort |
|------|-----------|--------|--------|
| 1-2 | Infrastructure & Auth | 7 issues | 10 days |
| 3-4 | Schema & Validation | 6 issues | 12 days |
| 5-6 | Job Processing | 8 issues | 14 days |
| 7-8 | UI & Job Management | 7 issues | 12 days |
| 9-10 | Import Modes | 4 issues | 7 days |
| 11-12 | Billing & Analytics | 8 issues | 14 days |
| **Total** | **All Phase 1** | **40 issues** | **69 days** |

---

## Implementation Plan Overview

### Phase 1: MVP (Months 1-3) - 40 GitHub Issues
**Goal**: Core import functionality with Shopify OAuth, JSON validation, async job processing, basic UI

**Key Components to Build**:
1. **Infrastructure** (Weeks 1-2)
   - AWS CDK setup (DynamoDB, S3, SQS, Lambda, App Runner)
   - Shopify OAuth & session management (partially done)
   - Webhook handlers (install/uninstall)

2. **Schema & Validation** (Weeks 3-4)
   - JSON schema definition (v1.0.0)
   - Schema validation engine (Zod)
   - Metafield/metaobject introspection queries
   - Validation engine with detailed error reporting

3. **Job Processing** (Weeks 5-6)
   - Lambda job processor skeleton
   - Job data model & CRUD operations
   - File upload & S3 storage
   - Job submission & queuing via SQS
   - Product creation in Shopify (batch processing)
   - Job status API endpoints

4. **UI & Job Management** (Weeks 7-8)
   - Dashboard layout (Polaris)
   - File upload page (drag-and-drop)
   - Job list page (with filtering/sorting)
   - Job detail page (progress, errors, logs)
   - Dry-run results display

5. **Import Modes** (Weeks 9-10)
   - OVERWRITE_EXISTING
   - NEW_ONLY
   - NEW_AND_DRAFT
   - WIPE_AND_RESTORE (with confirmation)
   - Mode selection UI

6. **Feature Gating & Analytics** (Weeks 11-12)
   - Plan definitions (FREE, SMALL, MEDIUM, LARGE)
   - Usage tracking (daily/monthly)
   - Limit enforcement
   - Merchant analytics dashboard
   - CloudWatch monitoring & alarms

### Phase 2: Enhancement & Launch (Months 4-6) - ~25 issues
See `/docs/phase-2-3-issues-template.md` section 1 for details:
- API endpoint for programmatic imports
- Advanced metafield types support
- Metaobject management UI
- Catalog export functionality
- Shopify Billing API integration
- Enhanced analytics
- Load testing & optimization

### Phase 3: Enterprise & Scale (Months 7-12) - ~20 issues
See `/docs/phase-2-3-issues-template.md` section 2 for details:
- Team collaboration (RBAC)
- Job scheduling
- Advanced error handling
- Internationalization
- Integration ecosystem

---

## Database Schema Roadmap

### Current State (Prisma SQLite)
Only Session model for OAuth. Need to add:

### Phase 1 Models (Add to prisma/schema.prisma)
```typescript
// Shop/Storefront
model Shop {
  id                 String    @id @default(cuid())
  domain             String    @unique
  name               String?
  accessToken        String    @db.Text  // Encrypted in production
  plan               String    @default("FREE")
  installedAt        DateTime  @default(now())
  uninstalledAt      DateTime?
  billingStatus      String    @default("ACTIVE")
  settings           Json?
  createdAt          DateTime  @default(now())
  updatedAt          DateTime  @updatedAt

  jobs               Job[]
  usageDaily         UsageDaily[]
  usageMonthly       UsageMonthly[]
  schemas            Schema[]
}

// Import Job
model Job {
  id                 String    @id @default(cuid())
  jobId              String    @unique  // ULID for sorting
  shop               Shop      @relation(fields: [shopDomain], references: [domain], onDelete: Cascade)
  shopDomain         String
  type               String    @default("IMPORT")
  mode               String    // OVERWRITE_EXISTING, NEW_ONLY, NEW_AND_DRAFT, WIPE_AND_RESTORE
  status             String    // QUEUED, PROCESSING, COMPLETED, FAILED, CANCELLED
  isDryRun           Boolean   @default(false)

  s3Key              String?   // S3 path to import file
  totalProducts      Int       @default(0)
  processedProducts  Int       @default(0)
  successfulProducts Int       @default(0)
  failedProducts     Int       @default(0)
  progressPercentage Int       @default(0)

  startedAt          DateTime?
  completedAt        DateTime?
  estimatedCompletionAt DateTime?

  errorSummary       Json?     // {ERROR_TYPE: count}
  shopifyApiCallsUsed Int      @default(0)
  createdBy          String?

  createdAt          DateTime  @default(now())
  updatedAt          DateTime  @updatedAt

  @@index([shopDomain])
  @@index([status])
  @@index([createdAt])
}

// Daily Usage
model UsageDaily {
  id                 String    @id @default(cuid())
  shop               Shop      @relation(fields: [shopDomain], references: [domain], onDelete: Cascade)
  shopDomain         String
  date               DateTime  @db.Date

  importsCount       Int       @default(0)
  productsImported   Int       @default(0)
  shopifyApiCalls    Int       @default(0)
  storageUsedBytes   Int       @default(0)

  createdAt          DateTime  @default(now())
  updatedAt          DateTime  @updatedAt

  @@unique([shopDomain, date])
  @@index([date])
}

// Monthly Usage (for billing)
model UsageMonthly {
  id                 String    @id @default(cuid())
  shop               Shop      @relation(fields: [shopDomain], references: [domain], onDelete: Cascade)
  shopDomain         String
  yearMonth          String    // "2025-01"

  importsCount       Int       @default(0)
  productsImported   Int       @default(0)
  shopifyApiCalls    Int       @default(0)
  storageUsedBytes   Int       @default(0)

  createdAt          DateTime  @default(now())
  updatedAt          DateTime  @updatedAt

  @@unique([shopDomain, yearMonth])
}

// Schema (metafield/metaobject definitions)
model Schema {
  id                 String    @id @default(cuid())
  shop               Shop      @relation(fields: [shopDomain], references: [domain], onDelete: Cascade)
  shopDomain         String    @unique

  version            String    @default("1.0.0")
  metafieldDefinitions Json?
  metaobjectDefinitions Json?
  lastValidatedAt    DateTime?

  createdAt          DateTime  @default(now())
  updatedAt          DateTime  @updatedAt
}
```

### Transition to Production
- **Phase 1 (Local Dev)**: SQLite via Prisma
- **Phase 2 (Staging/Production)**: Switch to PostgreSQL or DynamoDB via Prisma
- **AWS Production**: Consider DynamoDB single-table design for serverless scaling

---

## Critical Implementation Notes

### Authentication & Authorization
- **OAuth**: Shopify OAuth already integrated via `@shopify/shopify-app-react-router`
- **Session Storage**: Prisma session storage configured
- **API Protection**: All `/app/*` routes require authenticated session
- **Multi-tenant**: Data isolation by shop domain (enforce in all queries)

### File Uploads
- Use S3 for production, local filesystem for development
- Path structure: `imports/{shop-domain}/{job-id}/source.json`
- Implement multipart upload for files >5MB
- Set lifecycle policies (90-day to Glacier, then delete)

### Rate Limiting Strategy
- Shopify API provides rate limit headers in responses
- Track remaining API calls per shop
- Implement exponential backoff when approaching limits
- Use 10% buffer (stop at 90% utilization)

### Job Processing Architecture
- SQS (FIFO queue) → Lambda (polling) → DynamoDB (progress) → Shopify API
- Process products in batches of 50-100
- Each batch = one GraphQL mutation
- Update job progress after each batch
- Write detailed logs to S3 for analysis

### Testing Strategy
- **Unit Tests**: Schema validation, rate limiter, error handling (Vitest)
- **Integration Tests**: Full import flow with mocked Shopify API
- **E2E Tests**: Real merchant workflows (Playwright)
- **Load Tests**: 10,000 product imports, concurrent shops

---

## Shopify Admin API Details

### Required OAuth Scopes
```
write_products
read_products
read_product_listings
read_metaobject_definitions
write_metaobject_definitions
read_metaobjects
write_metaobjects
```

### Critical GraphQL Operations
1. **Metafield Definitions**
   - Query: `metafieldDefinitions(ownerType: PRODUCT)`
   - Returns: namespace, key, type, required flag

2. **Product Creation/Update**
   - `productCreate(input: {title, handle, variants})`
   - `productUpdate(input: {id, ...})`
   - Metafields embedded: `metafields: [{namespace, key, value, type}]`

3. **Bulk Delete** (for Wipe & Restore mode)
   - `productDeleteAsync(input: {ids: []})`
   - Returns: job ID for tracking

4. **Metaobject Management**
   - `metaobjectDefinitionCreate(input: {...})`
   - `metaobjectCreate(input: {type, fields})`

---

## Development Workflow

### Local Development
```bash
npm install
npm run setup          # Generate Prisma client & run migrations
npm run dev            # Start dev server (React Router + Shopify tunnel)
npm run typecheck      # TypeScript check
npm run lint           # ESLint check
npm run build          # Build for production
```

### Git Workflow
- **Branches**: `main` (production), `develop` (integration), `feature/*` (features)
- **Commits**: Use Conventional Commits (`feat:`, `fix:`, `docs:`, etc.)
- **PRs**: Require passing tests + type checks + linked GitHub issue

---

## Common Pitfalls to Avoid

1. **Cross-Tenant Data Leaks**: Always filter by `shopDomain` in queries
2. **Rate Limiting**: Don't ignore Shopify API response headers; implement backoff
3. **Partial Imports**: Jobs can partially succeed; track per-product errors
4. **Session Expiry**: Access tokens expire; implement refresh logic
5. **Cost Overruns**: Monitor S3/DynamoDB usage; set CloudWatch alerts
6. **Error Reporting**: Always include context (shop, job, product) in logs
7. **Concurrent Jobs**: Respect Shopify's 10 concurrent connections per app

---

## Next Steps for Implementation

**See `/docs/phase-1-issues-summary.md` for the complete list of 40 Phase 1 issues**

### Start With (Week 1-2):
- PHASE-1-INFRA-001: AWS Account & CDK Project Setup
- PHASE-1-INFRA-002: DynamoDB Table Creation
- PHASE-1-INFRA-003: S3 Bucket Setup
- PHASE-1-INFRA-004: SQS Queue Setup
- PHASE-1-AUTH-001: Shopify OAuth Implementation
- PHASE-1-AUTH-002: Embedded App Authentication
- PHASE-1-AUTH-003: Install/Uninstall Webhooks

See `ISSUES-INDEX.md` for dependency graph and full Phase 1 timeline.

---

## Resources

**Documentation**:
- Comprehensive Plan: `/docs/comprehensive-implementation-plan.md`
- Issues Breakdown: `/docs/github-issues-breakdown.md`
- Phase 1 Summary: `/docs/phase-1-issues-summary.md`
- Phase 2-3 Templates: `/docs/phase-2-3-issues-template.md`
- Issues Index: `/docs/ISSUES-INDEX.md`
- Completion Summary: `/docs/COMPLETION-SUMMARY.md`

**External**:
- Shopify Admin API: https://shopify.dev/api/admin-graphql
- React Router: https://reactrouter.com/docs
- Prisma: https://www.prisma.io/docs
- TypeScript: https://www.typescriptlang.org/docs
- Zod: https://zod.dev
- Shopify Polaris: https://polaris.shopify.com

---

**Document Version**: 1.1
**Last Updated**: 2025-11-05
**Status**: Phase 1 complete (40 issues ready), Phases 2-3 templates ready
