# Review Daily Work and Update Worklog

You are closing out the workday and need to:

1. **Get today's date** - Use the environment to determine today's date (e.g., 2025-11-10)
2. **Review git changes since midnight** - Run `git log --oneline --since="YYYY-MM-DD 00:00:00"` to see all commits made today, and `git diff` to see uncommitted changes
3. **Summarize accomplishments** - Based on the commits and changes, create a summary of what was accomplished today
4. **Find or create worklog file** - Look for `/docs/worklogs/YYYY-MM-DD-*.md` matching today's date. If it doesn't exist, create it with today's date
5. **Update worklog** - Add the accomplishments summary to the worklog file (or create new content if the file doesn't exist)
6. **Commit changes** - Commit the updated worklog file with message `docs: Update worklog for [DATE]`

## Format for new worklogs (if needed):
```markdown
# [Descriptive Title] - Work Log

**Date**: YYYY-MM-DD
**Branch**: [current git branch]
**Status**: IN PROGRESS / COMPLETE

---

## What Was Accomplished

[Bullet points or sections describing work done]

### Key Changes
- List major code changes
- Note new features
- Document bug fixes

### Issues Addressed
- Link to any GitHub issues #123

### Technical Decisions
- Document any architectural decisions made

---

## Next Steps

- What should be done next
- Any blockers to note

---

**Last Updated**: YYYY-MM-DD HH:MM
```

After reviewing and updating the worklog:
- Tell the user what was accomplished
- Show the worklog file path
- Show the commit that was made
