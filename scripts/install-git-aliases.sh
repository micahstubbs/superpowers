#!/bin/bash

# Install git aliases for line-level staging
# Enables parallel agent development without staging conflicts

set -e

echo "Installing git line-staging aliases..."

# Note: These aliases provide a simplified line-staging workflow
# For production use, consider tools like git add -p or git gui

if ! git config --global alias.stage-lines '!bash -c '\''git add -p "$1"'\'' -'; then
    echo "Error: Failed to install stage-lines alias"
    exit 1
fi

if ! git config --global alias.unstage-lines '!bash -c '\''git reset -p "$1"'\'' -'; then
    echo "Error: Failed to install unstage-lines alias"
    exit 1
fi

echo "✓ Git aliases installed successfully"
echo ""
echo "Usage:"
echo "  git stage-lines <file>     # Interactive staging (use git add -p)"
echo "  git unstage-lines <file>   # Interactive unstaging (use git reset -p)"
echo ""
echo "Note: These aliases use interactive mode (-p flag) for line-level control."
echo "      Press 'y' to stage a hunk, 'n' to skip, 's' to split, '?' for help."
