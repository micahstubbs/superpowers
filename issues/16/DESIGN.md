# Knowledge Lineages Skill - Design Document

> **Issue:** #16 - Knowledge Lineages Skill
> **Date:** 2025-11-24
> **Status:** Approved

## Overview

### Purpose

Preserve decision context across AI coding sessions so future sessions don't re-explore rejected paths or lose architectural rationale.

### Core Problem Solved

- AI sessions are stateless - each new conversation starts fresh
- Developers make decisions, AI helps implement, but the "why" is lost
- Next session: AI suggests the same approach that was already rejected
- Long-running projects accumulate implicit knowledge that's never written down

### How It Works

1. Other skills (brainstorming, debugging, etc.) trigger prompts at decision points
2. Skill guides capture of decision in AI-optimized format
3. Decisions append to `docs/DECISIONS.md`
4. Future AI sessions read this file to understand project history

### When It Activates

- After brainstorming finalizes a design
- After systematic-debugging identifies root cause
- After strangler-fig completes a migration phase
- Manual invocation anytime

### Target Users

- Developers using AI coding assistants on long-running projects
- Teams where multiple people (or AI sessions) touch the same codebase
- Projects with complex architectural decisions

---

## Design Decisions

| Question | Decision | Rationale |
|----------|----------|-----------|
| **Core Purpose** | Context Preservation System | Unique value for AI-assisted development (vs traditional ADRs) |
| **Trigger Points** | Automatic prompts at key moments | Captures decisions when fresh, integrates with other skills |
| **Storage Format** | Single project file (`docs/DECISIONS.md`) | AI can easily read one file, chronological log shows evolution |
| **Entry Structure** | AI-optimized format | Includes file refs, "why not" section, tags for filtering |
| **Integration** | Multiple skills | Different skills produce different knowledge worth preserving |

---

## File Format

### Storage Location

```
project-root/
└── docs/
    └── DECISIONS.md    # Single append-only file
```

### File Header

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

### Example Entry

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

---

## Skill Workflow

### Manual Invocation

When user explicitly wants to document a decision:

1. AI prompts for:
   - Decision title (short, descriptive)
   - Context (what prompted this?)
   - The decision itself
   - Alternatives considered and why rejected
   - Files/code affected
   - Tags
2. AI appends formatted entry to `docs/DECISIONS.md`
3. AI commits with message: `docs: add decision - [title]`

### Triggered by Other Skills

**After brainstorming completes:**
```
AI: "Design finalized and saved. Would you like to add this to the project decision log?"
- Yes → Capture key architectural choices from the design
- No → Continue without documenting
```

**After systematic-debugging finds root cause:**
```
AI: "Root cause identified: [X]. This might be worth documenting so future sessions
don't re-investigate. Add to decision log?"
- Yes → Capture the finding and resolution
- No → Continue
```

**After strangler-fig migration phase:**
```
AI: "Migration phase complete. Document this incremental change?"
- Yes → Capture what was migrated and why
- No → Continue
```

### Reading Decisions (Session Start)

The skill guides AI to **read** `docs/DECISIONS.md` at session start when working on established projects. This closes the loop - decisions written are decisions used.

---

## Integration with Other Skills

### Skills That Trigger Documentation Prompts

| Skill | Trigger Point | What to Capture |
|-------|---------------|-----------------|
| `brainstorming` | After design saved | Architectural choices, approach selected |
| `systematic-debugging` | After root cause identified | Bug pattern, resolution, prevention |
| `strangler-fig-pattern` | After migration phase | What migrated, rollout strategy |
| `characterization-testing` | After behavior documented | Discovered behaviors, known quirks |

### Integration Pattern

Each integrating skill adds a simple prompt at the end of its workflow:

```markdown
## After [Skill Action]

**Prompt:** "This [design/finding/migration] might be worth preserving in the
decision log. Document it?"

**If yes:**
- Pre-fill what we can from the skill's output
- Ask for any missing fields
- Append to docs/DECISIONS.md
- Commit with message: "docs: add decision - [title]"

**If no:**
- Continue without documenting
```

### Cross-References

Entries can reference other artifacts:
- `**Related:** docs/plans/2025-01-15-auth-design.md` - links to full design doc
- `**Supersedes:** 2024-06-01: Use session-based auth` - marks old decisions as superseded

### Tag Conventions

Suggested standard tags:
- `#architecture` - System-level design choices
- `#database` - Data storage decisions
- `#api` - API design choices
- `#security` - Security-related decisions
- `#performance` - Optimization choices
- `#tooling` - Build/dev tool choices
- `#lesson-learned` - From debugging sessions

---

## Success Criteria

The skill succeeds when:
- [ ] Decisions are captured with minimal friction
- [ ] Future AI sessions can read and understand past decisions
- [ ] AI stops suggesting previously-rejected approaches
- [ ] Project knowledge survives team/session changes
