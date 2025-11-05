# Phase 2 & Phase 3 Issues Template

This document provides the issue templates for Phase 2 and Phase 3. When you're ready to create these issues, follow the same format as Phase 1.

**Use this to generate issues after Phase 1 is complete.**

---

## Phase 2: Enhancement & Public Launch (Months 4-6, ~25 issues)

### Month 4: Advanced Features (Week 13-16)

#### PHASE-2-API-001: REST API Endpoint for Imports
- **Description**: Create REST API endpoint `/api/import` for external import submissions
- **Acceptance Criteria**:
  - POST `/api/import` endpoint
  - API key authentication (per shop)
  - Submit import file via multipart form data or JSON
  - Return job ID and status
  - Rate limiting (per API key)
  - Error handling and validation
  - Unit tests
  - Swagger/OpenAPI documentation
- **Dependencies**: PHASE-1-JOB-003 (job submission)
- **Estimated Effort**: 2 days
- **Labels**: `phase-2`, `backend`, `api`, `shopify`

#### PHASE-2-API-002: API Key Management UI & Backend
- **Description**: Generate, revoke, rotate API keys for shops
- **Acceptance Criteria**:
  - Generate API keys (hashed storage)
  - Revoke/deactivate keys
  - Show API key once (on creation)
  - API key management page (Polaris)
  - Scoped to shop (cannot access other shops)
  - Rotation capability
  - Activity log (when key was used)
  - Unit tests
  - Integration tests
- **Dependencies**: PHASE-2-API-001
- **Estimated Effort**: 2 days
- **Labels**: `phase-2`, `backend`, `frontend`, `security`

#### PHASE-2-SHOPIFY-002: Advanced Metafield Types Support
- **Description**: Support all Shopify metafield types (list, file_reference, dimension, etc.)
- **Acceptance Criteria**:
  - Support list.product, list.variant, list.metaobject types
  - Support file_reference type
  - Support json type
  - Support dimension, volume, weight, rating, color types
  - Validation for each type
  - File upload handling for file_reference
  - Unit tests for each type
  - Type mapping documentation
- **Dependencies**: PHASE-1-SCHEMA-004 (metafield validation)
- **Estimated Effort**: 3 days
- **Labels**: `phase-2`, `backend`, `shopify-api`, `validation`

#### PHASE-2-UI-011: Metaobject Management UI
- **Description**: Visual interface for creating and managing metaobject definitions
- **Acceptance Criteria**:
  - Create metaobject definition form
  - Add fields to definition
  - Edit existing definitions
  - View metaobject instances
  - Bulk create instances from JSON
  - Polaris components
  - Validation
  - Responsive design
  - E2E tests (Playwright)
- **Dependencies**: PHASE-2-SHOPIFY-002
- **Estimated Effort**: 3 days
- **Labels**: `phase-2`, `ui`, `frontend`, `shopify-api`

#### PHASE-2-IMPORT-002: Catalog Export Functionality
- **Description**: Export current product catalog in Inavor Shuttle format
- **Acceptance Criteria**:
  - Export all products or filtered subset
  - Include metafields and metaobjects
  - Export as JSON file (Inavor Shuttle format)
  - Download to S3
  - Generate presigned download URL
  - Filter options: collection, product type, vendor, tags
  - Async job for large catalogs
  - Unit tests
  - Integration tests
- **Dependencies**: PHASE-1-IMPORT-001 (import modes)
- **Estimated Effort**: 2 days
- **Labels**: `phase-2`, `backend`, `storage`

#### PHASE-2-IMPORT-003: Import Templates Library
- **Description**: Save and reuse import configurations as templates
- **Acceptance Criteria**:
  - Save import template (name, description, JSON schema)
  - List templates for shop
  - Load template for quick import
  - Edit template
  - Delete template
  - Share templates (future: marketplace)
  - DynamoDB storage
  - Polaris UI components
  - Unit tests
  - Integration tests
- **Dependencies**: PHASE-1-IMPORT-001
- **Estimated Effort**: 2 days
- **Labels**: `phase-2`, `backend`, `frontend`, `database`

#### PHASE-2-PERF-001: Performance Optimization (Caching & Tuning)
- **Description**: Implement caching and optimize batch sizes for performance
- **Acceptance Criteria**:
  - In-memory cache for metafield definitions (5-minute TTL)
  - Cache shop configuration (1-hour TTL)
  - Tune Lambda batch sizes (test 25, 50, 100, 200)
  - Load test with 10,000 products
  - Measure and document performance
  - Optimize for sub-30 min 10k product import
  - Unit tests
  - Load test results
