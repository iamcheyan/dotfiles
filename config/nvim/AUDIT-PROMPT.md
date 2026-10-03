# Neovim 配置全面体检与修复

对 `~/dotfiles/config/nvim/`（公开层）与 `~/chezmoi/dot_config/nvim-private/`（私有层）做一次完整的
健康体检，找出会导致报错、功能静默失效、性能退化的问题，**逐个修复并验证**，最后给出可清理清单。

## 背景

- 环境：Neovim 0.12.4（NixOS）、lazy.nvim、纯自管架构（LazyVim 已完全移除，但保留了移植代码）
- 已排除的干扰项（不要重复报告）：
  - 无头环境不会触发 `UIEnter`，所以 `Snacks.dashboard setup did not run`、
    `vim.ui.select is not set to Snacks.picker.select`、`Snacks.* setup {disabled}` 是**假象**，实测正常
  - TUI terminal mode 警告、lsp.log 里的 `LSP logging initiated` 噪音
  - 大小写扩展名检测（已于 2026-10-03 修复，见 `FILETYPE-DETECTION.md`）
- 已有基线：启动 51ms；打开 150 个真实文件零报错；`lua_ls`/`basedpyright` 正常 attach
- **参考上次审查**：`~/dotfiles/config/nvim/AUDIT-2026-10-03.md`（含 4 个 P0、5 个 P1 的复现证据）

## 要求

### 1. 必须用证据，禁止推测

每条发现必须给出：`文件:行号` + 代码片段 + **可复现的运行证据** + 后果 + 修复方案。
不能只读代码就下结论——凡声称「会报错/会失效」，都要实际跑一遍复现出来。

复现手段（按需组合）：
- `nvim --headless -u ~/.config/nvim/init.lua -c 'luafile /tmp/probe.lua' -c 'qa!'`
- 捕获 `vim.notify`（包一层记录 WARN/ERROR）来抓插件运行时通知
- `vim.fn.exists(":Cmd")` 验证命令存在性
- `vim.fn.maparg(k, mode, false, true)` 验证键位真实归属与 `rhs`/`callback`
- `debug.getinfo(fn, "S")` 定位函数实际来源
- 用 `--startuptime` 测启动耗时；对比修改前后

### 2. 重点排查方向

1. **不存在的命令/模块引用**：扫描所有 `<cmd>X`、`require("y")`，逐个验证 X/y 是否存在
   （历史教训：`TodoPicker` 不存在、`telescope.builtin` 已被删除、`dos2unix` 未安装）
2. **插件 setup 失败**：某个依赖抛错会中断整个 `setup()`，导致后续 `xxx.setup()` 全部不执行
   （历史教训：yanky 的 sqlite 失败 → `preserve_cursor`/`highlight` 从未配置）
3. **键位覆盖冲突**：多个文件/插件争抢同一 `lhs`，后加载者静默胜出
   （历史教训：`<leader>cf`/`<leader>cd` 被个人 keymaps 覆盖 LazyVim 语义）
4. **配置项被插件反向覆盖**：如 `vim.opt.showtabline` 被 bufferline 的 `auto_toggle_bufferline` 改写
5. **键位门槛永假**：如 `if vim.g.autoformat ~= false then`，而该变量被另一文件设为 `false`
6. **字符串转义错误**：尤其 `vim.keymap.set` 里的 `\\`、`<c-o>`、`%` 等
7. **插件功能重复/死代码**：找出做同一件事的多个插件、已删插件残留的高亮组/排除列表/键位
8. **外部依赖缺失**：`vim.fn.system()` 在可执行文件缺失时会**抛错**而非返回错误码
9. **LSP/诊断接线**：`client.handlers` 是否在 client 构造后才写（无效）、`on_attach` 是否跑完

### 3. 修复原则

- **删掉就删干净**：迁移所有调用方，移除废弃别名/再导出/兼容层，不留 shim
- **不要顺手扩大范围**：不添加未被要求的重试、校验、遥测、抽象
- **不要掩盖症状**：禁止用 pcall 吞掉错误、特例化输入、降级为静默 no-op
- 私有层改动走 `chezmoi apply ~/.config/nvim-private`，并在子模块内独立提交推送
- 公开层改动直接改 `~/dotfiles`，遵守该仓库既有约定

### 4. 验证要求（不可跳过）

- 每处修复都要**先复现问题、再确认修复**，并保留能捕获该缺陷的回归测试或明确的复现命令
- 跑一次真实场景冒烟：启动 nvim、打开各类真实文件、触发被修改的键位/命令，观察输出
- 检查 `~/.local/state/nvim/nvim.log` 与 `lsp.log` 无新增报错
- 对比修改前后的启动耗时（`--startuptime`），确认没有性能退化
- 跑一遍相关插件自带测试（如 `batch.nvim/tests/test.sh`、`cobol.nvim/scripts/test.sh`）

### 5. 输出

1. **已修复**：每条一行 + 证据 + 修复点
2. **待你决策**（有取舍的）：列出选项与影响，不要擅自替用户决定
3. **建议清理**：明确标注哪些是死代码、删了会有什么影响
4. **优化建议**：性能、启动时间、插件精简，每条要有数据支撑（如实测耗时）
5. **未发现问题**的部分也要说明「已检查，正常」，避免用户以为漏检

不要在没有实测证据的情况下声称任何东西是好的或坏的。
