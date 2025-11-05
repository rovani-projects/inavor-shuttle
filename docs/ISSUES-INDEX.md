# Inavor Shuttle - GitHub Issues Index

Complete index and guide for all GitHub issues across all project phases.

---

## Quick Navigation

### Phase 1: MVP (COMPLETE - 40 Issues Created)
- **Status**: ✅ All 40 issues created and ready
- **Location**: `/docs/phase-1-issues-summary.md`
- **View on GitHub**: https://github.com/rovani-projects/inavor-shuttle/issues?q=is%3Aopen+label%3Aphase-1
- **Issue Range**: #2 - #41
- **Duration**: Weeks 1-12 (3 months)
- **Effort**: ~69 person-days

### Phase 2: Enhancement & Launch (TEMPLATE READY)
- **Status**: 📋 Template created, issues not yet generated
- **Location**: `/docs/phase-2-3-issues-template.md` (Section 1)
- **When to Create**: After Phase 1 completion
- **Estimated Issues**: ~25
- **Duration**: Weeks 13-24 (3 months)
- **Effort**: ~50 person-days

### Phase 3: Enterprise & Scale (TEMPLATE READY)
- **Status**: 📋 Template created, issues not yet generated
- **Location**: `/docs/phase-2-3-issues-template.md` (Section 2)
- **When to Create**: After Phase 2 completion
- **Estimated Issues**: ~20
- **Duration**: Weeks 25-48 (6 months)
- **Effort**: ~40 person-days

---

## Documentation Files

### Core Implementation Planning
- **`/docs/comprehensive-implementation-plan.md`** (2,360 lines)
  - Complete project specification
  - Architecture design
  - Database schema
  - Technology stack
  - Deployment strategy
  - Security & compliance
  - Risk management

### Issue Management
- **`/docs/github-issues-breakdown.md`** (Master breakdown)
  - Detailed issue specifications
  - Dependencies graph
  - Priority ordering
  - Batch creation guide
  - All 85+ issue templates

- **`/docs/phase-1-issues-summary.md`** (Quick reference)
  - All 40 Phase 1 issues with GitHub links
  - Timeline and dependencies
  - Success criteria
  - Development workflow
  - Labels reference

- **`/docs/phase-2-3-issues-template.md`** (Future phases)
  - Phase 2 templates (~25 issues)
  - Phase 3 templates (~20 issues)
  - Usage instructions

---

## Phase 1 Issues Overview

### Week 1-2: Infrastructure & Authentication (7 issues)

**Issues**: #2-#8

| # | Issue | Effort | Dependencies |
|---|-------|--------|---|
| #2 | AWS Account & CDK Project Setup | 1 day | None |
| #3 | DynamoDB Table Creation | 2 days | #2 |
| #4 | S3 Bucket Setup | 1 day | #2 |
| #5 | SQS Queue Setup | 1 day | #2 |
| #6 | Shopify OAuth Implementation | 2 days | #3 |
| #7 | Embedded App Authentication | 1 day | #6 |
| #8 | Install/Uninstall Webhooks | 2 days | #3 |

**Can Start**: Week 1, Day 1

---

### Week 3-4: Schema & Validation (6 issues)

**Issues**: #9-#14

| # | Issue | Effort | Dependencies |
|---|-------|--------|---|
| #9 | JSON Schema Definition | 2 days | None |
| #10 | Schema Validation Engine | 2 days | #9 |
| #11 | File Upload Component | 1 day | None |
| #12 | Metafield Introspection | 2 days | #6 |
| #13 | Metafield Validation Engine | 3 days | #12 |
| #14 | Schema Documentation Page | 2 days | #9 |

**Can Start**: Week 3, after authentication complete

---

### Week 5-6: Job Processing (8 issues)

**Issues**: #15-#22

| # | Issue | Effort | Dependencies |
|---|-------|--------|---|
| #15 | Lambda Job Processor | 1 day | #5 |
| #16 | Job Data Model | 1 day | #3 |
| #17 | File Upload & S3 | 2 days | #4 |
| #18 | Job Submission | 2 days | #16, #10 |
| #19 | Job Processor Validation | 2 days | #15, #10, #13 |
| #20 | Shopify GraphQL Client | 2 days | #6 |
| #21 | Product Creation (Batch) | 3 days | #19, #20 |
| #22 | Job Status API | 1 day | #16 |

**Can Start**: Week 5, after schema and auth

---