- **Dependencies**: PHASE-1-LAMBDA-003 (product creation)
- **Estimated Effort**: 2 days
- **Labels**: `phase-2`, `backend`, `performance`, `optimization`

### Month 5: Billing & Analytics (Week 17-20)

#### PHASE-2-BILLING-004: Shopify Billing API Integration
- **Description**: Implement recurring subscription billing via Shopify API
- **Acceptance Criteria**:
  - Billing API mutation for creating subscriptions
  - Webhook handler for subscription status changes
  - Plan selection UI
  - Subscription confirmation page
  - Update shop plan on webhook
  - Handle payment failures
  - Test with dev store billing
  - Unit tests
  - Integration tests
- **Dependencies**: PHASE-1-BILLING-001 (plan definitions)
- **Estimated Effort**: 3 days
- **Labels**: `phase-2`, `backend`, `billing`, `shopify-api`, `webhooks`

#### PHASE-2-BILLING-005: Plan Upgrade/Downgrade Flow
- **Description**: Allow merchants to change subscription plans
- **Acceptance Criteria**:
  - UI for plan selection
  - Upgrade path (free to paid)
  - Downgrade path (paid to free or lower tier)
  - Billing API calls to update subscription
  - Webhook handling for status changes
  - Confirmation and receipt
  - Error handling (payment failures)
  - Unit tests
  - Integration tests
  - E2E tests (Playwright)
- **Dependencies**: PHASE-2-BILLING-004
- **Estimated Effort**: 2 days
- **Labels**: `phase-2`, `backend`, `frontend`, `billing`

#### PHASE-2-BILLING-006: Invoice Generation & Payment History
- **Description**: Generate invoices and show payment history to merchants
- **Acceptance Criteria**:
  - Query subscription charges from Shopify Billing API
  - Display payment history table
  - Generate invoice PDFs (from Shopify data)
  - Download invoice functionality
  - Email invoices to shop email
  - Polaris components
  - Unit tests
  - Integration tests
- **Dependencies**: PHASE-2-BILLING-004
- **Estimated Effort**: 2 days
- **Labels**: `phase-2`, `backend`, `frontend`, `billing`

#### PHASE-2-ANALYTICS-001: Advanced Analytics for Merchants
- **Description**: Enhanced analytics dashboard with trends and insights
- **Acceptance Criteria**:
  - Cost analysis (API calls, storage estimates)
  - Performance trends (import speed over time)
  - Comparison reports (before/after imports)
  - Custom report builder
  - Charts and graphs (Chart.js or Recharts)
  - Export analytics as CSV/PDF
  - Polaris components
  - Responsive design
  - E2E tests
- **Dependencies**: PHASE-1-UI-010 (basic analytics)
- **Estimated Effort**: 3 days
- **Labels**: `phase-2`, `ui`, `frontend`, `analytics`

#### PHASE-2-ANALYTICS-002: Admin Dashboard (Rovani Projects)
- **Description**: Internal dashboard for Rovani Projects to track business metrics
- **Acceptance Criteria**:
  - Total shops installed
  - Active shops (imported in last 30 days)
  - Plan distribution (how many on each plan)
  - Top error types across all shops
  - Revenue metrics (MRR, churn)
  - Trial conversion rate
  - Admin role protection
  - Polaris components
  - Unit tests
  - Integration tests
- **Dependencies**: PHASE-2-BILLING-004 (billing data)
- **Estimated Effort**: 2 days
- **Labels**: `phase-2`, `ui`, `frontend`, `analytics`, `admin`

### Month 6: Testing & Launch (Week 21-24)

#### PHASE-2-TESTING-002: Comprehensive E2E Testing (Playwright)
- **Description**: Full end-to-end testing with Playwright
- **Acceptance Criteria**:
  - Complete import flow test (upload → submit → complete)
  - Dry-run flow test
  - All import modes tested
  - All error scenarios tested
  - Multi-tenant isolation verified
  - Billing flow test (if using mock billing)
  - Analytics dashboard loads correctly
  - API endpoint tests
  - 50+ E2E tests, all passing
  - CI/CD runs E2E tests
- **Dependencies**: All Phase 2 features
- **Estimated Effort**: 3 days
- **Labels**: `phase-2`, `testing`, `qa`, `e2e`

