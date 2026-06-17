# Upstream Review: obra/superpowers main

**Date:** 2026-06-17  
**Local project:** `micahstubbs/superpowers` at `53789b7` (`v4.3.1-1-g53789b7`)  
**Upstream:** `obra/superpowers` at `b62616f` (`v6.0.2`)  
**Merge base:** `b9e16498b9b6`  
**Comparison examined:** `HEAD..upstream/main` after fetching `https://github.com/obra/superpowers.git`  
**Divergence:** local branch is 35 commits ahead and 371 commits behind upstream  
**Diff scale:** 223 files changed, 23,273 insertions, 14,209 deletions

## Executive Summary

Upstream has moved from the local fork's v4.3.1 lineage to v6.0.2. The delta is not a narrow patch series. It is a broad product and methodology release train that adds new agent harnesses, a visual brainstorming companion, substantial subagent-driven-development changes, new packaging and marketplace tooling, cross-platform hook fixes, and a new eval/testing strategy.

The local project is not merely stale; it has fork-specific functionality that upstream does not contain. The most important local-only work is the `br` / beads integration, Micah-owned package metadata, local Codex CLI packaging, local documentation/review artifacts, and four local skills not present upstream: `characterization-testing`, `context-7`, `knowledge-lineages`, and `strangler-fig-pattern`.

If this project were updated by a direct merge, it would import many real fixes and new capabilities, but it would also delete or overwrite local fork behavior. The right approach is selective porting or an intentional rebase with a preservation checklist.

## High-Level Release Delta

| Area | Local project | Upstream v6.0.2 |
| --- | --- | --- |
| Version | `4.3.1` plus local fork commits | `6.0.2` |
| Primary owner metadata | Micah Stubbs / `micahstubbs/superpowers` | Jesse Vincent / `obra/superpowers` |
| Agent harness support | Claude Code, Codex, OpenCode, Cursor-oriented fork work | Claude Code, Codex, OpenCode, Cursor, Gemini CLI, Copilot CLI, Kimi Code, Pi, Antigravity |
| Brainstorming | Text workflow, no current upstream visual server in local tree | Visual browser companion with zero-dependency server, auth, reconnect, sandboxing |
| SDD review | Local v4-era two-reviewer lineage plus beads additions | Single task reviewer, file-based handoffs, model pinning, final broad review |
| Planning | Local beads issue mirroring added | Global constraints, interfaces blocks, task right-sizing, pre-flight conflict review |
| Worktrees | Local fork includes beads-aware changes | Harness-native worktree preference, project-local `.worktrees/`, safer cleanup |
| Testing | In-tree shell and Claude Code tests; fork docs | Plugin-code tests in tree; behavior evals moved out to separate eval repo |
| Packaging | Local Codex plugin metadata and `.codex` bootstrap CLI | Native Codex plugin hook metadata; Codex marketplace sync script; no legacy `.codex` CLI |

## Upstream New Functionality

### New Harnesses and Platform Integrations

Upstream adds or substantially updates support for several agent harnesses:

- **Gemini CLI**: root `gemini-extension.json`, root `GEMINI.md`, and `skills/using-superpowers/references/gemini-tools.md`. The tool reference documents Gemini equivalents for common Claude Code actions and notes the lack of subagent support.
- **GitHub Copilot CLI**: `sessionStart` context injection using Copilot CLI's `additionalContext` format, plus `skills/using-superpowers/references/copilot-tools.md` and README install guidance.
- **Kimi Code**: `.kimi-plugin/plugin.json`, `docs/README.kimi.md`, and manifest tests.
- **Pi**: `.pi/extensions/superpowers.ts`, with session-start registration and bootstrap injection for native skills.
- **Antigravity (`agy`)**: `skills/using-superpowers/references/antigravity-tools.md` and tests under `tests/antigravity/`.
- **Codex App and Codex plugin mirror**: `hooks/hooks-codex.json`, `hooks/session-start-codex`, richer Codex tool docs, and `scripts/sync-to-codex-plugin.sh` for mirroring upstream into the OpenAI Codex plugin marketplace.
- **OpenCode**: a one-line plugin install path, runtime bootstrap caching, action-based tool mapping, modernized tests, and install caveats.
- **Cursor**: native hook metadata in `hooks/hooks-cursor.json`, a `.cursor-plugin/plugin.json`, and Windows hook execution fixes.

