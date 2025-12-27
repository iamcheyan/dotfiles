# NixOS 配置文件
# 参考包搜索：https://search.nixos.org/packages

{ config, pkgs, ... }:

{
  # 导入硬件自动生成的配置（包含分区、驱动等）
  imports = [
    ./hardware-configuration.nix
  ];

  # 启用新版 nix 命令和 flakes 支持
  nix = {
    package = pkgs.nix; # 指定使用的 nix 包
    extraOptions = ''
      experimental-features = nix-command flakes # 启用 nix-command 和 flakes 两个实验特性
    '';
  };

  # 允许安装非自由软件（如 Chrome、某些字体等）
  nixpkgs.config.allowUnfree = true;

  # 启用 systemd-boot 作为启动引导程序，并允许修改 EFI 变量
  boot.loader.systemd-boot.enable = true;           # 启用 systemd-boot
  boot.loader.efi.canTouchEfiVariables = true;      # 允许 NixOS 修改 EFI 变量（如自动引导）

  # 网络配置
  networking = {
    hostName = "nixos";                # 主机名
    networkmanager.enable = true;      # 启用 NetworkManager 管理网络
  };

  # 设置系统时区
  time.timeZone = "Asia/Tokyo";        # 时区设为东京

  # 语言与本地化设置
  i18n = {
    defaultLocale = "zh_CN.UTF-8";     # 默认语言环境为简体中文
    extraLocaleSettings = {            # 细分各类区域设置为日文（可根据需要调整）
      LC_ADDRESS = "ja_JP.UTF-8";
      LC_IDENTIFICATION = "ja_JP.UTF-8";
      LC_MEASUREMENT = "ja_JP.UTF-8";
      LC_MONETARY = "ja_JP.UTF-8";
      LC_NAME = "ja_JP.UTF-8";
      LC_NUMERIC = "ja_JP.UTF-8";
      LC_PAPER = "ja_JP.UTF-8";
      LC_TELEPHONE = "ja_JP.UTF-8";
      LC_TIME = "ja_JP.UTF-8";
    };
  };
  
  # 启用 Flatpak 支持（可用 flatpak 安装沙盒应用）
  services.flatpak.enable = true;

  # 系统级软件包（所有用户可用）
  environment.systemPackages = with pkgs; [
    flatpak         # Flatpak 包管理器
    firefox         # 火狐浏览器
    git             # Git 版本控制
    gedit           # GNOME 文本编辑器
    neofetch        # 系统信息展示
    zsh             # Z shell
    google-chrome   # Google Chrome 浏览器（非自由软件）
    filezilla       # FTP 客户端
    vscode          # Visual Studio Code 编辑器
    code-cursor     # IDE
  ];

  # 输入法相关环境变量（全局设置，适用于 GTK/Qt/X 应用）
  environment.sessionVariables = {
    GTK_IM_MODULE = "fcitx";        # GTK 应用输入法模块
    QT_IM_MODULE = "fcitx";         # Qt 应用输入法模块
    XMODIFIERS = "@im=fcitx";       # X11 输入法环境变量
    INPUT_METHOD = "fcitx";         # 通用输入法变量
  };

  # 图形界面设置（X11 + Cinnamon 桌面 + LightDM 登录管理器）
  services.xserver = {
    enable = true;                  # 启用 X server
    layout = "cn";                  # 键盘布局（中国）
    xkb.variant = "";               # 键盘变体（默认）

    displayManager.lightdm.enable = true;      # 启用 LightDM 登录管理器
    desktopManager.cinnamon.enable = true;     # 启用 Cinnamon 桌面环境
  };

  # 打印服务（CUPS）
  services.printing.enable = true;             # 启用打印服务

  # 音频服务（使用 PipeWire 替代 PulseAudio）
  services.pulseaudio.enable = false;          # 禁用 PulseAudio
  services.pipewire = {
    enable = true;            # 启用 PipeWire
    alsa.enable = true;       # 启用 ALSA 支持
    alsa.support32Bit = true; # 启用 32 位 ALSA 支持（兼容旧应用）
    pulse.enable = true;      # 提供 PulseAudio 兼容层
  };

  # 触控板支持（如需启用，取消注释）
  # services.xserver.libinput.enable = true;

  # 自动登录设置
  services.displayManager.autoLogin.enable = true;      # 启用自动登录
  services.displayManager.autoLogin.user = "tetsuya";   # 自动登录用户

  # 用户账户设置
  users.users.tetsuya = {
    isNormalUser = true;                        # 普通用户
    description = "tetsuya";                    # 用户描述
    extraGroups = [ "networkmanager" "wheel" ]; # 加入网络管理和管理员组
    packages = with pkgs; [ ];                  # 用户专属软件包（此处为空）
  };
  
  # 字体设置与优化
  fonts = {
    enableDefaultPackages = true;  # 启用 NixOS 默认字体包（含常用字体）
    fontconfig = {
      enable = true;               # 启用字体配置
      antialias = true;            # 启用抗锯齿
      hinting = {
        enable = true;             # 启用字体微调
        autohint = false;          # 不使用自动微调
        style = "slight";          # 微调风格（可选：none/slight/medium/full）
      };
      subpixel = {
        rgba = "rgb";              # 子像素顺序（如屏幕为 bgr 可改为 bgr）
        lcdfilter = "default";     # LCD 滤镜
      };
    };

    # 推荐字体包列表（自动 fallback，支持中日英等多语言）
    packages = with pkgs; [
      noto-fonts             # Noto Sans/Serif
      noto-fonts-cjk-sans    # Noto CJK Sans（中日韩）
      noto-fonts-emoji       # Emoji 字体
      liberation_ttf         # Liberation 字体
      dejavu_fonts           # DejaVu 字体
      source-han-sans        # 思源黑体
      source-han-serif       # 思源宋体
      wqy_zenhei             # 文泉驿正黑
      wqy_microhei           # 文泉驿微米黑
      unifont                # Unicode 全覆盖字体
    ];
  };

  # 系统状态版本（升级 NixOS 时需同步修改，勿随意更改）
  system.stateVersion = "25.05";
}
