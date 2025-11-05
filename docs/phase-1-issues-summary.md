# Phase 1 MVP - GitHub Issues Summary

**Created**: 2025-01-15
**Total Issues**: 40
**Repository**: https://github.com/rovani-projects/inavor-shuttle
**Milestone**: Phase 1 MVP
**Duration**: 12 weeks (3 months)

---

## Quick Links

- **All Phase 1 Issues**: https://github.com/rovani-projects/inavor-shuttle/issues?q=is%3Aopen+label%3Aphase-1
- **Issue Breakdown Document**: `/docs/github-issues-breakdown.md`
- **Comprehensive Implementation Plan**: `/docs/comprehensive-implementation-plan.md`

---

## Issue Listing by Week

### Week 1-2: Infrastructure & Authentication (7 issues)

Establish the foundational AWS infrastructure and implement Shopify OAuth.

| Issue # | Title | Est. Effort | Status |
|---------|-------|-------------|--------|
| #2 | PHASE-1-INFRA-001: AWS Account & CDK Project Setup | 1 day | ⏳ Ready |
| #3 | PHASE-1-INFRA-002: DynamoDB Table Creation & Configuration | 2 days | ⏳ Ready |
| #4 | PHASE-1-INFRA-003: S3 Bucket Setup with Lifecycle Policies | 1 day | ⏳ Ready |
| #5 | PHASE-1-INFRA-004: SQS Queue Setup (FIFO + DLQ) | 1 day | ⏳ Ready |
| #6 | PHASE-1-AUTH-001: Shopify OAuth Implementation | 2 days | ⏳ Ready |
| #7 | PHASE-1-AUTH-002: Embedded App Authentication Verification | 1 day | ⏳ Ready |
| #8 | PHASE-1-AUTH-003: Shop Install/Uninstall Webhook Handlers | 2 days | ⏳ Ready |

**Key Deliverables**:
- Full AWS infrastructure via CDK (DynamoDB, S3, SQS)
- Shopify OAuth flow working
- Multi-tenant shop records persisted
- Install/uninstall webhooks operational

**Dependencies**: None (start here)

---

### Week 3-4: Schema & Validation (6 issues)

Define JSON schema and implement comprehensive validation logic.

| Issue # | Title | Est. Effort | Status |
|---------|-------|-------------|--------|
| #9 | PHASE-1-SCHEMA-001: Define Import JSON Schema v1.0.0 | 2 days | ⏳ Ready |
| #10 | PHASE-1-SCHEMA-002: Schema Validation Engine | 2 days | ⏳ Ready |
| #11 | PHASE-1-UI-001: File Upload Component (Drag-and-Drop) | 1 day | ⏳ Ready |
| #12 | PHASE-1-SCHEMA-003: Metafield Introspection Queries | 2 days | ⏳ Ready |
| #13 | PHASE-1-SCHEMA-004: Metafield/Metaobject Validation Engine | 3 days | ⏳ Ready |
| #14 | PHASE-1-UI-002: Schema Documentation Page | 2 days | ⏳ Ready |

**Key Deliverables**:
- JSON schema definition (v1.0.0) in TypeScript
- Schema validation library (Zod-based)
- File upload UI component
- Metafield introspection queries
- Comprehensive metafield validation

**Dependencies**: Weeks 1-2 (authentication)

---

### Week 5-6: Job Processing (8 issues)

Implement async job processing pipeline with Shopify integration.

| Issue # | Title | Est. Effort | Status |
|---------|-------|-------------|--------|
| #15 | PHASE-1-LAMBDA-001: Lambda Job Processor Skeleton | 1 day | ⏳ Ready |
| #16 | PHASE-1-JOB-001: Job Data Model & CRUD Operations | 1 day | ⏳ Ready |
| #17 | PHASE-1-JOB-002: File Upload & S3 Storage | 2 days | ⏳ Ready |
| #18 | PHASE-1-JOB-003: Import Job Submission & Queuing | 2 days | ⏳ Ready |
| #19 | PHASE-1-LAMBDA-002: Job Processor - Load & Validate | 2 days | ⏳ Ready |
| #20 | PHASE-1-SHOPIFY-001: Shopify GraphQL Client Wrapper | 2 days | ⏳ Ready |
| #21 | PHASE-1-LAMBDA-003: Product Creation in Shopify (Batch Processing) | 3 days | ⏳ Ready |
| #22 | PHASE-1-JOB-004: Job Status API Endpoint | 1 day | ⏳ Ready |

