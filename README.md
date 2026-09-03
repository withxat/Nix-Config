# nix-config
❄️ A reproducible configuration for my systems / 我的系统配置即基础设施

## Ricardo 安装

使用官方 NixOS 26.05 minimal x86_64 ISO 启动，手动分区后通过 Flake 安装。
先在服务器控制面板切换到 UEFI，并重新从 ISO 启动，使用 systemd-boot 引导。
当前配置未设置 Secure Boot 签名，Secure Boot 保持关闭。
文件系统使用标签定位，不绑定 `/dev/vda`；手动分区前仍需要核对实际盘符。
网络目前使用 NixOS 默认的 DHCP，是否适用于这台服务器也需要核实。

在安装环境运行以下只读命令，确认 UEFI 启动、磁盘、地址、路由和 DHCP 租约：

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

`hosts/ricardo/hardware-configuration.nix` 目前仅描述这个安装约定，并非硬件扫描结果。
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
