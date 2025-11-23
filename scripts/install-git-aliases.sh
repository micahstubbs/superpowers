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
