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
