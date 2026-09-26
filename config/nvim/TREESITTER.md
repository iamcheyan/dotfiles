# Neovim Treesitter 配置说明与注意事项

- **最后更新**：2026-09-26
- **相关文件**：`config/nvim/lua/plugins/treesitter.lua`（唯一入口）、`config/nvim/lua/plugins/aerial.lua`
- **适用仓库**：`~/dotfiles`（公开基础层）；Chezmoi 只部署 `nvim-private` 与配色，不涉及本文件

---

## 一、运行时要求：Neovim ≥ 0.11

本配置固定使用 **`nvim-treesitter` 的 `main` 分支**（`master` 已由上游归档）。
`main` 需要 Neovim 0.11+ 与 **ABI-15** parser，因此：

| 项目 | 要求 |
|---|---|
| Neovim | **≥ 0.11**（本机 0.12.5，ABI 15） |
| nvim-treesitter | `main` |
| nvim-treesitter-textobjects | `main`（必须与上一行配对） |
| tree-sitter CLI | 编译 grammar 时需要（本机为 mason 提供的 0.26.8） |

> **注意**：如果某台机器还是 Neovim 0.10，**必须先升级 Neovim 再拉取本配置**。
> 0.10 上 `main` 分支整体不可用（ABI-15 parser 无法加载），表现为高亮完全失效。
> 历史上曾为 0.10 机器把分支钉在 `master`，该方案已于 2026-09-26 废弃。

---

## 二、目录布局与职责

| 路径 | 内容 | 说明 |
|---|---|---|
| `~/.local/share/nvim/site/parser/*.so` | 已安装的 parser | 由 `opts.install_dir` 指定；放在插件目录之外，`:Lazy` 操作不会清掉 |
| `~/.local/share/nvim/site/parser-info/*.revision` | 每个 parser 的 grammar revision | `:TSUpdate` 靠它判断是否需要重建 |
| `~/.local/share/nvim/site/queries/<lang>` | 软链接 → 插件 `runtime/queries/<lang>` | 永远指向插件当前查询，不会陈旧 |

`install_dir` 其实与 `main` 的默认值相同，显式写出是为了记录「parser 不放插件目录」这个不变量。

---

## 三、parser 生命周期：`build` 步骤做了什么

`main` **没有** `master` 的 `ensure_installed` 选项，所以补装逻辑写在 spec 的 `build` 里，在插件安装/更新时执行：

1. 用 `get_installed("parsers")` 求出 `ensure_installed` 里缺失的语言 → `TS.install(missing, { force = true })`
2. 调 `TS.update()`：重建 revision 落后于 `main` 所钉版本的 grammar
3. 对上述两个异步任务 `task:wait()`，等它们真正跑完

### 3.1 为什么必须重建「过期」的 parser

`main` 的查询文件跟随上游最新 grammar，而 parser 由 revision 钉住。**切换分支或跨大版本升级后，旧 grammar 会让查询直接报错并中断高亮**：

```text
Query error at 74:3. Invalid field name "operator":
  operator: _ @operator)
```

2026-09-26 从 `master` 切到 `main` 时实测命中过（`.lua` 一打开就报），按 `main` 的 revision 重建 16 个 parser 后恢复。手动修复命令：

```vim
:TSUpdate          " 只重建 revision 落后的 parser
:checkhealth nvim-treesitter
```

### 3.2 上游 API 怪癖（改这段代码前必读）

| 现象 | 原因 | 应对 |
|---|---|---|
| build 里 `TS.install(...)` 看似执行了，其实什么都没装 | `arun()` **不阻塞**，build 所在的那个 Neovim 返回后立刻退出，异步任务被掐断 | 必须 `task:wait()` |
| 缺 parser 但 `get_installed()` 说已安装，补装被跳过 | 不带参数时它把「只有 queries 目录」的语言也算作已安装 | 用 `get_installed("parsers")` |
| 传了缺失列表，`install()` 仍然跳过 | `install()` 内部按 `get_installed()`（同样包含 queries-only）过滤 | 传 `{ force = true }` |

---

## 四、filetype → parser 别名注册

`main` 不再注册任何 filetype 别名（`master` 的 `parsers.lua` 曾把 `javascriptreact` 映射到 `javascript`）。
因此本配置在 `lua/plugins/treesitter.lua` 的 `config` 中显式注册：