### Week 7-8: UI & Job Management (7 issues)

**Issues**: #23-#29

| # | Issue | Effort | Dependencies |
|---|-------|--------|---|
| #23 | Dashboard Layout | 1 day | None |
| #24 | Import Upload Page | 2 days | #11, #17 |
| #25 | Job List Page | 2 days | #22 |
| #26 | Job Detail Page | 2 days | #22 |
| #27 | Dry-Run Processor | 2 days | #19, #13 |
| #28 | Dry-Run Results UI | 2 days | #27 |
| #29 | Shop Config Page | 1 day | #16 |

**Can Start**: Week 7, after job processing

---

### Week 9-10: Import Modes (4 issues)

**Issues**: #30-#33

| # | Issue | Effort | Dependencies |
|---|-------|--------|---|
| #30 | Import Modes | 3 days | #20, #21 |
| #31 | Mode Selection UI | 2 days | #24, #30 |
| #32 | Job Cancellation | 1 day | #26, #16 |
| #33 | Download Logs & Reports | 1 day | #22, #26 |

**Can Start**: Week 9, after UI foundation

---

### Week 11-12: Billing & Analytics (8 issues)

**Issues**: #34-#41

| # | Issue | Effort | Dependencies |
|---|-------|--------|---|
| #34 | Plan Definitions | 1 day | None |
| #35 | Usage Tracking | 2 days | #3, #34 |
| #36 | Limit Enforcement | 1 day | #35, #18 |
| #37 | Analytics Dashboard | 2 days | #35 |
| #38 | CloudWatch Monitoring | 2 days | #2, #15 |
| #39 | Test Suite | 2 days | All Phase 1 |
| #40 | Documentation | 2 days | All Phase 1 |
| #41 | Staging Deployment | 2 days | All Phase 1 |

**Can Start**: Week 11, after all core features

---

## Project Statistics

### Total Scope

| Phase | Issues | Effort | Duration | Start Week |
|-------|--------|--------|----------|-----------|
| Phase 1 (MVP) | 40 | 69 days | 12 weeks | 1 |
| Phase 2 (Launch) | ~25 | 50 days | 12 weeks | 13 |
| Phase 3 (Scale) | ~20 | 40 days | 12 weeks | 25 |
| **Total** | **~85** | **~159 days** | **36 weeks** | - |

### Effort Distribution

```
Phase 1 Breakdown:
├── Infrastructure & Auth: 10 days (14%)
├── Schema & Validation: 12 days (17%)
├── Job Processing: 14 days (20%)
├── UI & Management: 12 days (17%)
├── Import Modes: 7 days (10%)
└── Billing & Analytics: 14 days (20%)
```

### Labels Used

**Phase Labels**:
- `phase-1`, `phase-2`, `phase-3`

**Component Labels**:
- `infrastructure`, `database`, `storage`, `messaging`
- `auth`, `security`, `webhooks`
- `backend`, `frontend`, `ui`, `api`
- `schema`, `validation`, `shopify-api`
- `lambda`, `job-processing`, `queue`
- `billing`, `analytics`, `admin`
- `monitoring`, `testing`, `qa`, `e2e`, `performance`
- `deployment`, `devops`, `ci-cd`
- `documentation`, `marketing`, `launch`, `feedback`
- `scheduling`, `i18n`, `integration`, `error-handling`
- `cost-optimization`, `maintenance`, `audit`, `notifications`

---

## Development Workflow

### Starting a New Task

1. **Choose an Issue**
   - Pick from the appropriate week based on dependencies
   - Ensure all dependencies are completed
   - Comment on issue to claim it

2. **Create Feature Branch**
   ```bash
   git checkout -b feature/PHASE-X-COMPONENT-SEQ
   # e.g., feature/PHASE-1-INFRA-001
   ```

3. **Develop & Test**
   - Follow acceptance criteria from issue
   - Write tests (unit + integration)
   - Commit with descriptive messages

4. **Create Pull Request**
   ```bash
   git push origin feature/PHASE-X-COMPONENT-SEQ
   # Then create PR on GitHub
   ```

5. **Link PR to Issue**
   - Use "Closes #XX" in PR description
   - Reference any related issues

6. **Review & Merge**
   - Resolve review comments
   - Ensure CI passes
   - Merge to main

7. **Close Issue**
   - Issue closes automatically when PR merges
   - Or manually close if work complete

---

## Dependency Graph (Simplified)

