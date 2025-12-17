---
paths:
  - tsconfig.json
  - package.json
---

# TypeScript プロジェクトセットアップ

## 手順

```bash
# 1. ディレクトリ作成 & 移動
mkdir <repo-name> && cd <repo-name>

# 2. Git 初期化
git init

# 3. npm 初期化
npm init -y

# 4. TypeScript 設定ファイル生成
npx tsc --init

# 5. 設定ファイル作成（後述の内容で作成）
#    - .oxfmtrc.json
#    - .oxlintrc.json
#    - lefthook.yml
#    - .textlintrc
#    - .github/workflows/deploy.yml
#    - .gitignore

# 6. パッケージ一括インストール
npm install -D oxfmt oxlint oxlint-tsgolint textlint textlint-rule-preset-ja-spacing @textlint/textlint-plugin-text lefthook typescript vitest

# 7. lefthook 初期化
npx lefthook install

# 8. GitHub リポジトリ作成 & push
gh repo create <repo-name> --private --source=. --push
```

## .oxfmtrc.json

Prettier 互換の設定。シングルクォート、printWidth: 80 を使用:

```json
{
  "$schema": "./node_modules/oxfmt/configuration_schema.json",
  "printWidth": 80,
  "tabWidth": 2,
  "useTabs": false,
  "semi": true,
  "singleQuote": true,
  "embeddedLanguageFormatting": "auto"
}
```

## .oxlintrc.json

oxlint Alpha から `--type-aware --type-check` オプションが追加され、`tsc --noEmit && eslint` を 1 コマンドに統合できるようになった。

- `--type-aware`: TypeScript の型情報を使った lint ルール（`@typescript-eslint` 相当）を有効化
- `--type-check`: `tsc --noEmit` 相当の型チェックを同時実行

基本的なルール設定。デフォルトで十分な場合は省略可能:

```json
{
  "$schema": "./node_modules/oxlint/configuration_schema.json",
  "plugins": ["typescript", "unicorn", "oxc"],
  "rules": {
    "no-console": "warn",
    "no-unused-vars": "error",
    "eqeqeq": "error"
  },
  "ignorePatterns": ["dist/", "node_modules/"]
}
```

## tsconfig.json 変更箇所

`npx tsc --init` 実行後、以下を設定:

```json
{
  "compilerOptions": {
    "target": "ES2021",
    "module": "ES2022",
    "lib": ["ES2021"],
    "moduleResolution": "node",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules"]
}
```

## lefthook.yml

```yaml
pre-commit:
  parallel: true
  commands:
    oxfmt:
      glob: "*.{js,ts,tsx,json,md,css,yaml,yml}"
      run: npx oxfmt --no-error-on-unmatched-pattern {staged_files}
      stage_fixed: true
    oxlint:
      glob: "*.{js,ts,tsx}"
      run: npx oxlint --type-aware --type-check --fix {staged_files}
      stage_fixed: true
    textlint:
      glob: "*.md"
      run: npx textlint --fix {staged_files}
      stage_fixed: true

pre-push:
  commands:
    test:
      run: npm test
```

## .textlintrc

```json
{
  "rules": {
    "preset-ja-spacing": {
      "ja-space-between-half-and-full-width": {
        "space": "always"
      }
    }
  }
}
```

## GitHub Actions（Cloudflare Workers デプロイ）

`.github/workflows/deploy.yml`:

```yaml
name: Deploy

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: "20"
      - run: npm ci
      - uses: cloudflare/wrangler-action@v3
        with:
          apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
```

## .gitignore

```
node_modules/
.env
.env.*
!.env.example
.wrangler/
dist/
*.log
```

## package.json scripts

```json
{
  "scripts": {
    "test": "vitest run",
    "test:watch": "vitest",
    "lint": "oxlint --type-aware --type-check --fix src/ && textlint --fix '**/*.md'",
    "format": "oxfmt",
    "check": "oxfmt --check && oxlint --type-aware --type-check src/",
    "prepare": "lefthook install"
  }
}
```

## Git hooks

Git hooks には lefthook を使う。husky は使わない。
