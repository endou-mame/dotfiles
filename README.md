# dotfiles
endou-mame's dotfiles managed by [chezmoi](https://www.chezmoi.io/).

## Get started

#### 1. Install chezmoi

```
brew install chezmoi
```

#### 2. Clone dotfiles

```
chezmoi init https://github.com/endou-mame/dotfiles.git
```

#### 3. Login to 1password cli (TODO: not implemented)

```
# On bash
eval $(op my.1password.com メールアドレス)

# On fish with fish-replay
replay 'eval $(op my.1password.com メールアドレス)'
```

#### 4. Apply dotfiles

```
chezmoi apply
```