Net effect: upstream is now a multi-harness framework rather than a Claude/Codex/OpenCode-focused skills repository.

### Visual Brainstorming Companion

Upstream adds a browser-based brainstorming companion centered in `skills/brainstorming/scripts/` and `skills/brainstorming/visual-companion.md`.

Major capabilities:

- Generates browser screens for mockups, diagrams, comparisons, and visual questions during brainstorming.
- Runs a local server from the brainstorming skill directory rather than global plugin paths.
- Uses a zero-dependency Node server (`server.cjs`) with built-in HTTP, WebSocket framing, file watching, and crypto primitives.
- Writes server metadata so agents can recover the URL and port even when stdout is hidden.
- Reconnects browser clients after restarts and shows live/paused state.
- Reuses a project/session port and key across restarts.
- Extends idle timeout to four hours in v6.
- Adds visual branding assets: `assets/app-icon.png` and `assets/superpowers-small.svg`.

This is the largest user-facing new feature. It introduces scripts, browser UI, tests, and security considerations not present in the local fork.

### Visual Companion Security Model

Upstream v6 hardens the visual companion:

- Per-session key required for every HTTP and WebSocket request.
- Key carried in the URL and stored in a tab-scoped cookie.
- File server refuses symlinks, dotfiles, resource-fork files, path traversal, and files outside the content sandbox.
- No-store and deny-framing headers are sent.
- Key-bearing files are owner-only.
- `stop-server.sh` checks process ownership before signaling.
- Windows lifecycle handling avoids unsafe POSIX ownership assumptions.

These are real security fixes. If the local fork ever imports the visual companion, these hardening changes should be imported with it.

### Subagent-Driven Development Rewrite

Upstream rewrites the SDD review loop:

- Replaces separate spec-reviewer and code-quality-reviewer prompts with one `task-reviewer-prompt.md`.
- One reviewer now returns both spec-compliance and code-quality verdicts.
- Adds a "cannot verify from diff" path for requirements that need controller-side checking.
- Adds one broad whole-branch review at the end.
- Adds file-based task handoff scripts: `skills/subagent-driven-development/scripts/task-brief` and `review-package`.
- Requires model selection to be explicit on dispatch.
- Forbids controller prompts that suppress reviewer findings or pre-rate severity.
- Makes reviewers read-only and skeptical of implementer rationales.
- Moves implementer reports into files and requires stronger evidence, including red/green evidence where TDD applies.
- Adds a progress ledger concept for resuming after context loss.

This is a material methodology change. It is intended to reduce cost and improve reviewer independence.

### Writing Plans and Planning Workflow

Upstream planning changes include:

- `Global Constraints` block for requirements that apply across tasks.
- Per-task `Interfaces` blocks describing task inputs and outputs.
- Task right-sizing guidance.
- Pre-flight plan review to surface conflicts before Task 1.
- Continued emphasis on design/spec docs under `docs/superpowers/specs/` and implementation plans under `docs/superpowers/plans/`.

The v5.0.0 release briefly made SDD mandatory on capable harnesses, but v5.0.5 restored a user choice between subagent-driven and inline execution after plan writing.

### Worktree Behavior

Upstream rewrites `using-git-worktrees` and `finishing-a-development-branch`:

- Detects when already inside a linked worktree.
- Defers to a harness-native worktree tool when available.
- Requires consent before creating worktrees.
- Stops using the legacy global `~/.config/superpowers/worktrees/` path.
- Uses project-local `.worktrees/` or `worktrees/` by default.
- Cleans up only worktrees with clear superpowers provenance.
- Handles detached HEAD with a reduced finish menu.
- Removes stale Cursor references and fixes step numbering.

### Code Review Consolidation

Upstream removes the named `superpowers:code-reviewer` agent and folds its persona and checklist into `skills/requesting-code-review/code-reviewer.md`.

Consequences:

- Skills dispatch `general-purpose` with a self-contained prompt template.
- The old `agents/code-reviewer.md` file is deleted upstream.
- Codex and Copilot workaround docs for named agents are simplified because no named agent ships.

### Evaluation and Testing Strategy

Upstream moves skill-behavior testing out of most in-tree shell tests and into a drill-based eval harness. That eval harness was briefly a submodule, then v6.0.2 stopped shipping it inside the plugin because it broke installs.

