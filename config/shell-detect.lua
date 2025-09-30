-- Shell 自动检测模块
-- 根据平台和可用的 shell 自动生成 launch 配置

local wezterm = require('wezterm')
local platform = require('utils.platform')

local module = {}

-- 获取 shell 的完整路径
local function get_shell_path(shell_name)
   local handle

   if platform.is_win then
      -- Windows: 使用 where 命令
      handle = io.popen('where ' .. shell_name .. ' 2>nul')
   else
      -- Unix: 使用 which 命令
      handle = io.popen('which ' .. shell_name .. ' 2>/dev/null')
   end

   if not handle then
      return nil
   end

   local result = handle:read('*a')
   handle:close()

   -- 清理结果（去除换行符）
   result = result:gsub('%s+$', '')

   if result == '' then
      return nil
   end

   return result
end

-- 检查 shell 是否可用
local function is_shell_available(shell_name)
   return get_shell_path(shell_name) ~= nil
end

-- Windows 专用：检测 Git Bash
local function get_git_bash_path()
   local possible_paths = {
      os.getenv('ProgramFiles') .. '\\Git\\bin\\bash.exe',
      os.getenv('ProgramFiles(x86)') .. '\\Git\\bin\\bash.exe',
      os.getenv('LOCALAPPDATA') .. '\\Programs\\Git\\bin\\bash.exe',
   }

   -- 检查 Scoop 安装路径
   local scoop = os.getenv('SCOOP')
   if scoop then
      table.insert(possible_paths, scoop .. '\\apps\\git\\current\\bin\\bash.exe')
   end

   -- 检查用户 Scoop 安装路径
   local user_home = os.getenv('USERPROFILE')
   if user_home then
      table.insert(possible_paths, user_home .. '\\scoop\\apps\\git\\current\\bin\\bash.exe')
   end

   for _, path in ipairs(possible_paths) do
      local file = io.open(path, 'r')
      if file then
         file:close()
         return path
      end
   end

   return nil
end

-- 检测所有可用的 shell (Windows)
local function detect_windows_shells()
   local shells = {}

   -- PowerShell Core
   if is_shell_available('pwsh') then
      table.insert(shells, {
         label = 'PowerShell Core',
         args = { 'pwsh', '-NoLogo' },
      })
   end

   -- PowerShell Desktop
   if is_shell_available('powershell') then
      table.insert(shells, {
         label = 'PowerShell Desktop',
         args = { 'powershell' },
      })
   end

   -- Command Prompt
   table.insert(shells, {
      label = 'Command Prompt',
      args = { 'cmd' },
   })

   -- Nushell
   if is_shell_available('nu') then
      table.insert(shells, {
         label = 'Nushell',
         args = { 'nu' },
      })
   end

   -- Git Bash
   local git_bash_path = get_git_bash_path()
   if git_bash_path then
      table.insert(shells, {
         label = 'Git Bash',
         args = { git_bash_path },
      })
   end

   return shells
end

-- 检测所有可用的 shell (Unix/Linux)
local function detect_unix_shells()
   local shells = {}

   -- Bash
   if is_shell_available('bash') then
      table.insert(shells, {
         label = 'Bash',
         args = { 'bash', '-l' },
      })
   end

   -- Zsh
   if is_shell_available('zsh') then
      table.insert(shells, {
         label = 'Zsh',
         args = { 'zsh', '-l' },
      })
   end

   -- Fish
   local fish_path = get_shell_path('fish')
   if fish_path then
      table.insert(shells, {
         label = 'Fish',
         args = { fish_path, '-l' },
      })
   end

   -- Nushell
   local nu_path = get_shell_path('nu')
   if nu_path then
      table.insert(shells, {
         label = 'Nushell',
         args = { nu_path, '-l' },
      })
   end

   return shells
end

-- 自动选择默认 shell
local function get_default_shell(available_shells)
   if #available_shells == 0 then
      if platform.is_win then
         return { 'pwsh', '-NoLogo' }
      else
         return { 'bash', '-l' }
      end
   end

   -- 优先级顺序
   local priority = {}

   if platform.is_win then
      priority = { 'PowerShell Core', 'PowerShell Desktop', 'Command Prompt' }
   elseif platform.is_mac then
      priority = { 'Fish', 'Zsh', 'Bash' }
   else
      -- Linux
      priority = { 'Fish', 'Bash', 'Zsh' }
   end

   -- 根据优先级选择
   for _, preferred in ipairs(priority) do
      for _, shell in ipairs(available_shells) do
         if shell.label == preferred then
            return shell.args
         end
      end
   end

   -- 如果没有匹配，返回第一个可用的
   return available_shells[1].args
end

-- 生成 launch 配置
function module.generate_launch_config()
   local available_shells = {}

   if platform.is_win then
      available_shells = detect_windows_shells()
   else
      available_shells = detect_unix_shells()
   end

   local default_prog = get_default_shell(available_shells)

   wezterm.log_info('Auto-detected default shell: ' .. table.concat(default_prog, ' '))
   wezterm.log_info('Available shells: ' .. #available_shells)

   return {
      default_prog = default_prog,
      launch_menu = available_shells,
   }
end

-- 用于调试：打印检测结果
function module.print_detection_info()
   local config = module.generate_launch_config()

   print('=== Shell Auto-Detection Results ===')
   print('Default Program: ' .. table.concat(config.default_prog, ' '))
   print('\nAvailable Shells:')

   for i, shell in ipairs(config.launch_menu) do
      print(string.format('  %d. %s - %s', i, shell.label, table.concat(shell.args, ' ')))
   end

   print('====================================')
end

return module