#### PHASE-2-TESTING-003: Load Testing & Performance Benchmarking
- **Description**: Load test with large catalogs and concurrent imports
- **Acceptance Criteria**:
  - 10,000+ product import completes in <30 min
  - 50 concurrent users browsing dashboard (no timeout)
  - 100 concurrent imports (staggered, not simultaneous)
  - Measure Lambda cold starts, latency
  - Measure DynamoDB query times
  - Document bottlenecks and optimization opportunities
  - Use k6 or Artillery
  - Report with recommendations
- **Dependencies**: PHASE-2-PERF-001 (optimization)
- **Estimated Effort**: 2 days
- **Labels**: `phase-2`, `testing`, `performance`, `qa`

#### PHASE-2-SECURITY-001: Security Audit & Penetration Testing
- **Description**: Comprehensive security review
- **Acceptance Criteria**:
  - Dependency vulnerability scan (Snyk)
  - OWASP top 10 review (XSS, CSRF, SQL injection, etc.)
  - Access token encryption verified
  - IAM roles follow least privilege
  - Data isolation between tenants verified
  - No secrets in code/logs
  - Secure headers configured
  - Report with findings and fixes
  - All critical/high issues resolved
- **Dependencies**: All Phase 2 features
- **Estimated Effort**: 2 days
- **Labels**: `phase-2`, `security`, `qa`

#### PHASE-2-DOCS-002: Comprehensive API & User Documentation
- **Description**: Complete documentation for public release
- **Acceptance Criteria**:
  - API documentation (REST endpoints, GraphQL queries)
  - User guide (step-by-step import process)
  - Schema documentation (metafields, metaobjects)
  - FAQ and troubleshooting
  - Video tutorials (optional)
  - Screenshots and diagrams
  - Architecture diagrams
  - Deployment guide
  - Support contact information
  - Published to public site or wiki
- **Dependencies**: All Phase 2 features
- **Estimated Effort**: 2 days
- **Labels**: `phase-2`, `documentation`

#### PHASE-2-DEPLOY-002: Deploy to Production
- **Description**: Deploy Phase 2 to production environment
- **Acceptance Criteria**:
  - All infrastructure deployed via CDK
  - Database schema deployed
  - App Runner service deployed
  - Lambda functions deployed
  - Shopify app updated (new endpoints, billing)
  - SSL certificates configured
  - CloudWatch monitoring enabled
  - Alerts configured
  - Smoke tests passing
  - Zero critical errors in first 24h
  - Rollback plan documented
- **Dependencies**: All Phase 2 features
- **Estimated Effort**: 2 days
- **Labels**: `phase-2`, `deployment`, `devops`

#### PHASE-2-LAUNCH-001: Shopify App Store Submission
- **Description**: Prepare and submit app for public App Store
- **Acceptance Criteria**:
  - App Store listing page created
  - Screenshots captured (5-8 high-quality images)
  - Marketing copy written
  - Demo video recorded (2-3 min)
  - Privacy policy published
  - Terms of service published
  - Support contact/email configured
  - FAQ page on support site
  - Submission to Shopify App Review
  - Beta testing with 5-10 real merchants
  - Fix any issues found in review
  - App published to App Store
- **Dependencies**: All Phase 2 features
- **Estimated Effort**: 3 days
- **Labels**: `phase-2`, `marketing`, `launch`

#### PHASE-2-BETA-001: Beta Testing & Merchant Feedback
- **Description**: Coordinate beta testing with select merchants
- **Acceptance Criteria**:
  - Recruit 5-10 beta testers from target market
  - Provide beta access and support
  - Collect feedback via survey/interviews
  - Prioritize bugs and improvements
  - Fix critical bugs within 48 hours
  - Iterate based on feedback
  - Document learnings for Phase 3
  - Thank you communications to beta testers
- **Dependencies**: All Phase 2 features
- **Estimated Effort**: 2 days (coordination)
- **Labels**: `phase-2`, `testing`, `beta`, `feedback`

---

## Phase 3: Enterprise & Scale (Months 7-12, ~20 issues)

### Month 7-8: Team Collaboration

#### PHASE-3-COLLAB-001: Role-Based Access Control (RBAC)
- **Description**: Implement team roles: Admin, Editor, Viewer
- **Acceptance Criteria**:
  - Admin role: Full access to all features
  - Editor role: Can run imports, view analytics
  - Viewer role: Read-only access
  - Role assignment by shop owner
  - Middleware to enforce role checks
  - DynamoDB schema for roles
  - Unit tests
  - Integration tests
