# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-10-01

### Added

#### 核心功能
- 🚀 一键安装 WezTerm 美化配置
- 🔍 自动检测系统中所有可用的 Shell 环境
- 🐚 支持多种 Shell：Bash, Zsh, Fish, PowerShell, Nushell, Git Bash
- 🌐 完整的跨平台支持：Linux, macOS, Windows

#### 安装方式
- 📦 NPX 在线安装支持 (`npx wezterm-universal-setup`)
- 🌐 curl/wget 一键安装脚本
- 💻 PowerShell 一键安装支持 (Windows)
- 📂 本地安装支持

#### Shell 自动检测
- 🔎 Lua 模块实现的智能 Shell 检测
- ⚙️ 自动生成 launch 配置
- 🎯 智能优先级排序
- 🔧 支持自定义配置

#### CLI 美化
- 🎨 精美的 ASCII 艺术横幅
- ✨ 彩色输出和图标支持
- ⠋ 加载动画和进度指示
- 📊 清晰的步骤和分段显示
- 🎯 结构化的日志输出

#### 脚本功能
- 📜 Unix Shell 环境检测脚本 (`detect-shell.sh`)
- 🪟 Windows Shell 环境检测脚本 (`detect-shell.ps1`)
- 🛠️ 完整的安装脚本 (`install.sh`, `install.ps1`)
- 📦 Node.js 入口点 (`index.js`)

#### 文档
- 📘 详细的 README 文档
- 🐛 故障排除指南
- ⚙️ 自定义配置说明
- 🎬 安装演示和示例

#### 开发工具
- 🔄 GitHub Actions CI/CD 工作流
- ✅ 自动化测试（Linux, macOS, Windows）
- 📦 NPM 包配置
- 🏷️ 自动发布流程

### Features Details

#### Shell Detection
- 自动扫描系统中所有可用的 Shell
- 根据平台智能选择默认 Shell
- 支持 JSON 格式输出
- 详细的检测日志

#### Installation Scripts
- 自动备份现有配置
- 克隆原始 WezTerm 美化项目
- 安装 Shell 检测模块
- 自动更新配置文件
- 完整的错误处理

#### Cross-Platform Support
- **Linux**: 支持所有主流发行版
- **macOS**: 支持 Intel 和 Apple Silicon
- **Windows**: 支持 PowerShell 5.1+ 和 PowerShell Core 7+

#### Customization
- 手动指定默认 Shell
- 添加自定义 Shell 配置
- 查看详细的检测信息
- 灵活的配置选项

### Technical Details

- **Languages**: Bash, PowerShell, Lua, JavaScript (Node.js)
- **Minimum Requirements**:
  - WezTerm >= 20240127-113634-bbcac864
  - Git
  - Node.js >= 12.0.0 (for NPX)
- **Tested Platforms**: Ubuntu 20.04+, macOS 11+, Windows 10+
- **License**: MIT

---

## [Unreleased]

### Planned Features

- [ ] 支持更多 Shell (tcsh, ksh, etc.)
- [ ] 配置导入/导出功能
- [ ] 主题选择器
- [ ] 插件系统
- [ ] Web UI 配置界面

---

[1.0.0]: https://github.com/YOUR_USERNAME/wezterm-universal-setup/releases/tag/v1.0.0