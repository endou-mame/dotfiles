#!/bin/sh
# mise のネイティブインストール
# https://mise.jdx.dev/getting-started.html

set -euo pipefail

echo "📦 Installing mise..."

curl https://mise.run | sh

# インストール確認
if command -v mise &> /dev/null; then
    echo "✅ mise installed successfully"
    echo "mise version: $(mise --version)"
else
    echo "⚠️ mise installation may have failed"
    exit 1
fi

echo "✅ mise setup complete"
