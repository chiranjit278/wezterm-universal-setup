#!/usr/bin/env node

/**
 * WezTerm Universal Setup - NPX Entry Point
 * Automatically detects platform and runs the appropriate installer
 */

const { spawn } = require('child_process');
const path = require('path');
const os = require('os');
const fs = require('fs');

// 颜色定义
const colors = {
  reset: '\x1b[0m',
  bright: '\x1b[1m',
  dim: '\x1b[2m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  magenta: '\x1b[35m',
  cyan: '\x1b[36m',
};

// 日志函数
const log = {
  info: (msg) => console.log(`${colors.cyan}ℹ${colors.reset}  ${msg}`),
  success: (msg) => console.log(`${colors.green}✓${colors.reset}  ${msg}`),
  warn: (msg) => console.log(`${colors.yellow}⚠${colors.reset}  ${msg}`),
  error: (msg) => console.log(`${colors.red}✗${colors.reset}  ${msg}`),
};

// 打印横幅
function printBanner() {
  console.clear();
  console.log('');
  console.log(colors.cyan + colors.bright + `
    ╦ ╦┌─┐┌─┐╔╦╗┌─┐┬─┐┌┬┐  ╦ ╦┌┬┐┬┬  ┌─┐
    ║║║├┤ ┌─┘ ║ ├┤ ├┬┘│││  ║ ║ │ ││  └─┐
    ╚╩╝└─┘└─┘ ╩ └─┘┴└─┴ ┴  ╚═╝ ┴ ┴┴─┘└─┘
    ┬ ┬┌┐┌┬┬  ┬┌─┐┬─┐┌─┐┌─┐┬    ┌─┐┌─┐┌┬┐┬ ┬┌─┐
    │ ││││└┐┌┘├┤ ├┬┘└─┐├─┤│    └─┐├┤  │ │ │├─┘
    └─┘┘└┘ └┘ └─┘┴└─└─┘┴ ┴┴─┘  └─┘└─┘ ┴ └─┘┴
  ` + colors.reset);
  console.log(colors.magenta + colors.bright + '    一键配置您的终端美化方案 🚀' + colors.reset);
  console.log(colors.dim + '    ────────────────────────────────────────────' + colors.reset);
  console.log(colors.bright + '    Version: 1.0.0  |  Multi-Shell Support' + colors.reset);
  console.log('');
}

// 检测平台
function detectPlatform() {
  const platform = os.platform();

  if (platform === 'win32') {
    return 'windows';
  } else if (platform === 'darwin') {
    return 'macos';
  } else if (platform === 'linux') {
    return 'linux';
  } else {
    return 'unknown';
  }
}

// 运行安装脚本
function runInstaller(platform) {
  const scriptDir = __dirname;
  let scriptPath;
  let command;
  let args = [];

  if (platform === 'windows') {
    scriptPath = path.join(scriptDir, 'install.ps1');

    if (!fs.existsSync(scriptPath)) {
      log.error('未找到 Windows 安装脚本');
      process.exit(1);
    }

    command = 'powershell.exe';
    args = [
      '-ExecutionPolicy', 'Bypass',
      '-File', scriptPath
    ];
  } else {
    scriptPath = path.join(scriptDir, 'install.sh');

    if (!fs.existsSync(scriptPath)) {
      log.error('未找到 Unix 安装脚本');
      process.exit(1);
    }

    command = 'bash';
    args = [scriptPath];
  }

  log.info(`检测到平台: ${platform}`);
  log.info(`执行安装脚本: ${scriptPath}`);
  console.log('');

  // 执行安装脚本
  const installer = spawn(command, args, {
    stdio: 'inherit',
    shell: true,
  });

  installer.on('error', (error) => {
    console.log('');
    log.error(`执行安装脚本时发生错误: ${error.message}`);
    process.exit(1);
  });

  installer.on('exit', (code) => {
    if (code !== 0) {
      process.exit(code);
    }
  });
}

// 主函数
function main() {
  printBanner();

  const platform = detectPlatform();

  if (platform === 'unknown') {
    log.error('不支持的操作系统平台');
    log.info('本工具支持: Windows, macOS, Linux');
    process.exit(1);
  }

  runInstaller(platform);
}

// 执行
main();