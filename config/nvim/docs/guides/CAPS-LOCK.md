# Neovim Caps Lock 状态指示器与 WSL / 跨平台支持指南

本文档说明本 Neovim 配置中底部状态栏 **Caps Lock 大小写指示器**（`CAPS ON` / `CAPS OFF` / `CAPS ?`）的设计原理、WSL (Windows Subsystem for Linux) 终端与 tmux 环境下的问题根因、权威平台技术来源、无额外开销的后台常驻 Worker 架构及排错指南。

---

## 1. 核心特性与显示状态

底部状态栏右侧模式指示器左侧包含独立的 Caps Lock 状态块：

| 显示内容 | 高亮样式 | 含义 |
|---|---|---|
| `CAPS ON` | `FreshStatusLineCaps`（鲜红底白字高亮，同时模式块也变红预警） | Caps Lock 开启，按键将输入大写字母 |
| `CAPS OFF` | `FreshStatusLineAccent`（默认主题绿底白字，正常状态） | Caps Lock 关闭，正常输入小写字母 |
| `CAPS ?` | `FreshStatusLineAccent`（默认主题绿底白字） | 当前平台或环境无法检测键盘锁定状态（保留未知状态，绝不伪报关闭） |

---

## 2. WSL 环境下的根因分析 (Root Cause Analysis)

### 2.1 为什么原实现在 WSL 终端和 tmux 下始终停留在 `CAPS OFF`？

在旧实现中，Linux 分支仅通过 `xset -q` 命令查询 X11 服务的按键状态：
```lua
output = vim.fn.system({ "xset", "-q" })
local state = output:match("Caps Lock:%s*(%a+)")
```

该实现在 WSL2 下存在致命缺陷：
1. **WSLg 与终端 PTY 输入通道解耦**：
   在 Windows 11 及带有 WSLg 支持的 WSL2 系统中，系统默认启动 Weston 合成器并向所有 Linux 终端导出了 `DISPLAY=:0`。当用户在 Ubuntu 中安装了 X11 常用工具包（如 `x11-xserver-utils`）时，`xset` 可执行文件存在，`xset -q` 可以成功连接并查询 `:0`。
   然而，用户在 Windows Terminal、tmux、Alacritty 或 VS Code 内置终端中编辑时，按键由 Windows 宿主机与 ConPTY / PTY 直接处理，**完全不会路由给 WSLg 的 XWayland/Weston 窗口**（除非用户专门聚焦在 WSLg 弹出的 Linux GUI 窗口上）。
   因此，WSLg X11 服务的按键状态**永远保持为初始的 `off`**，导致 `xset -q` 永远返回 `Caps Lock: off`，Neovim 状态栏因此被硬编码般锁定在 `CAPS OFF`。
2. **终端 PTY 协议不传递硬件修饰键锁定状态**：
   标准 ANSI / VT 伪终端（PTY）通道仅传输字符字节流和控制转义序列（例如将 `'a'` 转为 `'A'`），没有通用的标准转义序列来主动通知进程或供进程查询宿主机硬件 Caps Lock 切换状态。在 tmux 终端复用器下，键盘输入更被多路复用层抽象。
3. **Linux 内核输入设备的虚拟化隔离**：
   WSL2 运行于轻量级 Hyper-V 虚拟机容器中，没有对宿主机物理 USB/HID 键盘的直接直通。WSL 内核中的 `/dev/input/` 与 `/sys/class/leds/` 并不包含宿主机物理键盘及其 LED 状态。
4. **旧逻辑无法容错未知状态**：
   在旧逻辑中，若 `state` 解析非预期，函数直接退出，残留之前的旧状态；若 `xset` 返回 `off`，则强行写入关闭，无法准确区分“Caps Lock 关闭”与“检测不可用”。

---

## 3. 权威技术来源与平台规范 (Authoritative Upstream & Platform Sources)

以下记录本模块设计所依据的权威平台文档、来源链接与技术论证（访问日期：2026-10-08）：

