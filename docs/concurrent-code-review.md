# Concurrent-Safe Code Review

## The Problem

Traditional code review commands use git ranges:

```bash
gh pr create --body "$(git diff main...HEAD)"
```

**Issue:** If `main` moves (new commits pushed), `main...HEAD` changes:
- Your PR description becomes outdated
- Reviewers see different diffs
- Parallel agents can't safely create PRs

## The Solution

Use commit SHA lists instead of ranges:

```bash
# Get list of commits to review
commits=$(git log main..HEAD --format="%H" | tac)

# Generate review content from specific SHAs
git show $commits
```

**Benefits:**
- SHAs never change
- PR content stays accurate
- Multiple agents can create PRs simultaneously
- Reviewers see exact commits you intended

## Implementation

Update the requesting-code-review skill to use SHA-based review.
