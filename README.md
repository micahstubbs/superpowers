# Superpowers Community Edition

> **This is a community-enhanced fork** integrating the best contributions from the obra/superpowers fork network.

A comprehensive skills library of proven techniques, patterns, and workflows for AI coding assistants.

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

## What You Get

- **Testing Skills** - TDD, async testing, anti-patterns
- **Debugging Skills** - Systematic debugging, root cause tracing, verification
- **Collaboration Skills** - Brainstorming, planning, code review, parallel agents
- **Development Skills** - Git worktrees, finishing branches, subagent workflows
- **Meta Skills** - Creating, testing, and sharing skills

Plus:
- **Slash Commands** - `/superpowers:brainstorm`, `/superpowers:write-plan`, `/superpowers:execute-plan`
- **Automatic Integration** - Skills activate automatically when relevant
- **Consistent Workflows** - Systematic approaches to common engineering tasks

## Learn More

Read the introduction: [Superpowers for Claude Code](https://blog.fsck.com/2025/10/09/superpowers/)

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

## Installation

### Claude Code (via Plugin Marketplace)

In Claude Code, register the marketplace first:

```bash
/plugin marketplace add obra/superpowers-marketplace
```

Then install the plugin from this marketplace:

```bash
/plugin install superpowers@superpowers-marketplace
```

### Verify Installation

Check that commands appear:

```bash
/help
```

```
# Should see:
# /superpowers:brainstorm - Interactive design refinement
# /superpowers:write-plan - Create implementation plan
# /superpowers:execute-plan - Execute plan in batches
```

### Codex (Experimental)

**Note:** Codex support is experimental and may require refinement based on user feedback.

Tell Codex to fetch https://raw.githubusercontent.com/obra/superpowers/refs/heads/main/.codex/INSTALL.md and follow the instructions.

### Parallel Development Setup (Optional)

If you plan to use multiple AI agents or work with others simultaneously:

```bash
./scripts/install-git-aliases.sh
```

See [docs/parallel-development.md](docs/parallel-development.md) for details.

## Quick Start

### Using Slash Commands

**Brainstorm a design:**
```
/superpowers:brainstorm
```

**Create an implementation plan:**
```
/superpowers:write-plan
```

**Execute the plan:**
```
/superpowers:execute-plan
```

### Automatic Skill Activation

Skills activate automatically when relevant. For example:
- `test-driven-development` activates when implementing features
- `systematic-debugging` activates when debugging issues
- `verification-before-completion` activates before claiming work is done

## What's Inside

### Skills Library

**Testing** (`skills/testing/`)
- **test-driven-development** - RED-GREEN-REFACTOR cycle
- **condition-based-waiting** - Async test patterns
- **testing-anti-patterns** - Common pitfalls to avoid

**Debugging** (`skills/debugging/`)
- **systematic-debugging** - 4-phase root cause process
- **root-cause-tracing** - Find the real problem
- **verification-before-completion** - Ensure it's actually fixed
- **defense-in-depth** - Multiple validation layers

**Collaboration** (`skills/collaboration/`)
- **brainstorming** - Socratic design refinement
- **writing-plans** - Detailed implementation plans
- **executing-plans** - Batch execution with checkpoints
- **dispatching-parallel-agents** - Concurrent subagent workflows
- **requesting-code-review** - Pre-review checklist
- **receiving-code-review** - Responding to feedback
- **using-git-worktrees** - Parallel development branches
- **finishing-a-development-branch** - Merge/PR decision workflow
- **subagent-driven-development** - Fast iteration with quality gates

**Meta** (`skills/meta/`)
- **writing-skills** - Create new skills following best practices
- **sharing-skills** - Contribute skills back via branch and PR
- **testing-skills-with-subagents** - Validate skill quality
- **using-superpowers** - Introduction to the skills system

### Commands

All commands are thin wrappers that activate the corresponding skill:

- **brainstorm.md** - Activates the `brainstorming` skill
- **write-plan.md** - Activates the `writing-plans` skill
- **execute-plan.md** - Activates the `executing-plans` skill

## How It Works

1. **SessionStart Hook** - Loads the `using-superpowers` skill at session start
2. **Skills System** - Uses Claude Code's first-party skills system
3. **Automatic Discovery** - Claude finds and uses relevant skills for your task
4. **Mandatory Workflows** - When a skill exists for your task, using it becomes required

## Philosophy

- **Test-Driven Development** - Write tests first, always
- **Systematic over ad-hoc** - Process over guessing
- **Complexity reduction** - Simplicity as primary goal
- **Evidence over claims** - Verify before declaring success
- **Domain over implementation** - Work at problem level, not solution level

## Contributing

Skills live directly in this repository. To contribute:

1. Fork the repository
2. Create a branch for your skill
3. Follow the `writing-skills` skill for creating new skills
4. Use the `testing-skills-with-subagents` skill to validate quality
5. Submit a PR

See `skills/meta/writing-skills/SKILL.md` for the complete guide.

## Updating

Skills update automatically when you update the plugin:

```bash
/plugin update superpowers
```

## Community Contributors

This community fork integrates contributions from:

- **[anvanvan/flows](https://github.com/anvanvan/flows)** - Parallel agent infrastructure, Task tool patterns
- **[complexthings/superpowers](https://github.com/complexthings/superpowers)** - Multi-platform support, MCP replacements
- **[cuivienor/superpowers](https://github.com/cuivienor/superpowers)** - Language-specific examples, monorepo support
- **[jpcaparas/superpowers-laravel](https://github.com/jpcaparas/superpowers-laravel)** - Framework plugin pattern
- **[b0o/superpowers](https://github.com/b0o/superpowers)** - Git worktrees documentation
- **[obra/superpowers](https://github.com/obra/superpowers)** (upstream) - Original skills library

Full attribution in [fork-network-analysis.md](fork-network-analysis.md).

## License

MIT License - see LICENSE file for details

## Support

- **Issues**: https://github.com/obra/superpowers/issues
- **Marketplace**: https://github.com/obra/superpowers-marketplace
