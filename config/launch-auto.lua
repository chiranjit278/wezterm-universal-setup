-- WezTerm 通用配置入口文件
-- 自动检测并配置适合当前系统的 shell

local wezterm = require('wezterm')
local shell_detect = require('config.shell-detect')

-- 生成并返回 launch 配置
local config = shell_detect.generate_launch_config()

-- 如果需要查看检测信息，取消下面这行的注释
-- shell_detect.print_detection_info()

return config