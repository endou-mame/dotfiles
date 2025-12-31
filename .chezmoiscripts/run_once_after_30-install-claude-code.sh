#!/bin/bash
# Claude Code のネイティブインストール
# https://code.claude.com/docs/ja/setup#native-install-recommended

set -euo pipefail

echo "📦 Installing Claude Code (native)..."

curl -fsSL https://claude.ai/install.sh | bash

# インストール確認
if command -v claude &> /dev/null; then
    echo "✅ Claude Code installed successfully"
    echo "Claude Code version: $(claude --version)"
else
    echo "⚠️ Claude Code installation may have failed"
    exit 1
fi

echo ""
echo "ℹ️  Claude Code は自動更新されます"
echo "   手動更新: claude update"
echo "   状態確認: claude doctor"
