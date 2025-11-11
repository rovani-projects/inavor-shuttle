---
argument-hint: [issue-number]
---

# Start Working on Next GitHub Issue

Begin implementation of a GitHub issue by setting up branch, updating issue metadata, creating an implementation plan, and guiding through the complete workflow.

## Parameters
- `$1` (optional): Specific issue number to start (e.g., `15` for issue #15). If not provided, automatically find the next open issue in Phase 1 (#2-#41).

## Workflow

### Step 1: Determine Target Issue
- If `$1` is provided: Validate that issue #$1 exists and is open using `gh issue view $1`
- If `$1` is NOT provided: Run `gh issue list --label phase-1 --state open --limit 50` and select the issue with the lowest number (first in sequence)
- Extract from issue: title, labels, current milestone

### Step 2: Parse Issue Identifier
- Extract the pattern from the issue title (e.g., "PHASE-1-INFRA-001" or "PHASE-1-SCHEMA-004")
- If pattern is missing, construct it from issue number and title
- This identifier will be used for the branch name

### Step 3: Create and Checkout Feature Branch
- Branch name format: `feature/{ISSUE_IDENTIFIER}` (e.g., `feature/PHASE-1-INFRA-001`)
- Run: `git checkout -b feature/{ISSUE_IDENTIFIER}`
- Confirm successful branch creation

### Step 4: Update GitHub Issue
- Run `gh issue edit {ISSUE_NUMBER}` to:
  - Add/update type label: `bug`, `feature`, or `task` (infer from issue title/description)
  - Ensure milestone is set appropriately (Phase 1, Phase 2, etc.)
  - Assign to user: `@drovani`
- Leave a comment on the issue: "Starting implementation on branch feature/{ISSUE_IDENTIFIER}"

### Step 5: Create Implementation Plan
- Create file at: `/docs/plans/ISSUE-#{ISSUE_NUMBER}-{slug}.md`
  - Example: `/docs/plans/ISSUE-#15-lambda-job-processor.md`
  - Use the issue title to create the slug (lowercase, hyphens)

- Plan template content (customize based on issue):
```markdown
# Implementation Plan: Issue #{ISSUE_NUMBER}

{ISSUE_TITLE}

**Branch**: feature/{ISSUE_IDENTIFIER}
**Created**: {TODAY_DATE}

---

## Issue Summary

{Insert brief summary from issue description}

---

## Acceptance Criteria

{Extract from issue and format as checklist}
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

---

## Technical Approach

{Analyze the issue requirements and describe:}
- Key components/files to modify or create
- External dependencies needed
- Database schema changes (if any)
- API endpoints/GraphQL operations
- Third-party service integrations
- Security considerations

---

## Implementation Steps

{Break down the work into concrete steps, e.g.:}
1. Step description
2. Step description
3. Step description

---

## Testing Strategy

- Unit tests: [describe what to test]
- Integration tests: [describe what to test]
- Manual testing: [describe steps to verify]

---

## Files to Create/Modify

- [ ] `path/to/file.ts` - Description
- [ ] `path/to/file.test.ts` - Tests
- [ ] `path/to/component.tsx` - UI changes

---

## Notes & Considerations

- Important architectural decisions
- Performance considerations
- Security implications
- Known limitations or future improvements

---

## Definition of Done

✅ All acceptance criteria met
✅ Unit tests written and passing
✅ TypeScript strict mode passing (`npm run typecheck`)
✅ Code follows project conventions
✅ Incremental commits with clear messages
✅ Implementation plan deleted before PR
```

### Step 6: Commit the Plan
- Run: `git add docs/plans/ISSUE-#{ISSUE_NUMBER}-{slug}.md`
- Run: `git commit -m "docs: Add implementation plan for #{ISSUE_NUMBER}"`
- Run: `git push -u origin feature/{ISSUE_IDENTIFIER}`

### Step 7: Link Branch to GitHub Issue
- Run: `gh issue develop {ISSUE_NUMBER} --checkout` (or manually link via GitHub UI if command unavailable)
- Show the user the branch has been created and pushed

### Step 8: Start Implementation Phase
- Create TodoWrite items from the Acceptance Criteria section of the plan
- For each acceptance criterion, add a corresponding todo
- Initial task should be marked as `in_progress`
- Guide the user through implementation:
  - Explain what needs to be done
  - Create todos for major work items
  - After each significant change, make a commit with conventional commit messages:
    - `feat: Add feature description`
    - `fix: Fix bug description`
    - `test: Add tests for feature`
    - `refactor: Refactor component`
    - `docs: Update documentation`

### Step 9: During Implementation
- Run `npm run typecheck` after making changes
- Run tests as appropriate: `npm run test` or `npm run test:watch`
- Update TodoWrite status as tasks are completed
- Keep commits incremental and focused
- Reference issue number in commit messages when relevant: `feat: Add job processor (related to #15)`

### Step 10: Finalization (When Implementation Complete)
- Mark all todos as completed
- Delete the implementation plan: `rm /docs/plans/ISSUE-#{ISSUE_NUMBER}-{slug}.md`
- Run final checks:
  - `npm run typecheck` - Ensure no type errors
  - `npm run lint` - Ensure code style
  - `npm run test` - Ensure tests pass (if applicable)
- Commit the plan deletion: `chore: Remove implementation plan for #{ISSUE_NUMBER}`
- Push all commits: `git push origin feature/{ISSUE_IDENTIFIER}`

### Step 11: Create Pull Request
- Run: `gh pr create --title "{ISSUE_TITLE}" --body "$(cat <<'EOF'\nCloses #{ISSUE_NUMBER}\n\n## Summary\n\n{Brief description of changes made}\n\n## What Changed\n- Implementation of {feature/fix}\n- Added/Updated {component}\n- Tests for {feature}\n\n## Testing\n- [x] Unit tests passing\n- [x] TypeScript strict mode passing\n- [x] Manual testing completed\n\n## Review Notes\n- Key implementation details\n- Architectural decisions\n- Performance considerations (if applicable)\n\nEOF\n)"`
- Link the PR to the issue automatically (via "Closes #XX" text)
- Show the user the PR URL
- Leave PR open for review (do not merge)

## Summary for User
After all steps complete:
- Show branch name created
- Show issue #XX is assigned and ready
- Show path to implementation plan
- Confirm branch is pushed
- Ready for implementation with clear next steps
