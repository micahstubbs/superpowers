# Conflict Analysis: Remaining 7 Features vs. Superpowers Reloaded

**Analysis Date:** 2025-11-23
**Current Implementation:** Superpowers Reloaded (phases 1-4)
**Analyzed Features:** 7 remaining deferred features from fork network
**Status:** Detailed conflict assessment for implementation planning

---

## Executive Summary

All 7 remaining features have **LOW to MEDIUM conflict potential** with the current architecture. Most can be integrated with minor architectural adaptations. No fundamental conflicts discovered.

| # | Feature | Conflict Level | Recommendation | Effort |
|---|---------|---|---|---|
| #8 | CLI Tool with Smart Matching | MEDIUM | ADAPT | 2-3 days |
| #9 | Framework Detection Pattern | LOW | IMPLEMENT | 1-2 days |
| #12 | Git Worktrees Documentation | LOW | DOCUMENT-ONLY | 2-4 hours |
| #13 | Monorepo Detection | MEDIUM | IMPLEMENT | 2-3 days |
| #14 | Prompt Creation System | MEDIUM | ADAPT | 2-3 days |
| #15 | When-Stuck Dispatcher | LOW | IMPLEMENT | 1-2 days |
| #16 | Knowledge Lineages | LOW | IMPLEMENT | 1-2 days |

---

## Feature #8: CLI Tool with Smart Matching

**Source:** complexthings/superpowers (commits 185-188, 193-195)
**Key Component:** `superpowers-agent` command with skill discovery via suffix matching

### Current Architecture Context

```
Superpowers Reloaded:
├── Plugin Model (Claude Code native)
│   ├── .claude-plugin/plugin.json (registry)
│   └── Skills auto-discovered by Claude Code
├── Platform-Specific Setup
│   ├── scripts/setup-platform.sh (detection + config)
│   └── Platform files copied to user's project
└── Manual Installation
    └── /plugin install superpowers@superpowers-marketplace
```

### Proposed Feature

```
complexthings/superpowers CLI:
├── Global Installation: curl installer
├── Command: superpowers-agent
├── Features:
│   ├── Skill discovery with suffix matching
│   │   Example: `superpowers-agent tdd` → finds test-driven-development
│   ├── Bootstrap command for setup
│   └── Conditional tool detection
└── Configuration: AGENTS.md template
```

### Conflict Analysis

#### Architectural Conflict: PLUGIN vs CLI

**Current:** Plugin-based (Claude Code native)
```yaml
# Registration
/plugin install superpowers@superpowers-marketplace

# Activation
- SessionStart hook loads skills
- Claude Code auto-discovers skills for tasks
```

**Proposed:** CLI-based
```yaml
# Installation
curl https://... | bash

# Activation
superpowers-agent skill-name [args]
```

**Conflict Type:** DESIGN PHILOSOPHY
- Current: "Skills activate automatically when relevant" (transparent)
- Proposed: "Explicit skill invocation via CLI" (transparent too)
- **Compatibility:** HIGH - Both can coexist

#### Conflict Level: **MEDIUM**

**Issues:**
1. **Duplicate Discovery:** Users might discover same skill via plugin AND CLI
   - CLI duplicates `skill-discovery` work already in plugins
   - Creates two paths to same functionality

2. **Maintenance Burden:** CLI requires separate installation/update logic
   - Plugin uses marketplace (automatic updates)
   - CLI needs curl installer + version management
   - Two different upgrade paths

3. **Platform Mismatch:** CLI assumes global installation
   - Works for Claude Code (native environment)
   - Problematic for Cursor, Copilot, Gemini (different contexts)
   - May not work in containerized/sandbox environments

### Specific Conflicts with Current Code

**File: `.claude-plugin/plugin.json`**
```json
{
  "name": "superpowers",
  "description": "...",
  "version": "3.4.1"
}
```

CLI would need to:
- Read this file to understand version
- Synchronize version with global CLI installation
- Potential version mismatch issues

**File: `scripts/setup-platform.sh`**
```bash
# Current: Platform-specific setup
case $PLATFORM in
  "cursor") cp platforms/cursor/.cursorrules .cursorrules ;;
  "claude") ln -s ../../skills/* .claude/skills/ ;;
esac
```

CLI approach: Assumes Unix-like system with curl, git
- May fail on Windows (MSYS/WSL)
- May fail in restricted network environments
- Current setup-platform.sh handles this via git

**Skill Discovery Logic:**

Current (plugin model):
```yaml
SessionStart Hook → Loads using-superpowers skill
→ Claude Code reads .claude-plugin/plugin.json
→ Claude discovers skills in skills/ directory
→ Skills activate when relevant
```

CLI model:
```yaml
User runs: superpowers-agent test-driven
→ CLI parses "test-driven" (suffix matching)
→ Finds skill: test-driven-development
→ Executes or displays skill
```

**Conflict:** Skill discovery is redundant, but follows different semantics

### Conflict Resolution Path

**Option 1: Parallel Implementations** ✅ RECOMMENDED
- Keep plugin model as primary (automatic, transparent)
- Add CLI tool as secondary (explicit, utility)
- CLI reads same skill database as plugin
- Document as "convenience tool, plugin is recommended"

**Option 2: Merge Approaches**
- Create unified discovery layer: `lib/skill-discovery.js`
- Both plugin and CLI use same discovery logic
- Requires Node.js dependency (currently optional)
- More maintenance but better consistency

**Option 3: CLI Only**
- Deprecate plugin model
- Breaks native Claude Code experience
- NOT RECOMMENDED

### Specific Code Conflicts

**1. Smart Suffix Matching Algorithm**
```javascript
// complexthings: suffix-based discovery
"tdd" → "test-driven-development"
"syst-debug" → "systematic-debugging"
```

