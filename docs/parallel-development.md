# Parallel Development with Superpowers

## Overview

This guide explains how to work with multiple AI agents or developers simultaneously on the same codebase without conflicts.

## Git Line-Staging Aliases

### Installation

Run the installation script:

```bash
./scripts/install-git-aliases.sh
```

### Usage

**Stage specific lines:**
```bash
git stage-lines src/file.py 42 43 44
```

**Unstage specific lines:**
```bash
git unstage-lines src/file.py 42
```

### Why This Matters

Traditional `git add` stages entire files. When multiple agents work in parallel:
- Agent A modifies lines 10-20 in file.py
- Agent B modifies lines 50-60 in file.py
- Both run `git add file.py` → conflict!

With line-staging:
- Agent A: `git stage-lines file.py 10 11 12 ... 20`
- Agent B: `git stage-lines file.py 50 51 52 ... 60`
- No conflict! Each agent stages only their changes.

## Concurrent-Safe Code Review

See the `requesting-code-review` skill for details on using commit SHAs instead of git ranges.

**Traditional (unsafe for parallel work):**
```bash
git diff main...HEAD  # Breaks when main moves
```

**Concurrent-safe:**
```bash
git log main..HEAD --format="%H"  # List of commit SHAs
```

The code reviewer uses these specific SHAs, which never change, instead of branch ranges.