- **Estimated Effort**: 2 days
- **Labels**: `phase-3`, `backend`, `security`

#### PHASE-3-COLLAB-002: Activity Audit Log
- **Description**: Track who did what and when
- **Acceptance Criteria**:
  - Log import submissions
  - Log configuration changes
  - Log API key usage
  - Log plan changes
  - Audit log page (read-only)
  - Filter by action, date, user
  - Export audit log
  - DynamoDB storage
  - Polaris UI
  - Unit tests
- **Estimated Effort**: 2 days
- **Labels**: `phase-3`, `backend`, `frontend`, `audit`

#### PHASE-3-COLLAB-003: Team Notifications & Alerts
- **Description**: Email and in-app notifications for team members
- **Acceptance Criteria**:
  - Email notifications on job completion
  - Email on failed jobs
  - Email on usage limit reached
  - In-app notifications (banners)
  - Notification preferences per user
  - Unsubscribe functionality
  - Email templates
  - AWS SES integration
  - Unit tests
- **Estimated Effort**: 2 days
- **Labels**: `phase-3`, `backend`, `frontend`, `notifications`

### Month 8-9: Advanced Features

#### PHASE-3-SCHED-001: Job Scheduling
- **Description**: Schedule imports for future dates/times
- **Acceptance Criteria**:
  - Select date/time for scheduled import
  - One-time vs recurring (daily, weekly, monthly)
  - Calendar view of scheduled imports
  - Edit/cancel scheduled jobs
  - EventBridge rules for scheduling
  - Job submission on schedule
  - Timezone handling
  - Unit tests
  - Integration tests
- **Estimated Effort**: 2 days
- **Labels**: `phase-3`, `backend`, `frontend`, `scheduling`

#### PHASE-3-SCHED-002: Recurring Imports
- **Description**: Automate recurring imports (daily syncs, etc.)
- **Acceptance Criteria**:
  - Recurring import templates
  - Automatic job submission on schedule
  - Retry logic for failed recurring jobs
  - Pause/resume recurring imports
  - Usage tracking for recurring jobs
  - Notifications on recurring job failures
  - Unit tests
  - Integration tests
- **Estimated Effort**: 2 days
- **Labels**: `phase-3`, `backend`, `scheduling`

#### PHASE-3-ERROR-001: Advanced Error Handling & Retry Logic
- **Description**: Smart error recovery and retry strategies
- **Acceptance Criteria**:
  - Automatic retry for transient errors
  - Partial import resume (from last batch)
  - Smart error grouping with suggestions
  - Suggested fixes in error report
  - Manual retry with corrections
  - Dead letter queue monitoring
  - Sentry integration (error tracking)
  - Unit tests
- **Estimated Effort**: 2 days
- **Labels**: `phase-3`, `backend`, `error-handling`

### Month 9-10: Optimization & Internationalization

#### PHASE-3-PERF-002: Advanced Batch Optimization
- **Description**: Dynamic batch sizing based on product complexity
- **Acceptance Criteria**:
  - Measure product complexity (number of metafields)
  - Adjust batch size dynamically
  - Profile with various product types
  - Optimize for throughput vs memory
  - Load test with mixed product types
  - Document optimization strategy
  - Unit tests
- **Estimated Effort**: 2 days
- **Labels**: `phase-3`, `backend`, `performance`

#### PHASE-3-PERF-003: Parallel Processing for Large Imports
- **Description**: Process large imports using multiple Lambda instances
- **Acceptance Criteria**:
  - Split import into chunks
  - Launch parallel Lambda for each chunk
  - Coordinate progress across instances
  - Handle Shopify rate limits globally
  - Merge results
  - Cost analysis (parallel vs sequential)
  - Load test with 50k products
  - Unit tests
- **Estimated Effort**: 3 days
- **Labels**: `phase-3`, `backend`, `performance`

#### PHASE-3-I18N-001: Internationalization (Multi-language)
- **Description**: Support multiple languages
- **Acceptance Criteria**:
  - English (done)
  - Spanish, French, German (add 3 more)
  - Localized date/time formats
  - Currency formatting per region
  - Translation strings in JSON
  - i18n library integration (next-i18n, remix-i18n)
  - Locale selector in UI
  - Unit tests