```
Phase 1 Critical Path:

Week 1: #2 (AWS Setup)
        ├─ #3 (DynamoDB)
        │  └─ #6 (OAuth)
        │     ├─ #7 (Embedded Auth)
        │     └─ #8 (Webhooks)
        ├─ #4 (S3)
        │  └─ #17 (File Upload)
        └─ #5 (SQS)
           └─ #15 (Lambda Skeleton)

Week 3: #9 (JSON Schema)
        ├─ #10 (Validation)
        │  └─ #18 (Job Submission)
        └─ #13 (Metafield Validation)
           └─ #19 (Processor Validation)

Week 5: #20 (Shopify Client)
        └─ #21 (Product Creation)
           └─ #30 (Import Modes)

Week 7: #23 (Dashboard)
        └─ #24 (Upload Page)
           └─ #31 (Mode Selection UI)

Week 9: #32-33 (Cancellation, Logs)

Week 11: #34-41 (Billing, Analytics, Testing, Deployment)
```

---

## When to Create Phase 2 Issues

**Prerequisites for Phase 2 Kickoff**:

1. ✅ All 40 Phase 1 issues closed
2. ✅ Zero open bugs from Phase 1
3. ✅ Staging deployment successful with 5+ test stores
4. ✅ All Phase 1 documentation complete
5. ✅ Code review and approval of all Phase 1 PRs
6. ✅ Performance baseline established

**Then**:

```bash
# Use template from docs/phase-2-3-issues-template.md
# Create issues in batches as you did for Phase 1
# Update issue milestone to "Phase 2 Launch"
# Set issue range to follow Phase 1 sequence
```

---

## GitHub Issue Best Practices

### Writing Issues
- ✅ Clear, descriptive title
- ✅ Detailed description
- ✅ Specific acceptance criteria (checkboxes)
- ✅ Dependencies and related issues linked
- ✅ Estimated effort
- ✅ Relevant labels
- ✅ Assigned milestone

### Working on Issues
- ✅ Self-assign when starting
- ✅ Create feature branch from main
- ✅ Commit frequently with clear messages
- ✅ Create PR early (draft if not ready)
- ✅ Link PR to issue (Closes #XX)
- ✅ Request review when ready
- ✅ Respond to review comments promptly

### Closing Issues
- ✅ All acceptance criteria met
- ✅ Tests passing (unit + integration)
- ✅ Code reviewed and approved
- ✅ PR merged to main
- ✅ Issue closes automatically

---

## Tracking Progress

### Milestones View
- Visit: https://github.com/rovani-projects/inavor-shuttle/milestones
- See % complete for each phase
- Identify bottlenecks

### Project Board (Optional)
- Create board: "Inavor Shuttle Development"
- Columns: Backlog, In Progress, In Review, Done
- Drag issues across as they progress

### Labels View
- Filter by `phase-1` to see all Phase 1 work
- Filter by component (e.g., `backend`) to see related issues
- Combine filters for deeper analysis

---

## Support & Questions

### Issue Questions
- Ask in issue comments
- Tag relevant team members
- Link to related documentation

### Architecture Questions
- Refer to `/docs/comprehensive-implementation-plan.md`
- Check issue description for technical notes
- Review dependency chain for context

### Process Questions
- Check this file (ISSUES-INDEX.md)
- See Development Workflow section
- Ask in project discussions

---

## Key Documents Reference

| Document | Purpose | When to Use |
|----------|---------|------------|
| comprehensive-implementation-plan.md | Full project spec | Architecture decisions, understanding why |
| github-issues-breakdown.md | Detailed issue specs | Writing PRs, understanding full scope |
| phase-1-issues-summary.md | Quick Phase 1 ref | Daily work, seeing issue URLs |
| phase-2-3-issues-template.md | Future phases | Creating Phase 2/3 issues |
| ISSUES-INDEX.md | This file | Navigation, status, workflow |

---

## Summary

**Phase 1 Status**: ✅ Complete (40 issues created, #2-#41)

**Next Steps**:
1. Start assigning Week 1-2 infrastructure issues
2. Begin development work
3. Report progress weekly
4. After Phase 1 completion, create Phase 2 issues from template

**Total Project Timeline**: ~36 weeks (9 months) for all 3 phases

**Questions?** Check the documentation files or GitHub issue comments.

---

**Last Updated**: 2025-01-15
**Document Version**: 1.0
**Status**: Phase 1 Complete, Phases 2-3 Ready for Template Expansion
