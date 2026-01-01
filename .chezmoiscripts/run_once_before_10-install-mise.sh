#!/bin/sh
# mise のネイティブインストール
# https://mise.jdx.dev/getting-started.html

set -euo pipefail

echo "📦 Installing mise..."

curl https://mise.run | sh

MISE_BIN="${HOME}/.local/bin/mise"

# インストール確認
if [ -x "$MISE_BIN" ]; then
    echo "✅ mise installed successfully"
    echo "mise version: $($MISE_BIN --version)"
else
    echo "⚠️ mise installation may have failed"
    exit 1
fi

echo "✅ mise setup complete"
