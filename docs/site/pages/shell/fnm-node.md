> 摘要：fnm 的惰性加载包装器如何工作，以及 Inshellisense 的生成式集成。

# fnm 与 Node 工具链

## 为什么要包装

fnm 的标准初始化是 `eval "$(fnm env --use-on-cd)"`，每次启动 shell 都要执行一次子进程。本仓库把这件事推迟到第一次真正用 Node 时，减少启动开销。

`scripts/setup/setup_fnm.sh` 定义四个包装函数：`node`、`npm`、`npx`、`corepack`，以及 `fnm` 本身。

## 查找 fnm 二进制

```zsh
__fnm_bin() {
    for candidate in "$FNM_DIR/fnm" "$FNM_DIR/bin/fnm" \
                     "$HOME/.local/share/fnm/fnm" "$HOME/.local/bin/fnm"; do
        [[ -x "$candidate" ]] && { printf '%s\n' "$candidate"; return 0; }
    done
    command -v fnm 2>/dev/null && return 0
    ...
}
```

按常见安装位置依次探测，最后才查 PATH。这样即使 fnm 不在 PATH 里也能找到。

## 首次调用时的初始化

```zsh
__fnm_lazy_load() {
    [[ "${__FNM_LAZY_LOADED:-0}" == "1" ]] && return 0
    fnm_bin="$(__fnm_bin)" || { echo "Error: fnm not found" >&2; return 1; }
    eval "$("$fnm_bin" env --shell zsh --use-on-cd)"
    if ! "$fnm_bin" use default >/dev/null 2>&1; then
        latest_local=$("$fnm_bin" list 2>/dev/null | grep -Eo 'v[0-9]+\.[0-9]+\.[0-9]+' | sort -V | tail -1)
        [[ -n "$latest_local" ]] && "$fnm_bin" use "$latest_local"
    fi
    export __FNM_LAZY_LOADED=1
}
```

流程：

1. 用标志位保证只执行一次。
2. 执行 `fnm env`，把 Node 的 bin 目录注入 PATH。
3. 尝试切到 `default` 版本。
4. 如果没设 default，自动选本地最新的已安装版本，并把它设为 default。

第 4 步是容错：新装 fnm 但还没 `fnm default` 时，不至于所有 Node 命令都失败。

## 没有 fnm 时

```zsh
__fnm_lazy_dispatch() {
    if ! __fnm_bin >/dev/null; then
        unfunction node npm npx corepack 2>/dev/null || true
        command "$command_name" "$@"
        return $?
    fi
    ...
}
```

如果找不到 fnm（NixOS 常见，Node 由系统提供），直接删掉包装函数，调用系统命令。这样包装器不会挡住系统的 node。

## 日常用法

```bash
fnm list                  # 已安装版本
fnm list-remote --lts     # 可安装的 LTS
fnm install --lts
fnm default 22            # 设为默认
fnm use 20                # 当前 shell 切到 20
node --version
```

`.nvmrc` 或 `.node-version` 文件存在时，`--use-on-cd` 会在 `cd` 进目录时自动切换版本。

## Inshellisense

init.sh 在 Node/npm 可用时安装：

```bash
npm install --global @microsoft/inshellisense
```

它需要在交互式 shell 里生成集成脚本。注意 `is init zsh` 输出的是**一条 source 命令**，不是可直接 eval 的 shell 代码：

```zsh
if [[ -o interactive ]] && [[ -z "${ISTERM:-}" ]] && command -v is >/dev/null 2>&1; then
    if [[ ! -r "${XDG_DATA_HOME:-$HOME/.local/share}/inshellisense/init/zsh/init.zsh" ]]; then
        is init zsh >/dev/null 2>&1 || true
    fi
    source "${XDG_DATA_HOME:-$HOME/.local/share}/inshellisense/init/zsh/init.zsh"
fi
```

先检查文件是否存在，不存在才生成，然后 source。`ISTERM` 变量用于防止在它自己启动的子 shell 里递归加载。

### 用法

```bash
is                # 进入 Inshellisense 会话
is doctor         # 检查集成健康度
is complete 'git '  # 查看某前缀的补全
exit              # 退出会话
```

在普通输入时，它会在命令下方浮出参数建议：

| 键 | 动作 |
|---|---|
| `Tab` | 接受当前建议 |
| `↑` / `↓` | 切换建议 |
| `Esc` | 关闭建议 |

### 与 Zsh 补全的关系

Inshellisense 不替代 `compinit` 或 fzf-tab。它读取自己的 completion specs，覆盖范围取决于该项目的定义。两者同时存在时，Tab 的行为取决于当前是否显示建议：有建议时 Tab 归它，否则交回 Zsh。

### 更新

```bash
npm install --global @microsoft/inshellisense
is reinit
```

`is reinit` 重新生成集成文件，升级后必须跑一次。

## 排错

**`node` 报 fnm not found**：fnm 没装，且系统也没有 node。装一个。

**Node 版本不对**：`fnm list` 看当前指向，`fnm default <ver>` 重设。

**`is` 命令没有建议**：`is doctor` 检查；确认终端是交互式，且 `$TERM` 支持。

**每次 cd 都卡一下**：`--use-on-cd` 会在有 `.nvmrc` 的目录里执行 fnm 切换。目录很多时可以关掉，改为手动 `fnm use`。
