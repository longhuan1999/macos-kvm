# 环境变量

本页面列出了可用于配置容器的所有环境变量。

## 🍎 macOS

| 变量名 | 默认值 | 描述 |
|---|---|---|
| `VERSION` | `14` | 要安装的 macOS 版本，例如 `14` 或 `sonoma`。 |
| `MODEL` | `iMacPro1,1` | OpenCore 使用的 Mac 型号标识符。 |
| `SN` |  | Mac 序列号。未设置时自动生成。 |
| `MLB` |  | Mac 主板序列号。未设置时自动生成。 |
| `UUID` |  | Mac 系统 UUID。未设置时自动生成。 |

## 🧠 CPU 和内存

| 变量名 | 默认值 | 描述 |
|---|---|---|
| `CPU_CORES` | `1` | 分配给虚拟机的 CPU 核心数。也可以设置为 `max` 或 `half`。 |
| `CPU_MODEL` |  | 要使用的 QEMU CPU 模型。未设置时为 Intel/AMD 自动选择。 |
| `CPU_FLAGS` |  | 额外的 QEMU CPU 标志。 |
| `KVM` | `Y` | 启用 KVM 硬件加速。设置为 `N` 以禁用。 |
| `RAM_SIZE` | `4G` | 分配给虚拟机的 RAM 大小，例如 `4G`、`8G`、`max` 或 `half`。 |
| `RAM_CHECK` | `Y` | 在启动虚拟机之前检查主机是否有足够的可用内存。 |

## ⚙️ 系统

| 变量名 | 默认值 | 描述 |
|---|---|---|
| `MACHINE` | `q35` | QEMU 机器类型。 |
| `HPET` | `off` | 启用或禁用 QEMU HPET 定时器。 |
| `VMPORT` | `off` | 启用或禁用 QEMU VMware 端口。 |
| `ARGUMENTS` |  | 附加到生成的命令行的额外原始 QEMU 参数。 |

## 🚀 启动

| 变量名 | 默认值 | 描述 |
|---|---|---|
| `PICKER` | `N` | 显示 OpenCore 启动选择界面。 |
| `SECURE` | `off` | QEMU 安全启动标志。 |
| `LOGO` | `Y` | 启用自定义启动图标。 |
| `BOOT_INDEX` | `9` | OpenCore 启动介质的启动优先级索引。 |
| `USB` | `nec-usb-xhci,id=xhci -device usb-kbd,bus=xhci.0 -global nec-usb-xhci.msi=off` | QEMU USB 控制器设置。设置为 `no*` 值以禁用。 |

## 💾 存储

| 变量名 | 默认值 | 描述 |
|---|---|---|
| `DISK_SIZE` | `64G` | 主数据磁盘的大小。 |
| `DISK_FMT` | `raw` | 磁盘镜像格式，通常为 `raw` 或 `qcow2`。 |
| `DISK_TYPE` | `blk` | 磁盘控制器/设备类型，例如 `sata`、`scsi`、`nvme` 或 `blk`。 |
| `DISK_CACHE` | `none` | QEMU 磁盘缓存模式，例如 `none` 或 `writeback`。 |
| `DISK_IO` | `native` | QEMU 磁盘 I/O 模式，例如 `native`、`threads` 或 `io_uring`。 |
| `DISK_DISCARD` | `unmap` | 为数据磁盘启用 TRIM/unmap 支持。 |
| `DISK_ROTATION` | `1` | 报告给客户机的旋转速率。对于类 SSD 存储请使用 `1`。 |
| `DISK_FLAGS` |  | 创建 qcow2 磁盘时使用的额外选项。 |
| `ALLOCATE` | `N` | 创建数据磁盘时预分配磁盘空间。 |
| `STORAGE` | `/storage` | 用于磁盘、固件变量和生成文件的存储目录。 |

## 🌐 网络