**Key Deliverables**:
- Lambda function for processing import jobs
- Job data model in DynamoDB
- File upload endpoint and S3 storage
- Job submission and queuing logic
- Shopify GraphQL API client wrapper
- Product creation with batch processing
- Job status polling API

**Dependencies**: Weeks 1-4 (infrastructure, schema, validation)

---

### Week 7-8: UI & Job Management (7 issues)

Build user interface for dashboard and job management.

| Issue # | Title | Est. Effort | Status |
|---------|-------|-------------|--------|
| #23 | PHASE-1-UI-003: Dashboard Layout (Polaris) | 1 day | ⏳ Ready |
| #24 | PHASE-1-UI-004: Import Upload Page | 2 days | ⏳ Ready |
| #25 | PHASE-1-UI-005: Job List Page | 2 days | ⏳ Ready |
| #26 | PHASE-1-UI-006: Job Detail Page | 2 days | ⏳ Ready |
| #27 | PHASE-1-LAMBDA-004: Dry-Run Job Processor | 2 days | ⏳ Ready |
| #28 | PHASE-1-UI-007: Dry-Run Results Display | 2 days | ⏳ Ready |
| #29 | PHASE-1-CONFIG-001: Basic Shop Configuration Page | 1 day | ⏳ Ready |

**Key Deliverables**:
- Polaris-based dashboard layout
- File upload page with preview
- Job list with filtering and search
- Job detail page with progress and errors
- Dry-run validation processor
- Dry-run results display
- Shop configuration page

**Dependencies**: Weeks 5-6 (job processing)

---

### Week 9-10: Import Modes (4 issues)

Implement different import modes and job management features.

| Issue # | Title | Est. Effort | Status |
|---------|-------|-------------|--------|
| #30 | PHASE-1-IMPORT-001: Import Mode Implementation | 3 days | ⏳ Ready |
| #31 | PHASE-1-UI-008: Import Mode Selection UI | 2 days | ⏳ Ready |
| #32 | PHASE-1-JOB-005: Job Cancellation | 1 day | ⏳ Ready |
| #33 | PHASE-1-UI-009: Download Logs & Error Reports | 1 day | ⏳ Ready |

**Key Deliverables**:
- Import mode implementation (OVERWRITE, NEW_ONLY, NEW_AND_DRAFT, WIPE_AND_RESTORE)
- Mode selection UI with explanations
- Job cancellation functionality
- Log and error report download

**Dependencies**: Weeks 7-8 (UI)

---

### Week 11-12: Billing, Analytics & Deployment (8 issues)

Implement feature gating, usage tracking, monitoring, and staging deployment.

| Issue # | Title | Est. Effort | Status |
|---------|-------|-------------|--------|
| #34 | PHASE-1-BILLING-001: Plan & Feature Definitions | 1 day | ⏳ Ready |
| #35 | PHASE-1-BILLING-002: Usage Tracking (Daily & Monthly) | 2 days | ⏳ Ready |
| #36 | PHASE-1-BILLING-003: Limit Enforcement | 1 day | ⏳ Ready |
| #37 | PHASE-1-UI-010: Analytics Dashboard (Merchant View) | 2 days | ⏳ Ready |
| #38 | PHASE-1-MONITORING-001: CloudWatch Dashboards & Alarms | 2 days | ⏳ Ready |
| #39 | PHASE-1-TESTING-001: Unit & Integration Test Suite for Phase 1 | 2 days | ⏳ Ready |
| #40 | PHASE-1-DOCS-001: User Documentation & Help | 2 days | ⏳ Ready |
| #41 | PHASE-1-DEPLOY-001: Deploy to Staging Environment | 2 days | ⏳ Ready |

**Key Deliverables**:
- Plan definitions (FREE, SMALL, MEDIUM, LARGE)
- Daily and monthly usage tracking
- Limit enforcement before job submission
- Merchant analytics dashboard
- CloudWatch monitoring and alarms
- Comprehensive test suite (>80% coverage)
- User documentation
- Staging environment deployment

**Dependencies**: All previous weeks

---

## Phase 1 Success Criteria

By the end of Phase 1 (Week 12), the following should be achieved:

- [ ] 5 dev stores successfully importing 1000+ products
- [ ] Zero critical bugs in 2-week testing period
- [ ] <5 second average response time for API routes
- [ ] > 90% test coverage for core modules
- [ ] Complete AWS infrastructure deployed via CDK
- [ ] Comprehensive documentation (API, user guide)
- [ ] Dry-run validation working perfectly
- [ ] All import modes functioning correctly
- [ ] Usage limits enforced properly
- [ ] CloudWatch monitoring operational

