# wdiff

本地 `zsh` 插件，提供一个带历史缓存的 `nvim -d` 包装器。

## 用法

- `wdiff`
  手动输入左右两段文本，保存到缓存后打开 diff
- `wdiff list`
  查看近期任务，并显示左右摘要；如果安装了 `fzf`，会进入交互选择并重新打开
- `wdiff ls`
  `wdiff list` 的短别名
- `wdiff list 3`
  重新打开历史编号 `3`
- `wdiff 3`
  重新打开历史编号 `3`
- `wdiff path1 path2`
  直接比较两个路径

兼容别名：

- `widff ...`

## 缓存位置

- `${XDG_STATE_HOME:-$HOME/.local/state}/wdiff`

## 细节

- `wdiff` 打开的 `nvim -d` 会隐藏顶部 `bufferline/tabline`，并从中立目录启动，避免把当前项目旧 session/tab 带进来