Current upstream position:

- In-tree `tests/` are mostly plugin-code and harness integration tests.
- Skill-behavior evals live in a separate eval repository.
- `.pre-commit-config.yaml` and `scripts/lint-shell.sh` add shell linting.
- New tests cover brainstorm server auth, lifecycle, browser launch, WebSocket protocol, branding, Codex plugin sync, Kimi manifests, Pi extension, Antigravity tools, shell lint, and hooks.

### Contributor and Governance Changes

Upstream adds:

- `CLAUDE.md`, symlinked/instruction-aligned with `AGENTS.md`.
- `CODE_OF_CONDUCT.md`.
- GitHub issue templates for bugs, features, and platform support.
- A PR template requiring disclosure of model, harness, version, plugins, and whether content was human-written.
- Guidance that PRs target `dev`, not `main`.
- A new `docs/porting-to-a-new-harness.md` guide.

The contributor docs are explicitly designed to filter low-quality AI-generated PRs and platform-support submissions that do not load the bootstrap at session start.

## Upstream Bugfixes

### Hook and Shell Portability

Upstream contains many cross-platform hook fixes:

- Quotes `CLAUDE_PLUGIN_ROOT` safely for Windows and Linux.
- Replaces POSIX-incompatible `${BASH_SOURCE[0]:-$0}` in shell hooks.
- Replaces heredoc expansion with `printf` to avoid Bash 5.3 hangs.
- Uses portable `#!/usr/bin/env bash` shebangs.
- Routes Windows Cursor hooks through `run-hook.cmd`.
- Stops firing SessionStart bootstrap on resumed sessions.
- Pipes Windows hook `printf` through `cat` to absorb broken-pipe write errors.
- Adds dedicated `hooks/session-start` and `hooks/session-start-codex` paths.

### Brainstorm Server Reliability

Upstream fixes:

- Node 22 ESM/CommonJS breakage by using `server.cjs`.
- Owner-PID false positives when the owner process is another user or the WSL grandparent process exits early.
- Windows/MSYS2 lifecycle assumptions.
- Server stop behavior: SIGTERM, wait, SIGKILL fallback, and verification that the process actually died.
- Background launch and foreground fallback behavior on Windows/Git Bash.
- Liveness checking before reusing an existing server.
- UTF-8 charset declaration on served pages.
- Idle cleanup to avoid orphaned processes.

### Codex, OpenCode, Cursor, and Other Harness Fixes

Upstream fixes:

- Codex native skill discovery, Codex App compatibility, named-agent mapping docs, deprecated flag names, `wait_agent` mapping, and private/jokey review wording.
- Codex plugin version display when packaged plugins lack a root `package.json`.
- Codex plugin sync exclusions for `.gitmodules` and `.pre-commit-config.yaml`.
- OpenCode skill path consistency, native skills directory usage, bootstrap injection as a first user message rather than repeated system messages, `OPENCODE_CONFIG_DIR` handling, and tool mapping for `TodoWrite`.
- Cursor install command and manifest behavior.
- Copilot CLI context injection.

### Skill Content Fixes

Upstream fixes:

- `writing-plans` nested code fences.
- `test-driven-development` reference to testing anti-patterns.
- `writing-skills` frontmatter wording, changing "only two fields" to "two required fields".
- `systematic-debugging` accidentally triggering Claude Code extended-thinking keyword detection.
- `using-superpowers` listing a nonexistent "debugging" skill.
- Hardcoded personal paths in worktree docs.
- Stale docs references and platform-specific terminology.

### Test and Review Fixes

Upstream fixes:

- SDD integration tests that were silently bailing before assertions.
- Skill-recognition tests with case variations.
- Worktree path policy tests.
- Code review tests that plant concrete security defects and require detection.
- Document review tests, later moved into drill scenarios.

## Other Upstream Changes and Removals

### Removed From Upstream

Upstream removes several items currently present locally:

- Legacy slash command stubs: `commands/brainstorm.md`, `commands/execute-plan.md`, and `commands/write-plan.md`.
- Named agent file: `agents/code-reviewer.md`.
- Local `.codex/` installer and bootstrap CLI files.
- Shared `lib/skills-core.js`.
- Old platform directories under `platforms/`.
- Many local docs and examples, including language examples and local session summaries.
- `skills/characterization-testing`, `skills/context-7`, `skills/knowledge-lineages`, and `skills/strangler-fig-pattern`.

