# Neovim 大小写不敏感扩展名检测

- **最后更新**：2026-10-03
- **相关文件**：`config/nvim/lua/config/options.lua`（唯一入口）
- **私有层**：`~/chezmoi/dot_config/nvim-private/lua/{plugins/cobol.lua,batch.nvim/}`

---

## 一、问题：Neovim 的扩展名表区分大小写

Neovim 内置的 `extension` 表按**精确拼写**注册扩展名（`vim.filetype.lua` 中共 1298 项，
其中 50 组存在大小写变体），因此：

| 文件名 | 结果 |
|---|---|
| `run.bat` | `dosbatch` ✅ |
| `RUN.BAT` | **无 filetype**，完全没有高亮 ❌ |
| `PROG.CBL` | **无 filetype** ❌（`cbl` 有注册，`CBL` 没有） |
| `data.CPY` | **无 filetype** ❌ |
| `BT0P.CONF` | **无 filetype** ❌ |

`.conf`/`.cnf`/`.config` 更特殊：它们**根本不在扩展名表里**，只由内容回退
（`vim.filetype.detect.conf`）判定，且该回退只认 `^#` 注释。因此没有前导 `#`
的配置文件（如 `PageSize=5` 开头的 fcitx5 配置）同样检测失败。

COBOL 源码、批处理脚本和手写配置文件恰好最常用大写扩展名，所以受影响最明显。

---

## 二、`vim.filetype.add` 的两个陷阱

这是最初修复失败的原因，改这段代码前必须理解：

### 1. pattern 键是 **Lua pattern**，不是 glob

`vim.filetype.add` 会把每个 `pattern` 键包装成 `'^' .. key .. '$'`：

```lua
-- 错误：glob 写法
["*.[bB][aA][tT]"] = "dosbatch"
-- 实际注册为 "^*.[bB][aA][tT]$"
--   "*" 在这里是量词，修饰的是 "^" 字符本身，永远无法匹配任何文件名
```

```lua
-- 正确：Lua pattern 写法
[".*%.[bB][aA][tT]"] = "dosbatch"
-- 实际注册为 "^.*%.[bB][aA][tT]$"
```

### 2. 不要自己加 `$`

包装已经带 `$`，再写一个会变成 `$$`，同样永不匹配：

```lua
[".*%.[bB][aA][tT]$"] = "dosbatch"  -- ❌ 变成 "...$$"
```

### 3. 用负优先级让位给更精确的规则

`conf` 这类宽泛规则必须用 `priority = -1`，否则会抢走 Neovim 更精确的判定：

| 文件 | 需要的结果 |
|---|---|
| `~/.config/tmux/tmux.conf` | `tmux`（不是 `conf`） |
| `~/.config/kitty/kitty.conf` | `kitty` |
| `~/.config/hypr/*.conf` | `hyprlang` |
| `~/.config/wireplumber/**.conf` | `spajson` |

---

## 三、当前实现

`lua/config/options.lua` 中：

1. `ci_pattern(ext)` 把 `"bat"` 展开为 `".*%.[bB][aA][tT]"`，统一处理大小写。
2. 批量注册 `bat`/`cmd`→`dosbatch`、`cob`/`cbl`/`cobol`/`cpy`→`cobol`、
   `ini`→`dosini`、`env`→`env`，全部 `priority = -1`。
3. `conf`/`cnf`/`config` 走 `detect_generic_config`：读取前 120 行，统计 shell
   构造与 `KEY=VALUE` 赋值，据此选择 `sh` / `dosini` / `conf`。

分类阈值（shell ≥ 5 且多于赋值行 → `sh`；有赋值行 → `dosini`；否则 `conf`）是拿
本机 28 个真实 `.conf` 文件做基准测出来的，**改动前请重跑第四节的验证**。

> 内容嗅探需要 buffer。`vim.filetype.match({ filename = ... })` 这种只给文件名的
> 调用拿不到内容，会保守地返回 `conf`；只有真正 `:edit` 打开文件时才会分类。

---

## 四、验证方法

```bash
nvim --headless -u ~/.config/nvim/init.lua -c 'lua <检查脚本>' -c 'qa!'
```

检查脚本要点（必须**真正打开文件**，用 `vim.bo.filetype`，不要用 `vim.filetype.match`）：

```lua
for _, f in ipairs({ "RUN.BAT", "PROG.CBL", "DATA.CPY" }) do
  vim.cmd("edit! " .. f)
  print(f, vim.bo.filetype)   -- 期望 dosbatch / cobol / cobol
  vim.cmd("enew!")
end
```

2026-10-03 实测：大小写矩阵 **43/43** 通过，既有行为回归 **25/25** 通过，
`~/.local/state/nvim/nvim.log` 无报错。

---

## 五、故障排查

| 症状 | 原因 |
|---|---|
| 大写扩展名仍无高亮 | pattern 写成了 glob，或误加了 `$`（见第二节） |
| `tmux.conf` 变成 `conf` | 忘了 `priority = -1` |
| 配置文件分类不对 | 内容嗅探阈值需要调整，按第四节用真实文件重测 |
| 私有插件改了但没生效 | 运行 `chezmoi apply ~/.config/nvim-private`；`batch.nvim` 从源目录加载，`cobol.nvim` 从部署目录加载 |
