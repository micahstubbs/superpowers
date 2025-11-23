# obra/superpowers Fork Network Analysis

**Analysis Date:** 2025-11-23
**Total Forks:** 601
**Analyzed:** Top 50 most recently updated

## Executive Summary

Of the 601 forks of obra/superpowers, only **7 forks** have made significant unique contributions (3+ commits not in upstream). The most notable contributions fall into three categories:

1. **Multi-platform support** - Extending beyond Claude Code to other AI assistants
2. **Framework-specific skills** - Laravel-tailored workflows
3. **Parallel agent coordination** - Infrastructure for concurrent AI development
4. **Documentation improvements** - Better organization and examples

## Top Contributors by Unique Commits

| Fork | Unique Commits | Focus Area |
|------|----------------|------------|
| anvanvan/flows | 100 | Parallel agent workflows, git aliases, workflow organization |
| complexthings/superpowers | 61 | Multi-platform support, MCP replacements, CLI tools |
| cuivienor/superpowers | 23 | Language-specific examples, monorepo support |
| jpcaparas/superpowers-laravel | 9 | Laravel framework integration, Sail detection |
| Hacker0x01/claude-power-user | 6 | Fork setup and maintenance |
| b0o/superpowers | 3 | Git worktrees documentation improvements |
| dvdarkin/superpowers | 2 | Initial vision implementation |

---

## Detailed Fork Analysis

### 1. anvanvan/flows (100 unique commits)

**Repository:** https://github.com/anvanvan/flows

**Key Innovations:**

#### Task Tool Integration (Commits 71-100)
- **Problem Solved:** Claude would launch Task agents but fail to consume their results
- **Solution:** Explicit result consumption patterns documented in all skills
- **Files:** Integration documentation, consumption examples, skill enhancements
- **Value:** HIGH - Prevents wasted work by ensuring agent outputs are actually used

#### Concurrent-Safe Code Review (Commits 88-94)
- **Problem Solved:** Traditional git ranges (`main...HEAD`) fail when working in parallel
- **Solution:** Use commit SHA lists instead of ranges
- **Implementation:** Updated `requesting-code-review` skill with concurrent-safety notes
- **Value:** HIGH - Enables multiple agents/developers to work simultaneously

#### Custom Git Aliases (Referenced in README)
- `git stage-lines` - Stage specific lines within files
- `git unstage-lines` - Unstage specific lines
- **Value:** HIGH - Critical for parallel agent workflows where each agent stages only their changes

#### Workflow Phase Organization (Commits 37-65)
- **Initial approach:** Organized skills into workflow phases (00-meta, 01-understanding, etc.)
- **Reversal:** Moved back to flat structure after testing
- **Learning:** Documented decision-making process
- **Value:** MEDIUM - Provides rationale for structure decisions

#### New Skills Added (Commits 33-36)
- `characterization-testing` - Testing legacy code behavior
- `strangler-fig-pattern` - Incremental refactoring approach
- `when-stuck` - Dispatcher for stuck situations
- `knowledge-lineages` - Tracking decision history
- **Value:** MEDIUM - Useful specialized techniques

#### Documentation Improvements (Commits 1-10, 84-87)
- Skill dependency index
- Agent invocation pattern guide
- Standardized @flows: notation
- End-to-end consumption examples
- **Value:** MEDIUM - Improves discoverability and correct usage

**Recommendation:** **STRONGLY INCLUDE**

**Priority Contributions:**
1. ✅ Task tool result consumption patterns (prevents wasted agent work)
2. ✅ Concurrent-safe code review using SHA lists
3. ✅ Git line-staging aliases for parallel development
4. ✅ characterization-testing and strangler-fig-pattern skills
5. ⚠️ Workflow phase organization (document the decision, keep flat structure)

---

### 2. complexthings/superpowers (61 unique commits)

**Repository:** https://github.com/complexthings/superpowers

**Key Innovations:**

#### Multi-Platform Support (Commits 189-196)
- **Platforms:** Claude Code, Cursor, GitHub Copilot, Gemini, OpenCode, Codex
- **Implementation:** Platform-specific slash commands and hooks
- **Commands:** `/setup-skills` for each platform
- **Value:** VERY HIGH - Makes skills available beyond Claude ecosystem