**Issue:** What if abbreviation is ambiguous?
- "testing" could match: test-driven-development, testing-anti-patterns, testing-skills-with-subagents
- Need disambiguation logic

**Current:** Plugin avoids this by having Claude interpret context
**CLI:** Needs explicit disambiguation command

**2. Bootstrap Command**
```bash
superpowers-agent bootstrap
```

**Current Equivalent:**
```bash
./scripts/setup-platform.sh
```

**Conflict:** Two different bootstrap approaches
- setup-platform.sh is interactive (asks which platform)
- CLI would need flags: `superpowers-agent bootstrap --platform=cursor`

### Recommendation

**ADAPT** - Implement CLI tool with these constraints:

1. **Make plugin primary, CLI secondary**
   ```
   Primary (automatic): Claude Code plugin
   Secondary (explicit): superpowers-agent CLI
   ```

2. **Use unified skill discovery**
   - Share `lib/skill-discovery.js` between both
   - Avoid code duplication

3. **Platform compatibility**
   - CLI requires Node.js installed globally
   - Document as optional enhancement
   - setup-platform.sh remains standard path

4. **Version synchronization**
   - CLI reads version from `package.json` (if added)
   - Or from `.claude-plugin/plugin.json`
   - Single source of truth for version

5. **Suffix matching with disambiguation**
   ```bash
   superpowers-agent tdd           # Exact match
   superpowers-agent testing       # Ambiguous - shows options
   superpowers-agent testing --choose=1  # Select from list
   ```

---

## Feature #9: Framework Detection Pattern

**Source:** jpcaparas/superpowers-laravel (commits 134-135)
**Key Component:** Automatic environment detection (Sail vs non-Sail) with adaptive commands

### Current Architecture Context

**Current:** Skills are framework-agnostic
```
skills/test-driven-development/SKILL.md
├── Language examples: TypeScript, Python, Go
└── No framework-specific logic
```

**Setup:** Users manually configure for their framework
```
./scripts/setup-platform.sh  # Only handles AI assistant platform
# Users must manually understand their framework
```

### Proposed Feature

```
jpcaparas/superpowers-laravel model:
├── Framework Detection: Is Sail installed?
│   ├── Check: [ -f docker-compose.yml ]
│   └── Check: [ -f sail ]
├── Adaptive Commands:
│   ├── If Sail: ./vendor/bin/sail artisan ...
│   └── If not: php artisan ...
├── Validation & Safety: Interactive confirmation
└── Configuration: Per-app in monorepo context
```

### Conflict Analysis

#### No Architectural Conflict ✅

**Reason:** Detection is additive, not replacement

Current framework handling:
```markdown
# test-driven-development/SKILL.md
Use Jest for TypeScript, pytest for Python, go test for Go
```

Proposed framework handling:
```markdown
# test-driven-development/SKILL.md
Use Jest for TypeScript, pytest for Python, go test for Go

### Laravel-Specific Notes
If you detect Sail via setup script:
- Run tests: ./vendor/bin/sail artisan test
- Run migrations: ./vendor/bin/sail artisan migrate
```

**No conflict:** Proposed adds conditional notes, doesn't replace existing content

#### Detection Mechanism: CRITICAL DESIGN DECISION

**Question:** Where should detection happen?

**Option A: Skills contain detection** (proposed in jpcaparas)
```bash
# Inside skill execution
if [ -f ./vendor/bin/sail ]; then
    ./vendor/bin/sail artisan test
else
    ./vendor/bin/phpunit
fi
```

**Conflict:** Skills become less framework-agnostic
- MEDIUM impact: Makes skills conditional on framework files existing
- Test assumption: What if Sail file exists but isn't installed?

**Option B: Setup script detects framework** (current approach)
```bash
# In setup-platform.sh
if [ -f ./vendor/bin/sail ]; then
    FRAMEWORK_TYPE="laravel-sail"
    export FRAMEWORK_TYPE
fi

# In skill, reference env var
SAIL_COMMAND="${SAIL:-./vendor/bin/sail}"
```

**Advantage:** Skills stay framework-agnostic, config is separate
**Disadvantage:** Requires env var setup step

**Option C: Framework plugin pattern** (jpcaparas model)
```
superpowers/
├── skills/                    (core, framework-agnostic)
├── frameworks/
│   ├── laravel/
│   │   ├── sail-detection.sh
│   │   ├── overrides/
│   │   │   └── test-driven-development.skill.json
│   │   └── skills/
│   │       └── laravel-specific-skill.md
```

**Advantage:** Framework logic completely isolated
**Disadvantage:** More complex file structure

### Conflict Level: **LOW**

**No blocking conflicts**, but requires design decision on where logic lives.

### Specific Code Conflicts

**1. Skill File Structure**

Current: `skills/skill-name/SKILL.md` (flat)

Framework plugin pattern would add: `frameworks/laravel/overrides/test-driven-development.skill.json`

**Conflict:** Dual skill definitions
- Core skill for universal approach
- Framework override for Sail-specific approach

**Resolution:** Use clear naming convention
```
skills/test-driven-development/
├── SKILL.md (core)
└── FRAMEWORKS.md (includes framework-specific notes)
```

**2. Detection Script Location**

**Option A:** `scripts/detect-framework.sh`
```bash
#!/bin/bash
# Detect Laravel/Sail, Rails, etc.
```

**Option B:** `frameworks/detect.sh`
```bash
#!/bin/bash
# Modular detection per framework
```

**Current:** `scripts/setup-platform.sh` (platform, not framework)

**Recommendation:** New dedicated script
```
scripts/setup-framework.sh  (separate from setup-platform.sh)
└── Calls detect-*: frameworks/laravel/detect.sh, etc.
```

