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
readonly BACKUP_DIR="${HOME}/.config/wezterm-backup-$(date +%Y%m%d-%H%M%S)"

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

# 备份现有配置
backup_existing_config() {
    if [[ -d "$WEZTERM_CONFIG_DIR" ]]; then
        log_step "${ICON_FOLDER} 备份现有配置"

        echo -e "${CYAN}  源目录:${NC} ${WEZTERM_CONFIG_DIR}"
        echo -e "${CYAN}  目标:${NC} ${BACKUP_DIR}"
        echo

        mv "$WEZTERM_CONFIG_DIR" "$BACKUP_DIR" 2>/dev/null && \
            log_success "备份完成" || \
            log_error "备份失败"

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

# 更新配置
update_config() {
    log_step "${ICON_GEAR} 更新配置文件"

    local config_init="${WEZTERM_CONFIG_DIR}/config/init.lua"

    if [[ ! -f "$config_init" ]]; then
        log_error "配置文件不存在"
        echo
        return 1
    fi

    # 备份
    cp "$config_init" "${config_init}.backup"
    log_info "已创建配置备份"

    # 修改配置
    if grep -q "require('config.launch')" "$config_init"; then
        sed -i.bak "s/require('config\.launch')/-- require('config.launch') -- 已被自动检测替代/" "$config_init"
        sed -i.bak "/-- require('config\.launch')/a\\
-- 使用自动检测的 shell 配置\\
local launch_config = require('config.launch-auto')\\
for k, v in pairs(launch_config) do\\
   config[k] = v\\
end" "$config_init"

        log_success "已启用 Shell 自动检测"
        rm -f "${config_init}.bak"
    else
        log_warn "未找到 launch 配置"
    fi

    echo
}

# 检测 Shell 环境
detect_shell_env() {
    log_step "${ICON_SPARKLE} 检测 Shell 环境"

    local detect_script="${SCRIPT_DIR}/scripts/detect-shell.sh"

    if [[ -f "$detect_script" ]]; then
        bash "$detect_script"
    else
        log_warn "检测脚本不存在"
    fi

    echo
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
    if [[ -d "$BACKUP_DIR" ]]; then
        echo -e "${WHITE}  备份目录:${NC} ${BACKUP_DIR}"
    fi
    echo

    echo -e "${CYAN}${BOLD}🚀 下一步操作${NC}"
    print_separator
    echo -e "${WHITE}  1.${NC} 启动或重启 WezTerm"
    echo -e "${WHITE}  2.${NC} 配置将自动检测您的 shell 环境"
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
    check_wezterm
    backup_existing_config
    clone_config_repo
    install_shell_detect
    update_config
    detect_shell_env
    show_completion
}

# 错误处理
trap 'echo; log_error "安装过程中发生错误"; exit 1' ERR

# 执行主函数
main "$@"