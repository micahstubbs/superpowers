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

## Meta-Lessons

- **Documentation matters**: Install instructions that worked for upstream won't work for forks without updates
- **Two-step processes need both steps documented**: Users need to know about marketplace registration before plugin installation
