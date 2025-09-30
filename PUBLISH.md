# 发布到 GitHub Packages 指南

本文档说明如何将 wezterm-universal-setup 发布到 GitHub Packages。

## 📦 自动发布（推荐 ⭐）

项目已配置 GitHub Actions 自动发布，推送 tag 时自动触发！

### 快速发布步骤

```bash
cd /home/telagod/project/wezterm-universal-setup

# 1. 更新版本号（可选，自动创建 commit 和 tag）
npm version patch  # 1.0.0 -> 1.0.1
npm version minor  # 1.0.0 -> 1.1.0
npm version major  # 1.0.0 -> 2.0.0

# 2. 推送代码和 tag
git push && git push --tags

# 3. GitHub Actions 会自动：
#    ✅ 创建 GitHub Release
#    ✅ 发布到 GitHub Packages
#    ✅ 验证发布成功
```

### 或者手动创建 tag

```bash
# 1. 手动更新 package.json 中的版本号

# 2. 提交更改
git add package.json
git commit -m "chore: bump version to 1.0.1"

# 3. 创建 tag
git tag v1.0.1

# 4. 推送
git push && git push --tags

# 5. GitHub Actions 自动发布！
```

### 查看发布进度

```bash
# 查看最新的 workflow 运行
gh run list --limit 1

# 查看详细日志
gh run view --log

# 或访问 GitHub Actions 页面
# https://github.com/telagod/wezterm-universal-setup/actions
```

## 🔧 GitHub Actions 配置说明

### 工作流程

`.github/workflows/release.yml` 会在推送 `v*` tag 时触发：

1. **Checkout 代码**
2. **设置 Node.js** - 配置 GitHub Packages registry
3. **获取版本号** - 从 tag 提取版本
4. **创建 GitHub Release** - 包含详细的安装说明
5. **发布到 GitHub Packages** - 使用 `GITHUB_TOKEN` 认证
6. **验证发布** - 检查包是否成功发布

### 所需权限

GitHub Actions 自动拥有以下权限：
- ✅ `contents: write` - 创建 Release
- ✅ `packages: write` - 发布包
- ✅ `GITHUB_TOKEN` - 由 GitHub 自动提供

**无需手动配置任何 Secret！** 🎉

## 📥 用户安装指南

发布后，用户可以通过以下方式安装：

### 方式 1: curl/wget（推荐，无需认证）

**Unix/Linux/macOS:**
```bash
curl -fsSL https://raw.githubusercontent.com/telagod/wezterm-universal-setup/main/install.sh | bash

# 或使用 wget
wget -qO- https://raw.githubusercontent.com/telagod/wezterm-universal-setup/main/install.sh | bash
```

**Windows:**
```powershell
iwr -useb https://raw.githubusercontent.com/telagod/wezterm-universal-setup/main/install.ps1 | iex
```

### 方式 2: NPX（需要认证）

用户需要先配置认证：

```bash
# 1. 创建 GitHub Personal Access Token
#    访问: https://github.com/settings/tokens
#    权限: read:packages

# 2. 配置 npm
npm config set @telagod:registry https://npm.pkg.github.com
npm config set //npm.pkg.github.com/:_authToken USER_TOKEN

# 3. 使用 npx 安装
npx @telagod/wezterm-universal-setup
```

### 方式 3: 本地安装

```bash
git clone https://github.com/telagod/wezterm-universal-setup.git
cd wezterm-universal-setup
./install.sh  # 或 .\install.ps1 (Windows)
```

## 📋 准备工作（仅首次）

### 1. 确保已登录 GitHub

```bash
gh auth status
```

如果未登录，执行：
```bash
gh auth login
```

### 2. 检查仓库权限

确保你有仓库的写权限和包发布权限（通常仓库 owner 自动拥有）。

## 🔄 版本管理

### 语义化版本（Semantic Versioning）

- **Patch** (1.0.0 -> 1.0.1): Bug 修复
- **Minor** (1.0.0 -> 1.1.0): 新功能（向后兼容）
- **Major** (1.0.0 -> 2.0.0): 破坏性更改

### 更新 CHANGELOG

发布前更新 `CHANGELOG.md`：

