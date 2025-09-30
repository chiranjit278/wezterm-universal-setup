#!/usr/bin/env bash
# WezTerm Universal Setup - 美化安装脚本
# 自动检测 shell 环境并配置 WezTerm

set -euo pipefail

# 颜色和样式定义
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly BOLD='\033[1m'
readonly DIM='\033[2m'
readonly NC='\033[0m'

# 配置常量
readonly WEZTERM_CONFIG_REPO="https://github.com/KevinSilvester/wezterm-config.git"
readonly WEZTERM_CONFIG_DIR="${HOME}/.config/wezterm"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 全局变量 - 用户选择的 Shell
SELECTED_SHELL=""
SELECTED_SHELL_PATH=""

# 图标定义
readonly ICON_CHECK="✓"
readonly ICON_CROSS="✗"
readonly ICON_WARN="⚠"
readonly ICON_INFO="ℹ"
readonly ICON_ROCKET="🚀"
readonly ICON_SPARKLE="✨"
readonly ICON_GEAR="⚙"
readonly ICON_PACKAGE="📦"
readonly ICON_FOLDER="📁"
readonly ICON_PAINT="🎨"

# 日志函数
log_info() {
    echo -e "${BLUE}${ICON_INFO}${NC}  $1"
}

log_success() {
    echo -e "${GREEN}${ICON_CHECK}${NC}  $1"
}

log_warn() {
    echo -e "${YELLOW}${ICON_WARN}${NC}  $1"
}

log_error() {
    echo -e "${RED}${ICON_CROSS}${NC}  $1"
}