**3. Environment Variable Pollution**

Framework detection would export:
```bash
export FRAMEWORK_TYPE="laravel-sail"
export SAIL_COMMAND="./vendor/bin/sail artisan"
export TEST_RUNNER="./vendor/bin/sail artisan test"
```

**Conflict:** Skills might expect these without setup
- User clones repo, runs skill
- Detection hasn't run yet
- Script fails

**Resolution:**
- Detection is optional (assume non-Sail if not detected)
- Document setup flow clearly
- Consider lazy detection (run on-demand)

### Recommendation

**IMPLEMENT** - Framework detection with these guidelines:

1. **Keep detection modular**
   ```
   scripts/setup-framework.sh
   └── frameworks/*/detect.sh (one per framework)
   ```

2. **Use FRAMEWORKS.md in skills**
   ```
   skills/test-driven-development/
   ├── SKILL.md (core, universal)
   └── FRAMEWORKS.md (framework-specific notes & commands)
   ```

3. **Make detection optional**
   - Assume non-specialized environment if not detected
   - Let user override via environment variables
   - Don't fail if detection can't run

4. **Start with Laravel pattern**
   - jpcaparas already proved the approach works
   - Can extend to Rails, Django, etc. later

5. **Document in skills**
   ```markdown
   ### Laravel (using Sail)
   If detected:
   ```bash
   git config --show-origin --get-all skill.test-runner
   # Should show: ./vendor/bin/sail artisan test
   ```

---

## Feature #12: Git Worktrees Documentation

**Source:** b0o/superpowers (commits 124-126)
**Key Component:** Documentation clarifying bare vs non-bare repo workflows, cd persistence

### Current State

**File:** `skills/using-git-worktrees/SKILL.md`
**Length:** ~150 lines
**Content:** Basic git worktree workflow

**Current Documentation Issue:**
```markdown
# Using Git Worktrees

Create isolated workspaces for feature branches:

$ git worktree add ~/worktrees/my-feature
```

**Problem:** Doesn't address common pitfall
```bash
$ cd ~/worktrees/my-feature
$ pwd
/home/user/worktrees/my-feature

# Exit subshell
$ pwd
/home/user (BACK TO ORIGINAL DIRECTORY!)
# cd doesn't persist because it's a subshell
```

### Proposed Feature

**Problem Identified:** The cd to worktree directory doesn't persist outside the subshell
**Solution Options Documented:**

1. **Bare Repository Approach** ✅ BEST
   ```bash
   git init --bare ~/projects/repo.git
   cd ~/projects/repo.git
   git worktree add ~/worktrees/feature
   cd ~/worktrees/feature  # This WILL persist
   ```

2. **Wrapper Script**
   ```bash
   worktree() {
       cd ~/worktrees/$1
   }
   ```

3. **Terminal Tab/Pane**
   ```bash
   # Use tmux/screen to maintain separate shell
   tmux new-window -c ~/worktrees/feature
   ```

### Conflict Analysis

#### **NO ARCHITECTURAL CONFLICT** ✅

This is purely **documentation enhancement**, not code change.

**Current Skill:** Describes worktree creation but misses the cd persistence issue
**Proposed Enhancement:** Explain why cd doesn't persist and provide solutions

**No code needs to change:**
- No new scripts
- No new commands
- No new configuration
- Just better documentation

### Conflict Level: **NONE**

**However:** There IS a subtle point that could conflict with current skill usage:

**Current Code Assumption:**
```markdown
# Current SKILL.md
$ git worktree add ~/worktrees/my-feature
$ cd ~/worktrees/my-feature
[Now in worktree... do work...]
```

**This APPEARS to work in interactive shells** because:
- User manually types `cd`
- User stays in that shell
- Shell prompt shows worktree path

**But in scripts:**
```bash
#!/bin/bash
git worktree add ~/worktrees/my-feature
cd ~/worktrees/my-feature  # THIS DOESN'T PERSIST
git status  # Running in ORIGINAL directory!
```

**Current SKILL.md doesn't explicitly warn about this**, so users might copy-paste into scripts and have failures.

**Proposed enhancement prevents this confusion.**

### Specific Documentation Conflicts

**None.** This is purely additive documentation.

**Current content remains valid**, we're just adding:
1. Explanation of the cd persistence issue
2. When it matters (scripts vs interactive)
3. Solutions for different use cases

### Recommendation

**DOCUMENT-ONLY** - Update `skills/using-git-worktrees/SKILL.md`:

1. **Add section: "Important: Directory Changes in Scripts"**
   ```markdown
   ### ⚠️ Important: Directory Changes Don't Persist in Scripts

   When running git worktree commands in bash scripts, changes to the
   current directory don't persist after the script exits:

   ❌ **Won't work in scripts:**
   ```bash
   #!/bin/bash
   git worktree add ~/worktrees/feature
   cd ~/worktrees/feature  # This doesn't persist
   npm test  # Runs in ORIGINAL directory, not worktree!
   ```

   ✅ **Better approach:**
   ```bash
   #!/bin/bash
   cd ~/worktrees/feature &&\
   npm test
   ```

   Or use a bare repository (see below).
   ```

2. **Add section: "Bare Repository Pattern"**
   ```markdown
   ### Using Bare Repositories (Recommended)

   For larger projects, use a bare repository as the main repo:

   **Setup:**
   ```bash
   git init --bare ~/projects/repo.git
   cd ~/projects/repo.git
   git worktree add ~/worktrees/main
   ```

   **Advantages:**
   - Main worktree (~/worktrees/main) is where you actually work
   - Other worktrees for features/branches
   - Directory changes persist correctly
   - No confusion about "where is the repo?"
   ```

3. **Add troubleshooting section**
   ```markdown
   ### Troubleshooting

   **Q: I cd'd to the worktree but I'm back in the original directory**
   A: This is normal. The `cd` is a subshell command. Either:
   - Use bare repository pattern (recommended)
   - Use `cd && command` in scripts
   - Keep shell open in that directory
   ```

---

## Feature #13: Monorepo Detection

**Source:** cuivienor/superpowers (commit 129), jpcaparas/superpowers-laravel (commit 129)
**Key Component:** Multi-app detection in monorepos, scoped command execution

### Current Architecture Context

**Current Assumption:** Single app per repository
```
repository/
├── src/
├── package.json
└── tests/
```

**Current Skills:** Don't address monorepo structure
```
skills/test-driven-development/SKILL.md
# Assumes: run `npm test` in repo root
# Reality: Large monorepos have multiple apps, need scoped test runs
```

### Proposed Feature

**Problem:** Monorepos need app-scoped execution
```
monorepo/
├── apps/
│   ├── web/              ← Frontend app
│   │   ├── package.json
│   │   └── tests/
│   ├── api/              ← Backend app
│   │   ├── package.json
│   │   └── tests/
│   └── mobile/           ← Mobile app
│       ├── package.json
│       └── tests/
├── packages/             ← Shared packages
│   ├── ui-components/
│   └── utils/
```

**Solution:** Detect which app(s) changed, run tests for those apps only

### Conflict Analysis

#### Architectural Conflict: **SCOPE AWARENESS**

**Current:** Skills assume single scope
```markdown
# test-driven-development/SKILL.md
1. Write test
2. Run: `npm test`
3. Verify it fails
4. Write code
5. Run: `npm test` again
6. Verify it passes
```

**Proposed:** Skills need to be scope-aware
```markdown
# test-driven-development/SKILL.md
1. Detect app scope (which app are we working on?)
2. Write test in: apps/web/tests/...
3. Run: `npm --workspace=web test`  (or `turbo run test --scope=web`)
4. Verify it fails
... continue ...
```

**Conflict Type:** SKILL LOGIC CHANGE

Skills would need:
- Scope detection logic (is this a monorepo? which app are we in?)
- Conditional command execution (use --workspace vs no flag)
- Path navigation (tests might be in different locations)

**Impact Level:** MEDIUM

**Not a blocker**, but requires:
1. Updating skills to handle both single-app and multi-app
2. Documentation for monorepo patterns
3. Optional configuration per monorepo

#### Conflict Level: **MEDIUM**

### Specific Code Conflicts

**1. Test Runner Detection**

**Current implementation (in skills):**
```bash
if [ -f package-lock.json ]; then
    npm test
