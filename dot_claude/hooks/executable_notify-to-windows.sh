#!/bin/bash
#
# WSL2からWindows側へ通知を送るスクリプト
#
# PowerShellを使用してWindows バルーン通知を送信（カスタムアイコン対応）
#

set -euo pipefail

# PowerShellのパス
POWERSHELL_PATH="/mnt/c/windows/System32/WindowsPowerShell/v1.0/powershell.exe"

# 通知タイプの定義（絵文字のみ）
declare -A NOTIFICATION_EMOJI=(
    ["info"]="ℹ️"
    ["success"]="✅"
    ["warning"]="⚠️"
    ["error"]="❌"
)

# 通知を送信する関数
send_notification() {
    local title="$1"
    local message="$2"
    local type="${3:-info}"
    local duration="${4:-5000}"

    # 引数の検証
    if [[ -z "$title" || -z "$message" ]]; then
        echo "エラー: タイトルとメッセージが必要です" >&2
        return 1
    fi

    # 通知タイプの検証
    local valid_types="info success warning error"
    if [[ ! " $valid_types " =~ " $type " ]]; then
        echo "エラー: 無効な通知タイプ '$type'. 使用可能: $valid_types" >&2
        return 1
    fi

    # 絵文字を取得
    local emoji="${NOTIFICATION_EMOJI[$type]}"

    # タイトルに絵文字を追加
    local enhanced_title="$emoji $title"

    # シングルクォートをエスケープ
    enhanced_title=$(echo "$enhanced_title" | sed "s/'/''/g")
    message=$(echo "$message" | sed "s/'/''/g")

    # PowerShell バルーン通知スクリプト（Sleep完全削除）
    local notification_script="
Add-Type -AssemblyName System.Windows.Forms

\$notification = New-Object System.Windows.Forms.NotifyIcon
\$notification.Icon = [System.Drawing.SystemIcons]::Information
\$notification.BalloonTipTitle = '$enhanced_title'
\$notification.BalloonTipText = '$message'
\$notification.Visible = \$true
\$notification.ShowBalloonTip($duration)
\$notification.Dispose()
"

    # 通知送信の実行（同期実行）
    timeout 5s "$POWERSHELL_PATH" -NoProfile -Command "$notification_script" >/dev/null 2>&1

    return 0
}

# ヘルプ表示
show_help() {
    cat << EOF
WSL2からWindows バルーン通知を送信するスクリプト

使用方法:
  $0 -t タイトル -m メッセージ [-T タイプ] [-d 表示時間ms]

オプション:
  -t, --title     通知タイトル（必須）
  -m, --message   通知メッセージ（必須）
  -T, --type      通知タイプ [info|success|warning|error] (デフォルト: info)
  -d, --duration  表示時間（ミリ秒）(デフォルト: 5000)
  -h, --help      このヘルプを表示

通知タイプ（絵文字付き）:
  info      - ℹ️ （デフォルト）
  success   - ✅
  warning   - ⚠️
  error     - ❌

例:
  $0 -t "完了" -m "処理が正常に終了しました" -T success
  $0 -t "エラー" -m "接続に失敗しました" -T error
  $0 -t "警告" -m "ディスク容量が不足しています" -T warning
EOF
}

# PowerShellの存在確認
check_powershell() {
    if [[ ! -x "$POWERSHELL_PATH" ]]; then
        echo "エラー: PowerShellが見つかりません: $POWERSHELL_PATH" >&2
        echo "WSL2環境でWindowsのPowerShellにアクセスできることを確認してください" >&2
        return 1
    fi
}

# メイン処理
main() {
    check_powershell

    local title=""
    local message=""
    local type="info"
    local duration="5000"

    # オプション解析
    while [[ $# -gt 0 ]]; do
        case $1 in
            -t|--title)
                title="$2"
                shift 2
                ;;
            -m|--message)
                message="$2"
                shift 2
                ;;
            -T|--type)
                type="$2"
                shift 2
                ;;
            -d|--duration)
                duration="$2"
                shift 2
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                echo "エラー: 不明なオプション '$1'" >&2
                show_help >&2
                exit 1
                ;;
        esac
    done

    # タイトルとメッセージの必須チェック
    if [[ -z "$title" || -z "$message" ]]; then
        echo "エラー: タイトルとメッセージは必須です" >&2
        show_help >&2
        exit 1
    fi

    # 通知送信（同期）
    send_notification "$title" "$message" "$type" "$duration"
    echo "通知を送信しました"
    exit 0
}

# スクリプトが直接実行された場合のみmainを実行
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