log_step() {
    echo
    echo -e "${CYAN}${BOLD}▶ $1${NC}"
    echo -e "${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# 打印精美横幅
print_banner() {
    clear
    echo
    echo -e "${CYAN}${BOLD}"
    cat << "EOF"
    ╦ ╦┌─┐┌─┐╔╦╗┌─┐┬─┐┌┬┐  ╦ ╦┌┬┐┬┬  ┌─┐
    ║║║├┤ ┌─┘ ║ ├┤ ├┬┘│││  ║ ║ │ ││  └─┐
    ╚╩╝└─┘└─┘ ╩ └─┘┴└─┴ ┴  ╚═╝ ┴ ┴┴─┘└─┘
    ┬ ┬┌┐┌┬┬  ┬┌─┐┬─┐┌─┐┌─┐┬    ┌─┐┌─┐┌┬┐┬ ┬┌─┐
    │ ││││└┐┌┘├┤ ├┬┘└─┐├─┤│    └─┐├┤  │ │ │├─┘
    └─┘┘└┘ └┘ └─┘┴└─└─┘┴ ┴┴─┘  └─┘└─┘ ┴ └─┘┴
EOF
    echo -e "${NC}"
    echo -e "${MAGENTA}${BOLD}    一键配置您的终端美化方案 ${ICON_ROCKET}${NC}"
    echo -e "${DIM}    ────────────────────────────────────────────${NC}"
    echo -e "${WHITE}    Version: 1.0.0  |  Multi-Shell Support${NC}"
    echo
}

# 显示进度条
show_progress() {
    local duration=$1
    local width=50
    local progress=0

    while [ $progress -le 100 ]; do
        local filled=$((progress * width / 100))
        local empty=$((width - filled))

        printf "\r${CYAN}  ["
        printf "%${filled}s" | tr ' ' '█'
        printf "%${empty}s" | tr ' ' '░'
        printf "] ${progress}%%${NC}"

        progress=$((progress + 2))
        sleep "$duration"
    done
    echo
}

# 显示加载动画
show_spinner() {
    local pid=$1
    local message=$2
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'

    echo -n "  "
    while kill -0 "$pid" 2>/dev/null; do
        local temp=${spinstr#?}
        printf "\r${CYAN}%s${NC} %s" "${spinstr:0:1}" "$message"
        spinstr=$temp${spinstr%"$temp"}
        sleep 0.1
    done

    wait "$pid"
    local status=$?

    printf "\r"
    if [ $status -eq 0 ]; then
        log_success "$message"
    else
        log_error "$message (失败)"
    fi

    return $status
}

# 打印分隔线
print_separator() {
    echo -e "${DIM}────────────────────────────────────────────────────${NC}"
}

# 检查依赖
check_dependencies() {
    log_step "${ICON_PACKAGE} 检查系统依赖"

    local deps=("git")
    local all_found=true

    for dep in "${deps[@]}"; do
        if command -v "$dep" &>/dev/null; then
            local version=""
            case "$dep" in
                git)
                    version=$(git --version 2>/dev/null | cut -d' ' -f3)
                    ;;
            esac
            log_success "${dep} ${DIM}(${version})${NC}"
        else
            log_error "缺少依赖: ${dep}"
            all_found=false
        fi
    done

    if [ "$all_found" = false ]; then
        echo
        log_error "请先安装缺少的依赖"
        exit 1
    fi

    echo
}

# 检查 WezTerm
check_wezterm() {
    log_step "${ICON_GEAR} 检查 WezTerm 安装状态"

    if command -v wezterm &>/dev/null; then
        local version
        version=$(wezterm --version 2>/dev/null | head -n1)
        log_success "WezTerm ${DIM}${version}${NC}"
        echo
        return 0
    else
        log_warn "未检测到 WezTerm"
        echo
        echo -e "${YELLOW}  请访问以下链接安装 WezTerm:${NC}"
        echo -e "${WHITE}  https://wezfurlong.org/wezterm/installation.html${NC}"
        echo

        echo -n "  是否继续安装配置？ ${DIM}[y/N]${NC} "
        read -r response
        echo

        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            log_info "安装已取消"
            exit 0
        fi
    fi
}

# 清理现有配置(准备覆盖)
prepare_config_dir() {
    if [[ -d "$WEZTERM_CONFIG_DIR" ]]; then
        log_step "${ICON_FOLDER} 清理现有配置"

        echo -e "${YELLOW}  配置目录已存在,将被覆盖${NC}"
        echo -e "${CYAN}  位置:${NC} ${WEZTERM_CONFIG_DIR}"
        echo

        rm -rf "$WEZTERM_CONFIG_DIR"
        log_success "已清理旧配置"
        echo
    fi
}

# 克隆配置仓库
clone_config_repo() {
    log_step "${ICON_PACKAGE} 下载 WezTerm 美化配置"

    if [[ -d "$WEZTERM_CONFIG_DIR" ]]; then
        log_warn "配置目录已存在，跳过下载"
        echo
        return 0
    fi

    echo -e "${CYAN}  仓库:${NC} ${WEZTERM_CONFIG_REPO}"
    echo -e "${CYAN}  目标:${NC} ${WEZTERM_CONFIG_DIR}"
    echo

    {
        git clone --quiet --depth=1 "$WEZTERM_CONFIG_REPO" "$WEZTERM_CONFIG_DIR"
    } &
    show_spinner $! "正在克隆仓库..."

    echo
}

# 安装 shell 检测模块
install_shell_detect() {
    log_step "${ICON_PAINT} 安装 Shell 自动检测模块"

    local source_dir="${SCRIPT_DIR}/config"
    local target_dir="${WEZTERM_CONFIG_DIR}/config"

    if [[ ! -d "$source_dir" ]]; then
        log_warn "未找到检测模块，跳过此步骤"
        echo
        return 0
    fi

    local files=("shell-detect.lua" "launch-auto.lua")

    for file in "${files[@]}"; do
        if [[ -f "${source_dir}/${file}" ]]; then
            cp "${source_dir}/${file}" "${target_dir}/" && \
                log_success "${file}"
        fi
    done

    echo
}

# 应用用户选择的 Shell
apply_shell_preference() {
    local shell_detect_file="${WEZTERM_CONFIG_DIR}/config/shell-detect.lua"

    if [[ ! -f "$shell_detect_file" ]]; then
        log_warn "未找到 shell-detect.lua"
        return 0
    fi

    # 确定要设置的shell (首字母大写以匹配label)
    local preferred_shell=""
    if [[ -n "$SELECTED_SHELL" ]]; then
        case "$SELECTED_SHELL" in
            bash) preferred_shell="Bash" ;;
            zsh) preferred_shell="Zsh" ;;
            fish) preferred_shell="Fish" ;;
            pwsh) preferred_shell="PowerShell Core" ;;
            powershell) preferred_shell="PowerShell Desktop" ;;
            nu) preferred_shell="Nushell" ;;
            *) preferred_shell="$SELECTED_SHELL" ;;
        esac

        log_info "应用 Shell 优先级: ${GREEN}${preferred_shell}${NC}"
    else
        # 默认使用Zsh
        preferred_shell="Zsh"
        log_info "使用默认 Shell 优先级: ${GREEN}${preferred_shell}${NC}"
    fi

    # 替换占位符
    sed -i "s/USER_PREFERRED_SHELL/${preferred_shell}/g" "$shell_detect_file"

    echo
}

