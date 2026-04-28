# Code Quality Reviewer Prompt Template

Use this template when dispatching a code quality reviewer subagent.

**Purpose:** Verify implementation is well-built (clean, tested, maintainable)

**Only dispatch after spec compliance review passes.**

```
Task tool (superpowers:code-reviewer):
  Use template at requesting-code-review/code-reviewer.md

  WHAT_WAS_IMPLEMENTED: [from implementer's report]
  PLAN_OR_REQUIREMENTS: Task N from [plan-file]
  BASE_SHA: [commit before task]
  HEAD_SHA: [current commit]
  DESCRIPTION: [task summary]
  BEADS_ISSUE: [optional — `bd-...` ID if tracked in beads; reviewer prepends it to the assessment so the controller can route updates]
```

**Code reviewer returns:** Strengths, Issues (Critical/Important/Minor), Assessment (with beads issue ID at top if provided)

**Note:** Reviewers must NOT run `br` commands. The controller owns issue lifecycle and updates state based on the assessment.
