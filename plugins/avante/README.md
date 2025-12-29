# Avante.nvim + Gemini 配置指南

## 简介

`avante.nvim` 是一个 AI 驱动的 Neovim 插件，支持多种 AI 模型，包括 Google Gemini。本指南将帮助你安装和配置 avante.nvim 使用 Gemini。

## 安装步骤

### 1. 插件已自动安装

插件配置文件已创建在 `~/.config/nvim/lua/plugins/avante.lua`。

### 2. 获取 Gemini API Key

1. 访问 [Google AI Studio](https://makersuite.google.com/app/apikey)
2. 登录你的 Google 账户
3. 点击 "Create API Key" 创建新的 API 密钥
4. 复制生成的 API Key

### 3. 配置 API Key

**方法1: 使用环境变量（推荐）**

在 `~/.zshrc` 或 `~/.bashrc` 中添加：

```bash
export GEMINI_API_KEY="your-api-key-here"
```

然后重新加载 shell 配置：

```bash
source ~/.zshrc
```

**方法2: 直接在配置文件中设置（不推荐）**

编辑 `~/.dotfiles/plugins/avante/.env`，修改：

```lua
# Gemini API Key
GEMINI_API_KEY="your-api-key-here"

# Gemini Model Selection
GEMINI_MODEL=gemini-flash-latest
```

### 4. 安装插件

打开 Neovim，运行：

```vim
:Lazy sync
```

或者重启 Neovim，Lazy.nvim 会自动安装插件。

## 使用方法

### 基本命令

- `:AvanteAsk` - 向 AI 提问
- `:AvanteChat` - 打开聊天窗口
- `:AvanteReview` - 代码审查
- `:AvanteFix` - 修复代码问题

### 快捷键

- `<leader>aa` - Avante: Ask
- `<leader>ac` - Avante: Chat
- `<leader>ar` - Avante: Review
- `<leader>af` - Avante: Fix

### 使用示例

1. **代码提问**：
   - 选中代码
   - 按 `<leader>aa`
   - 输入问题，如 "解释这段代码的作用"

2. **代码审查**：
   - 选中代码
   - 按 `<leader>ar`
   - AI 会自动审查代码并提供建议

3. **代码修复**：
   - 选中有问题的代码
   - 按 `<leader>af`
   - AI 会尝试修复代码

4. **聊天模式**：
   - 按 `<leader>ac`
   - 在聊天窗口中与 AI 对话

## 配置选项

### 模型选择

在 `~/.config/nvim/lua/plugins/avante.lua` 中可以修改模型：

```lua
gemini = {
  model = "gemini-pro",  -- 可选: gemini-pro, gemini-pro-vision, gemini-ultra
  -- ...
}
```

### 其他配置

```lua
gemini = {
  model = "gemini-pro",
  max_tokens = 4096,      -- 最大输出长度
  temperature = 0.7,      -- 温度（0.0-1.0），控制随机性
  top_p = 0.95,           -- 核采样参数
  top_k = 40,             -- Top-K 采样参数
}
```

## 故障排除

### 问题1: API Key 未设置

**错误信息**：`GEMINI_API_KEY not found`

**解决方法**：
1. 检查环境变量是否设置：`echo $GEMINI_API_KEY`
2. 确保在 Neovim 启动前设置了环境变量
3. 或者直接在配置文件中设置 API Key

### 问题2: 插件未安装

**解决方法**：
```vim
:Lazy sync
```

### 问题3: 网络连接问题

**解决方法**：
1. 检查网络连接
2. 如果在中国大陆，可能需要配置代理
3. 检查防火墙设置

### 问题4: API 配额限制

**解决方法**：
1. 检查 [Google AI Studio](https://makersuite.google.com/app/apikey) 中的配额
2. 免费版本有使用限制
3. 考虑升级到付费版本

## 高级用法

### 使用多个 Provider

可以在配置中设置多个 provider，avante.nvim 会自动切换：

```lua
opts = {
  provider = "gemini",  -- 默认使用 gemini
  gemini = { ... },
  claude = { ... },     -- 备用 provider
}
```

### 自定义快捷键

在 `~/.config/nvim/lua/config/keymaps.lua` 中添加：

```lua
vim.keymap.set("n", "<leader>ag", "<cmd>AvanteAsk<cr>", { desc = "Avante Ask" })
```

## 参考资源

- [Avante.nvim GitHub](https://github.com/yetone/avante.nvim)
- [Google Gemini API 文档](https://ai.google.dev/docs)
- [Google AI Studio](https://makersuite.google.com/)

## 注意事项

1. **API Key 安全**：不要将 API Key 提交到公共仓库
2. **使用限制**：免费 API Key 有使用限制
3. **隐私**：代码会发送到 Google 服务器，注意隐私保护
4. **网络**：需要稳定的网络连接