#### MCP Replacement Skills (Commits 163-171)
- **`context-7` skill:** Documentation search with 98% less context usage
  - Scripts: `search.js` and `get-docs.js`
  - Uses external fetch + summarization instead of full context load
- **`playwright-skill`:** Browser automation without MCP overhead
  - Script: `run.js` executor
  - Reduces context usage dramatically
- **Value:** HIGH - Critical for cost/performance optimization

#### Prompt Creation System (Commits 137-144)
- **Feature:** `/meta-prompt` command
- **Templates:** do/plan/research/refine prompt types
- **Configuration:** Centralized config system with `get-config` command
- **Helper:** `get-next-number` script for numbering
- **Skill:** `creating-prompts` documentation
- **Value:** MEDIUM - Helps users create effective custom prompts

#### CLI Tool (Commits 185-188, 193-195)
- **Command:** `superpowers-agent`
- **Features:**
  - Skill discovery with smart suffix matching
  - `bootstrap` command for initial setup
  - Conditional tool detection
  - Global installation via curl
- **Template:** AGENTS.md for project configuration
- **Value:** HIGH - Simplifies adoption and management

#### Setup Skills Feature (Commits 175-184)
- **Command:** `/setup-skills` for all platforms
- **Purpose:** Initialize projects with skill library
- **Bootstrap:** Automatic command/skill updates
- **Value:** MEDIUM - Streamlines onboarding

**Recommendation:** **STRONGLY INCLUDE**

**Priority Contributions:**
1. ✅ Multi-platform support (Cursor, Copilot, Gemini, etc.)
2. ✅ MCP replacement skills (context-7, playwright)
3. ✅ CLI tool with smart skill matching
4. ✅ Prompt creation system
5. ⚠️ Consider merging with obra's plugin approach vs separate CLI

---

### 3. cuivienor/superpowers (23 unique commits)

**Repository:** https://github.com/cuivienor/superpowers

**Key Innovations:**

#### Language-Specific Examples (Commits 105-111)
- **Extracted examples for:**
  - `test-driven-development`: TypeScript/Jest, Python/pytest, Go
  - `testing-anti-patterns`: TypeScript, Python, Go
  - `condition-based-waiting`: Multiple languages
  - `defense-in-depth`: TypeScript, Python, Go, Rails
- **Structure:** Moved examples to `docs/examples/` directory
- **Value:** HIGH - Makes skills accessible to non-Ruby developers

#### Monorepo Support (Commit 129)
- **Feature:** Multi-app detection in monorepos
- **Context:** Laravel/Shopify monorepo patterns
- **Value:** MEDIUM - Useful for complex project structures

#### Shopify/Rails Specialization (Commits 118-122)
- **Skills added:**
  - `rails-database-migration`
  - `code-search` (monorepo-aware)
  - Shopify-specific contexts
- **Defensive examples:** Rails validation patterns
- **Value:** MEDIUM - Framework-specific but could generalize

#### Git Worktrees Enhancement (Commit 103)
- **Change:** Use `~/worktrees` with mirrored structure
- **Previous:** Worktrees in project directory
- **Value:** LOW - Personal preference, not universal improvement

#### Documentation (Commits 101-102, 112-117)
- **Hybrid architecture migration plan**
- **Updated README for current commands**
- **Removed legacy warnings**
- **Phase 3 backlog**
- **Value:** LOW - Specific to this fork's roadmap

**Recommendation:** **INCLUDE WITH ADAPTATIONS**

**Priority Contributions:**
1. ✅ Language-specific examples extraction (TypeScript, Python, Go)
2. ✅ Monorepo detection and support
3. ⚠️ Rails/Shopify skills (generalize or make optional)
4. ❌ Git worktrees location change (too opinionated)

---

### 4. jpcaparas/superpowers-laravel (9 unique commits)

**Repository:** https://github.com/jpcaparas/superpowers-laravel

**Key Innovations:**

