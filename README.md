# nix-config
❄️ A reproducible configuration for my systems / 我的系统配置即基础设施

## Ricardo 安装

使用官方 NixOS minimal x86_64 ISO 或 netboot.xyz 中的 NixOS 安装环境启动，手动分区后通过 Flake 安装。
安装环境版本可以与目标系统不同；本机使用 netboot.xyz 的 25.05 环境，目标版本由 `flake.lock` 锁定为 26.05。
先在服务器控制面板切换到 UEFI，并重新从 ISO 启动，使用 systemd-boot 引导。
当前配置未设置 Secure Boot 签名，Secure Boot 保持关闭。
已确认本机系统盘为 `/dev/vda`（100 GiB），文件系统使用硬件扫描生成的 UUID 定位。
重装时仍需重新核对盘符，并在格式化后重新生成硬件配置。
网络使用 Layer 面板提供的静态 IPv4，由 systemd-networkd 按 MAC 地址匹配网卡，
不依赖面板中的 `eth0` 名称或 DHCP。IPv6 子网尚未分配。

| 网络项目 | 值 |
| --- | --- |
| MAC | `00:0d:a3:34:3c:eb` |
| IPv4 | `207.2.122.137/24` |
| 子网掩码 | `255.255.255.0` |
| 网关 | `207.2.122.1` |
| DNS | `8.8.8.8`、`8.8.4.4` |

netboot.xyz 自动联网失败时，手动选择网卡 `0`，按上表填写网络信息。
这些设置用于当前启动环境；进入 Linux 安装环境后仍需确认联网，安装后的系统则使用仓库配置。

在 Linux 安装环境运行以下只读命令，确认 UEFI 启动、磁盘、地址和路由：

```sh
if [ -d /sys/firmware/efi ]; then echo UEFI; else echo BIOS; fi
lsblk -o NAME,PATH,SIZE,TYPE,FSTYPE,MOUNTPOINTS
ip -br address
ip -4 route
ip -6 route
sudo journalctl -b --no-pager -u dhcpcd -u NetworkManager -u systemd-networkd -n 60
```

第一条必须输出 `UEFI` 后再继续安装。

分区表使用 GPT，分区约定如下：

| 分区 | 大小 | 格式 / 标签 | 挂载点 |
| --- | --- | --- | --- |
| EFI System Partition（EF00） | 1 GiB | FAT32 / `BOOT` | `/boot` |
| 根分区 | 剩余空间 | ext4 / `nixos` | `/` |

4 GiB swap 文件由 NixOS 创建，无需单独的 swap 分区。

`hosts/ricardo/hardware-configuration.nix` 已包含本机实际硬件扫描结果及文件系统 UUID。
确认盘符并完成分区、格式化后，先将根分区挂载到 `/mnt`，再将 EFI 分区挂载到
`/mnt/boot`。两个分区都挂载好后，在仓库根目录运行：

```sh
sudo nixos-generate-config --root /mnt --show-hardware-config > hosts/ricardo/hardware-configuration.nix
```

核对生成的硬件配置中包含 `/` 和 `/boot`，并确认网络配置后，将硬件配置纳入 Git，安装：

```sh
git add hosts/ricardo/hardware-configuration.nix
sudo nixos-install --flake .#ricardo
```

## Docker 与维护

Ricardo 通过本仓库的 flake 运行 sing-box Shadowsocks 2022 落地，使用
`2022-blake3-aes-128-gcm`，监听 TCP/UDP 443，流量从本机直接出口。
Louise 保留原有 VLESS Reality 入口及客户端凭据；`xat` 的全部流量转到 Ricardo，
包括 SSH、邮件和 `ts.net`。`royal` 用户仍直接从 Louise 出口。

sing-box 凭据由 NixOS 服务启动时从以下 root 专用文件读取，不进入 Git 或 Nix store：

- `/etc/sing-box/secrets/shadowsocks-password`

密码为 Base64 编码的 16 字节随机密钥，与 Louise 的对应出站一致。
重装前需单独备份该文件；目录权限为 `0700`，文件权限为 `0600`，所有者为 root。
部署使用 `sudo nixos-rebuild switch --flake /etc/nixos#ricardo`。
部署后运行 `sudo sing-box check -c /run/sing-box/config.json` 检查运行配置，
并分别验证 `xat` 经 Louise 后的出口为 Ricardo、`royal` 的出口仍为 Louise。

- Docker 随系统启动，使用 `sudo docker` 和 `sudo docker compose` 管理。
- 日志使用 `local` 驱动，按 Docker 默认规则轮转和压缩。
- 默认桥接网络及新建的自定义桥接网络，将未指定地址的发布端口绑定到 `127.0.0.1`。
  需要公网访问时显式指定地址；数据库优先只接入容器内部网络。
- 每个服务的内存限额在 Compose 文件中按实际负载设置，先给系统和更新过程留约 1 GiB 内存。
- 重要数据使用持久卷或宿主机目录，具体备份目标和周期在服务确定后配置。
- Nix 每周清理超过 30 天的旧版本及不再被引用的存储路径，并定期执行存储去重。

依赖不会自动升级。需要更新时运行 `nix flake update nixpkgs`，检查并提交锁文件，
再在服务器执行 `sudo nixos-rebuild switch --flake .#ricardo`。

本地检查：

```sh
nix flake check --all-systems --no-build
```

该检查验证配置求值，不代表已经在服务器启动或运行过容器。
