# Knowledge Lineages Skill Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Create a skill that preserves decision context across AI sessions by documenting architectural decisions in an AI-optimized format.

**Architecture:** Single skill file (`skills/knowledge-lineages/SKILL.md`) that guides AI to capture and read decisions from `docs/DECISIONS.md`. Integrates with other skills via documentation prompts.

**Tech Stack:** Markdown skill file, follows existing superpowers skill conventions.

**Design Document:** `issues/16/DESIGN.md`

---

## Task 1: Create Knowledge-Lineages Skill File

**Files:**
- Create: `skills/knowledge-lineages/SKILL.md`

**Step 1: Create the skill directory**

```bash
mkdir -p skills/knowledge-lineages
```

**Step 2: Write the skill file**

Create `skills/knowledge-lineages/SKILL.md` with the following content:

```markdown
---
name: knowledge-lineages
description: Use when making architectural decisions or after completing brainstorming/debugging sessions - preserves decision context for future AI sessions
---

# Knowledge Lineages

## When to Use

- After making an architectural decision
- After brainstorming finalizes a design
- After systematic-debugging identifies a root cause
- After strangler-fig completes a migration phase
- When you want to document "why" for future sessions
- At project start to read existing decisions

**Don't use when:**
- Trivial implementation details (not architectural)
- Temporary decisions that will change soon
- Already documented elsewhere with full context

## The Problem

**Scenario:**
```
Session 1: "Let's use PostgreSQL instead of MongoDB"
AI: *implements with PostgreSQL*

Session 2: "Maybe we should use MongoDB for flexibility?"
AI: "Great idea! Let's refactor to MongoDB"
User: "Wait, we already decided against that..."
```

**With knowledge-lineages:**
```
Session 1: "Let's use PostgreSQL instead of MongoDB"
AI: *implements, then documents decision*

Session 2: AI reads docs/DECISIONS.md
AI: "I see you chose PostgreSQL over MongoDB because your data
is relational. Want me to continue with that approach?"
```

## Process

### Reading Decisions (Session Start)

**At the start of significant work on established projects:**

1. Check if `docs/DECISIONS.md` exists
2. If yes, read it to understand project history
3. Reference relevant decisions when making suggestions

```
AI: "Before we start, let me check for documented decisions..."
AI: *reads docs/DECISIONS.md*
AI: "I see several past decisions that may be relevant:
- 2025-01-15: Using PostgreSQL (not MongoDB)
- 2025-01-20: JWT auth (not sessions)
Ready to continue with these constraints in mind."
```

### Writing Decisions (After Key Moments)

**When to prompt for documentation:**

| Trigger | Prompt |
|---------|--------|
| After brainstorming | "Design finalized. Add key decisions to the decision log?" |
| After debugging | "Root cause found. Document this for future sessions?" |
| After migration phase | "Migration complete. Document what changed?" |
| Manual request | User asks to document a decision |

**Capture process:**

1. Ask for or derive:
   - Decision title (short, descriptive)
   - Context (what prompted this?)
   - The decision itself
   - Alternatives considered and why rejected
   - Files/code affected
   - Tags

2. Format as entry (see template below)

3. Append to `docs/DECISIONS.md`

4. Commit: `git commit -m "docs: add decision - [title]"`

## File Format

### Location

```
project-root/
└── docs/
    └── DECISIONS.md    # Single append-only file
```

### File Header (create if doesn't exist)

```markdown
# Project Decision Log

> This file preserves architectural decisions and rationale for AI coding assistants.
> Read this file at the start of sessions to understand project history.

---
```

### Entry Template

```markdown
## YYYY-MM-DD: [Short Decision Title]

**Context:** [1-2 sentences: What situation/problem prompted this decision?]

**Decision:** [1-2 sentences: What we decided to do]

**Why not:**
- [Alternative 1]: [Why rejected]
- [Alternative 2]: [Why rejected]

**Affects:** `path/to/file.ts`, `path/to/other.ts`

**Tags:** #category1 #category2

---
```

## Examples

### Example 1: Database Choice

```markdown
## 2025-01-15: Use PostgreSQL instead of MongoDB

**Context:** Needed to choose database for user data. Team has mixed experience.

**Decision:** Use PostgreSQL with Prisma ORM for type safety and relational integrity.

