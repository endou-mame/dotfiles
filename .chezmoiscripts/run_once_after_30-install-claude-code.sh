#!/bin/bash
# Claude Code のネイティブインストール
# https://code.claude.com/docs/ja/setup#native-install-recommended

set -euo pipefail

CLAUDE_BIN="${HOME}/.local/bin/claude"

echo "📦 Installing Claude Code (native)..."
echo "DEBUG: HOME=${HOME}"
echo "DEBUG: CLAUDE_BIN=${CLAUDE_BIN}"

curl -fsSL https://claude.ai/install.sh | bash

echo "DEBUG: Installation completed, checking binary..."
echo "DEBUG: ls result:"
ls -la "$CLAUDE_BIN" 2>&1 || echo "DEBUG: ls failed"

echo "DEBUG: test -x result:"
test -x "$CLAUDE_BIN" && echo "DEBUG: executable" || echo "DEBUG: not executable"

echo "DEBUG: test -L result:"
test -L "$CLAUDE_BIN" && echo "DEBUG: is symlink" || echo "DEBUG: not symlink"

# インストール確認
if [[ -x "$CLAUDE_BIN" ]]; then
    echo "✅ Claude Code installed successfully"
    echo "Claude Code version: $("$CLAUDE_BIN" --version)"
else
    echo "⚠️ Claude Code installation may have failed"
    exit 1
fi

echo ""
echo "ℹ️  Claude Code は自動更新されます"
echo "   手動更新: claude update"
echo "   状態確認: claude doctor"