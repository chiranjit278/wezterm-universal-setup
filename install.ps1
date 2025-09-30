# WezTerm Universal Setup - Windows 美化安装脚本
# 自动检测 shell 环境并配置 WezTerm

param(
    [switch]$Force = $false
)

# 错误处理
$ErrorActionPreference = "Stop"

# 配置常量
$Script:WEZTERM_CONFIG_REPO = "https://github.com/KevinSilvester/wezterm-config.git"
$Script:WEZTERM_CONFIG_DIR = Join-Path $env:USERPROFILE ".config\wezterm"
$Script:SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path

# 全局变量 - 用户选择的 Shell
$Script:SELECTED_SHELL = ""
$Script:SELECTED_SHELL_PATH = ""

# 图标定义
$Script:Icons = @{
    Check   = [char]0x2713  # ✓
    Cross   = [char]0x2717  # ✗
    Warn    = [char]0x26A0  # ⚠
    Info    = [char]0x2139  # ℹ
    Rocket  = [char]0x1F680 # 🚀
    Sparkle = [char]0x2728  # ✨
    Gear    = [char]0x2699  # ⚙
    Package = [char]0x1F4E6 # 📦
    Folder  = [char]0x1F4C1 # 📁
    Paint   = [char]0x1F3A8 # 🎨
}

# 日志函数
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = 'INFO',
        [switch]$NoNewline
    )

    $icon = switch ($Level) {
        'INFO'    { $Icons.Info }
        'SUCCESS' { $Icons.Check }
        'WARN'    { $Icons.Warn }
        'ERROR'   { $Icons.Cross }
        default   { '' }
    }

    $color = switch ($Level) {
        'INFO'    { 'Cyan' }
        'SUCCESS' { 'Green' }
        'WARN'    { 'Yellow' }
        'ERROR'   { 'Red' }
        default   { 'White' }
    }

    Write-Host "$icon  " -ForegroundColor $color -NoNewline
    if ($NoNewline) {
        Write-Host $Message -NoNewline
    } else {
        Write-Host $Message
    }
}

function Write-Step {
    param([string]$Message)

    Write-Host ""
    Write-Host "▶ $Message" -ForegroundColor Cyan
    Write-Host ("━" * 70) -ForegroundColor DarkGray
}

function Write-Separator {
    Write-Host ("─" * 70) -ForegroundColor DarkGray
}

# 打印精美横幅
function Write-Banner {
    Clear-Host
    Write-Host ""
    Write-Host @"
    ╦ ╦┌─┐┌─┐╔╦╗┌─┐┬─┐┌┬┐  ╦ ╦┌┬┐┬┬  ┌─┐
    ║║║├┤ ┌─┘ ║ ├┤ ├┬┘│││  ║ ║ │ ││  └─┐
    ╚╩╝└─┘└─┘ ╩ └─┘┴└─┴ ┴  ╚═╝ ┴ ┴┴─┘└─┘
    ┬ ┬┌┐┌┬┬  ┬┌─┐┬─┐┌─┐┌─┐┬    ┌─┐┌─┐┌┬┐┬ ┬┌─┐
    │ ││││└┐┌┘├┤ ├┬┘└─┐├─┤│    └─┐├┤  │ │ │├─┘
    └─┘┘└┘ └┘ └─┘┴└─└─┘┴ ┴┴─┘  └─┘└─┘ ┴ └─┘┴
"@ -ForegroundColor Cyan

    Write-Host ""
    Write-Host "    一键配置您的终端美化方案 $($Icons.Rocket)" -ForegroundColor Magenta
    Write-Host "    $("─" * 50)" -ForegroundColor DarkGray
    Write-Host "    Version: 1.0.0  |  Multi-Shell Support" -ForegroundColor White
    Write-Host ""
}

# 显示加载动画
function Show-Spinner {
    param(
        [ScriptBlock]$Task,
        [string]$Message
    )

    $spinChars = @('⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏')
    $job = Start-Job -ScriptBlock $Task
    $i = 0

    Write-Host "  " -NoNewline

    while ($job.State -eq 'Running') {
        $char = $spinChars[$i % $spinChars.Length]
        Write-Host "`r$char $Message" -ForegroundColor Cyan -NoNewline
        Start-Sleep -Milliseconds 100
        $i++
    }

    $result = Receive-Job -Job $job -Wait
    Remove-Job -Job $job

    Write-Host "`r" -NoNewline

    if ($result.Success -ne $false) {
        Write-Log $Message -Level SUCCESS
    } else {
        Write-Log "$Message (失败)" -Level ERROR
    }

    return $result
}

