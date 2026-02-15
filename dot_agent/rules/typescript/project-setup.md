---
paths:
  - tsconfig.json
  - package.json
---

# TypeScript Project Setup

## Steps

```bash
# 1. Create & Move to Directory
mkdir <repo-name> && cd <repo-name>

# 2. Initialize Git
git init

# 3. Initialize npm
npm init -y

# 4. Generate TypeScript Config File
npx tsc --init

# 5. Create Configuration Files (as described below)
#    - .oxfmtrc.json
#    - .oxlintrc.json
#    - lefthook.yml
#    - .textlintrc
#    - .github/workflows/deploy.yml
#    - .gitignore

# 6. Install Packages in Bulk
npm install -D oxfmt oxlint oxlint-tsgolint textlint textlint-rule-preset-ja-spacing @textlint/textlint-plugin-text lefthook typescript vitest

# 7. Initialize lefthook
npx lefthook install

# 8. Create GitHub Repository & Push
gh repo create <repo-name> --private --source=. --push
```

## .oxfmtrc.json

Prettier compatible configuration. Uses single quotes and printWidth: 80:

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

With the addition of the `--type-aware --type-check` options in oxlint Alpha, it is now possible to integrate `tsc --noEmit && eslint` into a single command.

- `--type-aware`: Enables lint rules that use TypeScript's type information (equivalent to `@typescript-eslint`).
- `--type-check`: Concurrently executes type checking equivalent to `tsc --noEmit`.

Basic rule configuration. Can be omitted if defaults are sufficient:

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

## tsconfig.json Modifications

After running `npx tsc --init`, set the following:

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

## GitHub Actions (Cloudflare Workers Deployment)

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

Uses lefthook for Git hooks. Does not use Husky.
