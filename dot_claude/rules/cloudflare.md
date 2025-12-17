---
paths:
  - wrangler.toml
  - wrangler.jsonc
---

# Cloudflare

## Pages ではなく Workers を使う

2025年時点で Cloudflare Pages は非推奨。新機能開発は全て Workers に集中しており、Pages は維持モードで将来的に終了予定。

- 新規プロジェクトでは Cloudflare Workers を使用する
- Workers は静的アセット配信と SSR の両方をサポート
- Pages Functions ではなく Workers を使う

参考: https://developers.cloudflare.com/workers/static-assets/migration-guides/migrate-from-pages/

## カスタムドメイン設定: routes ではなく custom_domain を使う

Workers にカスタムドメインを設定する場合、`routes` + `zone_name` ではなく `custom_domain = true` を使用する。

```toml
# NG: DNS レコードを手動作成する必要がある
routes = [
  { pattern = "example.com/*", zone_name = "example.com" }
]

# OK: DNS レコードと SSL 証明書が自動作成される
[[routes]]
pattern = "example.com"
custom_domain = true
```

| 設定                   | DNS レコード | SSL 証明書 | 用途                                       |
| ---------------------- | ------------ | ---------- | ------------------------------------------ |
| `routes` + `zone_name` | 手動作成     | 手動       | 特定パスのみ Worker に向ける場合           |
| `custom_domain = true` | 自動作成     | 自動       | ドメイン全体を Worker に向ける場合（推奨） |

## wrangler CLI の注意点

- コマンド構文: スペース区切り（`wrangler kv key list`）。古いコロン区切り（`wrangler kv:key list`）は動作しない
- KV 操作時は `--remote` オプション必須。省略するとローカルの空ストレージを参照してしまう

```bash
# NG: ローカルストレージを参照（データがないように見える）
npx wrangler kv key list --namespace-id xxx

# OK: リモート（本番）KV を参照
npx wrangler kv key list --namespace-id xxx --remote
```

- 一括削除: キーを JSON 配列ファイルに保存して `wrangler kv bulk delete` を使用

```bash
# キーをリストアップして JSON 配列に変換
npx wrangler kv key list --namespace-id xxx --remote | jq -r '.[].name' | jq -R . | jq -s . > keys.json

# 一括削除
npx wrangler kv bulk delete keys.json --namespace-id xxx --remote --force
```