# 显示进度条
function Show-Progress {
    param(
        [int]$PercentComplete,
        [string]$Status
    )

    $width = 50
    $filled = [math]::Floor($width * $PercentComplete / 100)
    $empty = $width - $filled

    Write-Host "`r  [" -NoNewline -ForegroundColor Cyan
    Write-Host ("█" * $filled) -NoNewline -ForegroundColor Cyan
    Write-Host ("░" * $empty) -NoNewline -ForegroundColor DarkGray
    Write-Host "] $PercentComplete% " -NoNewline -ForegroundColor Cyan
    Write-Host $Status -NoNewline
}

# 检查依赖
function Test-Dependencies {
    Write-Step "$($Icons.Package) 检查系统依赖"

    $deps = @("git")
    $allFound = $true

    foreach ($dep in $deps) {
        $cmd = Get-Command $dep -ErrorAction SilentlyContinue
        if ($cmd) {
            $version = ""
            if ($dep -eq "git") {
                $version = (git --version 2>$null).Split(' ')[2]
            }
            Write-Log "$dep ($version)" -Level SUCCESS
        } else {
            Write-Log "缺少依赖: $dep" -Level ERROR
            $allFound = $false
        }
    }

    if (-not $allFound) {
        Write-Host ""
        Write-Log "请先安装缺少的依赖" -Level ERROR
        Write-Host "  您可以使用以下命令安装:" -ForegroundColor Yellow
        Write-Host "    winget install Git.Git" -ForegroundColor White
        exit 1
    }

    Write-Host ""
}

# 检测并选择 Shell
function Select-Shell {
    Write-Step "$($Icons.Sparkle) 检测 Shell 环境"

    # 检测所有可用的 shell
    $shells = @("pwsh", "powershell", "bash", "zsh", "fish", "nu", "cmd")
    $availableShells = @()
    $currentShell = (Get-Process -Id $PID).Parent.ProcessName.ToLower()

    Write-Log "当前运行 Shell: $currentShell" -Level INFO
    Write-Host ""

    # 检测可用 shell
    foreach ($shell in $shells) {
        $cmd = Get-Command $shell -ErrorAction SilentlyContinue
        if ($cmd) {
            $shellPath = $cmd.Source
            $shellObj = [PSCustomObject]@{
                Name = $shell
                Path = $shellPath
            }
            $availableShells += $shellObj

            if ($shell -eq $currentShell) {
                Write-Log "$shell (当前) - $shellPath" -Level SUCCESS
            } else {
                Write-Log "  $shell - $shellPath" -Level INFO
            }
        }
    }

    if ($availableShells.Count -eq 0) {
        Write-Log "未检测到任何已知的 Shell" -Level ERROR
        return
    }

    Write-Host ""
    Write-Log "检测到 $($availableShells.Count) 个可用的 Shell" -Level INFO
    Write-Host ""

    # 让用户选择
    Write-Host "请选择默认 Shell:" -ForegroundColor Cyan
    Write-Host ""

    for ($i = 0; $i -lt $availableShells.Count; $i++) {
        $num = $i + 1
        $shell = $availableShells[$i]

        if ($shell.Name -eq $currentShell) {
            Write-Host "  $num) " -ForegroundColor Green -NoNewline
            Write-Host "$($shell.Name)" -ForegroundColor Green -NoNewline
            Write-Host " (当前) - " -NoNewline
            Write-Host $shell.Path -ForegroundColor DarkGray
        } else {
            Write-Host "  $num) " -ForegroundColor White -NoNewline
            Write-Host "$($shell.Name) - " -NoNewline
            Write-Host $shell.Path -ForegroundColor DarkGray
        }
    }

    Write-Host ""
    Write-Host "  0) 跳过此步骤,使用系统默认" -ForegroundColor DarkGray
    Write-Host ""

    # 读取用户选择
    do {
        $choice = Read-Host "  请输入选项 [0-$($availableShells.Count)]"

        if ($choice -eq "0") {
            Write-Log "使用系统默认 Shell" -Level INFO
            Write-Host ""
            return
        } elseif ($choice -match '^\d+$' -and [int]$choice -ge 1 -and [int]$choice -le $availableShells.Count) {
            $selectedIndex = [int]$choice - 1
            $Script:SELECTED_SHELL = $availableShells[$selectedIndex].Name
            $Script:SELECTED_SHELL_PATH = $availableShells[$selectedIndex].Path

            Write-Host ""
            Write-Log "已选择: $SELECTED_SHELL ($SELECTED_SHELL_PATH)" -Level SUCCESS
            Write-Host ""
            return
        } else {
            Write-Host "  无效选择,请重试" -ForegroundColor Red
        }
    } while ($true)
}

