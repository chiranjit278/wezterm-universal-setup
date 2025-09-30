# WezTerm Universal Setup

<div align="center">

![Banner](https://img.shields.io/badge/WezTerm-Universal_Setup-cyan?style=for-the-badge&logo=wezterm)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)
![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20macOS%20%7C%20Windows-green.svg?style=for-the-badge)
![Shell](https://img.shields.io/badge/Shell-Bash%20%7C%20Zsh%20%7C%20Fish%20%7C%20PowerShell-blue.svg?style=for-the-badge)

**🚀 一键配置您的 WezTerm 终端美化方案 🚀**

*基于 [KevinSilvester/wezterm-config](https://github.com/KevinSilvester/wezterm-config) 的通用安装配置方案*

[快速开始](#-快速开始) •
[特性](#-特性) •
[支持的 Shell](#-支持的-shell-环境) •
[文档](#-使用文档) •
[贡献](#-贡献)

</div>

---

## ✨ 特性

<table>
<tr>
<td width="50%">

### 🎯 一键安装
- **NPX 在线安装** - 无需克隆仓库
- **curl/wget** - 传统 Unix 方式
- **PowerShell** - Windows 原生支持
- **本地安装** - 离线环境可用

</td>
<td width="50%">

### 🔍 智能检测
- **自动识别** 系统中所有可用 Shell
- **优先级排序** 选择最佳默认 Shell
- **跨平台兼容** Linux / macOS / Windows
- **零配置** 开箱即用

</td>
</tr>
<tr>
<td width="50%">

### 🐚 多 Shell 支持
- Bash
- Zsh
- Fish
- PowerShell (Core & Desktop)
- Nushell
- Git Bash
- Command Prompt

</td>
<td width="50%">

### 🎨 美化体验
- **精美 CLI 界面** 彩色输出和图标
- **进度指示** 加载动画和进度条
- **详细日志** 清晰的安装步骤
- **安全备份** 自动备份现有配置

</td>
</tr>
</table>

---

## 🚀 快速开始

### 方式 1: NPX 在线安装 (推荐 ⭐)

最简单的方式，无需克隆仓库：

```bash
# 使用 npx (需要 Node.js >= 12.0.0)
npx wezterm-universal-setup
```

### 方式 2: curl/wget 在线安装

#### Linux / macOS

```bash
# 使用 curl
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/wezterm-universal-setup/main/install.sh | bash

# 或使用 wget
wget -qO- https://raw.githubusercontent.com/YOUR_USERNAME/wezterm-universal-setup/main/install.sh | bash
```

#### Windows PowerShell

```powershell
# 使用 iwr (Invoke-WebRequest)
iwr -useb https://raw.githubusercontent.com/YOUR_USERNAME/wezterm-universal-setup/main/install.ps1 | iex
```

### 方式 3: 本地安装

#### 克隆仓库

```bash
git clone https://github.com/YOUR_USERNAME/wezterm-universal-setup.git
cd wezterm-universal-setup
```

#### Linux / macOS

```bash
./install.sh
```

#### Windows

```powershell
.\install.ps1
```

---

## 📋 系统要求

### 必需

- **WezTerm** >= `20240127-113634-bbcac864`
  推荐: [Nightly 版本](https://github.com/wez/wezterm/releases/nightly)
- **Git**

### 可选 (用于 NPX 安装)

- **Node.js** >= 12.0.0
- **npm** 或 **yarn**

### 推荐

- **JetBrainsMono Nerd Font** 或其他 Nerd Font

---

## 🎬 安装演示

```
    ╦ ╦┌─┐┌─┐╔╦╗┌─┐┬─┐┌┬┐  ╦ ╦┌┬┐┬┬  ┌─┐
    ║║║├┤ ┌─┘ ║ ├┤ ├┬┘│││  ║ ║ │ ││  └─┐
    ╚╩╝└─┘└─┘ ╩ └─┘┴└─┴ ┴  ╚═╝ ┴ ┴┴─┘└─┘
    ┬ ┬┌┐┌┬┬  ┬┌─┐┬─┐┌─┐┌─┐┬    ┌─┐┌─┐┌┬┐┬ ┬┌─┐
    │ ││││└┐┌┘├┤ ├┬┘└─┐├─┤│    └─┐├┤  │ │ │├─┘
    └─┘┘└┘ └┘ └─┘┴└─└─┘┴ ┴┴─┘  └─┘└─┘ ┴ └─┘┴

    一键配置您的终端美化方案 🚀
    ────────────────────────────────────────────
    Version: 1.0.0  |  Multi-Shell Support

▶ 📦 检查系统依赖
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✓  git (2.39.1)

▶ ⚙ 检查 WezTerm 安装状态
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✓  WezTerm 20240203-110809-5046fc22

▶ 📦 下载 WezTerm 美化配置
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  仓库: https://github.com/KevinSilvester/wezterm-config.git
  目标: /home/user/.config/wezterm

⠋ 正在克隆仓库...
✓  正在克隆仓库...

▶ 🎨 安装 Shell 自动检测模块
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✓  shell-detect.lua
✓  launch-auto.lua

▶ ✨ 检测 Shell 环境
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[INFO] 当前默认 Shell: fish
[INFO] Shell 路径: /usr/bin/fish

[INFO] 检测可用的 Shell 列表:

  ✓ fish (当前) - /usr/bin/fish
  • bash - /usr/bin/bash
  • zsh - /usr/bin/zsh

    ╔════════════════════════════════════════════════╗
    ║                                                ║
    ║          ✨ 安装完成！                         ║
    ║          Enjoy your beautiful terminal! 🎉    ║
    ║                                                ║
    ╚════════════════════════════════════════════════╝

📁 配置信息
────────────────────────────────────────────────────
  配置目录: /home/user/.config/wezterm

🚀 下一步操作
────────────────────────────────────────────────────
  1. 启动或重启 WezTerm
  2. 配置将自动检测您的 shell 环境
  3. 按 F2 查看命令面板
  4. 查看完整文档: /home/user/.config/wezterm/README.md
```

---

## 🐚 支持的 Shell 环境

### Unix / Linux / macOS

| Shell | 检测方式 | 优先级 | 说明 |
|-------|---------|--------|------|
| **Fish** | 自动检测路径 | ⭐⭐⭐ | 推荐使用 |
| **Zsh** | 自动检测路径 | ⭐⭐ | macOS 默认 |
| **Bash** | 系统默认 | ⭐ | 通用兼容 |
| **Nushell** | 自动检测路径 | • | 实验性支持 |

### Windows

| Shell | 检测方式 | 优先级 | 说明 |
|-------|---------|--------|------|
| **PowerShell Core** | 命令检测 (pwsh) | ⭐⭐⭐ | 推荐使用 |
| **PowerShell Desktop** | 命令检测 (powershell) | ⭐⭐ | Windows 内置 |
| **Command Prompt** | 系统默认 | ⭐ | 基础终端 |
| **Git Bash** | 路径扫描 | ⭐ | 开发者常用 |
| **Nushell** | 命令检测 (nu) | • | 实验性支持 |

---

## 📂 项目结构

```
wezterm-universal-setup/
├── 📄 README.md                    # 本文档
├── 📄 LICENSE                      # MIT 许可证
├── 📄 package.json                 # NPM 包配置
├── 📄 .gitignore                   # Git 忽略规则
│
├── 🚀 index.js                     # NPX 入口点
├── 🚀 install.sh                   # Unix/Linux/macOS 安装脚本
├── 🚀 install.ps1                  # Windows PowerShell 安装脚本
│
├── 📂 config/
│   ├── shell-detect.lua            # Shell 自动检测核心模块
│   └── launch-auto.lua             # 自动生成的 launch 配置
│
└── 📂 scripts/
    ├── detect-shell.sh             # Unix Shell 环境检测
    └── detect-shell.ps1            # Windows Shell 环境检测
```

---

## 🎯 安装流程

安装脚本会自动执行以下步骤：

1. ✅ **检查系统依赖**
   验证 Git 和 WezTerm 是否已安装

2. 🔍 **检测 Shell 环境**
   扫描系统中所有可用的 Shell

3. 💾 **备份现有配置**
   如果存在旧配置，自动备份到带时间戳的目录

4. 📥 **下载美化配置**
   克隆原始 WezTerm 美化项目

5. 🔧 **安装检测模块**
   复制 Shell 自动检测模块到配置目录

6. ⚙️ **更新配置文件**
   修改配置以启用 Shell 自动检测

7. 🎉 **完成安装**
   显示配置信息和下一步操作

---

## 🛠️ 工作原理

### Shell 自动检测

安装脚本会扫描系统中所有可用的 Shell：

- **Unix/Linux/macOS**: 使用 `which` 命令检测 Shell 可执行文件
- **Windows**: 使用 `Get-Command` 和路径扫描检测 Shell

### 配置生成

`shell-detect.lua` 模块会：

1. 检测所有可用的 Shell
2. 根据平台确定优先级
3. 自动选择最佳的默认 Shell
4. 生成完整的 `launch_menu` 配置

### 配置集成

安装脚本会自动修改 `config/init.lua`：

```lua
-- 原始配置（已注释）
-- require('config.launch')

-- 使用自动检测的 shell 配置
local launch_config = require('config.launch-auto')
for k, v in pairs(launch_config) do
   config[k] = v
end
```

---

## ⚙️ 自定义配置

### 修改默认 Shell

编辑 `~/.config/wezterm/config/launch-auto.lua`:

```lua
local shell_detect = require('config.shell-detect')

-- 手动指定默认 Shell
return {
   default_prog = { 'zsh', '-l' },
   launch_menu = shell_detect.generate_launch_config().launch_menu,
}
```

### 查看检测信息

在 `~/.config/wezterm/config/launch-auto.lua` 中取消注释：

```lua
-- 取消注释以查看检测信息
shell_detect.print_detection_info()
```

### 添加自定义 Shell

编辑 `~/.config/wezterm/config/launch-auto.lua`:

```lua
local config = require('config.shell-detect').generate_launch_config()

-- 添加自定义 Shell
table.insert(config.launch_menu, {
   label = 'Custom Shell',
   args = { '/path/to/custom/shell', '--args' },
})

return config
```

---

## 🔧 手动检测 Shell

### Unix / Linux / macOS

```bash
cd wezterm-universal-setup
./scripts/detect-shell.sh

# 输出 JSON 格式
OUTPUT_JSON=true ./scripts/detect-shell.sh
```

### Windows

```powershell
cd wezterm-universal-setup
.\scripts\detect-shell.ps1

# 输出 JSON 格式
.\scripts\detect-shell.ps1 -OutputJson
```

---

## 🐛 故障排除

<details>
<summary><b>问题 1: 检测不到某个 Shell</b></summary>

**原因**: Shell 未添加到系统 PATH

**解决方案**:
1. 确认 Shell 已正确安装
2. 将 Shell 可执行文件路径添加到系统 PATH
3. 重新运行安装脚本

</details>

<details>
<summary><b>问题 2: WezTerm 启动后使用了错误的 Shell</b></summary>

**原因**: 自动检测优先级不符合预期

**解决方案**:
手动编辑 `~/.config/wezterm/config/launch-auto.lua` 指定默认 Shell

</details>

<details>
<summary><b>问题 3: NPX 安装失败</b></summary>

**原因**: Node.js 版本过低或网络问题

**解决方案**:
1. 升级 Node.js 到 >= 12.0.0
2. 使用其他安装方式 (curl/wget 或本地安装)
3. 检查网络连接

</details>

<details>
<summary><b>问题 4: Git Bash 未被检测到 (Windows)</b></summary>

**原因**: Git Bash 安装在非标准路径

**解决方案**:
手动在 `~/.config/wezterm/config/launch-auto.lua` 中添加：

```lua
table.insert(config.launch_menu, {
   label = 'Git Bash',
   args = { 'C:\\Path\\To\\Git\\bin\\bash.exe' },
})
```

</details>

<details>
<summary><b>问题 5: PowerShell 执行策略错误</b></summary>

**原因**: Windows 限制了脚本执行

**解决方案**:
```powershell
# 临时允许脚本执行
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# 然后运行安装脚本
.\install.ps1
```

</details>

---

## 📚 原始配置功能

本项目保留了原始配置的所有功能：

### 🖼️ 背景图片选择器

- 循环切换图片
- 模糊搜索图片
- 切换背景显示

快捷键参考：[原始项目文档](https://github.com/KevinSilvester/wezterm-config#background-images)

### 🎮 GPU 适配器选择

自动选择最佳的 GPU + 图形 API 组合（需启用 `WebGpu` 前端）

### ⌨️ 完整快捷键

所有快捷键保持不变，详见：[原始项目文档](https://github.com/KevinSilvester/wezterm-config#all-key-bindings)

---

## 🔗 相关链接

- **原始配置项目**: [KevinSilvester/wezterm-config](https://github.com/KevinSilvester/wezterm-config)
- **WezTerm 官网**: [wezfurlong.org/wezterm](https://wezfurlong.org/wezterm/)
- **WezTerm GitHub**: [github.com/wez/wezterm](https://github.com/wez/wezterm)
- **问题反馈**: [GitHub Issues](https://github.com/YOUR_USERNAME/wezterm-universal-setup/issues)

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

### 开发指南

1. Fork 本仓库
2. 创建特性分支
   ```bash
   git checkout -b feature/AmazingFeature
   ```
3. 提交更改
   ```bash
   git commit -m 'Add some AmazingFeature'
   ```
4. 推送到分支
   ```bash
   git push origin feature/AmazingFeature
   ```
5. 开启 Pull Request

### 贡献者行为准则

- 保持友好和尊重
- 遵循现有代码风格
- 提供清晰的提交信息
- 添加必要的文档

---

## 📄 许可证

本项目采用 [MIT 许可证](LICENSE)

---

## 🙏 致谢

- 感谢 [Kevin Silvester](https://github.com/KevinSilvester) 提供的优秀 WezTerm 配置
- 感谢所有为 WezTerm 项目做出贡献的开发者
- 感谢所有使用和反馈的用户

---

## 📊 项目状态

![GitHub stars](https://img.shields.io/github/stars/YOUR_USERNAME/wezterm-universal-setup?style=social)
![GitHub forks](https://img.shields.io/github/forks/YOUR_USERNAME/wezterm-universal-setup?style=social)
![GitHub issues](https://img.shields.io/github/issues/YOUR_USERNAME/wezterm-universal-setup)
![GitHub pull requests](https://img.shields.io/github/issues-pr/YOUR_USERNAME/wezterm-universal-setup)

---

<div align="center">

**⭐ 如果这个项目对您有帮助，请给我们一个 Star！ ⭐**

Made with ❤️ by KOOI

[⬆ 回到顶部](#wezterm-universal-setup)

</div>