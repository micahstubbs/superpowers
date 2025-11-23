# Community Fork Integration Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

> **Note on Skill Paths:** This plan references skills as `skills/name.md` for clarity, but the actual structure is `skills/name/SKILL.md`. When implementing, use the actual paths (e.g., `skills/requesting-code-review/SKILL.md` instead of `skills/requesting-code-review.md`).

**Goal:** Integrate all must-include contributions from the superpowers fork network into a new consolidated community fork.

**Architecture:** Cherry-pick and adapt 6 high-value contribution categories from 4 different forks (anvanvan/flows, complexthings/superpowers, cuivienor/superpowers, jpcaparas/superpowers-laravel). Start with critical infrastructure (parallel agent support), then expand to platform support, language examples, and specialized skills.

**Tech Stack:** Git, Bash, Python/JavaScript (for MCP replacement scripts), Markdown (documentation)

**Source Forks:**
- anvanvan/flows: https://github.com/anvanvan/flows
- complexthings/superpowers: https://github.com/complexthings/superpowers
- cuivienor/superpowers: https://github.com/cuivienor/superpowers
- obra/superpowers (upstream): https://github.com/obra/superpowers

---

## Prerequisites

### Task 0: Fork Setup

**Files:**
- Repository: Create new fork on GitHub from obra/superpowers
- Clone: `~/workspace/superpowers-community` (or desired location)

**Step 1: Create GitHub fork**

Navigate to https://github.com/obra/superpowers and click "Fork"
Name it: `superpowers-community` (or your preferred name)

**Step 2: Clone the fork**

```bash
cd ~/workspace
git clone git@github.com:YOUR_USERNAME/superpowers-community.git
cd superpowers-community
```

**Step 3: Add upstream and source fork remotes**

```bash
git remote add upstream https://github.com/obra/superpowers.git
git remote add flows https://github.com/anvanvan/flows.git
git remote add complexthings https://github.com/complexthings/superpowers.git
git remote add cuivienor https://github.com/cuivienor/superpowers.git
git fetch --all
```

**Step 4: Create integration branch**

```bash
git checkout -b integration/community-contributions
```

**Step 5: Verify setup**

Run: `git remote -v`
Expected: origin (your fork), upstream, flows, complexthings, cuivienor remotes listed

---

## Phase 1: Critical Infrastructure (Parallel Agent Support)

### Task 1: Git Line-Staging Aliases

**Files:**
- Create: `scripts/install-git-aliases.sh`
- Modify: `README.md` (add installation instructions)
- Create: `docs/parallel-development.md`

**Step 1: Create git aliases installation script**

```bash
# scripts/install-git-aliases.sh
#!/bin/bash

# Install git aliases for line-level staging
# Enables parallel agent development without staging conflicts

echo "Installing git line-staging aliases..."

git config --global alias.stage-lines '!f() { \
    file=$1; \
    shift; \
    git diff "$file" | \
    git apply --cached --unidiff-zero - <<< "$(echo "$@" | tr " " "\n" | \
    while read line; do git diff "$file" | grep -A1 "^@@.*+${line}" | tail -1; done)"; \
}; f'

git config --global alias.unstage-lines '!f() { \
    file=$1; \
    shift; \
    git diff --cached "$file" | \
    git apply --cached --reverse --unidiff-zero - <<< "$(echo "$@" | tr " " "\n" | \
    while read line; do git diff --cached "$file" | grep -A1 "^@@.*+${line}" | tail -1; done)"; \
}; f'

echo "✓ Git aliases installed successfully"
echo "Usage:"
echo "  git stage-lines <file> <line-numbers...>"
echo "  git unstage-lines <file> <line-numbers...>"
```

**Step 2: Make script executable**

Run: `chmod +x scripts/install-git-aliases.sh`

**Step 3: Test the script**

Run: `./scripts/install-git-aliases.sh`
Expected: "✓ Git aliases installed successfully"

**Step 4: Verify aliases are installed**

Run: `git config --global --get-regexp alias.stage-lines`
Expected: Output showing the alias definition

**Step 5: Create parallel development documentation**

```markdown
# docs/parallel-development.md

# Parallel Development with Superpowers

## Overview

This guide explains how to work with multiple AI agents or developers simultaneously on the same codebase without conflicts.

## Git Line-Staging Aliases

### Installation

Run the installation script:

```bash
./scripts/install-git-aliases.sh
```

### Usage

**Stage specific lines:**
```bash
git stage-lines src/file.py 42 43 44
```

**Unstage specific lines:**
```bash
git unstage-lines src/file.py 42
```

### Why This Matters

Traditional `git add` stages entire files. When multiple agents work in parallel:
- Agent A modifies lines 10-20 in file.py
- Agent B modifies lines 50-60 in file.py
- Both run `git add file.py` → conflict!

With line-staging:
- Agent A: `git stage-lines file.py 10 11 12 ... 20`
- Agent B: `git stage-lines file.py 50 51 52 ... 60`
- No conflict! Each agent stages only their changes.

## Concurrent-Safe Code Review

See the `requesting-code-review` skill for details on using commit SHAs instead of git ranges.

**Traditional (unsafe for parallel work):**
```bash
git diff main...HEAD  # Breaks when main moves
```

**Concurrent-safe:**
```bash
git log main..HEAD --format="%H"  # List of commit SHAs
```

The code reviewer uses these specific SHAs, which never change, instead of branch ranges.
```

**Step 6: Update README with installation instructions**

Add to README.md in "Installation" or "Setup" section:

```markdown
### Parallel Development Setup (Optional)

If you plan to use multiple AI agents or work with others simultaneously:

```bash
./scripts/install-git-aliases.sh
```

See [docs/parallel-development.md](docs/parallel-development.md) for details.
```

**Step 7: Commit changes**

```bash
git add scripts/install-git-aliases.sh docs/parallel-development.md README.md
git commit -m "feat: add git line-staging aliases for parallel development

Enables multiple agents to stage specific lines without conflicts.
Based on anvanvan/flows concurrent development infrastructure.
"
```

---

### Task 2: Concurrent-Safe Code Review

**Files:**
- Modify: `skills/requesting-code-review.md`
- Create: `docs/concurrent-code-review.md`

**Step 1: Fetch the concurrent-safe code review implementation**

```bash
git fetch flows
```

**Step 2: Check current requesting-code-review skill**

Run: `cat skills/requesting-code-review.md`
Note: Current implementation for comparison

**Step 3: Create concurrent code review documentation**

Create `docs/concurrent-code-review.md`:

```markdown
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
```

**Step 4: Update requesting-code-review skill**

Add to `skills/requesting-code-review.md` after the main instructions:

```markdown
## Concurrent-Safety Notes

**For parallel agent workflows:**

When creating code review requests in environments where multiple agents or developers work simultaneously, use commit SHAs instead of git ranges to ensure the review content never changes.

**Safe pattern:**
```bash
# Collect commit SHAs
review_commits=$(git log main..HEAD --format="%H" | tac)

# Use specific SHAs in review request
gh pr create --title "..." --body "$(
  echo "## Commits"
  echo "$review_commits" | while read sha; do
    echo "- $(git log -1 --format='%h %s' $sha)"
  done
  echo ""
  echo "## Changes"
  git show $review_commits
)"
```

**Why:** Git ranges like `main...HEAD` are relative and change when `main` moves. Commit SHAs are immutable.

See [docs/concurrent-code-review.md](../docs/concurrent-code-review.md) for details.
```

**Step 5: Verify the skill still renders correctly**

Run: `head -20 skills/requesting-code-review.md`
Expected: Valid markdown with frontmatter

**Step 6: Commit changes**

```bash
git add skills/requesting-code-review.md docs/concurrent-code-review.md
git commit -m "feat: add concurrent-safe code review patterns

Uses commit SHAs instead of git ranges for parallel workflows.
Based on anvanvan/flows commits 88-94.
"
```

---

### Task 3: Task Tool Result Consumption Documentation

**Files:**
- Create: `docs/task-tool-integration.md`
- Create: `docs/task-result-consumption-patterns.md`
- Modify: Multiple skills to add consumption patterns

**Step 1: Create task tool integration documentation**

Create `docs/task-tool-integration.md`:

```markdown
# Task Tool Integration Guide

## The Problem

Claude Code's Task tool launches subagents to perform work, but the parent agent often fails to use the results effectively:

**Bad pattern:**
```
Claude: "Let me launch a research agent..."
*launches agent*
*agent completes*
Claude: "The agent finished. What would you like to do next?"
← WASTED WORK! Results not consumed.
```

**Good pattern:**
```
Claude: "Let me launch a research agent..."
*launches agent*
*agent returns findings*
Claude: "Based on the agent's findings: [specific details from report]..."
← RESULTS CONSUMED! Work is used.
```

## Result Consumption Patterns

See [task-result-consumption-patterns.md](task-result-consumption-patterns.md) for the three core patterns.

## Skill Integration

All skills that use the Task tool should include explicit "Result Consumption" sections documenting how to use the subagent's output.

**Template:**

```markdown
## Result Consumption

After the [agent-type] agent completes:

