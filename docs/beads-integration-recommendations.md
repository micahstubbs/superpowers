# Beads (`br`) Integration Recommendations Across Superpowers Skills

This document audits all 18 skills in `skills/` and recommends where optional integration with `br` (beads_rust) would add value. The pattern was first applied in `subagent-driven-development` (v4.1.0); these recommendations extend it consistently.

## Methodology

Each skill was evaluated on three axes:

1. **Does the skill produce or consume discrete units of work?** (tasks, bugs, migration phases, feedback items)
2. **Would issue lifecycle (open → in_progress → blocked → closed) map cleanly onto the skill's existing process?**
3. **Is the integration cost (controller bookkeeping, prompt complexity) less than the value (audit trail, dependency tracking, cross-session resumption)?**

Skills are ranked **high / medium / low / skip**. Every recommendation is **purely additive and optional** — when `br` is unavailable or no `.beads/*.db` is reachable, behavior is unchanged.

## Shared Principles (apply to every recommendation below)

Before per-skill notes, these conventions should be consistent across any new integration:

- **Detection at process start.** `command -v br >/dev/null && br ready --json >/dev/null 2>&1` gates the entire optional path.
- **Auto-detect, never prompt.** When detection succeeds, USE beads silently. Never ask the user "mirror this plan?" or "track in beads?". When detection fails, silently skip. Pre-action confirmation is friction — beads is part of the user's workflow if `br` is installed.
- **Controller owns issue state, subagents reference IDs only.** Subagents thread `Beads issue: <id>` into commits/reports; they never call `br update` or `br close`.
- **Status transitions tie to existing process steps**, not new ones. Mapping table per skill should reuse existing decision points.
- **`br sync --flush-only` after every state change.** Never auto-commits.
- **Verify writes** with `br show <id>` (or grep on `.beads/issues.jsonl`) — `br update --status` has a known echo bug.
- **Reuse plan-declared IDs** if the plan already names them; never create duplicates.

## Tier 1 — High value, recommend implementing

### `writing-plans`

**Why this is the strongest candidate after subagent-driven-development:** The skill's explicit purpose (`skills/writing-plans/SKILL.md:18`) is to produce `docs/plans/YYYY-MM-DD-<feature>.md` containing N bite-sized tasks. Those tasks are precisely what beads issues are. The execution handoff (line 99–117) already routes to either `subagent-driven-development` (now beads-aware) or `executing-plans`.

**Proposed integration:**

When beads mode is on, the controller **automatically** mirrors plan tasks after saving — no prompt to the user:

```bash
br create --title "Epic: <plan title>" --type=feature --priority=1 [--labels=<scope>]
# For each Task N in plan:
br create --title "<task name>" --type=task --priority=2 --parent=<epic-id>
br dep add <task-N+1> <task-N>   # if plan declares ordering
```

The plan document gets an **"## Issue Tracking"** appendix listing the IDs, and the existing handoff prompt (line 109/116) gains an optional line: `Beads epic: <epic-id>` so the executor (subagent-driven-development or executing-plans) picks up the same IDs.

**Cost:** ~30 lines in SKILL.md. Plan format unchanged structurally — appendix is additive.

**Risk:** None — fully optional. If user declines, plan flow is identical to today.

---

### `executing-plans`

**Why:** Direct parallel of `subagent-driven-development` (sibling skill — both execute plans, just different session/parallelism trade-offs per `skills/executing-plans/SKILL.md:1-13` vs. the subagent variant). Currently uses TodoWrite only (line 22). The status-transition logic from the subagent skill maps verbatim:

| Existing step (executing-plans line ref)          | Beads command                                                |
|---------------------------------------------------|--------------------------------------------------------------|
| Step 2 "Mark as in_progress" (line 28)            | `br update <id> --status=in_progress`                        |
| Step 3 "Report. Ready for feedback" (line 33-37)  | leave `in_progress`; controller closes after partner OK      |
| Step 4 batch complete after partner approves      | `br close <id> -r "completed in <sha>"` per task in batch    |
| Step 5 finishing-a-development-branch handoff     | (passes through — see Tier 1 below)                          |

**Cost:** ~25 lines. Add an "Issue Tracking (Optional Beads Integration)" section between Step 4 and Step 5 mirroring the subagent-driven-development addition.

**Risk:** None — mirrors a pattern already shipped and tested in subagent-driven-development.

