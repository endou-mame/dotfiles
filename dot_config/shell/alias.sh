#!/bin/sh

# =============================================================================
# エイリアス
# =============================================================================
# eza settings
# https://github.com/eza-community/eza
EZA_DEFAULT_PARAMS='--git --group --group-directories-first --time-style=long-iso --color-scale=all --icons'

alias ls="eza $EZA_DEFAULT_PARAMS"
alias l="eza --git-ignore $EZA_DEFAULT_PARAMS"
alias ll="eza --all --header --long $EZA_DEFAULT_PARAMS"
alias llm="eza --all --header --long --sort=modified $EZA_DEFAULT_PARAMS"
alias la="eza -lbhHigUmuSa"
alias lx="eza -lbhHigUmuSa@"
alias lt="eza --tree $EZA_DEFAULT_PARAMS"
alias tree="eza --tree $EZA_DEFAULT_PARAMS"

# bat settings
# https://github.com/sharkdp/bat
alias cat="bat --theme-dark default --theme-light GitHub"