# 测试 WezTerm
function Test-WezTerm {
    Write-Step "$($Icons.Gear) 检查 WezTerm 安装状态"

    $wezterm = Get-Command wezterm -ErrorAction SilentlyContinue
    if ($wezterm) {
        $version = (wezterm --version 2>$null | Select-Object -First 1)
        Write-Log "WezTerm $version" -Level SUCCESS
        Write-Host ""
        return $true
    } else {
        Write-Log "未检测到 WezTerm" -Level WARN
        Write-Host ""
        Write-Host "  请访问以下链接安装 WezTerm:" -ForegroundColor Yellow
        Write-Host "  https://wezfurlong.org/wezterm/installation.html" -ForegroundColor White
        Write-Host ""

        $response = Read-Host "  是否继续安装配置？[y/N]"
        Write-Host ""

        if ($response -notmatch '^[Yy]$') {
            Write-Log "安装已取消" -Level INFO
            exit 0
        }
    }
}

# 清理现有配置(准备覆盖)
function Prepare-ConfigDir {
    if (Test-Path $WEZTERM_CONFIG_DIR) {
        Write-Step "$($Icons.Folder) 清理现有配置"

        Write-Host "  配置目录已存在,将被覆盖" -ForegroundColor Yellow
        Write-Host "  位置: " -NoNewline -ForegroundColor Cyan
        Write-Host $WEZTERM_CONFIG_DIR
        Write-Host ""

        try {
            Remove-Item -Path $WEZTERM_CONFIG_DIR -Recurse -Force
            Write-Log "已清理旧配置" -Level SUCCESS
        } catch {
            Write-Log "清理失败: $_" -Level ERROR
        }

        Write-Host ""
    }
}

# 克隆配置仓库
function Get-ConfigRepo {
    Write-Step "$($Icons.Package) 下载 WezTerm 美化配置"

    if (Test-Path $WEZTERM_CONFIG_DIR) {
        Write-Log "配置目录已存在，跳过下载" -Level WARN
        Write-Host ""
        return
    }

    Write-Host "  仓库: " -NoNewline -ForegroundColor Cyan
    Write-Host $WEZTERM_CONFIG_REPO
    Write-Host "  目标: " -NoNewline -ForegroundColor Cyan
    Write-Host $WEZTERM_CONFIG_DIR
    Write-Host ""

    $task = {
        git clone --quiet --depth=1 $using:WEZTERM_CONFIG_REPO $using:WEZTERM_CONFIG_DIR 2>&1 | Out-Null
        return @{ Success = $LASTEXITCODE -eq 0 }
    }

    Show-Spinner -Task $task -Message "正在克隆仓库..."
    Write-Host ""
}

# 安装 shell 检测模块
function Install-ShellDetect {
    Write-Step "$($Icons.Paint) 安装 Shell 自动检测模块"

    $sourceDir = Join-Path $SCRIPT_DIR "config"
    $targetDir = Join-Path $WEZTERM_CONFIG_DIR "config"

    if (-not (Test-Path $sourceDir)) {
        Write-Log "未找到检测模块，跳过此步骤" -Level WARN
        Write-Host ""
        return
    }

    $files = @("shell-detect.lua", "launch-auto.lua")

    foreach ($file in $files) {
        $sourcePath = Join-Path $sourceDir $file
        if (Test-Path $sourcePath) {
            Copy-Item $sourcePath -Destination $targetDir -Force
            Write-Log $file -Level SUCCESS
        }
    }

    Write-Host ""
}

# 应用用户选择的 Shell
function Apply-ShellPreference {
    $shellDetectFile = Join-Path $WEZTERM_CONFIG_DIR "config\shell-detect.lua"

    if (-not (Test-Path $shellDetectFile)) {
        Write-Log "未找到 shell-detect.lua" -Level WARN
        return
    }

    # 确定要设置的shell (首字母大写以匹配label)
    $preferredShell = ""
    if ($SELECTED_SHELL) {
        $preferredShell = switch ($SELECTED_SHELL) {
            "bash" { "Bash" }
            "zsh" { "Zsh" }
            "fish" { "Fish" }
            "pwsh" { "PowerShell Core" }
            "powershell" { "PowerShell Desktop" }
            "nu" { "Nushell" }
            "cmd" { "Command Prompt" }
            default { $SELECTED_SHELL }
        }

        Write-Log "应用 Shell 优先级: $preferredShell" -Level INFO
    } else {
        # 默认使用 PowerShell Core
        $preferredShell = "PowerShell Core"
        Write-Log "使用默认 Shell 优先级: $preferredShell" -Level INFO
    }

    # 替换占位符
    $content = Get-Content $shellDetectFile -Raw
    $newContent = $content -replace 'USER_PREFERRED_SHELL', $preferredShell
    Set-Content -Path $shellDetectFile -Value $newContent -NoNewline

    Write-Host ""
}

