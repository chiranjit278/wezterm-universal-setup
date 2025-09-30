#!/usr/bin/env bash
# Shell 自动检测脚本 - Unix/Linux/MacOS
# 用于检测当前用户的默认 shell 及可用 shell 列表

set -euo pipefail

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 获取当前 shell
get_current_shell() {
    local shell_path="${SHELL:-}"
    if [[ -z "$shell_path" ]]; then
        shell_path=$(getent passwd "$USER" 2>/dev/null | cut -d: -f7)
    fi

    if [[ -n "$shell_path" ]]; then
        basename "$shell_path"
    else
        echo "unknown"
    fi
}

# 检测 shell 是否可用
check_shell_available() {
    local shell_name="$1"
    command -v "$shell_name" &>/dev/null
}

# 获取 shell 的完整路径
get_shell_path() {
    local shell_name="$1"
    command -v "$shell_name" 2>/dev/null || echo ""
}

# 检测所有可用的 shell
detect_available_shells() {
    # pwsh: PowerShell Core (跨平台)
    # powershell: Windows PowerShell 5.x (Windows/WSL)
    local shells=("bash" "zsh" "fish" "pwsh" "powershell" "nu")
    local available_shells=()

    for shell in "${shells[@]}"; do
        local shell_path=""

        # 优先检测原生命令
        if check_shell_available "$shell"; then
            shell_path=$(get_shell_path "$shell")
        # WSL环境下检测Windows PowerShell
        elif [[ "$shell" == "powershell" ]] && command -v powershell.exe &>/dev/null; then
            shell_path=$(command -v powershell.exe 2>/dev/null)
        fi

        # 如果找到了shell,添加到列表
        if [[ -n "$shell_path" ]]; then
            available_shells+=("$shell:$shell_path")
        fi
    done

    printf '%s\n' "${available_shells[@]}"
}

# 主函数
main() {
    log_info "开始检测 Shell 环境..."
    echo

    # 检测当前 shell
    local current_shell
    current_shell=$(get_current_shell)
    log_success "当前默认 Shell: $current_shell"

    if [[ -n "$SHELL" ]]; then
        log_info "Shell 路径: $SHELL"
    fi

    echo
    log_info "检测可用的 Shell 列表:"
    echo

    # 检测所有可用 shell（兼容 Bash 3.2+）
    local available_shells=()
    while IFS= read -r line; do
        available_shells+=("$line")
    done < <(detect_available_shells)

    if [[ ${#available_shells[@]} -eq 0 ]]; then
        log_warn "未检测到任何已知的 Shell"
        return 1
    fi

    # 输出可用 shell
    for shell_info in "${available_shells[@]}"; do
        IFS=':' read -r shell_name shell_path <<< "$shell_info"

        if [[ "$shell_name" == "$current_shell" ]]; then
            echo -e "  ${GREEN}✓${NC} ${GREEN}$shell_name${NC} (当前) - $shell_path"
        else
            echo -e "  ${BLUE}•${NC} $shell_name - $shell_path"
        fi
    done

    echo

    # 输出 JSON 格式（供安装脚本使用）
    if [[ "${OUTPUT_JSON:-false}" == "true" ]]; then
        echo "{"
        echo "  \"current_shell\": \"$current_shell\","
        echo "  \"current_shell_path\": \"$SHELL\","
        echo "  \"available_shells\": ["

        local first=true
        for shell_info in "${available_shells[@]}"; do
            IFS=':' read -r shell_name shell_path <<< "$shell_info"

            if [[ "$first" != true ]]; then
                echo ","
            fi
            first=false

            echo -n "    {\"name\": \"$shell_name\", \"path\": \"$shell_path\"}"
        done
        echo
        echo "  ]"
        echo "}"
    fi

    return 0
}

# 执行主函数
main "$@"