# Review Yesterday's Work and Update Worklog

You are closing out yesterday's workday and need to:

1. **Get yesterday's date** - Use the environment to determine yesterday's date (e.g., if today is 2025-11-11, yesterday is 2025-11-10)
2. **Review git changes from yesterday** - Run `git log --oneline --since="YYYY-MM-DD 00:00:00" --until="YYYY-MM-DD 23:59:59"` to see all commits made yesterday
3. **Summarize accomplishments** - Based on the commits, create a summary of what was accomplished yesterday
4. **Find or create worklog file** - Look for `/docs/worklogs/YYYY-MM-DD-*.md` matching yesterday's date. If it doesn't exist, create it with yesterday's date
5. **Update worklog** - Add the accomplishments summary to the worklog file (or create new content if the file doesn't exist)
6. **Commit changes** - Commit the updated worklog file with message `docs: Update worklog for [YESTERDAY'S DATE]`

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
- Tell the user what was accomplished yesterday
- Show the worklog file path
- Show the commit that was made
