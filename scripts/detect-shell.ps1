# Shell 自动检测脚本 - Windows (PowerShell)
# 用于检测当前用户的默认 shell 及可用 shell 列表

param(
    [switch]$OutputJson = $false
)

# 颜色定义
$Script:Colors = @{
    Red    = 'Red'
    Green  = 'Green'
    Yellow = 'Yellow'
    Blue   = 'Cyan'
    Reset  = 'White'
}

# 日志函数
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = 'INFO'
    )

    $color = switch ($Level) {
        'INFO'    { $Colors.Blue }
        'SUCCESS' { $Colors.Green }
        'WARN'    { $Colors.Yellow }
        'ERROR'   { $Colors.Red }
        default   { $Colors.Reset }
    }

    Write-Host "[$Level] " -ForegroundColor $color -NoNewline
    Write-Host $Message
}

# 获取当前 shell
function Get-CurrentShell {
    $parentProcess = (Get-Process -Id $PID).Parent
    if ($null -ne $parentProcess) {
        return $parentProcess.ProcessName.ToLower()
    }
    return "powershell"
}

# 检测 shell 是否可用
function Test-ShellAvailable {
    param([string]$ShellName)

    $shell = Get-Command $ShellName -ErrorAction SilentlyContinue
    return $null -ne $shell
}

# 获取 shell 的完整路径
function Get-ShellPath {
    param([string]$ShellName)

    $shell = Get-Command $ShellName -ErrorAction SilentlyContinue
    if ($null -ne $shell) {
        return $shell.Source
    }
    return ""
}

# 检测 Git Bash
function Get-GitBashPath {
    # 常见的 Git Bash 安装路径
    $gitPaths = @(
        "$env:ProgramFiles\Git\bin\bash.exe",
        "$env:ProgramFiles(x86)\Git\bin\bash.exe",
        "$env:LOCALAPPDATA\Programs\Git\bin\bash.exe"
    )

    # 检查 Scoop 安装路径
    if ($env:SCOOP) {
        $gitPaths += "$env:SCOOP\apps\git\current\bin\bash.exe"
    }

    # 检查用户 Scoop 安装路径
    $userHome = $env:USERPROFILE
    $gitPaths += "$userHome\scoop\apps\git\current\bin\bash.exe"

    foreach ($path in $gitPaths) {
        if (Test-Path $path) {
            return $path
        }
    }

    return ""
}

# 检测所有可用的 shell
function Get-AvailableShells {
    $shellsToCheck = @(
        @{Name = "pwsh"; DisplayName = "PowerShell Core"},
        @{Name = "powershell"; DisplayName = "PowerShell Desktop"},
        @{Name = "cmd"; DisplayName = "Command Prompt"},
        @{Name = "nu"; DisplayName = "Nushell"},
        @{Name = "bash"; DisplayName = "Bash"},
        @{Name = "zsh"; DisplayName = "Zsh"},
        @{Name = "fish"; DisplayName = "Fish"}
    )

    $availableShells = @()

    foreach ($shell in $shellsToCheck) {
        $shellPath = ""

        if ($shell.Name -eq "bash") {
            # 特殊处理 Git Bash
            $gitBashPath = Get-GitBashPath
            if ($gitBashPath) {
                $shellPath = $gitBashPath
            }
        }

        if (-not $shellPath) {
            if (Test-ShellAvailable $shell.Name) {
                $shellPath = Get-ShellPath $shell.Name
            }
        }

        if ($shellPath) {
            $availableShells += @{
                Name        = $shell.Name
                DisplayName = $shell.DisplayName
                Path        = $shellPath
            }
        }
    }

    return $availableShells
}

# 主函数
function Main {
    Write-Log "开始检测 Shell 环境..." -Level INFO
    Write-Host

    # 检测当前 shell
    $currentShell = Get-CurrentShell
    Write-Log "当前运行的 Shell: $currentShell" -Level SUCCESS
    Write-Host

    Write-Log "检测可用的 Shell 列表:" -Level INFO
    Write-Host

    # 检测所有可用 shell
    $availableShells = Get-AvailableShells

    if ($availableShells.Count -eq 0) {
        Write-Log "未检测到任何已知的 Shell" -Level WARN
        return 1
    }

    # 输出可用 shell
    foreach ($shell in $availableShells) {
        if ($shell.Name -eq $currentShell) {
            Write-Host "  " -NoNewline
            Write-Host "✓ " -ForegroundColor Green -NoNewline
            Write-Host "$($shell.DisplayName) " -ForegroundColor Green -NoNewline
            Write-Host "(当前) - $($shell.Path)"
        } else {
            Write-Host "  • $($shell.DisplayName) - $($shell.Path)"
        }
    }

    Write-Host

    # 输出 JSON 格式（供安装脚本使用）
    if ($OutputJson) {
        $jsonObject = @{
            current_shell       = $currentShell
            available_shells    = $availableShells
        }

        $jsonOutput = $jsonObject | ConvertTo-Json -Depth 3
        Write-Output $jsonOutput
    }

    return 0
}

# 执行主函数
try {
    exit (Main)
} catch {
    Write-Log "发生错误: $_" -Level ERROR
    exit 1
}