---

## Tier 2 — Medium value, worth implementing once Tier 1 ships

### `systematic-debugging`

**Why:** The skill's Phase 1 (`skills/systematic-debugging/SKILL.md:50-122`) explicitly says "ALWAYS find root cause before attempting fixes." Filing a `bug` issue at the start of investigation gives the four phases an audit trail and lets multi-session investigations resume cleanly. The skill already produces a failing test (Phase 4, line 173) which is a natural commit-and-close moment.

**Proposed integration:** Optional, recommended in two narrow cases:

1. **Investigation > 1 session OR multi-component (line 73 "WHEN system has multiple components"):** Create `br create --type=bug --priority=<from-symptom>` at start; `br update --status=in_progress` during Phase 1; close on Phase 4 commit with `-r "Root cause: <X>; fix in <sha>"`.
2. **Architecture pivot (line 199 "If 3+ Fixes Failed"):** Update issue notes with each failed hypothesis; flag as `blocked` pending architectural discussion. The issue body then carries the "why not" history for `knowledge-lineages` to reference.

**Skip when:** Trivial bug, single-session fix, no architectural questions. The four phases already work without ceremony.

**Cost:** ~20 lines. Mostly a "When to file an issue" subsection — most uses skip it.

**Risk:** Process-fatigue — debugging is already a heavy discipline. Keep the integration explicitly optional and gated on the two cases above.

---

### `finishing-a-development-branch`

**Why:** This is the natural close-the-loop moment. The skill verifies tests, then offers merge/PR/keep/discard (`skills/finishing-a-development-branch/SKILL.md:51-63`). If the work was tracked in beads (epic + sub-issues), the merge or PR commit is the canonical "completed" event.

**Proposed integration:** After Step 4 executes (any of options 1, 2, 4 — not "keep as-is"):

```bash
# If beads mode and issue IDs were captured by the upstream skill (writing-plans / sda-d / executing-plans):
git log <merge-base>..HEAD --format=%H | xargs -I{} br orphans --commit {}
# OR explicitly: close every IN_PROGRESS issue whose ID appears in commit messages on the merged range
```

The skill's existing **Quick Reference table (line 152-160)** gains a fifth column: "Close beads issues" (✓ for options 1/2/4, — for option 3 keep-as-is).

**Cost:** ~15 lines plus a one-line addition to the existing Quick Reference table.

**Risk:** Low. The closes are conditional on beads mode AND on issue IDs being in commit messages — safe by construction.

---

### `strangler-fig-pattern`

**Why:** The skill is inherently multi-phase (`skills/strangler-fig-pattern/SKILL.md:32-37` — Month 1: 10%, Month 2: another 10%, etc.). Each rollout percentage milestone is a discrete unit of work that the team will revisit weekly. Beads issues with explicit dependencies (1% → 10% → 50% → 100%) and labels (`#strangler-fig`, target component name) would make the migration trackable across team members and sessions.

**Proposed integration:** Optional `## Tracking with Beads` subsection between Step 5 (Repeat for next use case, line 169) and Step 6 (Remove old implementation, line 195):

```bash
br create --title "Strangler-fig epic: replace LegacyReportGenerator" --type=feature --priority=1
br create --title "Add abstraction layer + 1% rollout" --type=task --parent=<epic>
br create --title "10% rollout" --type=task --parent=<epic>
br dep add <10%-id> <1%-id>
# ... 50%, 100%, remove-old-code ...
```

Each rollout percentage closes when monitoring confirms no regression — the issue's notes preserve the monitoring evidence for the post-mortem.

**Cost:** ~20 lines.

**Risk:** Low. Migration is already a long process; issue overhead is small relative to weeks of work.

---

## Tier 3 — Low value, mention only if integration is trivial

### `using-git-worktrees`

**Why low:** The worktree is a workspace, not a unit of work. But `using-git-worktrees/SKILL.md:80` already detects project name; if a beads issue ID is in scope, naming the worktree `.worktrees/<issue-id>-<short-desc>` (e.g., `.worktrees/bd-uh7c-codex-plugin/`) makes the workspace self-documenting and lets `br show <id>` link back to it.

**Proposed integration:** One sentence in the "Creation Steps" (line 82) — if a beads issue ID is provided in scope, prefer it as the branch/worktree prefix.

**Cost:** ~3 lines. Pure naming convention.

---