elif [ -f yarn.lock ]; then
    yarn test
fi
```

**Monorepo detection adds:**
```bash
# First detect monorepo structure
if [ -d "apps" ] && [ -d "packages" ]; then
    MONOREPO_TYPE="workspace"  # npm workspaces
elif [ -f "turbo.json" ]; then
    MONOREPO_TYPE="turbo"
elif [ -f "pnpm-workspace.yaml" ]; then
    MONOREPO_TYPE="pnpm"
else
    MONOREPO_TYPE="single"
fi

# Then adapt commands
case $MONOREPO_TYPE in
    "workspace")
        npm --workspace=DETECTED_APP test
        ;;
    "turbo")
        turbo run test --scope=DETECTED_APP
        ;;
    "single")
        npm test
        ;;
esac
```

**Conflict:** Complex conditional logic in skills
**Current approach:** Simple, assumes single app
**Proposed approach:** Must handle 4+ different monorepo patterns

**2. Scope Detection Algorithm**

**Question:** How to detect "current app scope"?

**Option A: Use git**
```bash
# Changed files are in which app?
git diff HEAD~1 --name-only | grep -o '^[^/]*' | sort -u
# Returns: "apps/web" or "packages/ui-components"
```

**Option B: Use CWD**
```bash
# Current directory indicates scope
PWD=/project/apps/web → scope=web
```

**Option C: User specifies**
```bash
SCOPE=web npm test
# Or: npm test -- --scope=web
```

**Conflict:** No universal solution
- Git approach works for CI/CD
- CWD approach works for interactive use
- User-specified is error-prone

**Current skills don't support options**, would need to be added

**3. Skills Need Monorepo Documentation**

**Current file structure:**
```
skills/test-driven-development/
└── SKILL.md  (~200 lines, everything in one file)
```

**With monorepo support:**
```
skills/test-driven-development/
├── SKILL.md (core TDD)
├── MONOREPO.md (monorepo-specific patterns)
└── examples/
    ├── single-app.md
    └── monorepo-turbo.md
```

**Conflict:** File organization gets more complex

### Specific Conflicts with Current Code

**File: `skills/test-driven-development/SKILL.md`**

Example command in skill:
```markdown
## Step 2: Run the Test

```bash
npm test
```

Expected output: ✅ PASS or ❌ FAIL
```

**Problem in monorepo:**
```bash
# In monorepo, this runs ALL app tests, not just current one
npm test
# Runs: test for web, api, mobile, ui-components, utils (~5 minutes)
# We only need: test for web (~1 minute)
```

**Solution needed:**
```markdown
## Step 2: Run the Test

```bash
# Single app repository
npm test

# Monorepo (npm workspaces)
npm --workspace=web test

# Monorepo (turbo)
turbo run test --scope=web
```

### Recommendation

**IMPLEMENT** - Add monorepo support with these design constraints:

1. **Keep skills single-app by default**
   - Current skills use simple `npm test`
   - Works for single-app repos (90% of cases)
   - No complexity added for simple cases

