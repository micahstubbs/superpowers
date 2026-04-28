# Lessons Learned

This file documents debugging lessons and insights discovered while working on this project.

---

## 2026-01-11T10:15 - Plugin Marketplace Registration Requires Correct Repo Reference

**Problem**: Install instructions for plugins in a forked marketplace pointed to the wrong repository (`obra/superpowers-marketplace` instead of `micahstubbs/superpowers`), causing installation failures.

**Root Cause**: When forking a marketplace repository, the install instructions still referenced the upstream repository name. The marketplace registration command must point to the actual repository hosting the `marketplace.json` file.

**Lesson**: When adding plugins to a forked marketplace, always update the marketplace registration command to reference the fork's repository path, not the upstream.

**Code Issue**:
```bash
# Before (broken - points to upstream that doesn't have your plugin)
/plugin marketplace add obra/superpowers-marketplace

# After (fixed - points to your fork with the plugin)
/plugin marketplace add micahstubbs/superpowers
```

**Solution**:
1. Updated the superpowers README.md to use `micahstubbs/superpowers` as the marketplace reference
2. Updated the double-shot-latte README.md to include the marketplace prerequisite step
3. Both install instructions now show the complete two-step process

**Prevention**:
- When adding a plugin to a forked marketplace, immediately verify and update install instructions in both:
  - The marketplace README (superpowers)
  - The plugin README (double-shot-latte)
- Test the full install flow before publishing: marketplace add → plugin install
- Document the marketplace repository path, not just the plugin name

---

## 2026-04-28T03:33 - `br update --status` echoes misleading title/diff

**Problem**: When integrating `br` (beads_rust) into the subagent-driven-development skill, calling `br update <id> --status=in_progress` returned output that looked like the issue had transitioned to **closed** (not in_progress) and showed a completely unrelated issue title in the echo. Briefly believed the issues were corrupt.

**Root Cause**: `br update --status` has a known display bug where the post-update echo shows incorrect/stale data — the wrong title, the wrong status delta, and even sometimes a fabricated diff. The actual database write is correct; only the terminal output lies. The grind skill's protocol notes mention this in passing ("a known `br` CLI display bug ... echoes a misleading title and bogus diff") but it surprises you the first time.

**Lesson**: Never trust `br update --status` echo output. Always verify writes independently — either with `br show <id>` immediately after, or by greping `.beads/issues.jsonl` after `br sync --flush-only`. This applies in all automation, especially loops where a misread would silently corrupt the audit trail across many issues.

**Code Issue**:
```bash
# Misleading: this output looks like a different issue closed, but the actual write is correct
$ br update bd-uh7c.1 --status in_progress --assignee claude
Updated bd-uh7c.1: <wrong title from another issue>
  status: open → closed       # ← THIS IS A LIE
  assignee: (none) → claude

# Reality:
$ br show bd-uh7c.1
◐ bd-uh7c.1 · <correct title>   [● P1 · IN_PROGRESS]   ← actually correct
```

**Solution**: Built verification directly into the integration pattern. The skills' new beads sections include "Verify the write after each state change. Confirm with `br show <id>` (or `grep '"<id>"' .beads/issues.jsonl` after sync) before moving on."

**Prevention**:
- Treat `br update --status` output as advisory only; never as confirmation of the write.
- After every `br update --status` call, immediately follow with `br show <id>` or grep the JSONL.
- Document this gotcha at every integration point — discoverability matters more than terseness here.
- If `br` upstream fixes the display bug, the verification step still costs nothing.

---

## Meta-Lessons

- **Documentation matters**: Install instructions that worked for upstream won't work for forks without updates
- **Two-step processes need both steps documented**: Users need to know about marketplace registration before plugin installation
- **Don't trust tool echo output for state confirmation**: Tools can lie about what they did. Verify state with a separate read after every write, especially in loops or automation. The cost of one extra read is far less than the cost of corrupting many records on a bad assumption.
