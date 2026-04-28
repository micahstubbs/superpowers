---
name: executing-plans
description: Use when you have a written implementation plan to execute in a separate session with review checkpoints
---

# Executing Plans

## Overview

Load plan, review critically, execute tasks in batches, report for review between batches.

**Core principle:** Batch execution with checkpoints for architect review.

**Announce at start:** "I'm using the executing-plans skill to implement this plan."

## The Process

### Step 1: Load and Review Plan
1. Read plan file
2. Review critically - identify any questions or concerns about the plan
3. If concerns: Raise them with your human partner before starting
4. If no concerns: Create TodoWrite and proceed

### Step 2: Execute Batch
**Default: First 3 tasks**

For each task:
1. Mark as in_progress
2. Follow each step exactly (plan has bite-sized steps)
3. Run verifications as specified
4. Mark as completed

### Step 3: Report
When batch complete:
- Show what was implemented
- Show verification output
- Say: "Ready for feedback."

### Step 4: Continue
Based on feedback:
- Apply changes if needed
- Execute next batch
- Repeat until complete

### Step 5: Complete Development

After all tasks complete and verified:
- Announce: "I'm using the finishing-a-development-branch skill to complete this work."
- **REQUIRED SUB-SKILL:** Use superpowers:finishing-a-development-branch
- Follow that skill to verify tests, present options, execute choice

## Issue Tracking (Optional Beads Integration)

When `br` (beads_rust) is available AND the project has a reachable `.beads/*.db`, **automatically** thread issue lifecycle through the existing process steps. Do not ask — beads is part of the user's workflow; if `br` is installed, use it. When unavailable, silently skip this section (TodoWrite alone is sufficient).

If the dispatch passed `Beads epic: <id>`, use it; otherwise find the plan's mirrored issues by reading the parent epic ID from the plan's "## Issue Tracking" appendix and listing its children (e.g., `br dep tree <epic-id>`).

**Detect at start (Step 1):**

```bash
command -v br >/dev/null && br ready --json >/dev/null 2>&1 && echo "beads mode on"
```

If beads mode is on, capture the IDs alongside TodoWrite entries — no prompt needed.

**Status transitions tied to existing process:**

| Existing step                                    | Beads command                                                          |
|--------------------------------------------------|------------------------------------------------------------------------|
| Step 2 "Mark as in_progress" (TodoWrite)         | `br update <id> --status=in_progress`                                  |
| Step 3 "Report. Ready for feedback."             | leave `in_progress`; controller closes after partner approval          |
| Step 4 batch complete after partner approves     | `br close <id> -r "completed in <commit-sha>"` per task in the batch   |
| After every state change                         | `br sync --flush-only`                                                 |

**Verify the write after each state change.** `br update --status` is known to echo a misleading title/diff. Confirm with `br show <id>` (or `grep '"<id>"' .beads/issues.jsonl` after sync) before moving on.

## When to Stop and Ask for Help

**STOP executing immediately when:**
- Hit a blocker mid-batch (missing dependency, test fails, instruction unclear)
- Plan has critical gaps preventing starting
- You don't understand an instruction
- Verification fails repeatedly

**Ask for clarification rather than guessing.**

## When to Revisit Earlier Steps

**Return to Review (Step 1) when:**
- Partner updates the plan based on your feedback
- Fundamental approach needs rethinking

**Don't force through blockers** - stop and ask.

## Remember
- Review plan critically first
- Follow plan steps exactly
- Don't skip verifications
- Reference skills when plan says to
- Between batches: just report and wait
- Stop when blocked, don't guess