### `receiving-code-review`

**Why low:** Review feedback items map naturally to tasks (`skills/receiving-code-review/SKILL.md:101-111` already says "Implement in this order"). But review threads usually live in PR comments, not beads. Creating issues for every review nit is overhead.

**Proposed integration:** A one-line note in the "Implementation Order" section: if a review item requires multi-session work or surfaces a new bug class, file it as a `br create --type=bug` and continue with the immediately-fixable items. Don't auto-create issues.

**Cost:** ~5 lines.

---

### `knowledge-lineages`

**Why low:** `docs/DECISIONS.md` (skill's primary artifact, line 92) is reflective documentation; beads is actionable work. They live in different layers.

**Proposed integration:** When a decision was made to resolve a beads issue (debugging, migration, architecture), the DECISIONS entry's `**Affects:**` line (line 124) can also list `**Beads:**: bd-...`. Cross-reference only — no lifecycle integration.

**Cost:** ~3 lines. Just a template addition.

---

### `characterization-testing`

**Why low:** Discoveries (security bugs, gaps, weird behaviors per `skills/characterization-testing/SKILL.md:135-145`) often warrant follow-up work. Filing each discovery as a `br create --type=bug` is a natural extension, but the skill's purpose is understanding, not tracking.

**Proposed integration:** A bullet in "When You're Done" (line 348) — for each unexpected behavior captured (especially security bugs like the plaintext-password example at line 295), consider `br create --type=bug` so the discovery isn't lost when this session ends.

**Cost:** ~5 lines.

---

### `brainstorming`

**Why low:** Brainstorming output is a design doc (`skills/brainstorming/SKILL.md:38-41`), not actionable tasks. Tasks come from `writing-plans`, which is already Tier 1.

**Proposed integration:** None directly. The handoff to `writing-plans` (line 46) carries any beads work forward.

---

## Tier 4 — Skip (no natural fit)

These skills should NOT add `br` integration; the cost-value ratio is wrong:

| Skill                                | Why skip                                                                  |
|--------------------------------------|---------------------------------------------------------------------------|
| `using-superpowers`                  | Meta — about skill invocation, not work tracking.                         |
| `writing-skills`                     | Skill creation has its own TDD-style workflow; issue overhead unhelpful.  |
| `test-driven-development`            | TDD is per-test cycle; far too granular for issues.                       |
| `dispatching-parallel-agents`        | Per-agent work is usually a sub-task of an existing issue; passing IDs through is enough (already covered in subagent-driven-development).         |
| `verification-before-completion`     | Verification gate, not work tracking.                                     |
| `requesting-code-review`             | Reviewer dispatch; already covered via the parent skill's integration.    |
| `context-7`                          | Documentation lookup; no work-unit semantics.                             |
| `subagent-driven-development`        | Already integrated (v4.1.0).                                              |

## Suggested Implementation Order

If implementing in stages:

1. **`writing-plans`** + **`executing-plans`** (Tier 1) — completes the plan-creation → execution loop with beads support end-to-end.
2. **`finishing-a-development-branch`** (Tier 2) — closes the loop on shipped work; small integration.
3. **`systematic-debugging`** (Tier 2) — narrowly scoped, opt-in for non-trivial bugs.
4. **`strangler-fig-pattern`** (Tier 2) — migration tracking; benefits compound over weeks.
5. **Tier 3 additions** as opportunistic single-line tweaks, not a dedicated effort.

## Cross-Skill Consistency Checklist

When implementing any of the above, every PR should:

- [ ] Add a "Issue Tracking (Optional Beads Integration)" section that mirrors the structure used in `subagent-driven-development/SKILL.md:85-118` (detection → mapping → status table → write verification).
- [ ] Add a Red Flag bullet: "Run `br` commands from inside subagents" — controller owns lifecycle.
- [ ] Add an Integration pointer at the bottom of the skill referencing the optional beads layer.
- [ ] Leave existing tests alone unless they begin to assert on TodoWrite-only behavior; the integration is additive.
- [ ] Bump `version` in all three plugin manifests (`.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, `.codex-plugin/plugin.json`) on any user-visible skill change.

## Out of Scope for This Document

- Building a "convert plan markdown to beads issues" tool — could be useful but is not a skill change.
- Changing how `subagent-driven-development` itself integrates (already shipped in v4.1.0).
- Anything that requires changes to `br` itself.