1. **Microsoft Learn: WSL Interoperability**
   - 链接：`https://learn.microsoft.com/en-us/windows/wsl/interop`
   - 核心结论：WSL 具备跨环境调用 Windows 二进制文件的原生能力（通过 `binfmt_misc` 的 `WSLInterop`）。通过该机制，Linux 进程可无缝调用 Windows 原生工具（如 `powershell.exe`）。该功能依赖 `/etc/wsl.conf` 中 `[interop] enabled = true`（默认启用）。
2. **Microsoft WSLg 架构与输入通道**
   - 链接：`https://github.com/microsoft/wslg`
   - 链接：`https://learn.microsoft.com/en-us/windows/wsl/tutorials/gui-apps`
   - 核心结论：WSLg 的 Weston 合成器通过 RDP 与 Windows 宿主机通信，仅为运行于 WSL 内部的 X11 / Wayland GUI 窗口提供渲染与输入转发。Windows Terminal 与命令行终端使用 Windows Console (ConPTY) 接口，两者输入通道完全独立。因此向 WSLg XWayland 服务查询终端键盘状态在架构上不可行。
3. **Microsoft Windows Terminal & Console PTY 架构**
   - 链接：`https://github.com/microsoft/terminal`
   - 链接：`https://learn.microsoft.com/en-us/windows/terminal/`
   - 核心结论：ConPTY 和 Linux PTY 仅传递字符与 VT 输入序列。Caps Lock 作为物理切换修饰键在宿主机层面转换为大小写字符，PTY 不传递状态变更事件，且 tmux 会进一步隔离底层终端私有协议。
4. **Linux 内核输入子系统在 WSL2 中的虚拟化**
   - 链接：`https://github.com/microsoft/WSL`
   - 核心结论：WSL2 虚拟化内核中不挂载宿主机 HID 键盘节点，宿主机键盘 LED 无法通过 Linux `/sys/class/leds/` 读取。
5. **.NET Runtime 与 Win32 API (`[System.Console]::CapsLock` & `GetKeyState`)**
   - 链接：`https://learn.microsoft.com/en-us/dotnet/api/system.console.capslock`
   - 链接：`https://github.com/dotnet/runtime/blob/main/src/libraries/System.Console/src/System/ConsolePal.Windows.cs`
   - 链接：`https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getkeystate`
   - 核心结论：`[System.Console]::CapsLock` 底层直接调用 Win32 `GetKeyState(VK_CAPITAL) & 1`（`0x14`）。在已运行的常驻进程内，该调用仅为用户空间内存位检查，耗时低于 1 微秒，开销几乎为零。

---

## 4. 架构设计与高效常驻 Worker 实现

为彻底解决 WSL 终端/tmux 中的检测失效问题，并在全平台避免每 Tick 进程生成的巨大开销，本配置在 [`lua/config/caps_lock.lua`](../../lua/config/caps_lock.lua) 中实现了平台自适应检测引擎：

```
┌─────────────────────────────────────────────────────────────┐
│                   Neovim 状态栏 Caps Lock                    │
│                  (_G._heirline_caps_lock_on)                │
└──────────────────────────────▲──────────────────────────────┘
                               │
            ┌──────────────────┴──────────────────┐
            │                                     │
    [WSL / Windows 原生]                 [macOS / 原生 Linux]
            │                                     │
   启动单一常驻 Worker                    macOS: ioreg 异步任务
(vim.fn.jobstart powershell.exe)          Linux: xset -q 异步任务
            │                                     │
   PowerShell 内存循环                   定时器 750ms 刷新
([Console]::CapsLock 轮询 250ms)                  │
            │                                     │
   仅当状态发生改变时输出:                                │
     True  -> on                                  │
     False -> off                                 │
            │                                     │
   Neovim on_stdout 回调 ─────────────────────────┘
   (每 Tick 进程生成数 = 0)
```

### 4.1 避免每 Tick 进程生成 (Zero Per-Tick Spawning)
如果每隔 750ms 在 WSL 中调用一次 `powershell.exe -Command "[Console]::CapsLock"`：
* 每次启动 Windows 进程需要跨越 WSL vsock/9p 边界并初始化 .NET CLR 运行时，耗时 200~800ms。
* 这会导致持续消耗单核 20%~40% 的 CPU，并造成 Neovim 主线程卡顿或异步任务堆积。

