# Superpowers for OpenCode

## Skills Library

The `skills/` directory provides systematic workflows for development tasks.

## Quick Start

**1. Check for applicable skill**

Before starting work, check if there's a relevant skill in `skills/`.

**2. Read the skill**

Open `skills/[skill-name]/SKILL.md` and read it completely.

**3. Follow exactly**

Follow the skill's process step-by-step. Don't skip steps.

## Essential Skills

**Test-Driven Development** (`skills/test-driven-development/SKILL.md`)
- Write test first
- Verify it fails
- Implement
- Verify it passes

**Systematic Debugging** (`skills/systematic-debugging/SKILL.md`)
- Investigate before hypothesizing
- Gather evidence
- Test theories
- Implement verified solutions

**Writing Plans** (`skills/writing-plans/SKILL.md`)
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

See `skills/verification-before-completion/SKILL.md`
