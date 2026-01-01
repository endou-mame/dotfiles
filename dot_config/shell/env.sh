#!/bin/sh

# =============================================================================
# 環境変数設定
# =============================================================================
# Windows ユーザー名を取得 (WSL2)
if [ -d /mnt/c ]; then
    WIN_USER=$(/mnt/c/Windows/System32/cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r')
fi

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

# WSL2専用
if [ -n "$WIN_USER" ]; then
    add_to_path "/mnt/c/Users/${WIN_USER}/AppData/Local/Programs/Microsoft VS Code/bin"
fi

export PATH