#### Laravel Framework Integration (Commit 135)
- **Skills:**
  - Laravel runner detection (Sail vs non-Sail)
  - TDD with Pest/PHPUnit
  - Database migrations and factories
  - Queue management
  - Quality checks (Pint, Larastan, etc.)
- **Metadata:** Plugin.json for marketplace
- **Value:** VERY HIGH - Complete framework integration model

#### Sail Detection (Commit 134)
- **Feature:** Automatic Docker/Sail environment detection
- **Commands:** Adapts `php artisan` vs `./vendor/bin/sail artisan`
- **Guardrails:** Interactive safety checks
- **Value:** HIGH - Prevents command failures in different environments

#### Monorepo Support (Commit 129)
- **Feature:** Multi-app detection in Laravel monorepos
- **Guidance:** Scoped Sail usage per app
- **Value:** MEDIUM - Increasingly common pattern

#### Best Practices Documentation (Commits 127-128)
- **Added:** Laravel-specific best practices skills
- **Caching:** Tags, locks, and proper invalidation
- **Workflows:** Streamlined for Laravel 11.x/12.x
- **Value:** MEDIUM - Educational for Laravel developers

#### Setup Documentation (Commits 132-133)
- **README:** Installation instructions
- **Screenshots:** Setup process visualization
- **Interactive safety:** Command confirmation
- **Value:** LOW - Documentation quality

**Recommendation:** **USE AS MODEL FOR FRAMEWORK PLUGINS**

**Priority Contributions:**
1. ✅ Framework detection pattern (Sail vs non-Sail)
2. ✅ Complete Laravel skill suite (use as template for other frameworks)
3. ✅ Monorepo detection and scoping
4. ⚠️ Best practices should be in framework-specific plugin, not core
5. 📋 Document this as the pattern for framework-specific forks

---

### 5. b0o/superpowers (3 unique commits)

**Repository:** https://github.com/b0o/superpowers

**Key Innovations:**

#### Git Worktrees Documentation (Commits 124-126)
- **Problem:** cd doesn't persist in non-bare repos
- **Solution:** Documented the issue and separate instructions
- **Added:** Bare vs non-bare repo workflows
- **Value:** MEDIUM - Helps users avoid confusion

#### Plugin Metadata (Commit 126)
- **Updated:** plugin.json metadata
- **Value:** LOW - Maintenance

**Recommendation:** **INCLUDE DOCUMENTATION IMPROVEMENTS**

**Priority Contributions:**
1. ✅ Git worktrees bare vs non-bare distinction
2. ✅ cd persistence issue documentation
3. ❌ Metadata changes (not applicable to upstream)

---

### 6. dvdarkin/superpowers (2 unique commits)

**Repository:** https://github.com/dvdarkin/superpowers

**Key Innovation:**

#### Initial Skill Vision (Commit 198)
- **Description:** "initial skill vision implemented, tested on 2 repos"
- **Details:** Limited information in commit message
- **Status:** Merge with upstream in commit 197
- **Value:** UNKNOWN - Need to examine actual changes

**Recommendation:** **INVESTIGATE FURTHER**

Need to examine the actual diff to understand what "skill vision" means.

---

### 7. Hacker0x01/claude-power-user (6 unique commits)

**Repository:** https://github.com/Hacker0x01/claude-power-user

**Key Changes:**

#### Repository Setup (Commits 203-205)
- **Changed:** Repository URLs to HackerOne org
- **Simplified:** Setup process
- **Value:** LOW - Fork maintenance, not feature improvements

#### Upstream Syncs (Commits 199-202)
- **Activity:** Regular merges from obra:main
- **Value:** LOW - Maintenance

**Recommendation:** **NO UNIQUE VALUE**

This fork appears to be organizational (HackerOne-specific) without unique technical contributions.

---

## Recommendations by Category

### Must Include (High Value, Universal Applicability)

1. **Task Tool Result Consumption Patterns** (anvanvan/flows)
   - Prevents wasted agent work
   - Universal problem across all Task tool usage
   - Documentation + skill updates

2. **Concurrent-Safe Code Review** (anvanvan/flows)
   - Enables parallel agent workflows
   - SHA-based review instead of git ranges
   - Critical for multi-agent development