**Why not:**
- MongoDB: Our data is relational (users→orders→items), document model would require denormalization
- SQLite: Won't scale for concurrent writes in production

**Affects:** `src/db/schema.prisma`, `src/models/`, `docker-compose.yml`

**Tags:** #database #infrastructure #architecture

---
```

### Example 2: Debugging Discovery

```markdown
## 2025-02-10: Race condition in order processing

**Context:** Orders occasionally showed wrong totals. Took 3 sessions to find.

**Decision:** Added mutex lock around price calculation. Root cause was concurrent cart updates during checkout.

**Why not:**
- Database transactions alone: Didn't catch the in-memory cart state issue
- Queue-based processing: Over-engineering for current scale

**Affects:** `src/services/order.ts:45-60`, `src/services/cart.ts`

**Tags:** #lesson-learned #concurrency #orders

---
```

### Example 3: Architecture Choice

```markdown
## 2025-03-01: Monorepo with Turborepo

**Context:** Growing to 3 packages (api, web, shared). Need to share code efficiently.

**Decision:** Use Turborepo for monorepo management with pnpm workspaces.

**Why not:**
- Nx: More complex than needed, heavier tooling
- Lerna: Less active maintenance, Turborepo is faster
- Separate repos: Code sharing becomes painful

**Affects:** `turbo.json`, `pnpm-workspace.yaml`, `packages/`

**Tags:** #architecture #tooling #monorepo

---
```

## Tag Conventions

Standard tags for consistency:

- `#architecture` - System-level design choices
- `#database` - Data storage decisions
- `#api` - API design choices
- `#security` - Security-related decisions
- `#performance` - Optimization choices
- `#tooling` - Build/dev tool choices
- `#lesson-learned` - From debugging sessions
- `#infrastructure` - Deployment/hosting decisions

## Cross-References

Link to related artifacts:

```markdown
**Related:** docs/plans/2025-01-15-auth-design.md
**Supersedes:** 2024-06-01: Use session-based auth
```

## Integration with Other Skills

**Skills that should prompt for documentation:**

- @superpowers:brainstorming → After design finalized
- @superpowers:systematic-debugging → After root cause found
- @superpowers:strangler-fig-pattern → After migration phase
- @superpowers:characterization-testing → After behavior documented

**Integration pattern for other skills:**

```markdown
## After [completing main workflow]

Ask: "Would you like to document this [decision/finding] in the project
decision log for future sessions?"

If yes: Use @superpowers:knowledge-lineages to capture the decision.
```

## Anti-Patterns

**DON'T:**
- ❌ Document every tiny decision (only architectural/significant ones)
- ❌ Write novels (keep entries concise)
- ❌ Skip the "why not" section (most valuable part!)
- ❌ Forget to read decisions at session start
- ❌ Document without committing

**DO:**
- ✅ Focus on decisions future-you will forget
- ✅ Always include rejected alternatives
- ✅ Link to affected files
- ✅ Use consistent tags
- ✅ Read before starting significant work
```

**Step 3: Verify the skill file exists and is readable**

```bash
cat skills/knowledge-lineages/SKILL.md | head -20
```

Expected: Shows the frontmatter and beginning of the skill.

**Step 4: Commit the new skill**

```bash
git add skills/knowledge-lineages/
git commit -m "feat: add knowledge-lineages skill for decision tracking

Tracks architectural decisions across AI sessions.
- AI-optimized format with 'why not' section
- Single file storage (docs/DECISIONS.md)
- Integrates with brainstorming, debugging skills

Closes #16"
```

---

## Task 2: Update README to Include New Skill

**Files:**
- Modify: `README.md`

**Step 1: Find the skills list section in README**

```bash
grep -n "knowledge\|Skills\|Available" README.md | head -20
```

**Step 2: Add knowledge-lineages to the skills list**

Find the skills table/list in README.md and add an entry for knowledge-lineages in the appropriate category (likely "Collaboration" or create "Documentation" category).

Add this row to the skills table:
```markdown
| knowledge-lineages | Track architectural decisions across AI sessions |
```

**Step 3: Verify the change**

```bash
grep -A2 -B2 "knowledge-lineages" README.md
```

Expected: Shows the new entry in context.

**Step 4: Commit the README update**

```bash
git add README.md
git commit -m "docs: add knowledge-lineages to README skills list"
```

---

## Task 3: Add Integration Hint to Brainstorming Skill

**Files:**
- Modify: `skills/brainstorming/SKILL.md`

**Step 1: Read the current brainstorming skill**

```bash
cat skills/brainstorming/SKILL.md
```

**Step 2: Add documentation prompt to the "After the Design" section**

Find the "After the Design" or "Documentation" section and add a prompt for knowledge-lineages:

```markdown
## After the Design

