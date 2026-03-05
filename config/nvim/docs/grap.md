在 LazyVim 里做 **grep 搜索**（通常是 `Space s g`，基于 Telescope + ripgrep），其实有很多实用技巧，可以像 IDE 一样精确搜索。下面是最常用的一些。

---

# 1️⃣ 大小写控制（非常重要）

ripgrep 默认是 **smart case**：

| 搜索内容   | 行为    |
| ------ | ----- |
| `user` | 忽略大小写 |
| `User` | 区分大小写 |

例子：

```text
user
```

匹配：

```
user
User
USER
```

但：

```text
User
```

只匹配：

```
User
```

---

# 2️⃣ 强制忽略大小写

使用 regex：

```text
(?i)user
```

结果：

```
user
User
USER
```

---

# 3️⃣ 强制区分大小写

```text
(?-i)user
```

---

# 4️⃣ 完整单词匹配（非常常用）

例如只匹配 `user`，不匹配 `username`。

```text
\buser\b
```

匹配：

```
user
```

不匹配：

```
username
superuser
```

---

# 5️⃣ 多关键字 OR 搜索

```text
user|account|profile
```

匹配任意一个。

---

# 6️⃣ AND 搜索（高级技巧）

ripgrep 不直接支持 AND，但可以：

```text
foo.*bar
```

表示：

```
foo ... bar
```

---

# 7️⃣ 排除某些内容

例如：

```text
error(?!_code)
```

匹配：

```
errorMessage
```

不匹配：

```
error_code
```

---

# 8️⃣ 搜索特定文件类型

在 Telescope 里可以写：

```text
TODO --type lua
```

或：

```text
TODO -t lua
```

只搜 `.lua`。

---

# 9️⃣ 排除目录

例如排除 `node_modules`：

```text
foo --glob '!node_modules/*'
```

---

# 🔟 只搜索某个目录

```text
auth/
```

或者：

```text
auth.*login
```

---

# ⚡ LazyVim 最常用 grep 技巧

| 功能    | 输入         |   |    |
| ----- | ---------- | - | -- |
| 忽略大小写 | `(?i)text` |   |    |
| 完整单词  | `\bword\b` |   |    |
| OR 搜索 | `a         | b | c` |
| 前后匹配  | `foo.*bar` |   |    |
| 排除    | `(?!xxx)`  |   |    |

---

# 🚀 LazyVim 隐藏神技

在任何单词上按：

```text
<leader>sw
```

实际：

```
Space s w
```

作用：

```
搜索光标下的单词
```

等同 IDE 的 **Find Usages**。

---

# ⭐ 最推荐记住的 4 个

```text
\bword\b      完整单词
foo|bar       OR 搜索
(?i)text      忽略大小写
foo.*bar      同一行匹配
```

---

如果你愿意，我可以再告诉你 **LazyVim 搜索的 7 个“高手技巧”**（例如：

* 只搜索 git 修改
* 搜索 TODO/FIXME
* 搜索函数名
* 类似 VSCode “symbol search”）

很多人用了之后基本不用 IDE 了。