```markdown
## [1.0.1] - 2025-10-01

### Fixed
- 修复 macOS Bash 兼容性问题

### Changed
- 更新文档
```

## 🐛 故障排除

### 问题 1: Actions 发布失败 - 权限错误

**原因**: workflow 缺少必要权限

**解决方案**: 已在 `release.yml` 中配置：
```yaml
permissions:
  contents: write
  packages: write
```

### 问题 2: 包名冲突

**原因**: 包名不正确

**解决方案**: 确保 `package.json` 中：
```json
{
  "name": "@telagod/wezterm-universal-setup",
  "publishConfig": {
    "registry": "https://npm.pkg.github.com"
  }
}
```

### 问题 3: Tag 未触发 workflow

**原因**: tag 格式不正确

**解决方案**: 确保 tag 以 `v` 开头：
```bash
git tag v1.0.0  # ✅ 正确
git tag 1.0.0   # ❌ 错误
```

### 问题 4: 用户无法安装

**原因**: 用户未配置认证

**解决方案**: 推荐用户使用 curl/wget 方式（无需认证）

## 📊 发布后检查

### 1. 验证 GitHub Release

```bash
# 查看所有 releases
gh release list

# 查看最新 release
gh release view --web
```

### 2. 验证 GitHub Packages

```bash
# 查看包信息
gh api /users/telagod/packages/npm/wezterm-universal-setup

# 或访问浏览器
# https://github.com/telagod?tab=packages
```

### 3. 测试安装

```bash
# 测试 curl 安装
curl -fsSL https://raw.githubusercontent.com/telagod/wezterm-universal-setup/main/install.sh | bash

# 测试 npx 安装（需要先配置认证）
npx @telagod/wezterm-universal-setup@latest
```

## 🎯 完整发布流程示例

```bash
# 1. 确保在 main 分支且代码是最新的
git checkout main
git pull

# 2. 运行测试（可选）
npm test  # 或查看 GitHub Actions

# 3. 更新 CHANGELOG.md
vim CHANGELOG.md

# 4. 提交 CHANGELOG
git add CHANGELOG.md
git commit -m "docs: update CHANGELOG for v1.0.1"
git push

# 5. 更新版本并创建 tag
npm version patch -m "chore: bump version to %s"

# 6. 推送 tag 触发自动发布
git push --tags

# 7. 等待 GitHub Actions 完成
gh run watch

# 8. 验证发布
gh release view --web
gh api /users/telagod/packages/npm/wezterm-universal-setup

# 9. 测试安装
curl -fsSL https://raw.githubusercontent.com/telagod/wezterm-universal-setup/main/install.sh | bash
```

## 📚 相关文档