The last four are local-only capabilities in this fork. They should be explicitly preserved if they still matter.

### Packaging and Metadata Changes

Upstream changes package identity and marketplace metadata:

- `.claude-plugin/plugin.json`, `.codex-plugin/plugin.json`, `.cursor-plugin/plugin.json`, `.kimi-plugin/plugin.json`, and `gemini-extension.json` report version `6.0.2`.
- Author/repository/homepage point to Jesse Vincent and `obra/superpowers`.
- Codex plugin metadata adds hooks, capabilities, default prompts, brand color, icon, logo, privacy policy, and terms URL.
- Root `package.json` and `.version-bump.json` support release/version workflows.
- `README.md` is rewritten around the upstream multi-harness installation story.

Those changes conflict with local fork metadata that intentionally points to Micah Stubbs and `micahstubbs/superpowers`.

### Documentation Reorganization

Upstream moves long-form design and plan artifacts into `docs/superpowers/specs/` and `docs/superpowers/plans/`. It adds plans/specs for visual brainstorming, zero-dependency brainstorm server, Codex App compatibility, worktree rewrite, eval migration, Pi extension, SDD task-scoped review dispatch, and visual companion hardening.

Local fork documents such as `docs/beads-integration-recommendations.md`, session summaries, and the v4.3.0 beads integration review are absent upstream.

## Local-Only Functionality at Risk

The local fork contains material functionality that upstream does not:

- **Beads integration**: local commits add optional `br` issue IDs, plan-to-issue mirroring, execution integration, and beads guidance across several skills.
- **Micah-owned metadata**: plugin manifests, homepage, repository, author, and marketplace identity point to Micah's fork.
- **Codex CLI bootstrap files**: local `.codex/` files and `superpowers-codex` script exist locally but upstream removed this approach in favor of native Codex plugin discovery and hooks.
- **Extra local skills**: `characterization-testing`, `context-7`, `knowledge-lineages`, and `strangler-fig-pattern`.
- **Fork documentation**: session summaries, `docs/beads-integration-recommendations.md`, multi-pass review docs, and review artifacts.
- **Double-shot-latte marketplace work**: local marketplace plugin registration and related lessons.

Any merge or rebase should preserve or consciously retire these local decisions.

## Porting Decisions by Category

Rewrite or apply the cross-platform hook fixes. They are mostly low-risk portability and reliability improvements. If the visual companion is imported, also rewrite/apply the v6 security fixes; those fixes are essential for any local server.

Rewrite or apply SDD, writing-plans, and worktree changes selectively. They are valuable, but each must be reconciled with local beads issue tracking and local workflow assumptions.

Apply new harness support selectively. Kimi, Pi, Antigravity, Gemini, Copilot, and upstream Codex hooks may or may not fit this fork's scope. Any Codex hook work should preserve Micah-owned metadata and local plugin identity.

Ignore or fork-adapt upstream's Codex marketplace sync script, because it targets upstream ownership. Ignore upstream metadata replacement, local-skill removals, and beads-doc removals unless the fork intentionally retires those choices. If importing evals work, follow v6.0.2 and do not ship the eval submodule in the plugin.

## Recommended Update Strategy

Do not direct-merge upstream into this fork without a preservation plan. The upstream diff deletes local functionality and rewrites package identity.

A careful port should first preserve fork identity and local-only skills in a guard list. Next, port the low-risk hook and shell fixes. After that, port SDD and writing-plans changes while reapplying beads integration. New harnesses should be imported only if they matter for this fork. If the visual companion is imported, bring the v6 security model and test suite with it. Keep the upstream eval harness out of the distributed plugin, matching v6.0.2. Finally, run focused tests for hooks, plugin metadata, SDD, writing-plans, and any imported harnesses.

## Evidence Reviewed

Evidence came from a fresh fetch of `https://github.com/obra/superpowers.git`, the `HEAD...upstream/main` divergence count, upstream-only and local-only git logs, `HEAD..upstream/main` diff stats and name-status output, upstream `RELEASE-NOTES.md` sections v5.0.0 through v6.0.2, local and upstream plugin manifests, and local/upstream skill directory inventories.
