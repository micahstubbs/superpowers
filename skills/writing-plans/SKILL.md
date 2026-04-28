---
name: writing-plans
description: Use when you have a spec or requirements for a multi-step task, before touching code
---

# Writing Plans

## Overview

Write comprehensive implementation plans assuming the engineer has zero context for our codebase and questionable taste. Document everything they need to know: which files to touch for each task, code, testing, docs they might need to check, how to test it. Give them the whole plan as bite-sized tasks. DRY. YAGNI. TDD. Frequent commits.

Assume they are a skilled developer, but know almost nothing about our toolset or problem domain. Assume they don't know good test design very well.

**Announce at start:** "I'm using the writing-plans skill to create the implementation plan."

**Context:** This should be run in a dedicated worktree (created by brainstorming skill).

**Save plans to:** `docs/plans/YYYY-MM-DD-<feature-name>.md`

## Bite-Sized Task Granularity

**Each step is one action (2-5 minutes):**
- "Write the failing test" - step
- "Run it to make sure it fails" - step
- "Implement the minimal code to make the test pass" - step
- "Run the tests and make sure they pass" - step
- "Commit" - step

## Plan Document Header

**Every plan MUST start with this header:**

```markdown
# [Feature Name] Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies/libraries]

---
```

## Task Structure

```markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

**Step 1: Write the failing test**

```python
def test_specific_behavior():
    result = function(input)
    assert result == expected
```

**Step 2: Run test to verify it fails**

Run: `pytest tests/path/test.py::test_name -v`
Expected: FAIL with "function not defined"

**Step 3: Write minimal implementation**

```python
def function(input):
    return expected
```

**Step 4: Run test to verify it passes**

Run: `pytest tests/path/test.py::test_name -v`
Expected: PASS

**Step 5: Commit**

```bash
git add tests/path/test.py src/path/file.py
git commit -m "feat: add specific feature"
```
```

## Remember
- Exact file paths always
- Complete code in plan (not "add validation")
- Exact commands with expected output
- Reference relevant skills with @ syntax
- DRY, YAGNI, TDD, frequent commits

## Issue Tracking (Optional Beads Integration)

When `br` (beads_rust) is available AND the project (or any ancestor) contains a `.beads/*.db`, you can mirror plan tasks to beads issues so the executor (subagent-driven-development or executing-plans) can pick them up and track lifecycle.

**Detect at start:**

```bash
command -v br >/dev/null && br ready --json >/dev/null 2>&1 && echo "beads mode on"
```

If beads mode is on, after saving the plan ask: **"Mirror this plan into beads issues now?"** If yes:

```bash
# One epic for the plan
br create --title "Epic: <plan title>" --type=feature --priority=1 [--labels=<scope>]

# One task per Task N in the plan, with the epic as parent
br create --title "<task name>" --type=task --priority=2 --parent=<epic-id>

# Encode any ordering the plan declares (e.g., "Task 3 depends on Task 2")
br dep add <task-N+1> <task-N>

br sync --flush-only
```

Append an **"## Issue Tracking"** section to the saved plan listing the IDs:

```markdown
## Issue Tracking

- Epic: bd-xxxx
- Task 1: bd-xxxx.1
- Task 2: bd-xxxx.2
- ...
```

When beads mode is off (or the user declines), skip this entire section — the plan works without it.

## Execution Handoff

After saving the plan, offer execution choice:

**"Plan complete and saved to `docs/plans/<filename>.md`. Two execution options:**

**1. Subagent-Driven (this session)** - I dispatch fresh subagent per task, review between tasks, fast iteration

**2. Parallel Session (separate)** - Open new session with executing-plans, batch execution with checkpoints

**Which approach?"**

**If Subagent-Driven chosen:**
- **REQUIRED SUB-SKILL:** Use superpowers:subagent-driven-development
- Stay in this session
- Fresh subagent per task + code review
- If issues were mirrored above, pass `Beads epic: <id>` so the sub-skill threads issue lifecycle

**If Parallel Session chosen:**
- Guide them to open new session in worktree
- **REQUIRED SUB-SKILL:** New session uses superpowers:executing-plans
- If issues were mirrored above, the new session can claim them directly via `br ready`