2. **Add optional monorepo detection**
   ```
   scripts/detect-monorepo.sh
   └── Sets MONOREPO_TYPE and CURRENT_APP env vars
   ```

3. **Create MONOREPO.md in skills that need it**
   ```
   skills/test-driven-development/
   ├── SKILL.md (core, single-app assumed)
   └── MONOREPO.md (alternative for monorepo users)
   ```

4. **Support 3 monorepo patterns minimum**
   - npm workspaces: `npm --workspace=app test`
   - turbo: `turbo run test --scope=app`
   - pnpm workspaces: `pnpm --filter=app test`

5. **Document user responsibility**
   ```markdown
   **Monorepo Users:** If this is a monorepo, you may need to:
   1. Set SCOPE environment variable
   2. Or modify commands to include --workspace or --scope flags
   3. See MONOREPO.md for details
   ```

6. **Optional automation**
   ```bash
   # If user runs setup-framework.sh or setup-monorepo.sh
   detect-monorepo.sh
   export MONOREPO_TYPE=turbo
   export CURRENT_APP=$(detect-app-from-git-changes)
   ```

---

## Feature #14: Prompt Creation System

**Source:** complexthings/superpowers (commits 137-144)
**Key Component:** `/meta-prompt` command with templates for prompt types (do/plan/research/refine)

### Current Architecture Context

**Current Approach:** Skills and commands live in repository
```
.claude/commands/
├── brainstorm.md
├── write-plan.md
└── execute-plan.md

skills/
├── brainstorming/
├── writing-plans/
└── executing-plans/
```

**Current Problem:** No system for CREATING new custom prompts
- Users read skills
- Users create their own prompts manually
- No templates or guidance

### Proposed Feature

**Solution: Prompt creation framework**
```bash
/meta-prompt
# Shows menu of prompt types:
# 1. do - Task execution prompt
# 2. plan - Implementation planning prompt
# 3. research - Investigation prompt
# 4. refine - Refinement/review prompt
```

**Templates for each type:**

1. **do - Task Execution Prompt**
   ```markdown
   # Task: [Name]

   ## Context
   [Provide context]

   ## Requirements
   - [What must be done]
   - [Success criteria]

   ## Steps
   1. [First step]
   2. [Second step]
   ```

2. **plan - Implementation Planning Prompt**
   ```markdown
   # Plan: [Feature Name]

   ## Design
   [Architectural approach]

   ## Tasks
   1. [Task 1]
   2. [Task 2]
   ```

3. **research - Investigation Prompt**
   ```markdown
   # Research: [Topic]

   ## Questions
   - [Question 1]
   - [Question 2]
   ```

4. **refine - Review Prompt**
   ```markdown
   # Review: [Subject]

   ## Criteria
   - [Criterion 1]
   - [Criterion 2]
   ```

### Conflict Analysis

#### **NO ARCHITECTURAL CONFLICT** ✅

**Reason:** This is purely a USER CONVENIENCE FEATURE

- Doesn't change how skills work
- Doesn't change how Claude Code works
- Just provides templates for manual prompt creation
- Users can ignore it and create prompts manually

**Current:** Users create custom prompts by hand
**Proposed:** Users create custom prompts using templates

**No code needs to change, just templates added.**

#### Conflict Level: **MEDIUM** (Due to Implementation Details)

**Why "MEDIUM" if no architectural conflict?**

**Issue 1: Command vs Skill vs Template**

```
Option A: Implement as Slash Command
/meta-prompt
└── Works in Claude Code, maybe not other platforms

Option B: Implement as Skill
/superpowers:meta-prompt
└── Works in all platforms, but less intuitive

Option C: Implement as Template Files
docs/prompt-templates/
├── do-prompt.md
├── plan-prompt.md
├── research-prompt.md
└── refine-prompt.md
└── Users copy and modify manually
```

**Current:** Superpower uses slash commands that wrap skills

**Conflict:** Where should this feature live?
- As command: `/meta-prompt` (less discoverable)
- As skill: Called when user wants to create prompts (makes sense)
- As templates: Just documentation (simplest)

**Issue 2: Interactive vs Static**

**Proposed (complexthings):** Interactive command
```bash
/meta-prompt
# Shows menu, user selects type
# Generates prompt template in editor
```

**Alternative:** Static templates
```
docs/prompt-templates/
├── do-prompt.md
├── plan-prompt.md
# User copies, fills in, uses
```

**Conflict:** Interactive requires command implementation
- Claude Code supports `/` commands
- Cursor, Copilot might not have equivalent
- Interactive UX harder to maintain across platforms

**Issue 3: Configuration System**

**Proposed (complexthings):** Centralized config
```bash
# get-config command
/meta-prompt --config=project

# Reads: AGENTS.md
# Uses configured details in template
```

**Current:** No centralized config system
- Skills are independent
- Users provide context each time

**Conflict:** Adding config system creates dependency
- AGENTS.md becomes required for prompts to work well
- Without it, templates are generic

### Specific Code Conflicts

**1. Command Implementation**

**Current slash command structure:**
```yaml
.claude/commands/brainstorm.md
---
name: superpowers:brainstorm
description: Interactive design refinement using Socratic method
---

## How to Use

[Instructions that invoke the skill]
```

**Proposed meta-prompt command:**
```yaml
.claude/commands/meta-prompt.md
---
name: superpowers:meta-prompt
description: Generate custom prompt templates
---

## How to Use

1. Select prompt type: do/plan/research/refine
2. [Generate template]
3. [Edit in your editor]
```

**Conflict:** No conflict, same pattern as existing commands

**2. Configuration Dependency**

