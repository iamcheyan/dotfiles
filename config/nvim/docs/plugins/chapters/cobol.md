# cobol.nvim

> 私有插件 · [回到插件目录](../PLUGINS.md)

## 它解决什么问题

为 GnuCOBOL 固定格式提供列布局、智能缩进、Copybook 与数据定义导航、异步编译/检查、折叠和 PIC 布局估算。

## 在当前配置里怎么用

`gd` 跳到当前文件或直接引用的 Copybook 中的段落/数据定义；多个候选时会弹出选择列表。跳转后按 `Ctrl-o` 返回、`Ctrl-i` 前进。`gf` 在 COPY 行打开 Copybook，`K` 预览定义或 Copybook。`<leader>uc` 切换列标尺；`:CobolToggleComment` 注释；`:CobolFormatCase` 格式化关键字；`:CobolLint` 检查；`:CobolBuild` / `:CobolRun` / `:CobolTest` 执行项目循环；`:CobolCalcRecord` 估算记录布局。

## 动手练习

先在项目根目录添加 `.cobol.json`：

```json
{
  "source_format": "fixed",
  "dialect": "default",
  "copybook_paths": ["copy", "cpy"],
  "compiler": "cobc",
  "compiler_args": ["-Wall"]
}
```

打开 COBOL 文件，确认列标尺中的第 7 列指示区、第 8–11 列 Area A、第 12–72 列 Area B。按 `gg=G` 试试整文件缩进，再检查注释、序号列和第 72 列的位置。在 PROCEDURE DIVISION 的 `PERFORM 1000-INITIALIZE` 上按 `gd`，再按 `Ctrl-o` 回来。若字段定义放在 COPY 引用的 Copybook 中，在字段名上按 `gd`；在 COPY 行按 `gf` 打开文件。然后执行 `:CobolTest`；单文件项目可再试 `:CobolBuild`、`:CobolRun`。多程序项目在 `.cobol.json` 的 `commands` 中给出参数数组，或让插件调用 Makefile 目标。完整设置与选项见私有插件目录中的 `README.zh-CN.md`。

## 注意事项

gd 由插件本地解析，不需要 COBOL LSP；会递归搜索 COPY 引用的 Copybook，重名候选可选择。项目命令读取已保存文件，执行前先保存。`.cbl`/`.cob`/`.cobol`/`.cpy` 应识别为 cobol。用 `:verbose nmap gd` 确认当前映射。

## 查快捷键和帮助

在 Neovim 里用 `:verbose nmap <按键>` 查看最终映射和定义来源；按 `<leader>` 后稍等可看 which-key 提示。可用命令可用 `:command <前缀>` 查询。
