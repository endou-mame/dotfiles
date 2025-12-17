---
paths:
  - "*.py"
  - pyproject.toml
  - uv.lock
---

# uv（Python パッケージ管理）

`uv add` を基本とする。`uv pip install` は移行期間や一時実験のみ。

| コマンド         | 用途                 | pyproject.toml | uv.lock      |
| ---------------- | -------------------- | -------------- | ------------ |
| `uv add`         | 新規プロジェクト開発 | 自動更新       | 自動生成     |
| `uv pip install` | 移行期間・一時実験   | 更新されない   | 生成されない |

```bash
# パッケージ追加（pyproject.toml に記録）
uv add requests

# 開発用依存
uv add --dev pytest

# 実行（activate 不要）
uv run python main.py

# 環境同期（clone 後）
uv sync

# 既存 requirements.txt からの移行
uv add -r requirements.txt
```
