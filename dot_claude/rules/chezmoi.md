---
paths:
  - ".chezmoi*"
  - chezmoi.toml
---

# chezmoi

`chezmoi update` でコンフリクトが発生したら、確認を求めずに自分で `chezmoi diff` を実行し、適切なアクション（`--force` でリモート適用、または `chezmoi re-add` でローカル反映）を提案する。
