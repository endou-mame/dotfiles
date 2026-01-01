#!/bin/sh

# =============================================================================
# 環境変数設定
# =============================================================================
# PATH 追加用関数（重複防止）
add_to_path() {
    case ":$PATH:" in
        *:"$1":*) ;;  # 既に存在する場合は何もしない
        *) PATH="$1:$PATH" ;;
    esac
}

# PATH設定
add_to_path "/usr/local/bin"
add_to_path "/usr/local/sbin"
add_to_path "/usr/bin"
add_to_path "/usr/sbin"
add_to_path "/bin"
add_to_path "/sbin"
add_to_path "$HOME/.local/bin"

export PATH