- **Estimated Effort**: 2 days
- **Labels**: `phase-3`, `frontend`, `i18n`

#### PHASE-3-I18N-002: Regional Support (Compliance)
- **Description**: Regional pricing and compliance
- **Acceptance Criteria**:
  - Detect merchant region
  - Show pricing in local currency
  - GDPR compliance (EU)
  - CCPA compliance (California)
  - Data residency options
  - Legal terms per region
  - Unit tests
- **Estimated Effort**: 1 day
- **Labels**: `phase-3`, `backend`, `compliance`

### Month 10-11: Integration Ecosystem

#### PHASE-3-INTEG-001: Zapier Integration
- **Description**: Connect Inavor Shuttle to Zapier
- **Acceptance Criteria**:
  - Zapier app created
  - Triggers: job completed, failed, limit reached
  - Actions: submit import, cancel job
  - Authentication with API key
  - Comprehensive documentation
  - Test with sample Zaps
- **Estimated Effort**: 2 days
- **Labels**: `phase-3`, `integration`, `backend`

#### PHASE-3-INTEG-002: Webhook Subscriptions
- **Description**: Allow external systems to subscribe to events
- **Acceptance Criteria**:
  - Job completion webhooks
  - Job failure webhooks
  - Custom webhook URLs per shop
  - Retry logic for failed webhooks
  - Signature verification
  - Webhook log/history
  - Unit tests
- **Estimated Effort**: 2 days
- **Labels**: `phase-3`, `backend`, `webhooks`

#### PHASE-3-INTEG-003: External Data Source Integration
- **Description**: Pull import data from external sources
- **Acceptance Criteria**:
  - Google Sheets integration (read CSV)
  - Airtable integration (read base)
  - CSV upload (enhanced)
  - API endpoint integration
  - OAuth for external services
  - Sync on schedule
  - Error handling
  - Unit tests
- **Estimated Effort**: 3 days
- **Labels**: `phase-3`, `backend`, `integration`

### Month 11-12: Optimization & Maintenance

#### PHASE-3-PERF-004: Cost Optimization
- **Description**: Reduce AWS costs without sacrificing performance
- **Acceptance Criteria**:
  - Analyze actual usage patterns
  - Optimize Lambda memory allocation
  - Review S3 lifecycle policies
  - Evaluate on-demand vs provisioned DynamoDB
  - Cost-saving recommendations
  - Implement 2-3 optimizations
  - Document cost savings
- **Estimated Effort**: 2 days
- **Labels**: `phase-3`, `backend`, `cost-optimization`

#### PHASE-3-MAINT-001: Customer Feedback Implementation
- **Description**: Implement top requested features from merchants
- **Acceptance Criteria**:
  - Collect feedback via survey
  - Prioritize by request frequency
  - Implement top 3-5 features
  - Communicate updates to customers
  - Release notes
  - Unit tests
- **Estimated Effort**: 3 days
- **Labels**: `phase-3`, `backend`, `frontend`, `feedback`

#### PHASE-3-MAINT-002: Continuous Monitoring & Optimization
- **Description**: Ongoing monitoring and improvement
- **Acceptance Criteria**:
  - Monthly performance reviews
  - Quarterly security audits
  - Usage analytics reporting
  - Error pattern analysis
  - Churn analysis
  - Competitive analysis
  - Roadmap updates
- **Estimated Effort**: Ongoing
- **Labels**: `phase-3`, `maintenance`, `monitoring`

---

## How to Use This Template

1. **After Phase 1 Completion**: Use these templates to create Phase 2 issues
2. **Adapt as Needed**: Modify acceptance criteria based on actual Phase 1 learnings
3. **Follow Same Format**: Use same Bash/gh CLI approach as Phase 1
4. **Link Dependencies**: Reference Phase 1 issues in Phase 2 dependencies
5. **Gather Feedback**: Incorporate merchant and team feedback before Phase 3

---

## Creating Phase 2/3 Issues

When ready, create issues using:

```bash
gh issue create \
  --title "PHASE-X-COMPONENT-SEQ: Title" \
  --body "Description and acceptance criteria" \
  --label "phase-x,component-label" \
  --milestone "Phase X Name"
```

Same approach as Phase 1, just use Phase 2 and Phase 3 templates above.

---

**Status**: Template ready for Phase 2 & 3 issue creation
**Total Phase 2 Issues**: ~25
**Total Phase 3 Issues**: ~20
**Total Project Issues**: ~85 across 3 phases
