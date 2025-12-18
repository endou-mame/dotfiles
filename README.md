# dotfiles

endou-mame's dotfiles managed by [chezmoi](https://www.chezmoi.io/).

WSL2 (Linux) 環境向けに設計された dotfiles で、複数の Linux ディストリビューションに対応しています。

## 特徴

- chezmoi によるクロスプラットフォーム dotfiles 管理
- 複数の Linux ディストリビューションに対応（Arch, Ubuntu, Debian, Fedora, openSUSE）
- ZSH + Sheldon + Starship によるモダンなシェル環境
- mise によるランタイムバージョン管理
- WSL2 環境に最適化（Windows 通知連携、VSCode パス自動追加）
- Claude Code のカスタムフック・コマンド・ルール
- GitHub Actions による複数ディストロでの自動テスト

## 対応環境

| ディストリビューション | パッケージマネージャー |
|------------------------|------------------------|
| Arch Linux | pacman |
| Ubuntu | apt |
| Debian | apt |
| Fedora / RHEL / CentOS | dnf |
| openSUSE Tumbleweed / Leap | zypper |

## インストール

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b $HOME/.local/bin init --apply git@github.com:endou-mame/dotfiles.git
```

このコマンドで以下が自動実行されます:

1. システムパッケージのインストール（curl, git, neovim, zsh, docker など）
2. [Homebrew (Linuxbrew)](https://docs.brew.sh/Homebrew-on-Linux) のインストール
3. [`~/.Brewfile`](./dot_Brewfile) に基づくパッケージのインストール
4. 設定ファイルの配置

## 含まれる設定

### シェル環境

| ツール | 説明 |
|--------|------|
| ZSH | メインシェル。ZDOTDIR で [`~/.config/zsh/`](./dot_config/zsh/) に設定を集約 |
| Starship | カスタマイズ可能なプロンプト [`~/.config/starship.toml`](./dot_config/starship.toml) |
| Sheldon | ZSH プラグイン管理（遅延読み込み対応） [`~/.config/sheldon/plugins.toml`](./dot_config/sheldon/plugins.toml) |

ZSH プラグイン:

- zsh-completions: 補完拡張
- zsh-autosuggestions: コマンド提案
- fzf-tab: fzf による補完
- zsh-syntax-highlighting: シンタックスハイライト

### CLI ツール（Homebrew）

[`~/.Brewfile`](./dot_Brewfile)

| ツール | 説明 |
|--------|------|
| bat | シンタックスハイライト付き cat |
| eza | モダンな ls 代替 |
| fzf | fuzzy finder |
| ghq | Git リポジトリ管理 |
| gh | GitHub CLI |
| fastfetch | システム情報表示 |
| jq | JSON プロセッサ |
| dive | Docker イメージ解析 |

### ランタイム管理（mise）

[`~/.config/mise/config.toml`](./dot_config/mise/config.toml)

| ランタイム | バージョン |
|------------|------------|
| Node.js | 24 |
| PHP | 8.5 |
| Python | latest |
| uv | latest |

### Claude Code

[`~/.claude/`](./dot_claude/)

| 設定 | 説明 |
|------|------|
| CLAUDE.md | 開発ガイドライン（日本語応答、Subagent活用など） |
| hooks | Windows 通知、コンテキスト保存/復元 |
| commands | `/fix-github-issue` カスタムコマンド |
| rules | chezmoi, cloudflare, python, typescript 用ルール |
| skills | draw.io ドキュメントアシスタント |

### Git

[`~/.gitconfig`](./dot_gitconfig)

- merge: fast-forward 禁止（マージコミットを明示的に作成）
- pull: fast-forward のみ許可
- デフォルトブランチ: main

### テキスト校正（textlint）

[`~/.textlintrc`](./dot_textlintrc)

日本語技術文書向けルール:

- preset-ja-spacing: 半角・全角間のスペース
- preset-ja-technical-writing: 技術文書向け
- preset-ai-writing: AI 文書向け

## ディレクトリ構造

```
.
├── .chezmoiignore
├── .github/workflows/test.yml
├── dot_Brewfile                 → ~/.Brewfile
├── dot_gitconfig                → ~/.gitconfig
├── dot_textlintrc               → ~/.textlintrc
├── dot_zshenv                   → ~/.zshenv
├── dot_config/
│   ├── fastfetch/config.jsonc   → ~/.config/fastfetch/config.jsonc
│   ├── mise/config.toml         → ~/.config/mise/config.toml
│   ├── sheldon/plugins.toml     → ~/.config/sheldon/plugins.toml
│   └── zsh/
│       ├── dot_zprofile         → ~/.config/zsh/.zprofile
│       ├── dot_zshenv           → ~/.config/zsh/.zshenv
│       └── dot_zshrc            → ~/.config/zsh/.zshrc
├── dot_claude/
│   ├── CLAUDE.md                → ~/.claude/CLAUDE.md
│   ├── settings.json            → ~/.claude/settings.json
│   ├── commands/
│   ├── hooks/
│   ├── rules/
│   └── skills/
├── run_once_01-install-packages.sh.tmpl
├── run_once_02-install-homebrew.sh.tmpl
└── run_onchange_03-brew-bundle.sh.tmpl
```

chezmoi の命名規則:

| 接頭辞 | 役割 |
|--------|------|
| `dot_` | ドットファイル/ディレクトリに展開 |
| `run_once_` | 初回のみ実行 |
| `run_onchange_` | ファイル変更時に実行 |
| `executable_` | 実行権限付きで展開 |
| `.tmpl` | Go テンプレートとして処理 |

## よく使う chezmoi コマンド

```sh
chezmoi apply -n     # ドライラン（変更内容を確認）
chezmoi diff         # 差分を表示
chezmoi update       # リモートから更新して適用
chezmoi add <file>   # ファイルを管理対象に追加
chezmoi cd           # ソースディレクトリへ移動
chezmoi re-add       # 変更したファイルを再追加
```

## カスタム関数 ([`~/.zshrc`](./dot_config/zsh/dot_zshrc) にて定義)

### gitls

[`~/.zshrc`](./dot_config/zsh/dot_zshrc#L117)

ghq で管理しているリポジトリを fzf で選択して移動:

```sh
gitls
```

### gitget

[`~/.zshrc`](./dot_config/zsh/dot_zshrc#L126)

リポジトリを ghq get して自動的に移動:

```sh
gitget https://github.com/user/repo
```

### gitrm

[`~/.zshrc`](./dot_config/zsh/dot_zshrc#L136)

ghq リポジトリを安全に削除（未コミット/未プッシュの変更がある場合は警告）:

```sh
gitrm
```

### brew（ラッパー）

[`~/.zshrc`](./dot_config/zsh/dot_zshrc#L90)

`brew install` / `brew uninstall` 時に Brewfile を自動更新し、chezmoi に反映:

```sh
brew install <package>
brew uninstall <package>
```

## CI

[test.yml](./.github/workflows/test.yml)

GitHub Actions で以下のディストリビューションでの dotfiles 適用をテスト:

- Ubuntu 24.04 / 22.04
- Debian 12
- Fedora 40
- Arch Linux
- openSUSE Tumbleweed

## ライセンス

MIT