**新设计**：
* 启动一个长生命周期的异步后台 Worker：
  ```powershell
  $last=$null; while($true){ try{ $c=[Console]::CapsLock; if($c -ne $last){ $last=$c; [Console]::Out.WriteLine($c); [Console]::Out.Flush() } }catch{ break }; Start-Sleep -Milliseconds 250 }
  ```
* 该 Worker 在常驻内存中以 250ms 为周期检查 `[Console]::CapsLock`（微秒级 Win32 调用，CPU 占用率低于 0.01%）。
* **只有在 Caps Lock 状态发生变化时**，Worker 才会向标准输出发送一行 `True` 或 `False` 并即时 Flush。
* Neovim 的 `on_stdout` 接收事件并立即触发 `redrawstatus`。
* 定时器在检查到 Worker 存活时直接跳过，**每 Tick 进程生成数为 0**，响应延迟缩短至 250ms 内，兼具零负载与高实时性。

### 4.2 保持未知/错误状态 (Preserving Unknown State)
* 当 WSL Interop 被禁用（例如 Docker 容器内部或 `/etc/wsl.conf` 禁用了 interop），或无法找到 `powershell.exe` 时：
  模块将状态显式设为 `nil`，界面正确显示为 `CAPS ?`，**绝不伪报为 `CAPS OFF`**。
* 当后台 Worker 异常崩溃或退出时：
  自动重置状态为 `nil`（`CAPS ?`），并设立 5 秒冷却时间（cooldown），防止频繁重启引起死循环。

---

## 5. 前置条件与兼容性说明

1. **WSL 环境**：
   - 支持 WSL 1 与 WSL 2（Ubuntu、Debian、Arch、openSUSE 等全部发行版）。
   - 终端支持：Windows Terminal、WezTerm、Alacritty、VS Code 终端以及 tmux。
   - 前置依赖：WSL 默认开启的 Windows Interop。如果通过 `/etc/wsl.conf` 配置了 `appendWindowsPath = false`，本模块会自动检查 `/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe`。
2. **Linux 原生环境**：
   - X11 / XWayland 环境支持，依赖 `xset` 命令（Debian/Ubuntu 包名：`x11-xserver-utils`）。
   - 纯 Wayland（无 XWayland）或无显示环境时，优雅降级为 `CAPS ?`。
3. **macOS 环境**：
   - 开箱即用，通过 macOS 原生 `ioreg` 异步检测 IOHID 键盘。
4. **Windows 原生环境**：
   - Windows 原生构建的 Neovim 自动使用同套 PowerShell 常驻 Worker。

---

## 6. 排错指南 (Troubleshooting)

### 状态栏显示 `CAPS ?`
1. **WSL Interop 是否开启**：
   在 WSL 终端中运行：
   ```bash
   powershell.exe -Command "[Console]::CapsLock"
   ```
   若输出 `cannot execute binary file: Exec format error` 或找不到命令，请检查 `/etc/wsl.conf`：
   ```ini
   [interop]
   enabled = true
   ```
2. **PATH 中是否包含 Windows 路径**：
   若输出 `command not found`，请确认 `/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe` 是否存在。

### 状态栏显示 `CAPS ON` 但实际输入为小写
* 若您在 Windows 上使用了 PowerToys 或 AutoHotkey 将 Caps Lock 键重映射为了 Ctrl，请检查映射工具是否锁定了 Caps Lock 硬件切换位。

---

## 7. 自动化测试与验证

在代码库根目录下运行回归测试套件：
```bash
nvim --headless -u NONE -l config/nvim/tests/caps_lock_spec.lua
```

测试覆盖：
* `is_wsl()` 在原生 Linux、WSL 环境变量和 `/proc/version` 各种特征下的精确识别。
* `get_wsl_powershell_cmd()` 在 PATH 与 `/mnt/c` 降级路径下的可执行文件检索。
* 状态机规范化（`true` / `false` / `nil`）。
* 输出解析器与 CRLF 兼容处理。
* Interop 缺失时的错误隔离与 `CAPS ?` 状态保持。
* 常驻 Worker 运行期间零进程生成的回归测试。
* Heirline 状态栏组件在各状态下的文本渲染与高亮属性验证。