| filetype | parser | 备注 |
|---|---|---|
| `sh`、`zsh` | `bash` | 原先依赖 `aerial.lua` 先被加载才注册，时序不确定；已改为 treesitter 配置统一注册，`aerial.lua` 里的重复注册已删除 |
| `javascriptreact`（`.jsx`） | `javascript` | `master` 上由 `parsers.lua` 提供，`main` 需要自己注册，否则 `.jsx` 静默失去高亮 |
| `typescriptreact`（`.tsx`） | `tsx` | `master` 上同样缺失，一并修好 |

判断某个 filetype 实际用了哪个 parser：

```vim
:lua =vim.treesitter.language.get_lang(vim.bo.filetype)
```

若返回值等于 filetype 本身（如 `sh`），说明没有注册，parser 不会加载。

---

## 五、从 0.10 / `master` 迁移到 0.11+ / `main`

1. 先把该机器 Neovim 升到 **0.11+**（本仓库 `scripts/install/install_nvim.sh` 装最新 release）
2. 拉取本仓库并重建软链：`cd ~/dotfiles && bash dotlink/dotlink link`
3. `nvim` 内执行 `:Lazy sync`，确认 `nvim-treesitter` 已在 `main`、`textobjects` 也在 `main`
4. 让 build 步骤跑完（`:Lazy sync` 会自动触发）；若已有旧 parser，确认它执行了 `TS.update()`
5. 按第七节做一次验证

**注意**：`config/nvim/lazy-lock.json` 在 `.gitignore` 中，**不入库**。分支与 commit 的钉住信息只存在于本机，换机后以 `main` 最新提交为准。

---

## 六、故障排查

| 症状 | 原因 | 处理 |
|---|---|---|
| `Query error ... Invalid field name "..."` | parser 比查询旧 | `:TSUpdate`（或让 build 步骤跑一遍） |
| 某 filetype 完全没有高亮 | 该 filetype 未注册别名，或 parser 缺失 | 查 `get_lang()`；`:TSInstall <lang>` |
| `attempt to call method 'range' (a nil value)`，栈里有 `nvim-treesitter/query_predicates.lua` | `master` 分支在 Neovim 0.12 上的已知不兼容（0.12 移除了 `all = false` 兼容包装，handler 直接收到 capture 列表） | 本项目已改用 `main`，不会再出现；若有人手工把分支改回 `master` 就会复现 |
| 注入（代码块内语言）不高亮 | 注入查询依赖的指令报错 | 看 `~/.local/state/nvim/nvim.log` 里的 `decor_provider_error` |

---

## 七、验证方法

无头快速验证（打开若干真实文件，检查高亮与注入，最后看日志）：

```bash
rm -f ~/.local/state/nvim/nvim.log
nvim --headless -u ~/.config/nvim/init.lua -l /tmp/check.lua
grep -c "Error\|Query error" ~/.local/state/nvim/nvim.log
```

`/tmp/check.lua` 内容示例（在放着这些示例文件的目录下运行，文件名可自行替换）：

```lua
for _, f in ipairs({ "a.md", "b.html", "b.rb", "a.jsx", "b.tsx", "a.sh", "t.lua" }) do
  vim.cmd("edit " .. f)
  local buf = vim.api.nvim_get_current_buf()
  pcall(vim.treesitter.start, buf)
  vim.api.nvim__redraw({ flush = true, valid = false })
  print(string.format("%-8s ft=%-16s lang=%-16s hl=%s", f, vim.bo.filetype,
    tostring(vim.treesitter.language.get_lang(vim.bo.filetype)),
    tostring(vim.treesitter.highlighter.active[buf] ~= nil)))
  vim.cmd("enew!")
end
vim.cmd("qa!")
```

其它检查：

```vim
:checkhealth nvim-treesitter        " ABI 版本、CLI、install_dir 是否可写并在 rtp
:lua =#require("nvim-treesitter").get_installed("parsers")
```

2026-09-26 切换后的实测结果：`treesitter_filetypes` 列出的 **28 个 filetype 全部 `hl=true`**；
markdown 注入 `bash,lua,markdown_inline`、html 注入 `javascript`、ruby heredoc 注入 `lua`；
`~/.local/state/nvim/nvim.log` 零报错；`checkhealth` 全 OK。

---

## 八、遗留事项

- `gitsigns.nvim` 仍钉在 `version = "v2.1.0"`（`lua/plugins/gitsigns.lua`）。当初是为 Neovim 0.10 兼容而加，0.10 支持已废弃；该版本在本机（0.12.5）工作正常，故暂未解钉。若要跟进上游最新，删除这一行即可。
- `nvim-treesitter-textobjects` 的 `opts` 用的是 `main` 的 schema（`move.keys.*`）。`master` 的 schema 不同（键直接挂在 `move` 下），**不要**在未同步改配置的情况下把分支改回 `master`。
