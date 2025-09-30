# 发布到 GitHub Packages 指南

本文档说明如何将 wezterm-universal-setup 发布到 GitHub Packages。

## 📦 准备工作

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