# Required Fixes for Phase 1 Implementation

**Before proceeding to Phase 2, address these issues.**

---

## CRITICAL FIX #1: Test Git Aliases

**Priority:** MUST FIX
**Estimated Time:** 15 minutes
**File:** `scripts/install-git-aliases.sh`

### Test Procedure

```bash
# 1. Create test environment
cd /tmp
git init git-alias-test
cd git-alias-test
git config user.email "test@example.com"
git config user.name "Test User"

# 2. Create test file
cat > test.txt << 'EOF'
line 1
line 2
line 3
line 4
line 5
line 6
line 7
line 8
line 9
line 10
EOF

git add test.txt
git commit -m "Initial commit"

# 3. Modify lines 3, 4, 5
sed -i '3s/.*/MODIFIED LINE 3/' test.txt
sed -i '4s/.*/MODIFIED LINE 4/' test.txt
sed -i '5s/.*/MODIFIED LINE 5/' test.txt

# 4. Install aliases (if not already installed)
cd /home/m/clone/superpowers
./scripts/install-git-aliases.sh

# 5. Test staging specific lines
cd /tmp/git-alias-test
git stage-lines test.txt 3 4

# 6. Verify results
echo "=== Should show ONLY lines 3-4 (staged) ==="
git diff --cached

echo "=== Should show ONLY line 5 (unstaged) ==="
git diff

# 7. Test unstaging
git unstage-lines test.txt 3

echo "=== Should show ONLY line 4 (staged) ==="
git diff --cached

echo "=== Should show lines 3 and 5 (unstaged) ==="
git diff
```

### Expected Results

**After step 5 (stage lines 3-4):**
```diff
# git diff --cached
-line 3
+MODIFIED LINE 3
-line 4
+MODIFIED LINE 4

# git diff
-line 5
+MODIFIED LINE 5
```

**After step 7 (unstage line 3):**
```diff
# git diff --cached
-line 4
+MODIFIED LINE 4

# git diff
-line 3
+MODIFIED LINE 3
-line 5
+MODIFIED LINE 5
```

### If Test PASSES

✅ Document results in VERIFICATION-REPORT.md
✅ Proceed to fix #2

### If Test FAILS

#### Option A: Fix Implementation

Research working git line-staging approaches and update script.

#### Option B: Document Limitation

Update `docs/parallel-development.md`:

```markdown
## Git Line-Staging Aliases

### ⚠️ Experimental Feature

**Status:** The line-staging aliases are experimental and may not work correctly in all scenarios.

**Known Limitations:**
- [List discovered limitations]

**Alternative Approach:**
- Use `git add -p` (interactive patch mode)
- Use `git add -e` (edit patch in editor)
```

#### Option C: Remove Feature

If unfixable and alternatives exist:
- Remove git aliases section from plan
- Update README.md to remove reference
- Keep documentation for reference but mark as inactive

---

## IMPORTANT FIX #2: Add Error Handling

**Priority:** SHOULD FIX
**Estimated Time:** 5 minutes
**File:** `scripts/install-git-aliases.sh`

### Current Code
```bash
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

### Fixed Code
```bash
#!/bin/bash
set -e  # Exit on error

# Install git aliases for line-level staging
# Enables parallel agent development without staging conflicts

echo "Installing git line-staging aliases..."

if ! git config --global alias.stage-lines '!f() { \
    file=$1; \
    shift; \
    git diff "$file" | \
    git apply --cached --unidiff-zero - <<< "$(echo "$@" | tr " " "\n" | \
    while read line; do git diff "$file" | grep -A1 "^@@.*+${line}" | tail -1; done)"; \
}; f'; then
    echo "❌ Failed to install stage-lines alias"
    echo "Error: git config command failed"
    exit 1
fi

if ! git config --global alias.unstage-lines '!f() { \
    file=$1; \
    shift; \
    git diff --cached "$file" | \
    git apply --cached --reverse --unidiff-zero - <<< "$(echo "$@" | tr " " "\n" | \
    while read line; do git diff --cached "$file" | grep -A1 "^@@.*+${line}" | tail -1; done)"; \
}; f'; then
    echo "❌ Failed to install unstage-lines alias"
    echo "Error: git config command failed"
    exit 1
fi

echo "✓ Git aliases installed successfully"
echo ""
echo "Usage:"
echo "  git stage-lines <file> <line-numbers...>"
echo "  git unstage-lines <file> <line-numbers...>"
echo ""
echo "To verify installation:"
echo "  git config --global --get alias.stage-lines"
```

### Apply Fix
```bash
cd /home/m/clone/superpowers
# Backup original
cp scripts/install-git-aliases.sh scripts/install-git-aliases.sh.bak

# Apply fix (paste fixed code into editor)
nano scripts/install-git-aliases.sh

# Test
./scripts/install-git-aliases.sh

# Commit
git add scripts/install-git-aliases.sh
git commit -m "fix: add error handling to git alias installation script

- Add set -e for fail-fast behavior
- Check git config command success
- Provide clear error messages on failure
- Add verification instructions to output
"
```

---

## IMPORTANT FIX #3: Run Verification Steps

**Priority:** SHOULD FIX
**Estimated Time:** 2 minutes

### Commands
```bash
cd /home/m/clone/superpowers

# Step 3 from plan
./scripts/install-git-aliases.sh

# Step 4 from plan
git config --global --get-regexp alias.stage-lines
git config --global --get-regexp alias.unstage-lines
```

### Document Results

Create or update `VERIFICATION-REPORT.md`:

```markdown
# Phase 1 Verification Report