---

## Development Workflow

### Starting Development

1. **Assign yourself** to an issue from the list above
2. **Create a feature branch** from `main`:
   ```bash
   git checkout -b feature/PHASE-1-COMPONENT-SEQ
   ```
3. **Follow the acceptance criteria** in the issue
4. **Write tests** as you develop
5. **Create a pull request** when ready
6. **Link the PR** to the issue (use `Closes #XX`)
7. **Request review** and address feedback
8. **Merge** when tests pass and approved

### Issue Dependencies

Issues must be completed in order due to dependencies:

```
Week 1-2 (Infrastructure & Auth)
    ↓
Week 3-4 (Schema & Validation)
    ↓
Week 5-6 (Job Processing)
    ↓
Week 7-8 (UI & Job Management)
    ↓
Week 9-10 (Import Modes)
    ↓
Week 11-12 (Billing & Analytics)
```

However, some issues can be worked in parallel:
- Weeks 1-2: All infrastructure and auth issues can be parallelized
- Weeks 3-4: Schema issues can overlap with auth completion
- Weeks 5-6: Job processing can partially overlap with schema completion

### Estimated Timeline

- **Week 1**: Start infrastructure issues
- **Week 2**: Start auth issues (can overlap)
- **Week 3**: Start schema issues
- **Week 4**: Continue schema + start early job processing
- **Week 5**: Continue job processing
- **Week 6**: Finalize job processing
- **Week 7**: Start UI development
- **Week 8**: Continue UI + dry-run
- **Week 9**: Import modes
- **Week 10**: Continue import modes
- **Week 11**: Billing, monitoring, testing
- **Week 12**: Final testing, documentation, staging deployment

---

## Labels Reference

All Phase 1 issues are labeled with:
- **`phase-1`**: All Phase 1 MVP issues
- **Component labels** (one per issue):
  - `infrastructure`: AWS infrastructure
  - `database`: DynamoDB
  - `storage`: S3
  - `messaging`: SQS
  - `auth`: Authentication
  - `backend`: Backend logic
  - `frontend`: Frontend UI
  - `ui`: UI components
  - `webhooks`: Webhook handling
  - `schema`: Schema definition
  - `lambda`: Lambda functions
  - `job-processing`: Job queue and processing
  - `shopify`: Shopify API integration
  - `billing`: Billing and plans
  - `monitoring`: Monitoring and alarms
  - `testing`: Testing and QA
  - `deployment`: Deployment
  - `documentation`: Documentation

---

## Test Coverage Goals

- **Overall**: >80% coverage
- **Critical Paths**: >90% coverage (auth, validation, job processing)
- **Shopify Integration**: >85% coverage (with mocked API)
- **UI Components**: >70% coverage

---

## Before Starting Phase 2

Before moving to Phase 2, ensure:

1. ✅ All 40 Phase 1 issues closed
2. ✅ Zero open bugs from Phase 1
3. ✅ Staging deployment successful
4. ✅ 5+ dev stores tested successfully
5. ✅ All documentation complete
6. ✅ Code reviewed and merged

---

## Phase 2 & 3 Issues

Phase 2 and Phase 3 issues will be created after Phase 1 completion.

See `/docs/github-issues-breakdown.md` for the full breakdown of future phases:
- **Phase 2** (~25 issues): Enhanced features, API, billing integration, launch prep
- **Phase 3** (~20 issues): Team collaboration, scheduling, optimization, enterprise features

---

## Quick Reference

| Component | Issues | Total Days |
|-----------|--------|-----------|
| Infrastructure & Auth | 7 | 10 days |
| Schema & Validation | 6 | 12 days |
| Job Processing | 8 | 14 days |
| UI & Management | 7 | 12 days |
| Import Modes | 4 | 7 days |
| Billing & Analytics | 8 | 14 days |
| **Phase 1 Total** | **40** | **69 days** |

(Estimated 69 person-days of effort, can be parallelized to ~12 weeks with team)

---

## Support & Questions

For questions about:
- **Architecture**: Refer to `/docs/comprehensive-implementation-plan.md`
- **Issue Details**: Check the issue description and acceptance criteria
- **Implementation Guidance**: See technical notes in each issue
- **Dependencies**: Check the issue links

---

**Status**: All Phase 1 issues created and ready for development
**Last Updated**: 2025-01-15
**Next Step**: Begin assigning Week 1-2 infrastructure issues to developers