| 变量名 | 默认值 | 描述 |
|---|---|---|
| `NETWORK` | `Y` | 网络模式。常用值为 `Y`（NAT）、`passt`、`slirp` 或 `N`（禁用网络）。 |
| `DHCP` | `N` | 启用 DHCP/macvtap 模式，以便虚拟机从外部 LAN 获取地址。 |
| `IP` |  | 客户机 IP 地址覆盖。 |
| `MAC` |  | 客户机网络适配器 MAC 地址。未设置时自动生成。 |
| `HOST` | `macOS` | 分配给虚拟机的主机名。 |
| `DEV` | `eth0` | 要使用的主机/容器网络接口。 |
| `MTU` |  | 客户机接口使用的网络 MTU。 |
| `MASK` | `255.255.255.0` | IPv4 子网掩码。 |
| `TAP` | `qemu` | TAP/macvtap 接口名称。 |
| `BRIDGE` | `docker` | 用于 NAT 网络的网桥名称。 |
| `ADAPTER` | `virtio-net-pci` | QEMU 网络适配器模型。 |
| `HOST_PORTS` |  | 为主机/容器端运行的服务保留的端口。 |
| `USER_PORTS` |  | 使用用户模式网络时转发到虚拟机的额外端口。 |
| `DNSMASQ_OPTS` |  | 额外的 dnsmasq 选项。 |
| `DNSMASQ_DEBUG` | `N` | 启用 dnsmasq 日志跟踪。 |
| `DNSMASQ_DISABLE` | `N` | 禁用内部 dnsmasq 解析器。 |
| `PASST_OPTS` |  | 额外的 passt 选项。 |
| `PASST_DEBUG` | `N` | 启用 passt 调试输出。 |

## 🖥️ 显示

| 变量名 | 默认值 | 描述 |
|---|---|---|
| `WIDTH` | `1920` | 为 macOS/OpenCore 配置的显示宽度。 |
| `HEIGHT` | `1080` | 为 macOS/OpenCore 配置的显示高度。 |
| `DISPLAY` | `web` | 显示后端。常用值为 `web`、`vnc`、`disabled` 或 `none`。 |
| `VGA` | `vmware` | QEMU 视频适配器模型。 |
| `GPU` | `N` | 启用 Intel iGPU 加速。实验性功能。 |
| `RENDERNODE` | `/dev/dri/renderD128` | 用于 GPU 加速的渲染节点。 |

## 🌍 Web UI

| 变量名 | 默认值 | 描述 |
|---|---|---|
| `WEB` | `Y` | 启用或禁用 Web 界面。 |
| `WEB_PORT` | `8006` | Web 界面端口。 |
| `VNC_PORT` | `5900` | VNC 服务器端口。 |
| `WSS_PORT` | `5700` | QEMU/noVNC 使用的 WebSocket 端口。 |
| `WSD_PORT` | `8004` | 内部 websocketd 端口。 |
| `PROTECT` | `N` | 为 Web 界面启用密码保护。 |

## 🎈 内存气球

另请参阅 [动态内存分配](https://github.com/qemus/qemu/blob/master/docs/ballooning.md) 以获取使用说明和重要注意事项。

| 变量名 | 默认值 | 描述 |
|---|---|---|
| `BALLOONING` | `N` | 启用动态内存气球。 |
| `BALLOONING_DEBUG` | `N` | 启用气球监视器的调试输出。 |
| `BALLOONING_MIN_MEM` | `33%` | 气球设备的最低内存目标。 |
| `BALLOONING_RAM_THRESHOLD` | `80.0` | 目标主机 RAM 使用百分比。 |
| `BALLOONING_RAM_THRESHOLD_HARD` | `90.0` | 主机 RAM 使用百分比阈值，达到此值气球操作将变得更加激进。 |
| `BALLOONING_PSI_PRESSURE` | `10.0` | PSI 内存压力级别，达到此值气球操作开始更激进地响应。 |
| `BALLOONING_PSI_PRESSURE_MAX` | `50.0` | PSI 内存压力级别，达到此值气球操作将达到最强响应。 |
| `BALLOONING_HYSTERESIS` | `128M` | 更新气球目标前的最小内存变化量。 |
| `BALLOONING_KP` | `0.5` | 气球控制器的比例增益。 |
| `BALLOONING_KI` | `0.05` | 气球控制器的积分增益。 |
| `BALLOONING_INTERVAL` | `5` | 轮询间隔（秒）。 |

## 🔌 关机

| 变量名 | 默认值 | 描述 |
|---|---|---|
| `SHUTDOWN` | `Y` | 启用优雅的 ACPI 关机。 |
| `TIMEOUT` | `115` | 等待虚拟机关机时的超时时间。 |

## 🐞 调试

| 变量名 | 默认值 | 描述 |
|---|---|---|
| `DEBUG` | `N` | 启用详细的调试输出。 |
| `TRACE` | `N` | 启用 shell 命令跟踪。 |
| `SERIAL` | `mon:stdio` | QEMU 串行设备设置。 |
| `MONITOR` | `unix:$QEMU_DIR/monitor.sock,server,wait=off,nodelay` | QEMU 监视器设备设置。 |
