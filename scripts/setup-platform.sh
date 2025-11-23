#!/bin/bash

# Detect which AI coding assistant is being used and set up appropriate integration

set -e

echo "🔍 Detecting AI coding platform..."

PLATFORM=""

# Detect Cursor
if [ -f ".cursorrules" ] || command -v cursor &> /dev/null; then
    PLATFORM="cursor"
fi

# Detect GitHub Copilot (check for .github directory and copilot config)
if [ -d ".github" ] && grep -q "copilot" .github/* 2>/dev/null; then
    PLATFORM="copilot"
fi

# Detect Claude Code (check for .claude directory)
if [ -d ".claude" ]; then
    PLATFORM="claude"
fi

# If not detected, ask user
if [ -z "$PLATFORM" ]; then
    echo "Could not auto-detect platform. Which are you using?"
    echo "1) Claude Code"
    echo "2) Cursor"
    echo "3) GitHub Copilot"
    echo "4) Gemini"
    echo "5) OpenCode"
    read -p "Enter number: " choice

    case $choice in
        1) PLATFORM="claude" ;;
        2) PLATFORM="cursor" ;;
        3) PLATFORM="copilot" ;;
        4) PLATFORM="gemini" ;;
        5) PLATFORM="opencode" ;;
        *) echo "Invalid choice"; exit 1 ;;
    esac
fi

echo "✓ Platform: $PLATFORM"
echo ""
echo "📦 Setting up superpowers for $PLATFORM..."

# Validate platforms directory exists
if [ ! -d "platforms/$PLATFORM" ]; then
    echo "Error: Platform files not found. Are you in the superpowers directory?"
    echo "Expected: platforms/$PLATFORM/"
    exit 1
fi

# Setup based on platform
case $PLATFORM in
    "cursor")
        cp platforms/cursor/.cursorrules .cursorrules
        echo "✓ Created .cursorrules"
        echo ""
        echo "Cursor will now use superpowers skills automatically."
        ;;

    "copilot")
        mkdir -p .github
        cp platforms/copilot/.github/copilot-instructions.md .github/
        echo "✓ Created .github/copilot-instructions.md"
        echo ""
        echo "GitHub Copilot will now use superpowers skills."
        ;;

    "claude")
        if [ ! -d ".claude/skills" ]; then
            mkdir -p .claude/skills
            ln -s ../../skills/* .claude/skills/ 2>/dev/null || cp -r skills/* .claude/skills/
            echo "✓ Linked skills to .claude/skills"
        fi
        echo ""
        echo "Claude Code will use superpowers skills via plugin."
        ;;

    "gemini")
        if [ ! -f "GEMINI.md" ]; then
            cp platforms/gemini/GEMINI.md .
            echo "✓ Created GEMINI.md"
        fi
        echo ""
        echo "Add GEMINI.md to your Gemini project context."
        ;;

    "opencode")
        if [ ! -f "OPENCODE.md" ]; then
            cp platforms/opencode/OPENCODE.md .
            echo "✓ Created OPENCODE.md"
        fi
        echo ""
        echo "Add OPENCODE.md to your OpenCode project context."
        ;;
esac

# Offer to install git aliases
echo ""
read -p "Install git line-staging aliases for parallel development? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    ./scripts/install-git-aliases.sh
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "📚 Next steps:"
echo "  1. Read docs/parallel-development.md for parallel workflow info"
echo "  2. Browse skills/ directory to see available techniques"
echo "  3. Start coding with systematic approaches!"