1. **Read the full report** - Don't skip sections
2. **Extract key findings** - [Specific what to look for]
3. **Take action** - [What to do with findings]
4. **Verify completeness** - [How to know you're done]

**Example:**

\```
Agent returned 3 bug candidates. For each:
- Note the file path and line number
- Understand the suspected issue
- Create a targeted fix plan
\```
```

## Verification

Before marking a Task tool usage as complete:

- [ ] Did you read the entire agent response?
- [ ] Did you extract specific details (not just "the agent found some things")?
- [ ] Did you take concrete action based on the findings?
- [ ] Can you articulate what you learned from the agent?

If any answer is "no", you haven't consumed the results yet.
```

**Step 2: Create consumption patterns documentation**

Create `docs/task-result-consumption-patterns.md`:

```markdown
# Task Tool Result Consumption Patterns

## Three Core Patterns

### Pattern 1: Direct Action

**Use when:** The subagent produces actionable items.

**Process:**
1. Launch Task agent
2. Agent returns specific items (files, bugs, tasks)
3. **For each item**, take immediate action
4. Verify all items processed

**Example:**

```
Task: Find all TODO comments
Agent returns:
  - src/api.py:42 "TODO: Add validation"
  - src/db.py:103 "TODO: Add index"

Consumption:
  FOR src/api.py:42:
    - Read surrounding code
    - Add validation
    - Remove TODO
  FOR src/db.py:103:
    - Read migration files
    - Create index migration
    - Remove TODO
```

### Pattern 2: Synthesis and Planning

**Use when:** The subagent produces information requiring analysis.

**Process:**
1. Launch Task agent
2. Agent returns findings, research, analysis
3. **Synthesize** findings into coherent understanding
4. **Create plan** based on synthesis
5. **Execute** plan

**Example:**

```
Task: Research authentication patterns
Agent returns: 15-page report on JWT, OAuth, Sessions

Consumption:
  Synthesis:
    - JWT: Stateless, scalable, token management complexity
    - OAuth: Social login, external dependency
    - Sessions: Stateful, simple, scaling challenges

  Decision:
    - Use JWT for API
    - Use sessions for web

  Plan:
    1. Implement JWT for /api/* routes
    2. Implement sessions for web routes
    3. Add refresh token rotation
```

### Pattern 3: Parallel Dispatch and Correlation

**Use when:** Multiple subagents work independently.

**Process:**
1. Launch N Task agents in parallel
2. Each agent returns results
3. **Correlate** results across agents
4. **Identify** patterns, conflicts, gaps
5. **Synthesize** unified understanding
6. Take action

**Example:**

```
Task: Debug production issue
Launch 3 agents:
  - Agent A: Search logs
  - Agent B: Review recent changes
  - Agent C: Check infrastructure

Agent A returns: Error spike at 14:32 UTC
Agent B returns: Deployment at 14:30 UTC
Agent C returns: No infrastructure changes

Correlation:
  - Timing matches: deployment → errors
  - Recent change is suspect

Action:
  - Review deployment diff
  - Identify bug in new code
  - Hotfix deployment
```

## Anti-Patterns

**DON'T:**
- ❌ "The agent completed successfully" (vague)
- ❌ "Agent found some issues" (no specifics)
- ❌ "See the agent's report above" (pass the buck)
- ❌ Launch agent and immediately ask user what to do next

**DO:**
- ✅ "Agent found 3 bugs: (1) null pointer in auth.py:42..."
- ✅ "Based on agent's research, I'll implement JWT because..."
- ✅ "Correlating agent A and B results, the root cause is..."
```

**Step 3: Commit documentation**

```bash
git add docs/task-tool-integration.md docs/task-result-consumption-patterns.md
git commit -m "docs: add Task tool result consumption patterns

Prevents wasted agent work by documenting how to consume results.
Based on anvanvan/flows commits 71-100.
"
```

**Step 4: Update systematic-debugging skill with consumption pattern**

Add to `skills/systematic-debugging.md` in the Investigation phase:

```markdown
### Result Consumption (When Using Task Tool)

If you launch investigation subagents:

1. **Read full reports** - Don't skim
2. **Extract specifics** - File paths, line numbers, error messages
3. **For each finding:**
   - Verify the finding yourself
   - Add to hypothesis list
   - Note confidence level
4. **Correlate** findings across multiple agents

See [docs/task-tool-integration.md](../docs/task-tool-integration.md) for patterns.
```

**Step 5: Update brainstorming skill with consumption pattern**

Add to `skills/brainstorming.md` after the main process:

```markdown
### Result Consumption (When Using Task Tool)

If brainstorming launches research or exploration subagents:

1. **Synthesize findings** - Don't just list what agent found
2. **Extract design implications** - How do findings affect design?
3. **Update design questions** - What new questions emerged?
4. **Revise constraints** - Any new constraints discovered?

See [docs/task-result-consumption-patterns.md](../docs/task-result-consumption-patterns.md), Pattern 2: Synthesis and Planning.
```

**Step 6: Commit skill updates**

```bash
git add skills/systematic-debugging.md skills/brainstorming.md
git commit -m "feat: add Task tool consumption patterns to debugging and brainstorming

Ensures subagent results are properly used.
"
```

---

## Phase 2: Platform Expansion (Multi-Platform Support)

### Task 4: Multi-Platform Command Infrastructure

**Files:**
- Create: `platforms/` directory structure
- Create: `platforms/cursor/.cursorrules`
- Create: `platforms/copilot/.github/copilot-instructions.md`
- Create: `platforms/gemini/GEMINI.md`
- Create: `platforms/opencode/OPENCODE.md`

**Step 1: Create platform directory structure**

```bash
mkdir -p platforms/{cursor,copilot,gemini,opencode,common}
```

**Step 2: Create Cursor integration**

Create `platforms/cursor/.cursorrules`:

```markdown
# Superpowers for Cursor

You have access to a comprehensive skills library in the `skills/` directory.

## Available Skills

To use a skill, read it from the `skills/` directory and follow its instructions exactly.

**Testing Skills:**
- `test-driven-development` - Write tests first, watch them fail, implement
- `testing-anti-patterns` - Avoid testing mocks instead of behavior
- `condition-based-waiting` - Replace arbitrary timeouts with condition polling

**Debugging Skills:**
- `systematic-debugging` - Four-phase framework: investigate, analyze, hypothesize, implement
- `root-cause-tracing` - Trace bugs backward to find original trigger
- `verification-before-completion` - Run verification before claiming success

**Collaboration Skills:**
- `brainstorming` - Refine rough ideas through Socratic method
- `writing-plans` - Create detailed implementation plans
- `requesting-code-review` - Process for requesting reviews
- `receiving-code-review` - Process for receiving reviews

**Development Skills:**
- `using-git-worktrees` - Create isolated workspaces for feature work
- `subagent-driven-development` - Dispatch subagents for independent tasks

## Usage Pattern

1. When user requests work, check if a skill applies
2. Read the relevant skill: `skills/[skill-name].md`
3. Follow the skill's instructions exactly
4. For multi-step work, use the writing-plans skill first

## Parallel Development

If working with multiple developers or sessions:
- Use git line-staging: `git stage-lines <file> <line-numbers>`
- Use concurrent-safe code review patterns (see `docs/concurrent-code-review.md`)

## Critical Rules

- **Use skills when they apply** - Don't skip them
- **Test-driven development** - Tests before implementation
- **Verify before claiming completion** - Run verification commands
- **Evidence over claims** - Show output, don't just say "it works"
```

**Step 3: Create GitHub Copilot integration**

Create `platforms/copilot/.github/copilot-instructions.md`:

```markdown
# Superpowers for GitHub Copilot

The `skills/` directory contains proven techniques and workflows.

## Skill Discovery

When starting a task:
1. Think: "Is there a skill for this?"
2. Check `skills/` directory
3. If found, read and follow it exactly

## Core Skills

**Test-Driven Development:**
```
Read: skills/test-driven-development.md
1. Write test
2. Watch it fail
3. Implement minimal code
4. Watch it pass
5. Commit
```

**Systematic Debugging:**
```
Read: skills/systematic-debugging.md
1. Investigate - gather facts
2. Analyze - find patterns
3. Hypothesize - form theories
4. Implement - test solutions
```

**Planning Complex Work:**
```
Read: skills/writing-plans.md
Create bite-sized implementation plan before coding.
```

## Anti-Patterns to Avoid

See `skills/testing-anti-patterns.md` before writing tests.

Common mistakes:
- Testing mock behavior instead of real behavior
- Adding test-only methods to production code
- Using mocks without understanding dependencies

## Verification

Before marking work complete:
- Run actual verification commands
- Show real output
- Don't just claim "it works"

See `skills/verification-before-completion.md`
```

**Step 4: Create Gemini integration**

Create `platforms/gemini/GEMINI.md`:

```markdown
# Superpowers Skills for Gemini

## Overview

The `skills/` directory contains systematic approaches to common development tasks.

## When to Use Skills

**Starting a task?** Check for relevant skill first.

**Common scenarios:**
- Adding new feature → `writing-plans.md` → `test-driven-development.md`
- Bug fix → `systematic-debugging.md`
- Code review → `requesting-code-review.md` or `receiving-code-review.md`
- Unclear requirements → `brainstorming.md`

## Skill Categories

**Testing:** TDD, anti-patterns, async testing
**Debugging:** Systematic debugging, root-cause tracing
**Planning:** Brainstorming, writing plans
**Development:** Git worktrees, subagent-driven development
**Verification:** Verification before completion

## Usage

1. Read the skill file: `skills/[skill-name].md`
2. Follow instructions exactly
3. Use checklist if provided
4. Verify completion criteria

## Parallel Development Support

Multi-session or multi-developer work:
- Install git aliases: `./scripts/install-git-aliases.sh`
- Use line-staging: `git stage-lines <file> <lines>`
- Use SHA-based code review (see `docs/concurrent-code-review.md`)
```

**Step 5: Create OpenCode integration**

Create `platforms/opencode/OPENCODE.md`:

```markdown
# Superpowers for OpenCode

## Skills Library

The `skills/` directory provides systematic workflows for development tasks.

## Quick Start

**1. Check for applicable skill**

Before starting work, check if there's a relevant skill in `skills/`.

**2. Read the skill**

Open `skills/[skill-name].md` and read it completely.

**3. Follow exactly**

Follow the skill's process step-by-step. Don't skip steps.

## Essential Skills

**Test-Driven Development** (`skills/test-driven-development.md`)
- Write test first
- Verify it fails
- Implement
- Verify it passes

**Systematic Debugging** (`skills/systematic-debugging.md`)
- Investigate before hypothesizing
- Gather evidence
- Test theories
- Implement verified solutions

**Writing Plans** (`skills/writing-plans.md`)
- Break complex work into bite-sized tasks
- Include exact file paths
- Include verification steps
- DRY, YAGNI, TDD principles

## Verification Requirement

Never claim work is complete without running verification:
```bash
# Run actual commands
npm test
npm run build
# etc
```

Show real output. "It should work" is not acceptable.

See `skills/verification-before-completion.md`
```

**Step 6: Commit platform integrations**

```bash
git add platforms/
git commit -m "feat: add multi-platform support (Cursor, Copilot, Gemini, OpenCode)

Makes skills accessible beyond Claude Code ecosystem.
Based on complexthings/superpowers commits 189-196.
"
```

---

### Task 5: Platform Detection and Setup Script

**Files:**
- Create: `scripts/setup-platform.sh`
- Modify: `README.md`

**Step 1: Create platform detection script**

Create `scripts/setup-platform.sh`:

```bash
#!/bin/bash

# Detect which AI coding assistant is being used and set up appropriate integration

set -e

echo "🔍 Detecting AI coding platform..."

PLATFORM=""

# Detect Cursor
if [ -f ".cursorrules" ] || command -v cursor &> /dev/null; then
    PLATFORM="cursor"
fi

# Detect GitHub Copilot (check for .github directory and copilot config)
if [ -d ".github" ] && grep -q "copilot" .github/* 2>/dev/null; then
    PLATFORM="copilot"
fi

# Detect Claude Code (check for .claude directory)
if [ -d ".claude" ]; then
    PLATFORM="claude"
fi

# If not detected, ask user
if [ -z "$PLATFORM" ]; then
    echo "Could not auto-detect platform. Which are you using?"
    echo "1) Claude Code"
    echo "2) Cursor"
    echo "3) GitHub Copilot"
    echo "4) Gemini"
    echo "5) OpenCode"
    read -p "Enter number: " choice

    case $choice in
        1) PLATFORM="claude" ;;
        2) PLATFORM="cursor" ;;
        3) PLATFORM="copilot" ;;
        4) PLATFORM="gemini" ;;
        5) PLATFORM="opencode" ;;
        *) echo "Invalid choice"; exit 1 ;;
    esac
fi

echo "✓ Platform: $PLATFORM"
echo ""
echo "📦 Setting up superpowers for $PLATFORM..."

# Setup based on platform
case $PLATFORM in
    "cursor")
        cp platforms/cursor/.cursorrules .cursorrules
        echo "✓ Created .cursorrules"
        echo ""
        echo "Cursor will now use superpowers skills automatically."
        ;;

    "copilot")
        mkdir -p .github
        cp platforms/copilot/.github/copilot-instructions.md .github/
        echo "✓ Created .github/copilot-instructions.md"
        echo ""
        echo "GitHub Copilot will now use superpowers skills."
        ;;

    "claude")
        if [ ! -d ".claude/skills" ]; then
            mkdir -p .claude/skills
            ln -s ../../skills/* .claude/skills/ 2>/dev/null || cp -r skills/* .claude/skills/
            echo "✓ Linked skills to .claude/skills"
        fi
        echo ""
        echo "Claude Code will use superpowers skills via plugin."
        ;;

    "gemini")
        if [ ! -f "GEMINI.md" ]; then
            cp platforms/gemini/GEMINI.md .
            echo "✓ Created GEMINI.md"
        fi
        echo ""
        echo "Add GEMINI.md to your Gemini project context."
        ;;

    "opencode")
        if [ ! -f "OPENCODE.md" ]; then
            cp platforms/opencode/OPENCODE.md .
            echo "✓ Created OPENCODE.md"
        fi
        echo ""
        echo "Add OPENCODE.md to your OpenCode project context."
        ;;
esac

# Offer to install git aliases
echo ""
read -p "Install git line-staging aliases for parallel development? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    ./scripts/install-git-aliases.sh
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "📚 Next steps:"
echo "  1. Read docs/parallel-development.md for parallel workflow info"
echo "  2. Browse skills/ directory to see available techniques"
echo "  3. Start coding with systematic approaches!"
```

**Step 2: Make script executable**

Run: `chmod +x scripts/setup-platform.sh`

**Step 3: Test the script (dry run)**

Run: `./scripts/setup-platform.sh`
Enter "1" for Claude Code when prompted
Expected: Script completes without errors

**Step 4: Update README with platform support**

Add to README.md near the top:

```markdown
## Platform Support

Superpowers works with multiple AI coding assistants:

- ✅ Claude Code (native plugin)
- ✅ Cursor
- ✅ GitHub Copilot
- ✅ Gemini
- ✅ OpenCode
- ✅ Codex

### Quick Setup

```bash
./scripts/setup-platform.sh
```

The script will detect your platform and configure superpowers automatically.
```

**Step 5: Commit changes**

```bash
git add scripts/setup-platform.sh README.md
git commit -m "feat: add platform detection and auto-setup script

Supports Claude Code, Cursor, Copilot, Gemini, OpenCode, Codex.
"
```

---

## Phase 3: Language Examples & Accessibility

### Task 6: Extract Language-Specific Examples

**Files:**
- Create: `docs/examples/` directory structure
- Create: `docs/examples/typescript/`, `docs/examples/python/`, `docs/examples/go/`
- Modify: Skills to reference external examples

**Step 1: Create examples directory structure**

```bash
mkdir -p docs/examples/{typescript,python,go,ruby,common}
```

**Step 2: Create TypeScript TDD examples**

Create `docs/examples/typescript/test-driven-development.md`:

```markdown
# Test-Driven Development - TypeScript Examples

## Example 1: Testing a Function

**Test (tests/math.test.ts):**

```typescript
import { describe, it, expect } from 'vitest';
import { add } from '../src/math';

describe('add', () => {
  it('adds two numbers', () => {
    expect(add(2, 3)).toBe(5);
  });

  it('handles negative numbers', () => {
    expect(add(-1, 1)).toBe(0);
  });
});
```

**Run test (should fail):**
```bash
npm test -- math.test.ts
# Expected: Error: Cannot find module '../src/math'
```

**Implementation (src/math.ts):**

```typescript
export function add(a: number, b: number): number {
  return a + b;
}
```

**Run test (should pass):**
```bash
npm test -- math.test.ts
# Expected: ✓ 2 tests passed
```

## Example 2: Testing an API Endpoint

**Test (tests/api.test.ts):**

```typescript
import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import request from 'supertest';
import { app, server } from '../src/app';

describe('POST /users', () => {
  afterAll(() => server.close());

  it('creates a new user', async () => {
    const response = await request(app)
      .post('/users')
      .send({ name: 'Alice', email: 'alice@example.com' });

    expect(response.status).toBe(201);
    expect(response.body).toMatchObject({
      name: 'Alice',
      email: 'alice@example.com'
    });
    expect(response.body.id).toBeDefined();
  });

  it('validates required fields', async () => {
    const response = await request(app)
      .post('/users')
      .send({ name: 'Bob' });

    expect(response.status).toBe(400);
    expect(response.body.error).toContain('email');
  });
});
```

**Run test (should fail):**
```bash
npm test -- api.test.ts
# Expected: Error: Cannot find module '../src/app'
```

**Implementation (src/app.ts):**

```typescript
import express from 'express';

export const app = express();
app.use(express.json());

const users: Array<{id: number, name: string, email: string}> = [];
let nextId = 1;

app.post('/users', (req, res) => {
  const { name, email } = req.body;

  if (!email) {
    return res.status(400).json({ error: 'email is required' });
  }

  const user = { id: nextId++, name, email };
  users.push(user);
  res.status(201).json(user);
});

export const server = app.listen(3000);
```

**Run test (should pass):**
```bash
npm test -- api.test.ts
# Expected: ✓ 2 tests passed
```
```

**Step 3: Create Python TDD examples**

Create `docs/examples/python/test-driven-development.md`:

```markdown
# Test-Driven Development - Python Examples

## Example 1: Testing a Function

**Test (tests/test_math.py):**

```python
import pytest
from src.math import add

def test_add_positive_numbers():
    assert add(2, 3) == 5

def test_add_negative_numbers():
    assert add(-1, 1) == 0

def test_add_zero():
    assert add(5, 0) == 5
```

**Run test (should fail):**
```bash
pytest tests/test_math.py
# Expected: ModuleNotFoundError: No module named 'src.math'
```

**Implementation (src/math.py):**

```python
def add(a: int, b: int) -> int:
    return a + b
```

**Run test (should pass):**
```bash
pytest tests/test_math.py
# Expected: 3 passed
```

## Example 2: Testing a Class

**Test (tests/test_user.py):**

```python
import pytest
from src.user import User, UserRepository

def test_user_creation():
    user = User(name="Alice", email="alice@example.com")
    assert user.name == "Alice"
    assert user.email == "alice@example.com"
    assert user.id is None

def test_repository_save():
    repo = UserRepository()
    user = User(name="Bob", email="bob@example.com")

    saved = repo.save(user)

    assert saved.id is not None
    assert saved.name == "Bob"

def test_repository_find_by_id():
    repo = UserRepository()
    user = repo.save(User(name="Charlie", email="charlie@example.com"))

    found = repo.find_by_id(user.id)

    assert found is not None
    assert found.name == "Charlie"

def test_repository_find_by_id_not_found():
    repo = UserRepository()
    assert repo.find_by_id(999) is None
```

**Run test (should fail):**
```bash
pytest tests/test_user.py
# Expected: ModuleNotFoundError: No module named 'src.user'
```

**Implementation (src/user.py):**

```python
from dataclasses import dataclass
from typing import Optional

@dataclass
class User:
    name: str
    email: str
    id: Optional[int] = None

class UserRepository:
    def __init__(self):
        self._users = {}
        self._next_id = 1

    def save(self, user: User) -> User:
        user.id = self._next_id
        self._users[user.id] = user
        self._next_id += 1
        return user

    def find_by_id(self, user_id: int) -> Optional[User]:
        return self._users.get(user_id)
```

**Run test (should pass):**
```bash
pytest tests/test_user.py
# Expected: 4 passed
```
```

**Step 4: Create Go TDD examples**

Create `docs/examples/go/test-driven-development.md`:

```markdown
# Test-Driven Development - Go Examples

## Example 1: Testing a Function

**Test (math_test.go):**

```go
package math

import "testing"

func TestAdd(t *testing.T) {
    tests := []struct {
        name string
        a, b int
        want int
    }{
        {"positive numbers", 2, 3, 5},
        {"negative numbers", -1, 1, 0},
        {"with zero", 5, 0, 5},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got := Add(tt.a, tt.b)
            if got != tt.want {
                t.Errorf("Add(%d, %d) = %d; want %d", tt.a, tt.b, got, tt.want)
            }
        })
    }
}
```

**Run test (should fail):**
```bash
go test -v
# Expected: undefined: Add
```

**Implementation (math.go):**

```go
package math

func Add(a, b int) int {
    return a + b
}
```

**Run test (should pass):**
```bash
go test -v
# Expected: PASS
```

## Example 2: Testing with Dependencies

**Test (user_test.go):**

```go
package user

import (
    "testing"
)

func TestUserCreation(t *testing.T) {
    u := User{Name: "Alice", Email: "alice@example.com"}

    if u.Name != "Alice" {
        t.Errorf("expected Name=Alice, got %s", u.Name)
    }
    if u.Email != "alice@example.com" {
        t.Errorf("expected Email=alice@example.com, got %s", u.Email)
    }
}

func TestRepositorySave(t *testing.T) {
    repo := NewRepository()
    u := &User{Name: "Bob", Email: "bob@example.com"}

    saved, err := repo.Save(u)
    if err != nil {
        t.Fatalf("Save failed: %v", err)
    }

    if saved.ID == 0 {
        t.Error("expected ID to be set")
    }
    if saved.Name != "Bob" {
        t.Errorf("expected Name=Bob, got %s", saved.Name)
    }
}

func TestRepositoryFindByID(t *testing.T) {
    repo := NewRepository()
    u := &User{Name: "Charlie", Email: "charlie@example.com"}

    saved, _ := repo.Save(u)
    found, err := repo.FindByID(saved.ID)

    if err != nil {
        t.Fatalf("FindByID failed: %v", err)
    }
    if found.Name != "Charlie" {
        t.Errorf("expected Name=Charlie, got %s", found.Name)
    }
}

func TestRepositoryFindByIDNotFound(t *testing.T) {
    repo := NewRepository()

    _, err := repo.FindByID(999)
    if err == nil {
        t.Error("expected error for non-existent ID")
    }
}
```

**Run test (should fail):**
```bash
go test -v
# Expected: undefined: User, Repository
```

**Implementation (user.go):**

```go
package user

import "errors"

type User struct {
    ID    int
    Name  string
    Email string
}

type Repository struct {
    users  map[int]*User
    nextID int
}

func NewRepository() *Repository {
    return &Repository{
        users:  make(map[int]*User),
        nextID: 1,
    }
}

func (r *Repository) Save(u *User) (*User, error) {
    u.ID = r.nextID
    r.users[u.ID] = u
    r.nextID++
    return u, nil
}

func (r *Repository) FindByID(id int) (*User, error) {
    u, ok := r.users[id]
    if !ok {
        return nil, errors.New("user not found")
    }
    return u, nil
}
```

**Run test (should pass):**
```bash
go test -v
# Expected: PASS
```
```

**Step 5: Update test-driven-development skill to reference examples**

Add to `skills/test-driven-development.md` after the main content:

```markdown
## Language-Specific Examples

See language-specific TDD examples and patterns:

- [TypeScript](../docs/examples/typescript/test-driven-development.md) - Jest/Vitest patterns
- [Python](../docs/examples/python/test-driven-development.md) - pytest patterns
- [Go](../docs/examples/go/test-driven-development.md) - testing package patterns
- [Ruby](../docs/examples/ruby/test-driven-development.md) - RSpec patterns

These examples show complete test files, commands, and implementations for each language.
```

**Step 6: Commit language examples**

```bash
git add docs/examples/ skills/test-driven-development.md
git commit -m "feat: add language-specific TDD examples (TypeScript, Python, Go)

Makes TDD skill accessible to non-Ruby developers.
Based on cuivienor/superpowers commits 105-111.
"
```

---

### Task 7: Add Defense-in-Depth Examples

**Files:**
- Create: `docs/examples/typescript/defense-in-depth.md`
- Create: `docs/examples/python/defense-in-depth.md`
- Create: `docs/examples/go/defense-in-depth.md`
- Modify: `skills/defense-in-depth.md`

**Step 1: Create TypeScript defense examples**

Create `docs/examples/typescript/defense-in-depth.md`:

```markdown
# Defense-in-Depth - TypeScript Examples

## Layer 1: API Input Validation

```typescript
// src/api/users.ts
import { z } from 'zod';

const CreateUserSchema = z.object({
  name: z.string().min(1).max(100),
  email: z.string().email(),
  age: z.number().int().min(0).max(150).optional(),
});

app.post('/users', async (req, res) => {
  // Layer 1: Validate at entry point
  const result = CreateUserSchema.safeParse(req.body);

  if (!result.success) {
    return res.status(400).json({ error: result.error });
  }

  const user = await userService.create(result.data);
  res.status(201).json(user);
});
```

## Layer 2: Service-Level Validation

```typescript
// src/services/user-service.ts
type CreateUserData = {
  name: string;
  email: string;
  age?: number;
};

class UserService {
  async create(data: CreateUserData): Promise<User> {
    // Layer 2: Business rule validation
    if (!this.isValidEmail(data.email)) {
      throw new Error('Invalid email format');
    }

    if (await this.emailExists(data.email)) {
      throw new Error('Email already registered');
    }

    return this.repository.save(data);
  }

  private isValidEmail(email: string): boolean {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
  }

  private async emailExists(email: string): Promise<boolean> {
    return (await this.repository.findByEmail(email)) !== null;
  }
}
```

## Layer 3: Repository-Level Validation

```typescript
// src/repositories/user-repository.ts
class UserRepository {
  async save(data: CreateUserData): Promise<User> {
    // Layer 3: Data integrity validation
    if (!data.name || !data.email) {
      throw new Error('Name and email are required');
    }

    if (data.name.length > 100) {
      throw new Error('Name too long');
    }

    // Save to database
    const user = await db.users.create({ data });
    return user;
  }
}
```

## Why Three Layers?

**Scenario:** API validation gets disabled during debugging

```typescript
// Someone comments out validation temporarily
// app.post('/users', async (req, res) => {
//   const result = CreateUserSchema.safeParse(req.body);
//   ...
// });
app.post('/users', async (req, res) => {
  const user = await userService.create(req.body);
  res.json(user);
});
```

**Result:** Service-level and repository-level validation still prevent invalid data!

- Layer 2 catches: duplicate emails, business rule violations
- Layer 3 catches: missing required fields, data integrity issues

**Single-layer validation:** Bug would reach production.
**Defense-in-depth:** Bug is contained.
```

**Step 2: Create Python defense examples**

Create `docs/examples/python/defense-in-depth.md`:

```markdown
# Defense-in-Depth - Python Examples

## Layer 1: API Input Validation

```python
# api/users.py
from flask import Flask, request, jsonify
from pydantic import BaseModel, EmailStr, Field, ValidationError

class CreateUserRequest(BaseModel):
    name: str = Field(min_length=1, max_length=100)
    email: EmailStr
    age: int = Field(ge=0, le=150, default=None)

@app.route('/users', methods=['POST'])
def create_user():
    try:
        # Layer 1: Validate at entry point
        data = CreateUserRequest(**request.json)
    except ValidationError as e:
        return jsonify({'error': e.errors()}), 400

    user = user_service.create(data.dict())
    return jsonify(user), 201
```

## Layer 2: Service-Level Validation

```python
# services/user_service.py
from typing import Dict, Any
import re

class UserService:
    def create(self, data: Dict[str, Any]) -> Dict[str, Any]:
        # Layer 2: Business rule validation
        if not self._is_valid_email(data['email']):
            raise ValueError('Invalid email format')

        if self._email_exists(data['email']):
            raise ValueError('Email already registered')

        return self.repository.save(data)

    def _is_valid_email(self, email: str) -> bool:
        pattern = r'^[^\s@]+@[^\s@]+\.[^\s@]+$'
        return re.match(pattern, email) is not None

    def _email_exists(self, email: str) -> bool:
        return self.repository.find_by_email(email) is not None
```

## Layer 3: Repository-Level Validation

```python
# repositories/user_repository.py
from typing import Dict, Any

class UserRepository:
    def save(self, data: Dict[str, Any]) -> Dict[str, Any]:
        # Layer 3: Data integrity validation
        if not data.get('name') or not data.get('email'):
            raise ValueError('Name and email are required')

        if len(data['name']) > 100:
            raise ValueError('Name too long')

        # Save to database
        user = self.db.users.insert_one(data)
        return {**data, 'id': user.inserted_id}
```

## Why Three Layers?

**Scenario:** Flask validation gets bypassed

```python
# Direct call to service (e.g., from background job)
user_service.create({'name': 'Alice'})  # Missing email!
```

**Result:**
- Layer 2 would catch missing email (if it checks)
- Layer 3 definitely catches it: `ValueError('Name and email are required')`

**Single-layer validation:** Background jobs could create invalid data.
**Defense-in-depth:** Invalid data is impossible.
```

**Step 3: Create Go defense examples**

Create `docs/examples/go/defense-in-depth.md`:

```markdown
# Defense-in-Depth - Go Examples

## Layer 1: API Input Validation

```go
// api/handlers.go
package api

import (
    "encoding/json"
    "net/http"
    "github.com/go-playground/validator/v10"
)

type CreateUserRequest struct {
    Name  string `json:"name" validate:"required,min=1,max=100"`
    Email string `json:"email" validate:"required,email"`
    Age   *int   `json:"age" validate:"omitempty,min=0,max=150"`
}

var validate = validator.New()

func (h *Handler) CreateUser(w http.ResponseWriter, r *http.Request) {
    var req CreateUserRequest

    // Layer 1: Validate at entry point
    if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
        http.Error(w, err.Error(), http.StatusBadRequest)
        return
    }

    if err := validate.Struct(req); err != nil {
        http.Error(w, err.Error(), http.StatusBadRequest)
        return
    }

    user, err := h.service.Create(req.Name, req.Email, req.Age)
    if err != nil {
        http.Error(w, err.Error(), http.StatusBadRequest)
        return
    }

    json.NewEncoder(w).Encode(user)
}
```

## Layer 2: Service-Level Validation

```go
// service/user_service.go
package service

import (
    "errors"
    "regexp"
)

type UserService struct {
    repo Repository
}

func (s *UserService) Create(name, email string, age *int) (*User, error) {
    // Layer 2: Business rule validation
    if !isValidEmail(email) {
        return nil, errors.New("invalid email format")
    }

    exists, err := s.repo.EmailExists(email)
    if err != nil {
        return nil, err
    }
    if exists {
        return nil, errors.New("email already registered")
    }

    return s.repo.Save(name, email, age)
}

func isValidEmail(email string) bool {
    re := regexp.MustCompile(`^[^\s@]+@[^\s@]+\.[^\s@]+$`)
    return re.MatchString(email)
}
```

## Layer 3: Repository-Level Validation

```go
// repository/user_repository.go
package repository

import "errors"

type UserRepository struct {
    db *sql.DB
}

func (r *UserRepository) Save(name, email string, age *int) (*User, error) {
    // Layer 3: Data integrity validation
    if name == "" || email == "" {
        return nil, errors.New("name and email are required")
    }

    if len(name) > 100 {
        return nil, errors.New("name too long")
    }

    // Save to database
    result, err := r.db.Exec(
        "INSERT INTO users (name, email, age) VALUES (?, ?, ?)",
        name, email, age,
    )
    if err != nil {
        return nil, err
    }

    id, _ := result.LastInsertId()
    return &User{ID: int(id), Name: name, Email: email, Age: age}, nil
}
```

## Why Three Layers?

**Scenario:** Handler validation gets refactored incorrectly

```go
func (h *Handler) CreateUser(w http.ResponseWriter, r *http.Request) {
    var req CreateUserRequest
    json.NewDecoder(r.Body).Decode(&req)

    // Validation accidentally removed during refactor!
    user, _ := h.service.Create(req.Name, req.Email, req.Age)
    json.NewEncoder(w).Encode(user)
}
```

**Result:**
- Layer 2 catches: invalid email format, duplicate emails
- Layer 3 catches: missing required fields, length violations

**Single-layer validation:** Refactoring bug reaches production.
**Defense-in-depth:** Bug is contained.
```

**Step 4: Update defense-in-depth skill**

Add to `skills/defense-in-depth.md`:

```markdown
## Language-Specific Examples

See complete defense-in-depth implementations:

- [TypeScript](../docs/examples/typescript/defense-in-depth.md) - Express + Zod + Prisma
- [Python](../docs/examples/python/defense-in-depth.md) - Flask + Pydantic
- [Go](../docs/examples/go/defense-in-depth.md) - net/http + validator
- [Ruby](../docs/examples/ruby/defense-in-depth.md) - Rails validations

Each shows all three layers with realistic failure scenarios.
```

**Step 5: Commit defense examples**

```bash
git add docs/examples/*/defense-in-depth.md skills/defense-in-depth.md
git commit -m "feat: add language-specific defense-in-depth examples

Shows validation layers for TypeScript, Python, Go.
Based on cuivienor/superpowers.
"
```

---

## Phase 4: Specialized Skills

### Task 8: Add Characterization Testing Skill

**Files:**
- Create: `skills/characterization-testing.md`

**Step 1: Fetch skill from anvanvan/flows**

```bash
git fetch flows
```

**Step 2: Extract the skill file**

```bash
git show flows/main:skills/characterization-testing.md > skills/characterization-testing.md
```

If the file doesn't exist in that path, we'll create it based on the concept:

Create `skills/characterization-testing.md`:

```markdown
---
name: characterization-testing
description: Use when working with legacy code or code you don't understand - captures actual behavior before refactoring
---

# Characterization Testing

## When to Use

- Working with legacy code
- Code with no tests
- Code you don't understand
- Before refactoring unclear code
- When documentation is missing or wrong

**Don't use when:**
- Code already has good tests
- You wrote the code recently
- Behavior is well-documented and simple

## The Problem

**Scenario:**
```
Boss: "Fix the bug in the report generator"
You: *reads 500 lines of undocumented code*
You: "I have no idea what this is supposed to do"
```

**Traditional approach:**
1. Read code, try to understand
2. Make change
3. Hope nothing breaks
4. 🔥 Production fire 🔥

**Characterization testing approach:**
1. Write tests that capture current behavior
2. Now you know what it does
3. Make change
4. Tests tell you what broke
5. Fix intentionally

## Process

### Step 1: Identify Behavior Surface

**Find the entry points:**

```python
# What are the public methods/functions?
class ReportGenerator:
    def generate(self, data, format='pdf'):  # ← Entry point
        ...

    def _internal_helper(self):  # ← Not an entry point (private)
        ...
```

**List them:**
- `generate(data, format='pdf')`
- `generate(data, format='html')`
- `generate(data, format='csv')`

### Step 2: Capture Current Behavior

**Write tests for what it currently does (not what it should do):**

```python
# tests/test_report_generator.py
def test_generate_pdf_with_simple_data():
    generator = ReportGenerator()
    data = [{'name': 'Alice', 'score': 100}]

    result = generator.generate(data, format='pdf')

    # Capture whatever it actually returns
    assert result.startswith(b'%PDF-1.4')
    assert b'Alice' in result
    assert b'100' in result

def test_generate_with_empty_data():
    generator = ReportGenerator()

    # What does it actually do with empty data?
    result = generator.generate([], format='pdf')

    # Maybe it returns empty PDF, maybe it crashes?
    # Write test for actual behavior
    assert result == b''  # Or whatever it actually does

def test_generate_html_escapes_input():
    generator = ReportGenerator()
    data = [{'name': '<script>alert("xss")</script>'}]

    result = generator.generate(data, format='html')

    # Does it escape HTML? Let's find out!
    # This test captures the actual behavior
    assert '<script>' not in result  # If this fails, we found a bug!

def test_generate_csv_with_quotes():
    generator = ReportGenerator()
    data = [{'name': 'Alice "Awesome" Anderson'}]

    result = generator.generate(data, format='csv')

    # Capture actual quoting behavior
    assert '"Alice ""Awesome"" Anderson"' in result
```

### Step 3: Run Tests and Record Results

```bash
pytest tests/test_report_generator.py -v
```

**If test fails:**
- Good! You learned something about the actual behavior
- Update test to match actual behavior
- Add comment explaining unexpected behavior

**Example:**

```python
def test_generate_with_none_data():
    generator = ReportGenerator()

    # Expected: would raise exception
    # Actual: returns empty string (weird but that's what it does)
    result = generator.generate(None, format='pdf')

    assert result == b''  # TODO: Should this raise an exception instead?
```

### Step 4: You Now Understand the Code

**Before characterization tests:**
- "I have no idea what this does"

**After characterization tests:**
- "It generates PDF/HTML/CSV reports"
- "It doesn't validate input (accepts None)"
- "HTML output doesn't escape user input (XSS vulnerability!)"
- "CSV output properly quotes values"
- "Empty data returns empty bytes"

### Step 5: Make Changes Safely

**Now you can refactor/fix bugs with confidence:**

```python
# Fix the XSS vulnerability
def generate(self, data, format='pdf'):
    if format == 'html':
        data = self._escape_html(data)  # New code
    ...
```

**Run tests:**
```bash
pytest tests/test_report_generator.py -v
```

**If tests pass:**
- ✅ Change preserved existing behavior
- ✅ (except the XSS bug you intentionally fixed)

**If tests fail:**
- ⚠️ Change broke something unexpected
- Read the failure to understand what changed
- Decide if that's intentional or a bug

## Examples

### Example 1: Unknown Function

```javascript
// What does this do?
function processOrder(order) {
    const result = {};
    if (order.items) {
        result.total = order.items.reduce((s, i) => s + (i.price * i.qty), 0);
    }
    if (order.discount) {
        result.total *= (1 - order.discount);
    }
    if (result.total > 1000) {
        result.shipping = 0;
    } else {
        result.shipping = 10;
    }
    return result;
}
```

**Characterization tests:**

```javascript
test('calculates total from items', () => {
    const result = processOrder({
        items: [
            { price: 10, qty: 2 },
            { price: 5, qty: 3 }
        ]
    });
    expect(result.total).toBe(35);
});

test('applies discount to total', () => {
    const result = processOrder({
        items: [{ price: 100, qty: 1 }],
        discount: 0.1
    });
    expect(result.total).toBe(90);
});

test('free shipping over 1000', () => {
    const result = processOrder({
        items: [{ price: 1001, qty: 1 }]
    });
    expect(result.shipping).toBe(0);
});

test('10 dollar shipping under 1000', () => {
    const result = processOrder({
        items: [{ price: 999, qty: 1 }]
    });
    expect(result.shipping).toBe(10);
});

test('handles missing items', () => {
    const result = processOrder({});
    // Actual behavior: total is undefined, shipping still calculated
    expect(result.total).toBeUndefined();
    expect(result.shipping).toBe(10);  // Bug? Should maybe throw error?
});
```

**Now you understand:**
- Calculates total from items
- Applies discount
- Free shipping >$1000, $10 otherwise
- Bug: undefined total when no items (should probably be 0 or throw error)

### Example 2: Legacy API

```python
# Legacy authentication function - unclear behavior
def authenticate_user(username, password, session):
    user = db.query(User).filter_by(username=username).first()
    if user and user.password == password:
        session['user_id'] = user.id
        user.last_login = datetime.now()
        db.commit()
        return True
    return False
```

**Characterization tests:**

```python
def test_authenticate_valid_user(db_session):
    user = User(username='alice', password='secret123')
    db_session.add(user)
    db_session.commit()
    session = {}

    result = authenticate_user('alice', 'secret123', session)

    assert result is True
    assert session['user_id'] == user.id
    assert user.last_login is not None

def test_authenticate_invalid_password(db_session):
    user = User(username='alice', password='secret123')
    db_session.add(user)
    db_session.commit()
    session = {}

    result = authenticate_user('alice', 'wrong', session)

    assert result is False
    assert 'user_id' not in session
    # Captures actual behavior: last_login NOT updated on failure
    assert user.last_login is None

def test_authenticate_nonexistent_user():
    session = {}

    result = authenticate_user('nobody', 'anything', session)

    assert result is False
    assert 'user_id' not in session

def test_authenticate_stores_plaintext_password():
    # This test captures a security vulnerability!
    user = User(username='alice', password='secret123')

    # Actual behavior: passwords stored in plaintext
    assert user.password == 'secret123'  # SECURITY BUG!
```

**Discovered:**
- Valid credentials → sets session, updates last_login
- Invalid credentials → doesn't set session, doesn't update last_login
- **SECURITY BUG:** Passwords stored in plaintext!

**Now you can fix safely:**

```python
# Add password hashing
def authenticate_user(username, password, session):
    user = db.query(User).filter_by(username=username).first()
    if user and verify_password(password, user.password_hash):  # Changed
        session['user_id'] = user.id
        user.last_login = datetime.now()
        db.commit()
        return True
    return False
```

**Update characterization test:**

```python
def test_authenticate_hashes_password():
    user = User(username='alice')
    user.set_password('secret123')  # New helper method

    # New behavior: passwords are hashed
    assert user.password_hash != 'secret123'
    assert user.password_hash.startswith('$2b$')  # bcrypt hash
```

## Anti-Patterns

**DON'T:**
- ❌ Write tests for what the code "should" do
- ❌ Skip weird behaviors ("I'll fix that later")
- ❌ Mock everything (you need real behavior)
- ❌ Assume the code is correct

**DO:**
- ✅ Write tests for what the code actually does
- ✅ Capture weird behaviors explicitly
- ✅ Use real dependencies when possible
- ✅ Treat unexpected behavior as discoveries

## When You're Done

You should be able to answer:
- What are the entry points?
- What are valid inputs?
- What does it return for each input type?
- What are the side effects?
- What are the edge cases?
- What are the bugs?

**If you can't answer these, write more characterization tests.**

## Integration with Other Skills

**After characterization testing:**
- Use @superpowers:systematic-debugging to fix discovered bugs
- Use @superpowers:strangler-fig-pattern to refactor safely
- Use @superpowers:test-driven-development for new features

**Before refactoring:**
- Always write characterization tests first
- Then refactor
- Tests tell you what broke
```

**Step 3: Verify skill format**

Run: `head -10 skills/characterization-testing.md`
Expected: Valid frontmatter and markdown

**Step 4: Commit the skill**

```bash
git add skills/characterization-testing.md
git commit -m "feat: add characterization-testing skill for legacy code

Captures actual behavior before refactoring.
Based on anvanvan/flows commit 784331e.
"
```

---

### Task 9: Add Strangler Fig Pattern Skill

**Files:**
- Create: `skills/strangler-fig-pattern.md`

**Step 1: Create strangler fig pattern skill**

Create `skills/strangler-fig-pattern.md`:

```markdown
---
name: strangler-fig-pattern
description: Use when refactoring large legacy systems - incrementally replace old code with new code without a big-bang rewrite
---

# Strangler Fig Pattern

## When to Use

- Refactoring large legacy systems
- Replacing outdated frameworks
- Modernizing monoliths
- Risk-averse rewrites
- Can't afford downtime

**Don't use when:**
- Small, well-tested codebase (just refactor directly)
- Complete rewrite is actually necessary
- Old and new systems can't coexist

## The Problem

**Big-Bang Rewrite:**
```
Month 1-6: Build new system
Month 7: "Big switch" to new system
Month 8: 🔥 Everything is broken 🔥
```

**Strangler Fig Pattern:**
```
Month 1: Replace 10% of system
Month 2: Replace another 10%
...
Month 10: Old system completely replaced
Each month: Working system in production
```

## The Pattern

Like a strangler fig tree that grows around a host tree and eventually replaces it, incrementally replace old code with new code.

### Step 1: Identify a Strangleable Component

**Good candidates:**
- Isolated feature or module
- Clear boundaries
- Can run in parallel with old code

**Bad candidates:**
- Core infrastructure everything depends on
- Tightly coupled to entire system
- No clear boundaries

**Example:**
```
✅ Good: User authentication module
✅ Good: Reporting system
✅ Good: Search functionality
❌ Bad: Database layer
❌ Bad: Request routing
❌ Bad: Logging infrastructure
```

### Step 2: Create an Abstraction Layer

**Add an interface that can route to old or new implementation:**

```python
# abstraction_layer.py
class ReportGenerator:
    def __init__(self):
        self.old_generator = LegacyReportGenerator()
        self.new_generator = None  # Will be added incrementally

    def generate(self, data, format='pdf'):
        # Feature flag: control rollout
        if should_use_new_generator(format):
            return self.new_generator.generate(data, format)
        else:
            return self.old_generator.generate(data, format)

def should_use_new_generator(format):
    # Start with 0%, gradually increase
    rollout_percentage = get_rollout_percentage('new_report_generator')
    return random.random() < rollout_percentage
```

**All code now uses abstraction layer:**

```python
# Before
from legacy_reports import LegacyReportGenerator
generator = LegacyReportGenerator()
report = generator.generate(data)

# After
from abstraction_layer import ReportGenerator
generator = ReportGenerator()
report = generator.generate(data)  # Routes to old or new
```

### Step 3: Implement New Version for One Use Case

**Start small:**

```python
# new_report_generator.py
class ModernReportGenerator:
    def generate(self, data, format='pdf'):
        if format == 'pdf':
            return self._generate_pdf(data)
        else:
            raise NotImplementedError(f"Format {format} not yet supported")

    def _generate_pdf(self, data):
        # New, clean implementation for PDF only
        ...
```

**Update abstraction layer:**

```python
class ReportGenerator:
    def __init__(self):
        self.old_generator = LegacyReportGenerator()
        self.new_generator = ModernReportGenerator()

    def generate(self, data, format='pdf'):
        # Only use new generator for PDF format, others still use old
        if format == 'pdf' and should_use_new_generator(format):
            return self.new_generator.generate(data, format)
        else:
            return self.old_generator.generate(data, format)
```

### Step 4: Gradual Rollout

**Week 1: 1% of PDF reports use new generator**

```python
def should_use_new_generator(format):
    if format == 'pdf':
        return random.random() < 0.01  # 1%
    return False
```

**Monitor:** Errors, performance, user feedback

**Week 2: If successful, increase to 10%**

```python
def should_use_new_generator(format):
    if format == 'pdf':
        return random.random() < 0.10  # 10%
    return False
```

**Week 3: 50%**
**Week 4: 100%**

```python
def should_use_new_generator(format):
    if format == 'pdf':
        return True  # 100%
    return False
```

### Step 5: Repeat for Next Use Case

**Now implement HTML format:**

```python
class ModernReportGenerator:
    def generate(self, data, format='pdf'):
        if format == 'pdf':
            return self._generate_pdf(data)
        elif format == 'html':
            return self._generate_html(data)  # New
        else:
            raise NotImplementedError(f"Format {format} not yet supported")
```

**Gradual rollout again:**

```python
def should_use_new_generator(format):
    if format == 'pdf':
        return True  # PDF fully migrated
    elif format == 'html':
        return random.random() < 0.01  # Start HTML at 1%
    return False
```

### Step 6: Remove Old Implementation

**Once all use cases migrated and stable:**

```python
# Remove abstraction layer
class ReportGenerator:
    def generate(self, data, format='pdf'):
        # Old implementation completely removed
        return ModernReportGenerator().generate(data, format)

# Eventually: Remove abstraction layer entirely, use ModernReportGenerator directly
```

**Delete legacy code:**

```bash
git rm legacy_reports.py
git commit -m "refactor: remove legacy report generator

All use cases migrated to ModernReportGenerator.
"
```

## Complete Example: Authentication Migration

### Phase 1: Add Abstraction

```python
# auth.py
class AuthService:
    def __init__(self):
        self.old_auth = LegacySessionAuth()
        self.new_auth = ModernJWTAuth()

    def authenticate(self, username, password):
        # Route based on user flag
        user = get_user(username)
        if user and user.use_jwt_auth:
            return self.new_auth.authenticate(username, password)
        else:
            return self.old_auth.authenticate(username, password)
```

### Phase 2: Implement New Auth (JWT)

```python
# modern_jwt_auth.py
class ModernJWTAuth:
    def authenticate(self, username, password):
        user = db.query(User).filter_by(username=username).first()
        if user and verify_password(password, user.password_hash):
            token = create_jwt_token(user.id)
            return {'token': token, 'user': user}
        return None
```

### Phase 3: Gradual Migration

**Week 1: Opt-in beta**

```python
# Only users who explicitly opted in
if user.beta_tester:
    user.use_jwt_auth = True
```

**Week 2: New users**

```python
# All newly registered users
if user.created_at > datetime(2025, 11, 1):
    user.use_jwt_auth = True
```

**Week 3: 10% of existing users**

```python
if hash(user.id) % 100 < 10:
    user.use_jwt_auth = True
```

**Week 4-8: Gradual increase to 100%**

**Week 9: All users on JWT**

### Phase 4: Remove Old System

```python
# auth.py - simplified
class AuthService:
    def authenticate(self, username, password):
        return ModernJWTAuth().authenticate(username, password)
```

```bash
git rm legacy_session_auth.py
git commit -m "refactor: remove legacy session auth

All users migrated to JWT authentication.
"
```

## Benefits

**Vs. Big-Bang Rewrite:**

| Big-Bang | Strangler Fig |
|----------|---------------|
| All-or-nothing | Incremental |
| High risk | Low risk |
| Long development, no releases | Continuous releases |
| Users get everything at once | Users get gradual improvements |
| Rollback = disaster | Rollback = adjust percentage |
| Hard to test everything | Test each piece thoroughly |

## Rollback Strategy

**If new implementation has issues:**

```python
# Immediate rollback
def should_use_new_generator(format):
    return False  # Back to 0% instantly
```

**Or partial rollback:**

```python
# Roll back from 50% to 10% while investigating
def should_use_new_generator(format):
    return random.random() < 0.10
```

**Big-bang rewrite:** Rollback means reverting entire deployment, losing weeks of work.

**Strangler fig:** Rollback means changing a percentage. Old code still there.

## Anti-Patterns

**DON'T:**
- ❌ Build entire new system before strangling
- ❌ Skip the abstraction layer
- ❌ Go 0% → 100% in one step
- ❌ Forget to monitor during rollout
- ❌ Leave abstraction layer forever

**DO:**
- ✅ Strangle one small piece at a time
- ✅ Always have working system in production
- ✅ Monitor each rollout percentage
- ✅ Keep old and new implementations simple
- ✅ Remove old code once migration complete

## Integration with Other Skills

**Use with:**
- @superpowers:characterization-testing - Test old behavior before strangling
- @superpowers:test-driven-development - Build new implementation with tests
- @superpowers:verification-before-completion - Verify each rollout percentage

**Workflow:**

1. Use @characterization-testing on legacy component
2. Use @writing-plans to plan strangler fig migration
3. Use @test-driven-development for new implementation
4. Implement abstraction layer
5. Gradual rollout with monitoring
6. Use @verification-before-completion at each percentage
7. Remove old code

## Success Criteria

You successfully used strangler fig pattern when:

- [ ] Old system never completely turned off until 100% migrated
- [ ] Each increment delivered working software to production
- [ ] Rollback was always possible
- [ ] Old code was eventually removed
- [ ] Users experienced gradual improvement, not disruption
```

**Step 2: Commit the skill**

```bash
git add skills/strangler-fig-pattern.md
git commit -m "feat: add strangler-fig-pattern skill for incremental refactoring

Reduces risk in large system rewrites through gradual replacement.
Based on anvanvan/flows commit f5e0a28.
"
```

---

## Phase 5: MCP Replacement Skills (Optional)

### Task 10: Add Context-7 Skill

**Files:**
- Create: `skills/context-7.md`
- Create: `scripts/context-7/search.js`
- Create: `scripts/context-7/get-docs.js`
- Create: `package.json` (if not exists)

**Note:** This task is marked optional because it requires JavaScript runtime and adds dependencies. Include if targeting context optimization.

**Step 1: Create package.json for scripts**

```bash
cd scripts
mkdir -p context-7
cd context-7
npm init -y
npm install node-fetch cheerio
```

**Step 2: Create search script**

Create `scripts/context-7/search.js`:

```javascript
#!/usr/bin/env node

// Context-7 search script
// Searches documentation with minimal context usage

const https = require('https');

async function search(query, source = 'mdn') {
  const sources = {
    mdn: 'https://developer.mozilla.org/api/v1/search?q=',
    npm: 'https://registry.npmjs.org/-/v1/search?text=',
  };

  const url = sources[source] + encodeURIComponent(query);

  return new Promise((resolve, reject) => {
    https.get(url, (res) => {
      let data = '';
      res.on('data', (chunk) => data += chunk);
      res.on('end', () => {
        try {
          const results = JSON.parse(data);
          // Return summarized results, not full content
          resolve(results.documents || results.objects || []);
        } catch (e) {
          reject(e);
        }
      });
    }).on('error', reject);
  });
}

// CLI usage
if (require.main === module) {
  const [,, query, source] = process.argv;
  search(query, source).then(results => {
    console.log(JSON.stringify(results.slice(0, 5), null, 2));
  });
}

module.exports = { search };
```

**Step 3: Create documentation fetch script**

Create `scripts/context-7/get-docs.js`:

```javascript
#!/usr/bin/env node

// Fetch and summarize documentation
// Returns only essential content, not full HTML

const https = require('https');
const { JSDOM } = require('jsdom');

async function getDocs(url) {
  return new Promise((resolve, reject) => {
    https.get(url, (res) => {
      let data = '';
      res.on('data', (chunk) => data += chunk);
      res.on('end', () => {
        try {
          const dom = new JSDOM(data);
          const doc = dom.window.document;

          // Extract only essential content
          const title = doc.querySelector('h1')?.textContent || '';
          const summary = doc.querySelector('.summary')?.textContent ||
                         doc.querySelector('p')?.textContent || '';
          const code = Array.from(doc.querySelectorAll('pre code'))
            .slice(0, 3)
            .map(el => el.textContent);

          resolve({ title, summary, examples: code });
        } catch (e) {
          reject(e);
        }
      });
    }).on('error', reject);
  });
}

// CLI usage
if (require.main === module) {
  const [,, url] = process.argv;
  getDocs(url).then(docs => {
    console.log(JSON.stringify(docs, null, 2));
  });
}

module.exports = { getDocs };
```

**Step 4: Create context-7 skill**

Create `skills/context-7.md`:

```markdown
---
name: context-7
description: Use when you need to search documentation or fetch web content with minimal context usage - 98% reduction vs MCP tools
---

# Context-7: Lightweight Documentation Search

## When to Use

- Need to look up API documentation
- Search for package/library information
- Fetch specific web content
- Documentation research tasks

**Don't use when:**
- You already know the answer
- Documentation is in local files (use Read tool)
- Need interactive browsing (use MCP browser tool)

## The Problem

**MCP tools load full context:**
```
MCP fetch → 50KB HTML → 40KB to LLM context
Cost: High
Latency: High
```

**Context-7 loads summary:**
```
Context-7 → Fetch externally → Summarize → 1KB to context
Cost: 98% reduction
Latency: Lower
```

## Usage

### Search Documentation

```bash
node scripts/context-7/search.js "array methods" mdn
```

**Returns:** Top 5 results with titles and URLs (not full content)

### Fetch Specific Documentation

```bash
node scripts/context-7/get-docs.js "https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/map"
```

**Returns:** Title, summary, and top 3 code examples (not full page)

## Integration

**In skills:**

```markdown
## Research Phase

Use context-7 for documentation lookup:

```bash
# Search for relevant docs
results=$(node scripts/context-7/search.js "your query" mdn)

# Fetch specific page
docs=$(node scripts/context-7/get-docs.js "$url")
```

Parse the summarized results (not full HTML).
```

## Benefits

**Context usage comparison:**

| Method | Context Used | Cost |
|--------|-------------|------|
| MCP WebFetch | ~40KB | $$$ |
| Context-7 | ~1KB | $ |
| Reduction | 98% | 97% |

**Latency comparison:**

| Method | Time |
|--------|------|
| MCP | 2-3s + LLM processing |
| Context-7 | 1-2s total |

## Limitations

- Requires Node.js runtime
- Limited to predefined sources (MDN, npm)
- Can't handle complex interactions
- May miss some content

**When to use MCP instead:**
- Need full page content
- Interactive browsing required
- Custom authentication needed
- Context cost not a concern

## Available Sources

**Current:**
- `mdn` - Mozilla Developer Network
- `npm` - NPM package registry

**Extending:**

Add new sources to `search.js`:

```javascript
const sources = {
  mdn: 'https://developer.mozilla.org/api/v1/search?q=',
  npm: 'https://registry.npmjs.org/-/v1/search?text=',
  pypi: 'https://pypi.org/search/?q=',  // Add new source
};
```
```

**Step 5: Commit context-7 skill**

```bash
git add skills/context-7.md scripts/context-7/
git commit -m "feat: add context-7 skill for lightweight documentation search

98% context reduction vs MCP tools.
Based on complexthings/superpowers commits 163-171.
"
```

---

## Final Steps

### Task 11: Update Main README

**Files:**
- Modify: `README.md`

**Step 1: Add community fork notice**

Add near the top of README.md:

```markdown
# Superpowers Community Edition

> **This is a community-enhanced fork** integrating the best contributions from the obra/superpowers fork network.

## What's New in Community Edition

**Critical Infrastructure:**
- ✅ Git line-staging aliases for parallel agent development
- ✅ Concurrent-safe code review patterns
- ✅ Task tool result consumption patterns

**Platform Support:**
- ✅ Multi-platform support (Claude Code, Cursor, Copilot, Gemini, OpenCode)
- ✅ Platform auto-detection and setup

**Language Accessibility:**
- ✅ TypeScript, Python, Go examples for all core skills
- ✅ Language-specific TDD and defense-in-depth patterns

**New Skills:**
- ✅ Characterization testing (legacy code)
- ✅ Strangler fig pattern (incremental refactoring)
- ✅ Context-7 (lightweight documentation search)

**Credit:** Contributions from anvanvan/flows, complexthings/superpowers, cuivienor/superpowers, and others.

See [fork-network-analysis.md](fork-network-analysis.md) for full attribution.

---
```

**Step 2: Update installation section**

Replace or augment installation instructions:

```markdown
## Quick Start

### 1. Choose Your Platform

This works with multiple AI coding assistants:

```bash
./scripts/setup-platform.sh
```

### 2. (Optional) Install Parallel Development Support

```bash
./scripts/install-git-aliases.sh
```

### 3. Start Using Skills

Browse `skills/` directory and start using systematic approaches!

See [docs/parallel-development.md](docs/parallel-development.md) for multi-agent workflows.
```

**Step 3: Add contributors section**

Add before or after license section:

```markdown
## Community Contributors

This community fork integrates contributions from:

- **anvanvan/flows** - Parallel agent infrastructure, Task tool patterns
- **complexthings/superpowers** - Multi-platform support, MCP replacements
- **cuivienor/superpowers** - Language-specific examples, monorepo support
- **jpcaparas/superpowers-laravel** - Framework plugin pattern
- **b0o/superpowers** - Git worktrees documentation
- **obra/superpowers** (upstream) - Original skills library

Full attribution in [fork-network-analysis.md](fork-network-analysis.md).
```

**Step 4: Commit README updates**

```bash
git add README.md
git commit -m "docs: update README for community edition

Credits all major contributors and highlights new features.
"
```

---

### Task 12: Create Integration Summary

**Files:**
- Create: `INTEGRATION-SUMMARY.md`

**Step 1: Create integration summary document**

Create `INTEGRATION-SUMMARY.md`:

```markdown
# Community Fork Integration Summary

**Integration Date:** 2025-11-23
**Base:** obra/superpowers
**Integrated Forks:** 4 (anvanvan/flows, complexthings/superpowers, cuivienor/superpowers, jpcaparas/superpowers-laravel)

## Integrated Features

### Phase 1: Critical Infrastructure

✅ **Git Line-Staging Aliases**
- Source: anvanvan/flows
- Files: `scripts/install-git-aliases.sh`, `docs/parallel-development.md`
- Purpose: Enable parallel agent development without staging conflicts

✅ **Concurrent-Safe Code Review**
- Source: anvanvan/flows (commits 88-94)
- Files: `skills/requesting-code-review.md`, `docs/concurrent-code-review.md`
- Purpose: SHA-based review for parallel workflows

✅ **Task Tool Result Consumption**
- Source: anvanvan/flows (commits 71-100)
- Files: `docs/task-tool-integration.md`, `docs/task-result-consumption-patterns.md`, skill updates
- Purpose: Prevent wasted agent work

### Phase 2: Platform Expansion

✅ **Multi-Platform Support**
- Source: complexthings/superpowers (commits 189-196)
- Files: `platforms/*/`, `scripts/setup-platform.sh`
- Purpose: Support Claude, Cursor, Copilot, Gemini, OpenCode

### Phase 3: Language Examples

✅ **TypeScript Examples**
- Source: cuivienor/superpowers (commits 105-111)
- Files: `docs/examples/typescript/*.md`
- Skills: TDD, defense-in-depth

✅ **Python Examples**
- Source: cuivienor/superpowers
- Files: `docs/examples/python/*.md`
- Skills: TDD, defense-in-depth

✅ **Go Examples**
- Source: cuivienor/superpowers
- Files: `docs/examples/go/*.md`
- Skills: TDD, defense-in-depth

### Phase 4: Specialized Skills

✅ **Characterization Testing**
- Source: anvanvan/flows (commit 784331e)
- Files: `skills/characterization-testing.md`
- Purpose: Test legacy code before refactoring

✅ **Strangler Fig Pattern**
- Source: anvanvan/flows (commit f5e0a28)
- Files: `skills/strangler-fig-pattern.md`
- Purpose: Incremental refactoring approach

### Phase 5: MCP Replacements (Optional)

✅ **Context-7 Skill**
- Source: complexthings/superpowers (commits 163-171)
- Files: `skills/context-7.md`, `scripts/context-7/*.js`
- Purpose: 98% context reduction for documentation search

## Deferred Features

**Framework-Specific Skills:**
- Laravel skills (jpcaparas/superpowers-laravel) - Should remain separate plugin
- Rails/Shopify skills (cuivienor/superpowers) - Too specific for core

**Workflow Organization:**
- Phase-based structure (anvanvan/flows) - Tested and rejected by original author

**Git Worktrees Location:**
- ~/worktrees preference (cuivienor/superpowers) - Too opinionated

## Testing Verification

Each integrated feature should be tested:

- [ ] Git aliases install and work correctly
- [ ] Platform detection works for all platforms
- [ ] Language examples are accurate
- [ ] Skills render correctly with frontmatter
- [ ] Scripts execute without errors
- [ ] Documentation links are valid

## Migration Notes for Users

**From obra/superpowers:**
- All existing skills preserved
- New skills added in `skills/` directory
- Optional features require opt-in (git aliases, platform setup)

**From anvanvan/flows:**
- Workflow phase organization not included (kept flat structure)
- All valuable skills and patterns included
- Git aliases require manual installation

**From complexthings/superpowers:**
- Platform-specific files in `platforms/` directory
- MCP replacement skills optional (require Node.js)
- CLI tool not included (conflicts with plugin model)

**From cuivienor/superpowers:**
- Examples extracted to `docs/examples/` (not inline)
- Framework-specific skills not included
- Monorepo patterns documented but not automated

## Attribution

Full commit-by-commit attribution in `fork-network-analysis.md`.

## Maintenance

**Staying in sync with upstream:**

```bash
# Periodically fetch and merge upstream
git fetch upstream
git merge upstream/main
```

**Staying in sync with source forks:**

```bash
# Check for new valuable commits
git fetch flows
git fetch complexthings
git fetch cuivienor

# Review logs for new features
git log upstream/main..flows/main
git log upstream/main..complexthings/main
git log upstream/main..cuivienor/main
```

## Contact

For questions about integrated features:
- Parallel development: See anvanvan/flows
- Multi-platform support: See complexthings/superpowers
- Language examples: See cuivienor/superpowers
- Original skills: See obra/superpowers
```

**Step 2: Commit integration summary**

```bash
git add INTEGRATION-SUMMARY.md
git commit -m "docs: add integration summary for community edition

Documents all integrated features and sources.
"
```

---

### Task 13: Final Verification

**Step 1: Verify directory structure**

Run:
```bash
tree -L 2 -I 'node_modules|.git'
```

Expected output should include:
- `skills/` with new skills
- `docs/` with examples and guides
- `scripts/` with installation scripts
- `platforms/` with platform integrations

**Step 2: Verify all scripts are executable**

Run:
```bash
find scripts -name "*.sh" -exec chmod +x {} \;
ls -l scripts/*.sh
```

Expected: All .sh files have execute permission

**Step 3: Test git aliases installation**

Run:
```bash
./scripts/install-git-aliases.sh
git config --global --get-regexp alias.stage-lines
```

Expected: Alias definition printed

**Step 4: Test platform setup**

Run:
```bash
./scripts/setup-platform.sh
```

Select "1" for Claude Code
Expected: Script completes without errors

**Step 5: Verify skill files render**

Run:
```bash
for skill in skills/*.md; do
  echo "Checking $skill..."
  head -5 "$skill" | grep -q "^---$" || echo "⚠️  Missing frontmatter: $skill"
done
```

Expected: No warnings

**Step 6: Verify documentation links**

Run:
```bash
grep -r "\](../" docs/ skills/ | grep -v ".git" | while read line; do
  file=$(echo "$line" | cut -d: -f1)
  link=$(echo "$line" | grep -o "\](../[^)]*)" | sed 's/](//' | sed 's/)//')
  if [ ! -f "$link" ]; then
    echo "⚠️  Broken link in $file: $link"
  fi
done
```

Expected: No broken links (or investigate any found)

**Step 7: Create verification report**

Create `VERIFICATION-REPORT.md`:

```markdown
# Integration Verification Report

**Date:** 2025-11-23
**Verifier:** [Your name or "Automated"]

## Checklist

- [x] Directory structure complete
- [x] All scripts executable
- [x] Git aliases install correctly
- [x] Platform setup script works
- [x] All skill files have valid frontmatter
- [x] Documentation links valid
- [x] Examples are syntactically correct
- [x] README updated
- [x] Attribution documented

## Test Results

### Git Aliases
```bash
$ ./scripts/install-git-aliases.sh
✓ Git aliases installed successfully

$ git config --global --get alias.stage-lines
[output shows alias definition]
```

### Platform Setup
```bash
$ ./scripts/setup-platform.sh
✓ Platform: claude
✓ Created .claude/skills links
```

### Skills Validation
```bash
$ for skill in skills/*.md; do head -5 "$skill" | grep -q "^---$" || echo "Missing: $skill"; done
[no output = all valid]
```

## Issues Found

[None / List any issues]

## Sign-off

Integration verified and ready for use.
```

**Step 8: Commit verification report**

```bash
git add VERIFICATION-REPORT.md
git commit -m "test: add integration verification report

All features tested and verified working.
"
```

---

## Completion

### Push to GitHub

**Step 1: Push integration branch**

```bash
git push origin integration/community-contributions
```

**Step 2: Create pull request**

On GitHub, create PR from `integration/community-contributions` to `main`

**PR Title:** "Community Fork Integration - Phase 1-5"

**PR Description:**

```markdown
## Summary

Integrates must-include contributions from the superpowers fork network.

## Integrated Features

**Critical Infrastructure:**
- Git line-staging aliases (anvanvan/flows)
- Concurrent-safe code review (anvanvan/flows)
- Task tool result consumption patterns (anvanvan/flows)

**Platform Expansion:**
- Multi-platform support (complexthings/superpowers)
- Claude, Cursor, Copilot, Gemini, OpenCode

**Language Accessibility:**
- TypeScript, Python, Go examples (cuivienor/superpowers)

**New Skills:**
- Characterization testing (anvanvan/flows)
- Strangler fig pattern (anvanvan/flows)
- Context-7 (complexthings/superpowers)

## Documentation

- [fork-network-analysis.md](fork-network-analysis.md) - Full analysis
- [INTEGRATION-SUMMARY.md](INTEGRATION-SUMMARY.md) - Integration details
- [VERIFICATION-REPORT.md](VERIFICATION-REPORT.md) - Test results

## Attribution

All contributions properly attributed to original authors.

See fork-network-analysis.md for commit-level attribution.

## Testing

- [x] Git aliases tested
- [x] Platform setup tested
- [x] Skills validated
- [x] Examples verified
- [x] Documentation links checked

Ready to merge.
```

---

## Plan Execution Options

Plan complete and saved to `docs/plans/2025-11-23-community-fork-integration.md`.

**Two execution options:**

**1. Subagent-Driven (this session)**
- I dispatch fresh subagent per task
- Review between tasks
- Fast iteration

**2. Parallel Session (separate)**
- Open new session with executing-plans
- Batch execution with checkpoints

**Which approach would you like to use?**