# 更新配置
function Update-Config {
    Write-Step "$($Icons.Gear) 更新配置文件"

    $weztermConfig = Join-Path $WEZTERM_CONFIG_DIR "wezterm.lua"

    if (-not (Test-Path $weztermConfig)) {
        Write-Log "wezterm.lua 不存在" -Level ERROR
        Write-Host ""
        return
    }

    # 替换 config.launch 为 config.launch-auto
    $content = Get-Content $weztermConfig -Raw

    if ($content -match "require\('config\.launch'\)") {
        $newContent = $content -replace "require\('config\.launch'\)", "require('config.launch-auto')"
        Set-Content -Path $weztermConfig -Value $newContent -NoNewline
        Write-Log "已启用 Shell 自动检测" -Level SUCCESS
    } else {
        Write-Log "未找到 launch 配置" -Level WARN
    }

    Write-Host ""
}

# 显示完成信息
function Show-Completion {
    Write-Host ""
    Write-Host @"
    ╔════════════════════════════════════════════════╗
    ║                                                ║
    ║          ✨ 安装完成！                         ║
    ║          Enjoy your beautiful terminal! 🎉    ║
    ║                                                ║
    ╚════════════════════════════════════════════════╝
"@ -ForegroundColor Green

    Write-Host ""
    Write-Host "📁 配置信息" -ForegroundColor Cyan
    Write-Separator
    Write-Host "  配置目录: " -NoNewline -ForegroundColor White
    Write-Host $WEZTERM_CONFIG_DIR

    if ($SELECTED_SHELL) {
        Write-Host "  默认 Shell: " -NoNewline -ForegroundColor White
        Write-Host $SELECTED_SHELL -ForegroundColor Green
    }

    Write-Host ""
    Write-Host "🚀 下一步操作" -ForegroundColor Cyan
    Write-Separator
    Write-Host "  1. " -NoNewline -ForegroundColor White
    Write-Host "启动或重启 WezTerm"
    Write-Host "  2. " -NoNewline -ForegroundColor White
    if ($SELECTED_SHELL) {
        Write-Host "WezTerm 将使用您选择的 " -NoNewline
        Write-Host $SELECTED_SHELL -ForegroundColor Green
    } else {
        Write-Host "配置将自动检测您的 shell 环境"
    }
    Write-Host "  3. " -NoNewline -ForegroundColor White
    Write-Host "按 " -NoNewline
    Write-Host "F2" -ForegroundColor Magenta -NoNewline
    Write-Host " 查看命令面板"
    Write-Host "  4. " -NoNewline -ForegroundColor White
    Write-Host "查看完整文档: " -NoNewline
    Write-Host "$WEZTERM_CONFIG_DIR\README.md" -ForegroundColor DarkGray

    Write-Host ""
    Write-Host "⚙️  自定义配置" -ForegroundColor Cyan
    Write-Separator
    Write-Host "  Shell 配置: " -NoNewline -ForegroundColor White
    Write-Host "config\launch-auto.lua" -ForegroundColor DarkGray
    Write-Host "  SSH/WSL 域: " -NoNewline -ForegroundColor White
    Write-Host "config\domains.lua" -ForegroundColor DarkGray
    Write-Host "  外观设置:   " -NoNewline -ForegroundColor White
    Write-Host "config\appearance.lua" -ForegroundColor DarkGray

    Write-Host ""
    Write-Host ("━" * 70) -ForegroundColor DarkGray
    Write-Host "  感谢使用 WezTerm Universal Setup! ✨" -ForegroundColor Magenta
    Write-Host ""
}

# 主函数
function Main {
    try {
        Write-Banner
        Test-Dependencies
        Select-Shell
        Test-WezTerm
        Prepare-ConfigDir        # 清理现有配置,不备份
        Get-ConfigRepo
        Install-ShellDetect
        Apply-ShellPreference    # 应用用户选择
        Update-Config
        Show-Completion
    } catch {
        Write-Host ""
        Write-Log "安装过程中发生错误: $_" -Level ERROR
        exit 1
    }
}

# 执行主函数
Main