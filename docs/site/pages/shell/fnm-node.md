> 摘要：fnm 的惰性加载包装器如何工作，以及它如何为 npm 全局命令提供 PATH。

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

## 排错

**`node` 报 fnm not found**：fnm 没装，且系统也没有 node。装一个。

**Node 版本不对**：`fnm list` 看当前指向，`fnm default <ver>` 重设。

**`is` 命令没有建议**：`is doctor` 检查；确认终端是交互式，且 `$TERM` 支持。

**每次 cd 都卡一下**：`--use-on-cd` 会在有 `.nvmrc` 的目录里执行 fnm 切换。目录很多时可以关掉，改为手动 `fnm use`。
<!-- lang:en -->
> Summary: How the lazy-loading wrapper for fnm works, and how it provides PATH for npm global commands.

# fnm and the Node Toolchain

## Why wrap it

fnm's standard initialization is `eval "$(fnm env --use-on-cd)"`, which spawns a subprocess every time the shell starts. This repo defers that until Node is actually used for the first time, reducing startup overhead.

`scripts/setup/setup_fnm.sh` defines four wrapper functions — `node`, `npm`, `npx`, `corepack` — plus `fnm` itself.

## Locating the fnm binary

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

It probes common installation locations in order and only falls back to PATH at the end. This way fnm can still be found even when it is not on PATH.

## Initialization on first invocation

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

The flow:

1. A flag ensures it only runs once.
2. Runs `fnm env`, injecting Node's bin directory into PATH.
3. Tries to switch to the `default` version.
4. If no default is set, automatically picks the latest locally installed version and sets it as default.

Step 4 is a fallback: when fnm was just installed but `fnm default` hasn't been run yet, Node commands don't all fail.

## When fnm is absent

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

If fnm cannot be found (common on NixOS, where Node is provided by the system), the wrapper functions are removed and the system command is called directly. That way the wrapper doesn't block the system's node.

## Everyday usage

```bash
fnm list                  # 已安装版本
fnm list-remote --lts     # 可安装的 LTS
fnm install --lts
fnm default 22            # 设为默认
fnm use 20                # 当前 shell 切到 20
node --version
```

When a `.nvmrc` or `.node-version` file exists, `--use-on-cd` automatically switches versions when you `cd` into the directory.

## Troubleshooting

**`node` reports "fnm not found"**: fnm is not installed and the system has no node either. Install one.

**Wrong Node version**: check the current target with `fnm list`, then reset it with `fnm default <ver>`.

**The `is` command gives no suggestions**: run `is doctor` to check; make sure the terminal is interactive and `$TERM` supports it.

**Every `cd` stalls briefly**: `--use-on-cd` executes an fnm switch in directories containing `.nvmrc`. If you visit many such directories, you can turn it off and use `fnm use` manually instead.
<!-- lang:ja -->
> 要約：fnm の遅延ロードラッパーの仕組みと、npm グローバルコマンドへの PATH 提供の方法。

# fnm と Node ツールチェーン

## なぜラップするのか

fnm の標準的な初期化は `eval "$(fnm env --use-on-cd)"` で、シェルを起動するたびにサブプロセスを一度実行する必要があります。本リポジトリではこれを最初に Node を実際に使う時まで延期し、起動オーバーヘッドを減らしています。

`scripts/setup/setup_fnm.sh` は 4 つのラッパー関数 `node`、`npm`、`npx`、`corepack` と、`fnm` 本体を定義します。

## fnm バイナリの探索

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

よくあるインストール先を順に調べ、最後に PATH を確認します。これにより fnm が PATH にない場合でも見つけられます。

## 初回呼び出し時の初期化

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

処理の流れ：

1. フラグで一度だけ実行されることを保証します。
2. `fnm env` を実行し、Node の bin ディレクトリを PATH に注入します。
3. `default` バージョンへの切り替えを試みます。
4. default が未設定の場合、ローカルにインストール済みの最新バージョンを自動選択し、default に設定します。

第 4 手順はフェイルセーフです。fnm を新規インストールした直後でまだ `fnm default` を実行していない時でも、Node コマンドがすべて失敗することはありません。

## fnm がない場合

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

fnm が見つからない場合（Node がシステム提供の NixOS でよくあるケース）は、ラッパー関数を削除してシステムのコマンドを直接呼び出します。これによりラッパーがシステムの node を妨げることがありません。

## 日常の使い方

```bash
fnm list                  # 已安装版本
fnm list-remote --lts     # 可安装的 LTS
fnm install --lts
fnm default 22            # 设为默认
fnm use 20                # 当前 shell 切到 20
node --version
```

`.nvmrc` または `.node-version` ファイルが存在する場合、`--use-on-cd` が `cd` でディレクトリに入った時に自動でバージョンを切り替えます。

## トラブルシューティング

**`node` が fnm not found を出す**：fnm がインストールされておらず、システムにも node がありません。どちらかをインストールしてください。

**Node のバージョンが違う**：`fnm list` で現在の向き先を確認し、`fnm default <ver>` で設定し直します。

**`is` コマンドに候補が出ない**：`is doctor` で確認します。ターミナルが対話式で、`$TERM` が対応していることを確かめてください。

**cd のたびに一瞬固まる**：`--use-on-cd` は `.nvmrc` があるディレクトリで fnm の切り替えを実行します。対象ディレクトリが多い場合は無効化して手動の `fnm use` に切り替えると良いでしょう。