**Proposed config approach:**
```yaml
# AGENTS.md (or .superpowers-config)
project_name: My Project
team: AI Engineering
tools: Claude, Cursor, GitHub Copilot
frameworks: Node.js, React, TypeScript
```

**Used in templates:**
```markdown
# Task: {{project.name}} - [Task]

## Team Context
Working with {{team}}, using {{tools}}

## Technical Stack
{{frameworks}}
```

**Current:** Skills don't assume config exists

**Conflict:** Creating config dependency
- Some users might not want to create AGENTS.md
- Prompts should work without it (fallback templates)

**3. Template Storage**

**Option A: In repository (complexthings approach)**
```
.superpowers/
├── templates/
│   ├── do-prompt.md
│   ├── plan-prompt.md
│   └── refine-prompt.md
└── meta-prompt/
    └── generator.js
```

**Option B: In documentation**
```
docs/prompt-templates/
├── do-prompt.md
├── plan-prompt.md
└── refine-prompt.md
```

**Option C: Both (hybrid)**
```
docs/prompt-templates/     (for reading/understanding)
.superpowers/templates/    (for tooling/generation)
```

**Current:** No template system exists

**Conflict:** Where should templates live?
- If in .superpowers/: Needs tooling to generate
- If in docs/: Users find and copy manually
- If both: Maintenance burden

### Recommendation

**ADAPT** - Implement with these design constraints:

**Choice: Start with Documentation Templates (Low Complexity)**

1. **Create template documentation**
   ```
   docs/prompt-templates/
   ├── README.md (explains each type)
   ├── do-task.md (task execution)
   ├── plan-feature.md (implementation planning)
   ├── research-topic.md (investigation)
   └── refine-code.md (review/refinement)
   ```

2. **Make templates self-contained**
   ```markdown
   # DO PROMPT: Task Execution

   Copy this template and fill in the [bracketed] sections:

   ---

   # Task: [What needs to be done?]

   ## Context
   [Why is this needed? What's the background?]

   ## Requirements
   - [Must have X]
   - [Must have Y]
   - [Success looks like Z]

   [... rest of template ...]
   ```

3. **No configuration system required initially**
   - Templates are generic but clear
   - Users fill in their specific details
   - No AGENTS.md dependency

4. **Optional: Add command later**
   ```
   If demand grows:
   /superpowers:create-prompt
   └── Guides users through template selection
   └── Can be added in future phase
   ```

5. **Link from README**
   ```markdown
   ## Creating Custom Prompts

   Use our prompt templates as starting points:
   - [DO Prompt Template](docs/prompt-templates/do-task.md)
   - [PLAN Prompt Template](docs/prompt-templates/plan-feature.md)
   - [RESEARCH Prompt Template](docs/prompt-templates/research-topic.md)
   - [REFINE Prompt Template](docs/prompt-templates/refine-code.md)
   ```

6. **Future: Interactive command**
   ```
   Once templates prove useful:
   /superpowers:create-prompt type=do
   └── Opens template in editor
   └── Potentially uses AGENTS.md config if available
   ```

---

## Feature #15: When-Stuck Dispatcher

**Source:** anvanvan/flows (commits 33-36, referenced in fork analysis)
**Key Component:** Dispatcher for when AI development gets blocked/stuck

### Current Architecture Context

**Current:** No explicit "stuck" handling
```
Existing skills handle:
- TDD: Write test, implement, refactor
- Debugging: Systematic 4-phase approach
- Planning: Break down tasks
- Collaboration: Code review, parallel work

Missing: "What do I do when NONE of these work and I'm stuck?"
```

### Proposed Feature

**Problem Solved:** Development gets stuck, what now?

**Example scenarios:**
```
1. Error that doesn't match any known pattern
   → Try: systematic-debugging skill
   → Still stuck: Try when-stuck dispatcher

2. Task is too big/complex
   → Try: writing-plans skill
   → Still stuck: Try when-stuck dispatcher

3. Multiple conflicting requirements
   → Try: brainstorming skill
   → Still stuck: Try when-stuck dispatcher

4. Don't know which skill applies
   → Try: when-stuck dispatcher
   → Guides to appropriate skill or new approach
```

### Conflict Analysis

#### **NO ARCHITECTURAL CONFLICT** ✅

**Reason:** This is a new meta-skill, doesn't change existing ones

**Current:** Skills handle specific problems
**Proposed:** Meta-dispatcher for "unsolved problems"

**No conflicts with existing code.**

**However:** There IS a SEMANTIC ISSUE

#### Conflict Level: **LOW** (Design consideration, not implementation blocker)

### Specific Design Conflicts

**1. Dispatcher vs Brainstorming Overlap**

**Current brainstorming skill:**
```
Problem: Need to design solution to problem
Approach: Socratic method, question-based refinement
```

**Proposed when-stuck skill:**
```
Problem: I'm stuck and don't know what to do
Approach: Diagnostic questions, route to right skill
```

**Question:** When should user use brainstorming vs when-stuck?

**Brainstorming:** "I need to design X"
**When-stuck:** "I don't know what to do"

**Conflict:** Overlap in scenarios like:
- "I tried everything but still can't solve problem"
- "I'm stuck designing the solution"

**Resolution:** Clear scope separation
```
Brainstorming: "I know WHAT problem to solve, need to design HOW"
When-stuck: "I don't even know WHICH problem is the real issue, or what approach to try"
```

**2. Dispatcher vs Systematic Debugging Overlap**

**Current systematic debugging:**
```
Phase 1: Root Cause Investigation
Phase 2: Pattern Analysis
Phase 3: Hypothesis Testing
Phase 4: Implementation
```

**Proposed when-stuck:**
```
Diagnosis: What type of stuck are you?
├── Stuck on error → systematic-debugging
├── Stuck on design → brainstorming
├── Stuck on planning → writing-plans
├── Stuck on code review → receiving-code-review
└── Unknown what to do → [new approach needed]
```

