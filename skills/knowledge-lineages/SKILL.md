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
- MongoDB: Our data is relational (users->orders->items), document model would require denormalization
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

- @superpowers:brainstorming - After design finalized
- @superpowers:systematic-debugging - After root cause found
- @superpowers:strangler-fig-pattern - After migration phase
- @superpowers:characterization-testing - After behavior documented

**Integration pattern for other skills:**

```markdown
## After [completing main workflow]

Ask: "Would you like to document this [decision/finding] in the project
decision log for future sessions?"

If yes: Use @superpowers:knowledge-lineages to capture the decision.
```

## Anti-Patterns

**DON'T:**
- Document every tiny decision (only architectural/significant ones)
- Write novels (keep entries concise)
- Skip the "why not" section (most valuable part!)
- Forget to read decisions at session start
- Document without committing

**DO:**
- Focus on decisions future-you will forget
- Always include rejected alternatives
- Link to affected files
- Use consistent tags
- Read before starting significant work
