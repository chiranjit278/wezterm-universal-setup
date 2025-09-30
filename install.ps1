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
$Script:BACKUP_DIR = Join-Path $env:USERPROFILE ".config\wezterm-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

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

# 检查 WezTerm
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

# 备份现有配置
function Backup-ExistingConfig {
    if (Test-Path $WEZTERM_CONFIG_DIR) {
        Write-Step "$($Icons.Folder) 备份现有配置"

        Write-Host "  源目录: " -NoNewline -ForegroundColor Cyan
        Write-Host $WEZTERM_CONFIG_DIR
        Write-Host "  目标:   " -NoNewline -ForegroundColor Cyan
        Write-Host $BACKUP_DIR
        Write-Host ""

        try {
            Move-Item -Path $WEZTERM_CONFIG_DIR -Destination $BACKUP_DIR -Force
            Write-Log "备份完成" -Level SUCCESS
        } catch {
            Write-Log "备份失败: $_" -Level ERROR
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

# 更新配置
function Update-Config {
    Write-Step "$($Icons.Gear) 更新配置文件"

    $configInit = Join-Path $WEZTERM_CONFIG_DIR "config\init.lua"

    if (-not (Test-Path $configInit)) {
        Write-Log "配置文件不存在" -Level ERROR
        Write-Host ""
        return
    }

    # 备份
    Copy-Item $configInit -Destination "$configInit.backup" -Force
    Write-Log "已创建配置备份" -Level INFO

    # 读取并修改配置
    $content = Get-Content $configInit -Raw

    if ($content -match "require\('config\.launch'\)") {
        $newContent = $content -replace `
            "require\('config\.launch'\)", `
            @"
-- require('config.launch') -- 已被自动检测替代
-- 使用自动检测的 shell 配置
local launch_config = require('config.launch-auto')
for k, v in pairs(launch_config) do
   config[k] = v
end
"@

        Set-Content -Path $configInit -Value $newContent -NoNewline
        Write-Log "已启用 Shell 自动检测" -Level SUCCESS
    } else {
        Write-Log "未找到 launch 配置" -Level WARN
    }

    Write-Host ""
}

# 检测 Shell 环境
function Invoke-ShellDetection {
    Write-Step "$($Icons.Sparkle) 检测 Shell 环境"

    $detectScript = Join-Path $SCRIPT_DIR "scripts\detect-shell.ps1"

    if (Test-Path $detectScript) {
        & $detectScript
    } else {
        Write-Log "检测脚本不存在" -Level WARN
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

    if (Test-Path $BACKUP_DIR) {
        Write-Host "  备份目录: " -NoNewline -ForegroundColor White
        Write-Host $BACKUP_DIR
    }

    Write-Host ""
    Write-Host "🚀 下一步操作" -ForegroundColor Cyan
    Write-Separator
    Write-Host "  1. " -NoNewline -ForegroundColor White
    Write-Host "启动或重启 WezTerm"
    Write-Host "  2. " -NoNewline -ForegroundColor White
    Write-Host "配置将自动检测您的 shell 环境"
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
        Test-WezTerm
        Backup-ExistingConfig
        Get-ConfigRepo
        Install-ShellDetect
        Update-Config
        Invoke-ShellDetection
        Show-Completion
    } catch {
        Write-Host ""
        Write-Log "安装过程中发生错误: $_" -Level ERROR
        exit 1
    }
}

# 执行主函数
Main