**Conflict:** When-stuck includes systematic-debugging as one option

**But:** What if user has already tried systematic-debugging?

**Resolution:** Document decision tree more clearly
```
IF you have error message AND haven't tried systematic-debugging:
    Use: systematic-debugging

IF you tried systematic-debugging AND error is still unsolved:
    Use: when-stuck (ask for alternative approaches)

IF you don't have error message (stuck on design/architecture):
    Use: brainstorming
```

**3. Reducer vs Expander Problem**

**When-stuck could expand to infinite options:**

```
"I'm stuck"
├── What type of problem?
│   ├── Error/bug
│   ├── Design question
│   ├── Performance issue
│   ├── Documentation question
│   ├── Deployment issue
│   ├── Team coordination issue
│   └── "Other - tell me more"
```

**Risk:** Skill becomes too generic, not actionable

**Current when-stuck in anvanvan/flows:** No commit available to review exact implementation

**Design consideration:** Keep scope focused
- when-stuck is dispatcher, not solver
- Routes to specialized skills
- "Other" branch suggests documenting new use case (feedback loop)

### Recommendation

**IMPLEMENT** - Add when-stuck dispatcher with these constraints:

1. **Clear Scope: Diagnostic and Routing Only**
   ```markdown
   # When-Stuck Dispatcher

   When you don't know which skill to use or what to do:

   ## Questions to Narrow Down

   1. Do you have an error message?
      YES → Use: systematic-debugging
      NO → Continue to Q2

   2. Do you know what to build, but not how?
      YES → Use: brainstorming
      NO → Continue to Q3

   3. Is the work too big to hold in your head?
      YES → Use: writing-plans
      NO → Continue to Q4

   4. Are you waiting for feedback on your code?
      YES → Use: receiving-code-review
      NO → Continue to Q5

   5. Still stuck?
      Report issue: [link to issues]
      Describe: What did you try? What happened?
   ```

2. **Integration with existing skills**
   - No code changes to existing skills
   - when-stuck just routes to them
   - Includes exit strategies (when to ask for help)

3. **Feedback collection**
   - "Still stuck" option collects info about new use cases
   - Informs future skill development
   - Prevents skill scope creep

4. **Keep it simple**
   - Maximum 5-6 decision branches
   - No sub-branches within sub-branches
   - Encourage skill combination (e.g., brainstorming + writing-plans)

5. **Document in help**
   ```markdown
   ## Getting Unstuck

   If you feel stuck and don't know which skill to use:

   /superpowers:when-stuck

   This dispatcher will ask diagnostic questions to guide you to:
   - systematic-debugging (for errors)
   - brainstorming (for design issues)
   - writing-plans (for complex tasks)
   - receiving-code-review (for feedback)

   If none of these work, please report the situation.
   ```

---

## Feature #16: Knowledge Lineages

**Source:** anvanvan/flows (referenced in fork analysis)
**Key Component:** Documentation system for tracking decision history and context lineages

### Current Architecture Context

**Current:** Skills document HOW to do things, not WHY decisions were made

```
skills/test-driven-development/SKILL.md
- Explains the RED-GREEN-REFACTOR cycle
- Shows examples
- But doesn't explain why TDD was chosen over other testing approaches
```

**Missing context:**
```
Historical decisions:
- WHY is characterization-testing important? (Legacy code context)
- WHY strangler-fig pattern? (Incremental refactoring context)
- WHY parallel agents? (Multi-developer context)
- WHY concurrent-safe code review? (Git scaling issues)
```

### Proposed Feature

**Problem Solved:** Understanding decision lineages

**What it enables:**
```
User reads: test-driven-development skill
Sees note: "Based on decision from parallel-development context"
Clicks: Sees full decision lineage
├── Problem: Multiple developers working on same codebase
├── Context: Git conflicts on sequential commits
├── Decision: Use git line-staging for fine-grained control
├── Trade-offs: More complex, better parallelism
└── Alternatives considered: [links to rejected approaches]
```

### Conflict Analysis

#### **NO ARCHITECTURAL CONFLICT** ✅

**Reason:** This is documentation/metadata, not code change

**Current:** Skills are standalone
**Proposed:** Skills include decision context

**No changes to skill execution, just enriched documentation.**

#### Conflict Level: **LOW** (Metadata/Documentation Only)

### Specific Implementation Considerations

**1. Metadata Format**

**Option A: YAML Frontmatter Addition**
```yaml
---
name: test-driven-development
description: RED-GREEN-REFACTOR cycle
decision-lineage:
  - problem: "How to ensure code quality?"
  - context: "Multiple developers, high change frequency"
  - decision: "Implement TDD as mandatory practice"
  - alternatives:
    - acceptance-testing (tried, too late in cycle)
    - code-review-only (insufficient, misses edge cases)
---
```

**Option B: Separate File**
```
skills/test-driven-development/
├── SKILL.md (the skill)
└── LINEAGE.md (decision history)
```

**Current:** No metadata system

**Recommendation:** Use Option B (separate file)
- Doesn't clutter main skill file
- Easy to ignore if not interested
- Can be edited separately from skill

**2. Linking Between Skills**

**Current state:** Skills are independent
```
test-driven-development/SKILL.md (standalone)
systematic-debugging/SKILL.md (standalone)
receiving-code-review/SKILL.md (standalone)
```

**With lineages:** Need to link related decisions
```
test-driven-development/LINEAGE.md
└── "Often used with: systematic-debugging (when tests fail)"

systematic-debugging/LINEAGE.md
└── "Often precedes: receiving-code-review (show results)"
```

