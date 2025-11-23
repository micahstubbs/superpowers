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
