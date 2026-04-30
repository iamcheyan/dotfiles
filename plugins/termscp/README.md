# termscp

这个目录负责把 `termscp` 接入当前 dotfiles，并提供一个专门给你练 SSH 用的本地容器入口。

## 文件

- `install_termscp.sh`: 跨平台安装脚本
- `termscp.zsh`: shell 集成、安装入口、练习用函数

## 安装

直接装：

```bash
install:termscp
```

可选方法：

```bash
install:termscp --method auto
install:termscp --method release
install:termscp --method package
install:termscp --method cargo
install:termscp --force
```

安装逻辑：

- `auto`:
  - macOS: 先走 GitHub Releases 预编译包
  - Linux: 先走 `cargo install`，再回退到 release 包
- `release`: 根据当前平台下载最新 release 资产
- macOS:
  - `aarch64-apple-darwin.tar.gz`
  - `x86_64-apple-darwin.tar.gz`
- Debian / Ubuntu:
  - `aarch64-unknown-linux-gnu.tar.gz`
  - `x86_64-unknown-linux-gnu.tar.gz`
- 其他 Linux:
  - `aarch64-unknown-linux-gnu.tar.gz`
  - `x86_64-unknown-linux-gnu.tar.gz`
- `package`: 只在少数平台尝试原生包管理器
- `cargo`: 作为最终兜底

说明：

- Debian / Ubuntu 虽然 release 里有 `.deb`，但它依赖宿主系统库版本
- 对 Ubuntu 22.04 这类较老系统，直接安装 `.deb` 很容易失败
- `x86_64-unknown-linux-gnu.tar.gz` 这类包也不是静态链接，仍然可能依赖较新的 `glibc` / `icu`
- 所以 Linux 上默认更稳的是 `cargo install`

## Shell 集成

`termscp.zsh` 会提供这些入口：

- `install:termscp`: 安装 termscp
- `tscp`: `termscp` 的短别名
- `termscp-lab`: 用 `sftp://student@localhost:2222` 直接连你的 SSH 练习容器
- `termscp-lab-scp`: 用 `scp://student@localhost:2222` 直接连你的 SSH 练习容器

默认练习环境变量：

```bash
TERMSCP_LAB_HOST=localhost
TERMSCP_LAB_PORT=2222
TERMSCP_LAB_USER=student
TERMSCP_LAB_REMOTE_DIR=/home/student
TERMSCP_LAB_PROTOCOL=sftp
```

如果你改了容器账号或端口，可以覆盖：

```bash
export TERMSCP_LAB_USER=alice
export TERMSCP_LAB_PORT=2200
```

## 配合 alpine-sshd 练习

先启动你刚建的 SSH 练习容器：

```bash
cd ~/dotfiles/chezmoi/dot_config/dotfiles/alpine-sshd
docker build -t alpine-sshd-practice .
docker run -d --name alpine-sshd-practice -p 2222:22 alpine-sshd-practice
```

先确认 SSH 正常：

```bash
ssh student@localhost -p 2222
```

然后打开 termscp：

```bash
termscp-lab
```

首次连接时你需要：

- 输入密码：`student`
- 接受主机指纹

## 直接命令行连接

不用函数也可以：

```bash
termscp "sftp://student@localhost:2222:/home/student"
termscp "scp://student@localhost:2222:/home/student"
```

我建议练习时优先用 `sftp`，通常兼容性更好。

## 推荐练习

1. 在本地建一个测试文件，再上传到容器

```bash
echo hello > /tmp/ssh-lab.txt
termscp-lab
```

2. 在容器里建目录，再把文件下载回来
3. 试试重命名、删除、移动
4. 把容器改成密钥登录，再用 termscp 重新连
5. 对比 `sftp://` 和 `scp://` 两种模式

## 备注

- 如果 `termscp` 已安装但新 shell 里命令不存在，重开一个 shell
- 如果你是在 WSL 里练习，`localhost:2222` 这套通常可以直接用