**Conflict:** Creates dependency graph
- Must keep links updated when skills change
- Potential for broken references

**Resolution:** Lightweight linking
- Optional, not enforced
- Links are documented, not automated
- Tolerate some staleness

**3. Version/Timeline Tracking**

**Option A: Timestamp lineages**
```markdown
# Knowledge Lineage: When-Stuck Dispatcher

## Evolution Timeline

**2025-11-15:** Initial concept
- Problem: No meta-skill for stuck situations
- Solution: Create diagnostic dispatcher

**2025-11-22:** Added integration with brainstorming
- Clarified when to use when-stuck vs brainstorming

**2025-12-01:** [Future update]
```

**Option B: No timeline**
- Lineage describes current decision, not history
- Simpler to maintain

**Recommendation:** Start with Option B
- Can add timeline later if needed
- Most users care about current understanding, not history

### Recommendation

**IMPLEMENT** - Add knowledge lineages with these constraints:

1. **Create LINEAGE.md files for key skills**
   ```
   skills/test-driven-development/
   ├── SKILL.md (the practice)
   └── LINEAGE.md (why we chose this practice)

   skills/systematic-debugging/
   ├── SKILL.md (the process)
   └── LINEAGE.md (why this approach works)
   ```

2. **Lineage file template**
   ```markdown
   # Knowledge Lineage: [Skill Name]

   ## Problem This Solves
   [The fundamental problem that led to this skill]

   ## Context
   [When and why this problem arises]

   ## Decision
   [Why this approach was chosen]

   ## Trade-offs
   - [Advantage 1]
   - [Advantage 2]
   - [Limitation 1]
   - [Limitation 2]

   ## Alternatives Considered
   - [Alternative 1]: Why not chosen
   - [Alternative 2]: Why not chosen

   ## Related Skills
   - [Skill A]: When used together
   - [Skill B]: Similar approach to different problem
   ```

3. **Link from main skill**
   ```markdown
   # test-driven-development

   [... main skill content ...]

   ## Why This Approach?

   For more context on why TDD is important and how it was chosen,
   see [Knowledge Lineage](./LINEAGE.md).
   ```

4. **Start with these skills**
   - test-driven-development (why TDD?)
   - systematic-debugging (why this process?)
   - characterization-testing (why for legacy code?)
   - strangler-fig-pattern (why incremental?)
   - parallel-development (why concurrent work?)

5. **Link between lineages carefully**
   ```markdown
   # Lineage: test-driven-development

   ## Related Skills
   - See: [systematic-debugging/LINEAGE.md](../../systematic-debugging/LINEAGE.md)
     - Both part of disciplined development approach
   - See: [characterization-testing/LINEAGE.md](../../characterization-testing/LINEAGE.md)
     - TDD for new code, characterization testing for legacy code
   ```

6. **Keep maintenance burden low**
   - Lineages are optional enrichment
   - Don't require lineage for every skill
   - Focus on most-used/most-foundational skills

---

## Summary Table: Conflicts & Recommendations

| Feature | Conflict Level | Type | Key Issue | Recommendation | Effort | Phase |
|---------|---|---|---|---|---|---|
| #8 CLI Tool | MEDIUM | Architecture | Plugin vs CLI duplication | ADAPT: Parallel implementation | 2-3 days | 5 |
| #9 Framework Detection | LOW | Design | Where detection logic lives | IMPLEMENT: Modular per-framework | 1-2 days | 4 |
| #12 Git Worktrees Docs | LOW | Documentation | cd persistence explanation | DOCUMENT-ONLY: Update skill | 2-4 hours | 4 |
| #13 Monorepo Detection | MEDIUM | Scope | Skills assume single app | IMPLEMENT: Optional monorepo paths | 2-3 days | 4 |
| #14 Prompt Creation | MEDIUM | UX/Tools | Command vs template approach | ADAPT: Start with templates | 2-3 days | 5 |
| #15 When-Stuck | LOW | Meta | Overlap with brainstorming | IMPLEMENT: Clear scope dispatch | 1-2 days | 5 |
| #16 Knowledge Lineages | LOW | Documentation | Decision history tracking | IMPLEMENT: Optional LINEAGE.md files | 1-2 days | 5 |

---

## Implementation Sequencing Recommendation

**Phase 4 Extensions (2-4 weeks):**
1. Framework Detection (#9) - Foundation for other features
2. Git Worktrees Docs (#12) - Quick documentation fix
3. Monorepo Detection (#13) - Many users need this

**Phase 5 User Experience (2-3 weeks):**
4. CLI Tool (#8) - Parallel implementation path
5. Prompt Creation (#14) - Improves user onboarding
6. When-Stuck Dispatcher (#15) - Meta-skill for getting help
7. Knowledge Lineages (#16) - Documentation enrichment

---

## Key Findings

### ✅ No Blockers
All 7 features can be integrated without breaking existing functionality.

### ⚠️ Design Decisions Required
- **Feature #8 (CLI):** Choose between plugin-primary vs CLI-primary approach
- **Feature #13 (Monorepo):** Decide on detection placement (skill vs config vs setup script)
- **Feature #14 (Prompts):** Template-first vs interactive-command-first approach

### 📚 Documentation-Heavy
- #12 (Git Worktrees) is pure documentation
- #16 (Knowledge Lineages) is pure documentation
- #15 (When-Stuck) is mostly documentation with minimal skill code

### 🔄 Additive Features
None of these features require removing existing code. All can coexist with current implementation.

### 💡 Recommended First Integration Target
**Feature #9 (Framework Detection)** - Lowest conflict, broadest impact on user experience

---

**Analysis Complete**
**Date:** 2025-11-23
**Confidence Level:** High (based on detailed code examination and architecture review)