**Date:** 2025-11-23
**Verifier:** [Your name]

## Task 1: Git Line-Staging Aliases

### Installation Script Test

**Command:**
```bash
./scripts/install-git-aliases.sh
```

**Output:**
```
[Paste actual output]
```

**Status:** ✅ PASS / ❌ FAIL

### Alias Verification

**Command:**
```bash
git config --global --get-regexp alias.stage-lines
git config --global --get-regexp alias.unstage-lines
```

**Output:**
```
[Paste actual output]
```

**Status:** ✅ PASS / ❌ FAIL

### Functional Test

[Results from Critical Fix #1 test procedure]

**Status:** ✅ PASS / ❌ FAIL

---

## Overall Status

- [x] Installation script executes without errors
- [x] Aliases are installed in global git config
- [x] Functional testing completed
- [ ] All tests passed

**Ready to proceed:** YES / NO
```

---

## MINOR FIX #4: Move Plan to Correct Directory

**Priority:** NICE TO HAVE
**Estimated Time:** 1 minute

### Commands
```bash
cd /home/m/clone/superpowers

# Create plans directory
mkdir -p docs/plans

# Move plan
git mv 2025-11-23-community-fork-integration.md docs/plans/

# Commit
git commit -m "refactor: move integration plan to docs/plans directory

Follows project organizational structure.
"
```

---

## MINOR FIX #5: Update Plan with Actual Paths

**Priority:** NICE TO HAVE
**Estimated Time:** 5 minutes

### Changes Needed

**File:** `docs/plans/2025-11-23-community-fork-integration.md`

**Find:** `skills/requesting-code-review.md`
**Replace:** `skills/requesting-code-review/SKILL.md`

**Find:** `skills/systematic-debugging.md`
**Replace:** `skills/systematic-debugging/SKILL.md`

**Find:** `skills/brainstorming.md`
**Replace:** `skills/brainstorming/SKILL.md`

**Add note at top of plan:**
```markdown
> **Note:** This repository uses `skills/skill-name/SKILL.md` structure, not `skills/skill-name.md`.
> Path references updated to reflect actual structure.
```

### Apply Fix
```bash
cd /home/m/clone/superpowers/docs/plans

# Edit file
nano 2025-11-23-community-fork-integration.md

# Commit
git add 2025-11-23-community-fork-integration.md
git commit -m "docs: update plan with correct skill file paths

Reflects actual repository structure (skills/name/SKILL.md).
"
```

---

## MINOR FIX #6: Validate Internal Links

**Priority:** NICE TO HAVE
**Estimated Time:** 5 minutes

### Link Validation Script

Create `scripts/validate-links.sh`:

```bash
#!/bin/bash
set -e

echo "Validating internal markdown links..."
errors=0

while IFS=: read -r file link_line; do
    # Extract link path
    link=$(echo "$link_line" | grep -o "\](../[^)]*)" | sed 's/](//' | sed 's/)//' | sed 's/#.*//')

    if [ -z "$link" ]; then
        continue
    fi

    # Resolve relative path
    dir=$(dirname "$file")
    target="$dir/$link"

    # Normalize path
    target=$(realpath -m "$target" 2>/dev/null || echo "$target")

    # Check if file exists
    if [ ! -f "$target" ]; then
        echo "❌ Broken link in $file:"
        echo "   Link: $link"
        echo "   Resolved to: $target"
        echo ""
        errors=$((errors + 1))
    fi
done < <(find docs skills -name "*.md" -exec grep -H "](../" {} \; 2>/dev/null)

if [ $errors -eq 0 ]; then
    echo "✅ All links valid"
    exit 0
else
    echo "❌ Found $errors broken link(s)"
    exit 1
fi
```

### Run Validation
```bash
cd /home/m/clone/superpowers
chmod +x scripts/validate-links.sh
./scripts/validate-links.sh
```

### Fix Any Broken Links

If script reports broken links, fix them in the respective files.

---

## Checklist

Before proceeding to Phase 2:

- [ ] **CRITICAL:** Git aliases functionally tested
- [ ] **CRITICAL:** Test results documented
- [ ] **IMPORTANT:** Error handling added to script
- [ ] **IMPORTANT:** Verification steps executed
- [ ] **IMPORTANT:** Plan paths updated
- [ ] **MINOR:** Plan moved to docs/plans/
- [ ] **MINOR:** Links validated
- [ ] **MINOR:** All fixes committed

---

## Quick Fix All Script

If you want to apply all fixes at once:

```bash
#!/bin/bash
cd /home/m/clone/superpowers

echo "Applying all Phase 1 fixes..."

# Fix #4: Move plan
mkdir -p docs/plans
git mv 2025-11-23-community-fork-integration.md docs/plans/ 2>/dev/null || true

# Fix #2: Add error handling (manual - see above)
echo "⚠️  Fix #2 requires manual editing of scripts/install-git-aliases.sh"

# Fix #6: Create link validator
cat > scripts/validate-links.sh << 'EOF'
[paste script from Fix #6]
EOF
chmod +x scripts/validate-links.sh

# Fix #3: Run verification
./scripts/install-git-aliases.sh
git config --global --get-regexp alias.stage-lines
git config --global --get-regexp alias.unstage-lines

# Fix #1: Test aliases (manual - see above)
echo "⚠️  Fix #1 requires manual testing - see FIXES-REQUIRED.md"

echo "✓ Automated fixes applied"
echo "⚠️  Manual fixes still required - see above"
```

---

**End of Required Fixes**
**Next:** Complete fixes, then proceed to Phase 2