# 更新配置
update_config() {
    log_step "${ICON_GEAR} 更新配置文件"

    local wezterm_config="${WEZTERM_CONFIG_DIR}/wezterm.lua"

    if [[ ! -f "$wezterm_config" ]]; then
        log_error "wezterm.lua 不存在"
        echo
        return 1
    fi

    # 替换 config.launch 为 config.launch-auto
    if grep -q "require('config\.launch')" "$wezterm_config"; then
        sed -i "s/require('config\.launch')/require('config.launch-auto')/g" "$wezterm_config"
        log_success "已启用 Shell 自动检测"
    else
        log_warn "未找到 launch 配置"
    fi

    echo
}

# 检测并选择 Shell
detect_and_select_shell() {
    log_step "${ICON_SPARKLE} 检测 Shell 环境"

    # 检测所有可用的 shell
    # pwsh: PowerShell Core (跨平台)
    # powershell: Windows PowerShell 5.x (Windows/WSL)
    local shells=("bash" "zsh" "fish" "pwsh" "powershell" "nu")
    local available_shells=()
    local shell_paths=()
    local current_shell=""

    # 获取当前默认 shell
    if [[ -n "${SHELL:-}" ]]; then
        current_shell=$(basename "$SHELL")
    fi

    log_info "当前默认 Shell: ${GREEN}${current_shell}${NC}"
    echo

    # 检测可用 shell
    for shell in "${shells[@]}"; do
        local shell_path=""

        # 优先检测原生命令
        if command -v "$shell" &>/dev/null; then
            shell_path=$(command -v "$shell")
        # WSL环境下检测Windows PowerShell
        elif [[ "$shell" == "powershell" ]] && command -v powershell.exe &>/dev/null; then
            shell_path=$(command -v powershell.exe)
        fi

        # 如果找到了shell,添加到列表
        if [[ -n "$shell_path" ]]; then
            available_shells+=("$shell")
            shell_paths+=("$shell_path")

            if [[ "$shell" == "$current_shell" ]]; then
                log_success "${shell} (当前) ${DIM}- ${shell_path}${NC}"
            else
                log_info "  ${shell} ${DIM}- ${shell_path}${NC}"
            fi
        fi
    done

    if [[ ${#available_shells[@]} -eq 0 ]]; then
        log_error "未检测到任何已知的 Shell"
        return 1
    fi

    echo
    log_info "检测到 ${#available_shells[@]} 个可用的 Shell"
    echo

    # 让用户选择
    echo -e "${CYAN}${BOLD}请选择默认 Shell:${NC}"
    echo

    for i in "${!available_shells[@]}"; do
        local num=$((i + 1))
        local shell="${available_shells[$i]}"
        local path="${shell_paths[$i]}"

        if [[ "$shell" == "$current_shell" ]]; then
            echo -e "  ${GREEN}${num})${NC} ${GREEN}${shell}${NC} (当前) ${DIM}- ${path}${NC}"
        else
            echo -e "  ${WHITE}${num})${NC} ${shell} ${DIM}- ${path}${NC}"
        fi
    done

    echo
    echo -e "  ${DIM}0) 跳过此步骤,使用系统默认${NC}"
    echo

    # 读取用户选择
    local choice=""
    while true; do
        echo -n "  请输入选项 [0-${#available_shells[@]}]: "
        read -r choice

        if [[ "$choice" == "0" ]]; then
            log_info "使用系统默认 Shell: ${current_shell}"
            echo
            return 0
        elif [[ "$choice" =~ ^[0-9]+$ ]] && [[ $choice -ge 1 ]] && [[ $choice -le ${#available_shells[@]} ]]; then
            local selected_index=$((choice - 1))
            SELECTED_SHELL="${available_shells[$selected_index]}"
            SELECTED_SHELL_PATH="${shell_paths[$selected_index]}"

            echo
            log_success "已选择: ${GREEN}${SELECTED_SHELL}${NC} ${DIM}(${SELECTED_SHELL_PATH})${NC}"
            echo
            return 0
        else
            echo -e "  ${RED}无效选择,请重试${NC}"
        fi
    done
}

# 显示完成信息
show_completion() {
    echo
    echo -e "${GREEN}${BOLD}"
    cat << "EOF"
    ╔════════════════════════════════════════════════╗
    ║                                                ║
    ║          ✨ 安装完成！                         ║
    ║          Enjoy your beautiful terminal! 🎉    ║
    ║                                                ║
    ╚════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"

    echo -e "${CYAN}${BOLD}📁 配置信息${NC}"
    print_separator
    echo -e "${WHITE}  配置目录:${NC} ${WEZTERM_CONFIG_DIR}"
    if [[ -n "$SELECTED_SHELL" ]]; then
        echo -e "${WHITE}  默认 Shell:${NC} ${GREEN}${SELECTED_SHELL}${NC}"
    fi
    echo

    echo -e "${CYAN}${BOLD}🚀 下一步操作${NC}"
    print_separator
    echo -e "${WHITE}  1.${NC} 启动或重启 WezTerm"
    if [[ -n "$SELECTED_SHELL" ]]; then
        echo -e "${WHITE}  2.${NC} WezTerm 将使用您选择的 ${GREEN}${SELECTED_SHELL}${NC}"
    else
        echo -e "${WHITE}  2.${NC} 配置将自动检测您的 shell 环境"
    fi
    echo -e "${WHITE}  3.${NC} 按 ${MAGENTA}F2${NC} 查看命令面板"
    echo -e "${WHITE}  4.${NC} 查看完整文档: ${DIM}${WEZTERM_CONFIG_DIR}/README.md${NC}"
    echo

    echo -e "${CYAN}${BOLD}⚙️  自定义配置${NC}"
    print_separator
    echo -e "${WHITE}  Shell 配置:${NC} ${DIM}config/launch-auto.lua${NC}"
    echo -e "${WHITE}  SSH/WSL 域:${NC} ${DIM}config/domains.lua${NC}"
    echo -e "${WHITE}  外观设置:${NC} ${DIM}config/appearance.lua${NC}"
    echo

    echo -e "${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${MAGENTA}  感谢使用 WezTerm Universal Setup! ${ICON_SPARKLE}${NC}"
    echo
}

# 主函数
main() {
    print_banner
    check_dependencies
    detect_and_select_shell
    check_wezterm
    prepare_config_dir        # 清理现有配置,不备份
    clone_config_repo
    install_shell_detect
    apply_shell_preference    # 应用用户选择
    update_config
    show_completion
}

# 错误处理
trap 'echo; log_error "安装过程中发生错误"; exit 1' ERR

# 执行主函数
main "$@"