3. **Git Line-Staging Aliases** (anvanvan/flows)
   - `git stage-lines` and `git unstage-lines`
   - Enables parallel staging without conflicts
   - Fundamental for concurrent work

4. **Multi-Platform Support Framework** (complexthings/superpowers)
   - Extends to Cursor, Copilot, Gemini, OpenCode
   - Platform-specific command adapters
   - Massive expansion of potential user base

5. **MCP Replacement Skills** (complexthings/superpowers)
   - context-7 for documentation (98% context reduction)
   - playwright-skill for browser automation
   - Cost and performance critical

6. **Language-Specific Examples** (cuivienor/superpowers)
   - TypeScript, Python, Go examples
   - Makes skills accessible beyond Ruby
   - Essential for adoption

### Should Include (High Value, Requires Adaptation)

7. **CLI Tool with Smart Matching** (complexthings/superpowers)
   - Global installation
   - Suffix-based skill matching
   - May need to integrate with obra's plugin approach

8. **Framework Detection Pattern** (jpcaparas/superpowers-laravel)
   - Use as template for framework plugins
   - Automatic environment detection
   - Adaptive command generation

9. **Characterization Testing Skill** (anvanvan/flows)
   - Testing legacy code behavior
   - Pairs well with systematic-debugging
   - Valuable specialized technique

10. **Strangler Fig Pattern Skill** (anvanvan/flows)
    - Incremental refactoring approach
    - Reduces risk in large changes
    - Proven technique worth documenting

### Consider Including (Medium Value)

11. **Prompt Creation System** (complexthings/superpowers)
    - Templates for do/plan/research/refine
    - Configuration system
    - Helps users create effective prompts

12. **Monorepo Detection** (cuivienor/superpowers, jpcaparas/superpowers-laravel)
    - Multi-app awareness
    - Scoped command execution
    - Increasingly common pattern

13. **When-Stuck Dispatcher** (anvanvan/flows)
    - Helps when development is blocked
    - Could be valuable but needs evaluation

14. **Knowledge Lineages** (anvanvan/flows)
    - Tracks decision history
    - Good for long-running projects

15. **Git Worktrees Documentation** (b0o/superpowers)
    - Bare vs non-bare distinction
    - cd persistence issues
    - Clarifies common confusion

### Do Not Include

16. **Workflow Phase Organization** (anvanvan/flows)
    - Tested and reversed
    - Flat structure proven better
    - Document the decision, don't implement

17. **Git Worktrees Location Change** (cuivienor/superpowers)
    - Too opinionated (~/worktrees)
    - No clear universal benefit

18. **Fork-Specific Metadata** (Hacker0x01, others)
    - Organizational, not technical

### Framework-Specific (Separate Plugins)

19. **Laravel Skills Suite** (jpcaparas/superpowers-laravel)
    - Complete framework integration
    - Should remain separate plugin
    - Use as model for other frameworks

20. **Rails/Shopify Skills** (cuivienor/superpowers)
    - Framework-specific
    - Better as separate plugin

---

## Implementation Recommendations

### Phase 1: Critical Infrastructure (Immediate)

1. Merge concurrent-safe code review patterns (anvanvan/flows)
2. Add git line-staging aliases (anvanvan/flows)
3. Integrate Task tool consumption documentation (anvanvan/flows)
4. Add MCP replacement skills as examples (complexthings/superpowers)

### Phase 2: Platform Expansion (Near-term)

5. Implement multi-platform support framework (complexthings/superpowers)
6. Add language-specific example structure (cuivienor/superpowers)
7. Create CLI tool or enhance plugin system (complexthings/superpowers)
8. Document framework plugin pattern using Laravel as reference

### Phase 3: Skill Enhancements (Medium-term)

9. Add characterization-testing skill (anvanvan/flows)
10. Add strangler-fig-pattern skill (anvanvan/flows)
11. Enhance git worktrees documentation (b0o/superpowers)
12. Add monorepo detection patterns (cuivienor, jpcaparas)

### Phase 4: User Experience (Longer-term)

