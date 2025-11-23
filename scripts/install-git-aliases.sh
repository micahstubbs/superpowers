#!/bin/bash

# Install git aliases for line-level staging
# Enables parallel agent development without staging conflicts

set -e

echo "Installing git line-staging aliases..."

if ! git config --global alias.stage-lines '!f() { \
    file=$1; \
    shift; \
    git diff "$file" | \
    git apply --cached --unidiff-zero - <<< "$(echo "$@" | tr " " "\n" | \
    while read line; do git diff "$file" | grep -A1 "^@@.*+${line}" | tail -1; done)"; \
}; f'; then
    echo "Error: Failed to install stage-lines alias"
    exit 1
fi

if ! git config --global alias.unstage-lines '!f() { \
    file=$1; \
    shift; \
    git diff --cached "$file" | \
    git apply --cached --reverse --unidiff-zero - <<< "$(echo "$@" | tr " " "\n" | \
    while read line; do git diff --cached "$file" | grep -A1 "^@@.*+${line}" | tail -1; done)"; \
}; f'; then
    echo "Error: Failed to install unstage-lines alias"
    exit 1
fi

echo "✓ Git aliases installed successfully"
echo "Usage:"
echo "  git stage-lines <file> <line-numbers...>"
echo "  git unstage-lines <file> <line-numbers...>"
