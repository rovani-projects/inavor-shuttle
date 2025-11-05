# GitHub Issues Creation - Restart Guide

If you need to restart the GitHub issues creation process at any point, use this guide.

---

## Current Status (as of 2025-01-15)

✅ **Phase 1**: COMPLETE
- 40 issues created (#2-#41)
- All documentation written
- Ready for development

📋 **Phase 2 & 3**: READY FOR CREATION
- Templates written
- Documentation prepared
- Waiting for Phase 1 completion before creation

---

## Restarting Different Phases

### Restarting Phase 1 Issue Creation

**If**: Phase 1 issues need to be recreated

1. **Delete existing issues** (if needed):
   ```bash
   # Warning: This will delete all Phase 1 issues
   # Use GitHub UI to close/delete issues #2-#41
   ```

2. **Use the breakdown document**:
   ```bash
   cat docs/github-issues-breakdown.md
   ```

3. **Create issues in batches**:
   ```bash
   # Use Task tool with general-purpose subagent
   # Reference the section "Creating Phase 2/3 Issues" in breakdown
   ```

4. **Track created issues**:
   ```bash
   # Document issue numbers returned
   # Update phase-1-issues-summary.md with actual URLs
   ```

---

### Creating Phase 2 Issues

**When**: After Phase 1 is complete (40 issues closed)

1. **Review Phase 2 template**:
   ```bash
   cat docs/phase-2-3-issues-template.md | head -800
   ```

2. **Create Phase 2 issues**:
   ```bash
   # Use same process as Phase 1
   # Launch Task agent with general-purpose subagent
   # Create ~25 issues for Phase 2
   ```

3. **Create Phase 2 summary**:
   ```bash
   # Copy phase-1-issues-summary.md format
   # Replace Phase-1 with Phase-2 throughout
   # Update GitHub issue URLs
   ```

4. **Commit changes**:
   ```bash
   git add docs/
   git commit -m "feat: Create Phase 2 GitHub issues (~25 issues)"
   ```

---

### Creating Phase 3 Issues

**When**: After Phase 2 is complete (~50 issues total closed)

1. **Review Phase 3 template**:
   ```bash
   cat docs/phase-2-3-issues-template.md | tail -1000
   ```

2. **Create Phase 3 issues**:
   ```bash
   # Use same process as Phase 1 & 2
   # Create ~20 issues for Phase 3
   ```

3. **Create Phase 3 summary**:
   ```bash
   # Similar to Phase 2
   # Update documentation
   ```

4. **Commit changes**:
   ```bash
   git add docs/
   git commit -m "feat: Create Phase 3 GitHub issues (~20 issues)"
   ```

---

## File Recovery

All documentation is version-controlled. To recover:

```bash
# Check git history
git log --oneline docs/

# View any previous version
git show COMMIT_HASH:docs/filename.md

# Restore deleted file
git checkout COMMIT_HASH -- docs/filename.md
```

---

## Updating Existing Issues

If you need to update issue descriptions or add more details:

```bash
# Use GitHub web interface
# Or use gh CLI
gh issue edit 42 --body "New body content"
gh issue edit 42 --add-label "new-label"
```

---

## Reordering Dependencies

If dependencies change (e.g., issue #X now depends on #Y instead of #Z):

1. **Update the breakdown document**:
   ```bash
   vim docs/github-issues-breakdown.md
   # Update the dependency section
   ```

2. **Update issue on GitHub**:
   ```bash
   gh issue edit #ISSUE_NUMBER --body "Updated with new dependencies"
   ```

3. **Commit the change**:
   ```bash
   git add docs/
   git commit -m "docs: Update dependencies for issue #X"
   ```

---

## Restarting Development

If development starts and issues need adjustment:

1. **Create new issues for discovered tasks**:
   ```bash
   gh issue create --title "PHASE-1-X-XXX: New task" --body "..."
   ```

2. **Update related issues**:
   - Add links to new issues
   - Adjust acceptance criteria if needed
   - Update dependencies

3. **Document changes**:
   ```bash
   # Update phase-1-issues-summary.md
   # Add notes about changes
   ```

4. **Communicate**:
   - Update project board
   - Post in team discussions
   - Document rationale

---

## Backup & Restore

All documentation is in `/docs/`. To backup:

```bash
# Already backed up in git
git push origin main

# Or manual backup
cp -r docs/ ~/inavor-shuttle-docs-backup/
```

To restore from backup:

```bash
git reset --hard COMMIT_HASH
# Or
cp -r ~/inavor-shuttle-docs-backup/ docs/
git add docs/
git commit -m "Restore documentation from backup"
```

---

## Key Files to Maintain

**Critical files** (don't delete):
- `/docs/comprehensive-implementation-plan.md` (original spec)
- `/docs/github-issues-breakdown.md` (master breakdown)
- `/docs/ISSUES-INDEX.md` (navigation)

**Auto-generated/updatable files**:
- `/docs/phase-1-issues-summary.md` (update with actual GitHub links)
- `/docs/phase-2-3-issues-template.md` (template, copy to create Phases 2-3)
- `/docs/COMPLETION-SUMMARY.md` (update after Phase 1 complete)

---

## Resuming Mid-Task

If you need to stop and resume creating issues:

1. **Check where you stopped**:
   ```bash
   # Last commit message shows what was done
   git log --oneline -5
   ```

2. **See what issues exist**:
   ```bash
   gh issue list --limit 50 | grep "PHASE-1"
   ```

3. **Continue from next issue**:
   ```bash
   # From github-issues-breakdown.md, find next uncreated issue
   # Create it using gh CLI or Task agent
   ```

4. **Track progress**:
   ```bash
   # Update ISSUES-INDEX.md or create a progress file
   echo "Created issues #2-#15, next is #16" > .issue-progress
   ```

---

## Common Issues & Fixes

### Issue: Can't create issues (authentication error)

**Solution**:
```bash
gh auth login
# Follow prompts to authenticate
```

### Issue: Issue #X was created but with wrong title/content

**Solution**:
```bash
gh issue edit #X --title "New Title"
gh issue edit #X --body "New body content"
```

### Issue: Need to close/reopen an issue

**Solution**:
```bash
gh issue close #X
gh issue reopen #X
```

### Issue: Dependencies changed, need to update links

**Solution**:
```bash
# Update issue body with new dependency links
gh issue edit #X --body "Updated description with new dependencies: (#Y, #Z)"
```

---

## Quick Commands Reference

```bash
# List all Phase 1 issues
gh issue list --label "phase-1" --limit 100

# List all issues created by you
gh issue list --created-by @me

# View specific issue
gh issue view #42

# Edit issue
gh issue edit #42 --title "New Title"
gh issue edit #42 --add-label "new-label"

# Close issue
gh issue close #42

# Reopen issue
gh issue reopen #42

# Create issue (single)
gh issue create --title "Title" --body "Body" --label "label"

# Create milestone
gh api repos/rovani-projects/inavor-shuttle/milestones -f title="Phase 1 MVP"
```

---

## Documentation Structure

```
docs/
├── comprehensive-implementation-plan.md   (2,360 lines)
│   └─ Original full spec
├── github-issues-breakdown.md             (1,500 lines)
│   └─ Master breakdown of all 85+ issues
├── phase-1-issues-summary.md              (600 lines)
│   └─ Quick reference with GitHub links
├── phase-2-3-issues-template.md           (800 lines)
│   └─ Templates for future phases
├── ISSUES-INDEX.md                        (550 lines)
│   └─ Navigation and project tracking
├── COMPLETION-SUMMARY.md                  (500 lines)
│   └─ What was created and how to use
└── RESTART-GUIDE.md                       (this file)
    └─ How to restart or resume
```

---

## Progress Tracking

### Phase 1
- ✅ Issues created: #2-#41 (40 total)
- ✅ Documentation complete
- ⏳ Development: Waiting to start
- ⏳ Testing: After development
- ⏳ Deployment: After testing

### Phase 2
- 📋 Issues: Templates written
- ⏳ Creation: After Phase 1 complete
- ⏳ Development: Weeks 13-24
- ⏳ Testing: Week 25
- ⏳ Launch: Week 26

### Phase 3
- 📋 Issues: Templates written
- ⏳ Creation: After Phase 2 complete
- ⏳ Development: Weeks 27-48
- ⏳ Scaling: After launch

---

## Next Actions

**To resume from current state**:

1. ✅ All documentation created and committed
2. ✅ All Phase 1 issues created in GitHub
3. 👉 Review: `/docs/phase-1-issues-summary.md`
4. 👉 Start: Assign Week 1-2 issues (#2-#8)
5. 👉 Develop: Begin implementation

**To create Phase 2 (after Phase 1 complete)**:

1. Verify Phase 1: All 40 issues closed
2. Review: `/docs/phase-2-3-issues-template.md` (first 800 lines)
3. Create: ~25 Phase 2 issues using same process
4. Write: Phase 2 summary document
5. Commit: `git commit -m "feat: Create Phase 2 issues"`

---

**Last Updated**: 2025-01-15
**Status**: Phase 1 Complete, Ready for Development
**Next Phase**: Phase 2 Creation (when Phase 1 complete)

Safe to close and restart anytime. All state is in version control.