13. Implement prompt creation system (complexthings/superpowers)
14. Add when-stuck dispatcher (anvanvan/flows)
15. Add knowledge-lineages skill (anvanvan/flows)

---

## Technical Debt & Conflicts

### Architectural Decisions

**Plugin vs CLI Approach:**
- obra/superpowers: Claude Code plugin marketplace
- complexthings/superpowers: Global CLI tool

**Resolution:** Support both. Plugin for Claude Code native integration, CLI for other platforms.

### Skill Organization

**Flat vs Hierarchical:**
- anvanvan/flows tested hierarchical (00-meta, 01-understanding, etc.)
- Reverted to flat after testing
- Decision: Keep flat, document the rationale

### Example Organization

**Inline vs Extracted:**
- Original: Examples inline in skills
- cuivienor: Extracted to `docs/examples/`

**Resolution:** Extract language-specific examples, keep universal examples inline

---

## Quality Assessment

### Code Quality

- **anvanvan/flows:** Excellent commit messages, test-driven approach, documented reversals
- **complexthings/superpowers:** Comprehensive but rapid iteration, some consolidation needed
- **cuivienor/superpowers:** Clean refactoring, good separation of concerns
- **jpcaparas/superpowers-laravel:** Professional, well-tested, good documentation

### Documentation Quality

- **anvanvan/flows:** Excellent technical docs, integration guides
- **complexthings/superpowers:** Good README, needs more inline docs
- **cuivienor/superpowers:** Architecture docs, migration plans
- **jpcaparas/superpowers-laravel:** User-focused, screenshot-enhanced

### Testing Evidence

- **anvanvan/flows:** Explicit test files, pressure tests
- **complexthings/superpowers:** Test scripts included
- **cuivienor/superpowers:** Code review iteration visible
- **jpcaparas/superpowers-laravel:** "tested on 2 repos" claims

---

## Risk Assessment

### Low Risk (Safe to Merge)

- Documentation improvements
- Language-specific examples
- Git worktrees clarifications
- New specialized skills (characterization-testing, strangler-fig)

### Medium Risk (Needs Testing)

- Task tool consumption patterns (behavior change)
- MCP replacement skills (new dependencies)
- CLI tool (new distribution method)
- Multi-platform support (compatibility verification)

### High Risk (Needs Careful Integration)

- Concurrent-safe code review (fundamental workflow change)
- Git line-staging aliases (requires git configuration)
- Framework detection patterns (environment-dependent)

---

## Community Insights

### Active Contributors

1. **An Van (anvanvan/flows):** 100 commits, systematic approach, excellent documentation
2. **Greg Harvell (complexthings):** 61 commits, rapid iteration, multi-platform focus
3. **Peter Petrov (cuivienor):** 23 commits, language-specific improvements
4. **JP Caparas (jpcaparas):** 9 commits, framework specialization

### Contribution Patterns

- Most forks (594/601) are passive (0 unique commits)
- Active forks focus on specific use cases (framework, platform, workflow)
- Little apparent coordination between fork authors
- Opportunity for consolidation

### Potential Collaboration

Recommend reaching out to top 4 contributors about:
1. Upstream contribution interest
2. Coordination on multi-platform support
3. Framework plugin standards
4. Example organization

---

## Conclusion

Out of 601 forks, **7 have made significant contributions** worth incorporating. The highest-value contributions are:

1. **Parallel agent infrastructure** (anvanvan/flows) - Enables concurrent AI development
2. **Multi-platform support** (complexthings/superpowers) - Expands beyond Claude Code
3. **Language-specific examples** (cuivienor/superpowers) - Makes skills accessible to all developers
4. **Framework plugin model** (jpcaparas/superpowers-laravel) - Demonstrates specialization approach

A consolidated fork should incorporate 15-20 specific contributions from these forks, organized into 4 implementation phases.

**Estimated Effort:**
- Phase 1: 2-3 days (critical infrastructure)
- Phase 2: 1-2 weeks (platform expansion)
- Phase 3: 1 week (skill enhancements)
- Phase 4: 1 week (UX improvements)

**Total:** 4-6 weeks of integration work for a comprehensive community-enhanced fork.