- [GitHub Packages 文档](https://docs.github.com/en/packages)
- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [语义化版本](https://semver.org/lang/zh-CN/)
- [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)

## ✅ 发布检查清单

发布前确认：

- [ ] 所有测试通过（GitHub Actions CI）
- [ ] CHANGELOG.md 已更新
- [ ] 版本号正确（package.json）
- [ ] 代码已推送到 main 分支
- [ ] Release workflow 配置正确
- [ ] README.md 包含最新的安装说明

发布后确认：

- [ ] GitHub Release 已创建
- [ ] GitHub Packages 中可见
- [ ] curl/wget 安装测试通过
- [ ] npx 安装测试通过（可选）
- [ ] 文档链接正确

---

## 💡 提示

1. **推荐 curl/wget 方式** - 用户体验最好，无需认证
2. **自动发布很方便** - 只需推送 tag，其余自动完成
3. **GITHUB_TOKEN 自动提供** - 无需手动配置 Secret
4. **定期发布** - 积累功能后统一发布新版本

---

准备就绪后，推送 tag 即可自动发布！🚀

### 1. 确保已登录 GitHub

```bash
gh auth status
```

如果未登录，执行：
```bash
gh auth login
```

### 2. 创建 GitHub Personal Access Token (PAT)

1. 访问：https://github.com/settings/tokens/new
2. 选择权限：
   - `write:packages` (发布包)
   - `read:packages` (读取包)
   - `repo` (访问仓库)
3. 生成 token 并保存

### 3. 配置本地 npm 认证

```bash
# 方式 A: 使用环境变量
export GITHUB_TOKEN=your_github_token_here

# 方式 B: 更新 .npmrc（已包含在项目中）
# .npmrc 文件会自动从环境变量读取 GITHUB_TOKEN
```

## 🚀 发布步骤

### 方法 1: 手动发布

```bash
cd /home/telagod/project/wezterm-universal-setup

# 1. 确保所有更改已提交
git status

# 2. 设置 GitHub Token
export GITHUB_TOKEN=your_github_token_here

# 3. 发布到 GitHub Packages
npm publish

# 4. 验证发布
gh api /users/telagod/packages/npm/wezterm-universal-setup
```

### 方法 2: 使用 GitHub Actions（自动发布）

项目已配置 Release workflow，当推送 tag 时自动发布：

```bash
cd /home/telagod/project/wezterm-universal-setup

# 1. 创建 tag
git tag v1.0.0
git push origin v1.0.0

# 2. GitHub Actions 会自动：
#    - 创建 GitHub Release
#    - 发布到 GitHub Packages
```

**注意**: 需要在 GitHub 仓库设置中添加 Secret：
- Settings → Secrets and variables → Actions
- 添加 `GITHUB_TOKEN` (由 GitHub 自动提供)

## 📥 用户安装指南

发布后，用户可以通过以下方式安装：

### 1. 配置 GitHub Packages 认证

用户需要先配置认证：

```bash
# 创建自己的 GitHub Personal Access Token
# 访问: https://github.com/settings/tokens
# 权限: read:packages

# 配置 npm
npm config set @telagod:registry https://npm.pkg.github.com
npm config set //npm.pkg.github.com/:_authToken YOUR_TOKEN

# 或者创建 ~/.npmrc 文件
echo "@telagod:registry=https://npm.pkg.github.com" > ~/.npmrc
echo "//npm.pkg.github.com/:_authToken=YOUR_TOKEN" >> ~/.npmrc
```

### 2. 使用 npx 安装

```bash
npx @telagod/wezterm-universal-setup
```

### 3. 或者先安装再使用

```bash
npm install -g @telagod/wezterm-universal-setup
wezterm-setup
```

## 🔄 更新版本

发布新版本时：

```bash
cd /home/telagod/project/wezterm-universal-setup

# 1. 更新版本号
npm version patch  # 1.0.0 -> 1.0.1
# 或
npm version minor  # 1.0.0 -> 1.1.0
# 或
npm version major  # 1.0.0 -> 2.0.0

# 2. 推送更改和 tag
git push && git push --tags

# 3. 发布新版本
export GITHUB_TOKEN=your_token
npm publish
```

## 🐛 故障排除

### 问题 1: 发布失败 - 401 Unauthorized

**原因**: GitHub Token 未配置或已过期

**解决方案**:
```bash
# 检查 token
echo $GITHUB_TOKEN

# 重新设置
export GITHUB_TOKEN=your_new_token

# 或更新 .npmrc
```

### 问题 2: 包名冲突

**原因**: 包名已存在

**解决方案**:
- GitHub Packages 的包名必须使用 scoped name (@username/package-name)
- 确保 package.json 中的 name 为 `@telagod/wezterm-universal-setup`

### 问题 3: 用户无法安装

**原因**: 用户未配置 GitHub Packages 认证

**解决方案**:
- 在 README 中提供清晰的认证配置说明
- 建议用户创建只读 token (read:packages)

## 📚 相关文档

- [GitHub Packages 文档](https://docs.github.com/en/packages)
- [npm 发布指南](https://docs.npmjs.com/cli/v9/commands/npm-publish)
- [GitHub Actions Workflows](https://docs.github.com/en/actions)

## ✅ 检查清单

发布前检查：

- [ ] package.json 中的 name 为 `@telagod/wezterm-universal-setup`
- [ ] package.json 包含 `publishConfig.registry`
- [ ] .npmrc 文件配置正确
- [ ] 所有测试通过（GitHub Actions）
- [ ] CHANGELOG.md 已更新
- [ ] README.md 包含 GitHub Packages 安装说明
- [ ] GitHub Token 已设置
- [ ] 版本号正确

---

准备就绪后，执行发布命令即可！🚀