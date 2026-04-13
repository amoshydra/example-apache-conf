#!/bin/bash
# Install git hooks

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOKS_DIR="$SCRIPT_DIR/../.githooks"
GIT_HOOKS_DIR="$SCRIPT_DIR/../.git/hooks"

echo "Installing git hooks..."

# Create .git/hooks if it doesn't exist
mkdir -p "$GIT_HOOKS_DIR"

# Install pre-push hook
if [ -f "$HOOKS_DIR/pre-push" ]; then
    ln -sf "$HOOKS_DIR/pre-push" "$GIT_HOOKS_DIR/pre-push"
    chmod +x "$HOOKS_DIR/pre-push"
    echo "✅ pre-push hook installed"
    echo "   This hook will update README.md with test results before each push"
else
    echo "❌ pre-push hook not found in .githooks/"
    exit 1
fi

echo ""
echo "To uninstall: rm $GIT_HOOKS_DIR/pre-push"