**Documentation:**
- Write the validated design to `docs/plans/YYYY-MM-DD-<topic>-design.md`
- Use elements-of-style:writing-clearly-and-concisely skill if available
- Commit the design document to git

**Decision Log (optional):**
- Ask: "Would you like to add key decisions from this design to the project decision log?"
- If yes: Use @superpowers:knowledge-lineages to capture architectural choices
- This preserves the "why" for future AI sessions
```

**Step 3: Verify the change**

```bash
grep -A5 "knowledge-lineages" skills/brainstorming/SKILL.md
```

Expected: Shows the new integration section.

**Step 4: Commit the integration**

```bash
git add skills/brainstorming/SKILL.md
git commit -m "feat: integrate knowledge-lineages prompt into brainstorming skill"
```

---

## Task 4: Add Integration Hint to Systematic-Debugging Skill

**Files:**
- Modify: `skills/systematic-debugging/SKILL.md`

**Step 1: Read the current systematic-debugging skill**

```bash
cat skills/systematic-debugging/SKILL.md
```

**Step 2: Add documentation prompt after root cause section**

Find the section where root cause is confirmed and add:

```markdown
## After Root Cause Confirmed

**Optional: Document for future sessions**

If this was a non-obvious bug that took significant investigation:

Ask: "This root cause might be worth documenting so future sessions don't
re-investigate. Add to the project decision log?"

If yes: Use @superpowers:knowledge-lineages with:
- Context: What symptoms led to investigation
- Decision: The root cause and fix
- Why not: Other hypotheses that were ruled out
- Tags: #lesson-learned plus relevant domain tags
```

**Step 3: Verify the change**

```bash
grep -A5 "knowledge-lineages" skills/systematic-debugging/SKILL.md
```

Expected: Shows the new integration section.

**Step 4: Commit the integration**

```bash
git add skills/systematic-debugging/SKILL.md
git commit -m "feat: integrate knowledge-lineages prompt into systematic-debugging skill"
```

---

## Task 5: Verify Skill Works End-to-End

**Files:**
- None (verification only)

**Step 1: Verify skill is discoverable**

The skill should appear in the superpowers skill list. Check that the frontmatter is correct:

```bash
head -5 skills/knowledge-lineages/SKILL.md
```

Expected:
```
---
name: knowledge-lineages
description: Use when making architectural decisions or after completing brainstorming/debugging sessions - preserves decision context for future AI sessions
---
```

**Step 2: Verify skill content is complete**

```bash
wc -l skills/knowledge-lineages/SKILL.md
```

Expected: Approximately 200-250 lines (substantial skill documentation).

**Step 3: Verify all integration points are in place**

```bash
grep -l "knowledge-lineages" skills/*/SKILL.md
```

Expected output:
```
skills/brainstorming/SKILL.md
skills/systematic-debugging/SKILL.md
skills/knowledge-lineages/SKILL.md
```

**Step 4: Final verification - no syntax errors in markdown**

```bash
# Check frontmatter is valid YAML-ish
head -4 skills/knowledge-lineages/SKILL.md | grep -E "^(---|name:|description:)"
```

Expected: All three lines match (---, name:, description:).

---

## Summary

| Task | Description | Commit Message |
|------|-------------|----------------|
| 1 | Create knowledge-lineages skill | `feat: add knowledge-lineages skill for decision tracking` |
| 2 | Update README | `docs: add knowledge-lineages to README skills list` |
| 3 | Integrate with brainstorming | `feat: integrate knowledge-lineages prompt into brainstorming skill` |
| 4 | Integrate with systematic-debugging | `feat: integrate knowledge-lineages prompt into systematic-debugging skill` |
| 5 | End-to-end verification | (no commit - verification only) |

**Total commits:** 4
**Files created:** 1 (`skills/knowledge-lineages/SKILL.md`)
**Files modified:** 3 (`README.md`, `skills/brainstorming/SKILL.md`, `skills/systematic-debugging/SKILL.md`)
