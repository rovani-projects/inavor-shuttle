---
argument-hint: {pr-number}
---

# Squash Merge Pull Request

Squash merge a PR to its target branch with a detailed commit message, then close it. This command takes a PR number and performs a squash merge with a comprehensive commit message for future developers.

## Parameters
- `$1` (required): PR number (e.g., `15` for PR #15)

## Workflow

### Step 1: Validate PR Exists
- Run: `gh pr view $1 --json number,title,body,baseRefName,headRefName,state,commits`
- Extract: PR number, title, description, target branch, source branch, state, commit count
- Verify PR state is OPEN (cannot merge if already merged or closed)
- If PR doesn't exist, show error and exit

### Step 2: Fetch PR and Commit Details
- Display PR information:
  - PR title and number
  - Target branch (base)
  - Source branch (head)
  - Number of commits being squashed
  - PR description (first 200 characters)

### Step 3: Build Detailed Commit Message
- Create a comprehensive commit message from:
  - **First line**: PR title (e.g., "feat: Add job processing queue")
  - **Blank line**
  - **Body**: PR description (cleaned up, first few lines or summary)
  - **Blank line**
  - **Footer**: List all issues closed by PR (if any, extracted from PR body)
  - **Footer**: Add "Squash merged PR #{number}" with link
  - **Footer**: List all contributor commits being squashed

Example format:
```
feat: Add job processing queue

Implement async job queue using SQS FIFO for reliable product imports.
Supports multiple job types and progress tracking.

Closes #15, #16
Squash merged PR #23
Squashed commits from: author1, author2, author3
```

### Step 4: Perform Squash Merge with Custom Message
- Run: `gh pr merge $1 --squash --body "$(cat <<'EOF'\n{DETAILED_MESSAGE}\nEOF\n)"`
- If `--body` flag doesn't work, use interactive merge:
  - `gh pr merge $1 --squash` (will prompt for commit message)
  - Paste the detailed commit message when prompted
- Verify merge succeeded

### Step 5: Verify Merge Success
- Confirm the PR was successfully merged
- Show output indicating:
  - PR is now closed
  - Source branch deleted
  - Target branch updated with squash commit
- Verify the merge commit exists with the detailed message

### Step 6: Local Repository Cleanup
After successful merge, clean up the local repository:
- Checkout the target branch: `git checkout {baseRefName}`
- Pull the latest changes: `git pull origin {baseRefName}`
- Delete the local source branch: `git branch -D {headRefName}`
- Confirm all steps completed successfully

This ensures the local repository is in sync with the remote and removes stale branches.

### Step 7: Provide Summary to User
Display:
- ✅ PR #{number} successfully merged
- **Title**: {PR title}
- **Target Branch**: {base branch name} (now checked out locally with latest changes)
- **Source Branch**: {head branch name} (deleted from GitHub and locally)
- **Commits Squashed**: {count} commits
- **Merge Commit Message**: (show the full message that was created)
- **Local Repository**: On {base branch name}, synced with remote
- Ready for next tasks

## Error Handling
- If PR doesn't exist: "Error: PR #{number} not found"
- If PR is already merged: "Error: PR #{number} is already merged"
- If PR is closed (not merged): "Error: PR #{number} is closed and cannot be merged"
- If merge has conflicts: "Error: Cannot merge - conflicts detected. Resolve manually or rebase the branch"
- If merge checks are failing: Show which checks are failing and suggest waiting or fixing before merge
- If user lacks permissions: "Error: You don't have permission to merge this PR"
- If checkout fails: "Warning: Could not checkout {base branch}. You may need to manually switch branches"
- If pull fails: "Warning: Could not pull latest changes. You may need to manually run git pull"
- If local branch deletion fails: "Warning: Could not delete local branch {head branch}. It may not exist locally or may be the current branch"

## Notes
- The detailed commit message preserves important context for future developers reviewing git history
- The source branch is automatically deleted after successful merge on GitHub
- The local source branch is also deleted to keep the local repository clean
- All commits from the PR are squashed into one commit
- The commit message includes references to closed issues for automatic linking
- After merge, the local repository will be on the target branch with the latest changes pulled
