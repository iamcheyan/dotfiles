> 摘要：zsh-vi-mode 让命令行拥有 Vim 的普通/可视模式，并默认以插入模式启动。

# zsh-vi-mode

## 用途

Zsh 自带 `bindkey -v` 的 vi 模式，但功能有限。`jeffreytse/zsh-vi-mode` 提供完整实现：文本对象、寄存器、可视模式、可配置的模式指示器。

本仓库用它把命令行编辑变成 Vim 手感：`Esc` 进入普通模式，然后 `w`、`b`、`dd`、`ciw` 都能用。

## 加载方式

```zsh
zinit ice lucid
zinit light jeffreytse/zsh-vi-mode

export ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT

function zvm_after_init() {
  zvm_bindkey viins '^[[A' atuin-up-search
  zvm_bindkey viins '^[OA' atuin-up-search
}
```

### lucid 的作用

`lucid` 让插件加载时不立刻绑定键位。原因是 zsh-vi-mode 会重置整个键位表，如果它先执行，后面插件的 `bindkey` 可能被覆盖。

加了 `lucid` 后，实际初始化推迟到 `zshrc` 加载完毕，此时其它插件已经设置好键位。

### ZVM_LINE_INIT_MODE

默认情况下 vi-mode 启动后是普通模式，每次开终端都要先按 `i`。这个变量改成 Insert 模式，符合日常输入习惯。

### zvm_after_init

插件提供的 hook，在所有初始化完成后调用。本仓库在这里把上箭头绑给 Atuin：

```zsh
zvm_bindkey viins '^[[A' atuin-up-search
zvm_bindkey viins '^[OA' atuin-up-search
```

两种转义序列对应不同终端的上箭头编码，两个都要绑。

## 模式

| 模式 | 进入方式 | 提示符 |
|---|---|---|
| Insert | 默认，或 `i`、`a`、`I`、`A` | 正常 |
| Normal | `Esc` | 光标变方块 |
| Visual | 普通模式下 `v` | 选区高亮 |
| Visual-line | 普通模式下 `V` | 整行选区 |

## 常用键位

### 移动

| 键 | 动作 |
|---|---|
| `h` / `l` | 左 / 右一个字符 |
| `w` / `b` | 下一个 / 上一个词首 |
| `e` | 词尾 |
| `0` / `$` | 行首 / 行尾 |
| `^` | 第一个非空字符 |
| `f<char>` / `F<char>` | 行内向后 / 向前跳到字符 |
| `t<char>` / `T<char>` | 跳到字符前 |

### 编辑

| 键 | 动作 |
|---|---|
| `x` | 删除光标处字符 |
| `dd` | 删除整行 |
| `dw` | 删除一个词 |
| `D` | 删到行尾 |
| `cw` | 改一个词 |
| `cc` | 改整行 |
| `r<char>` | 替换一个字符 |
| `~` | 切换大小写 |

### 文本对象

| 键 | 动作 |
|---|---|
| `ciw` | 改词内 |
| `caw` | 改一个词（含空格） |
| `ci"` | 改双引号内 |
| `ci'` | 改单引号内 |
| `ci(` / `ci)` | 改括号内 |
| `di{` | 删花括号内 |

### 可视模式

| 键 | 动作 |
|---|---|
| `v` | 进入字符可视 |
| `V` | 进入行可视 |
| `y` | 复制选区 |
| `d` | 删除选区 |
| `c` | 改选区 |
| `>` / `<` | 缩进 |

### 历史

| 键 | 动作 |
|---|---|
| `k` / `j`（普通模式） | 上一条 / 下一条历史 |
| `↑` / `↓`（插入模式） | 交给 Atuin（本仓库配置） |
| `/` | 反向搜索历史 |
| `?` | 正向搜索历史 |

## 模式指示器

插件可以在提示符里显示当前模式。本仓库没启用，靠 Starship 的 `vimcmd_symbol` 间接提示：

```toml
[character]
vimcmd_symbol = "[❯](bold yellow)"
```

普通模式下提示符变黄，是一个轻量的模式提示。

想用插件自带的指示器：

```zsh
ZVM_MODE_INDICATOR=1
```

## 与 autosuggestions 的顺序

vi-mode 必须在 zsh-autosuggestions **之前**加载。

原因：autosuggestions 会在 `zle` 里插入建议文本，vi-mode 会重设键位表。如果顺序反了，建议文本的接受键（默认 `→`）可能失效。

本仓库的顺序是对的：

```zsh
zinit light jeffreytse/zsh-vi-mode
...
zinit light zsh-users/zsh-autosuggestions
```

## 排错

**启动是普通模式**：`ZVM_LINE_INIT_MODE` 没设，或设在了插件加载之后。必须在 `zinit light` 之前 `export`。

**上箭头不搜索历史**：`zvm_after_init` 没被调用，或 Atuin 没装。检查：

```zsh
bindkey '^[[A'
```

**`Esc` 没反应**：可能被终端或 tmux 拦截。在 tmux 里检查 `escape-time`。

**键位被别的插件覆盖**：检查 vi-mode 是否在其它插件之前加载。`lucid` 参数是必需的。

**`ciw` 之类文本对象不工作**：这些是 vi-mode 提供的，如果失效说明插件没真正初始化。`zinit list | grep vi-mode` 确认。
