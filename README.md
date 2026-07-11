# macos-kvm
本项目旨在为使用[`kholia/OSX-KVM`](https://github.com/kholia/OSX-KVM)项目在QEMU/KVM环境下运行macOS虚拟机的需求，提供初始安装环境(**基于apt包管理的Linux发行版**)，并利用[`dockur/macos`](https://github.com/dockur/macos)和[`qemus/qemu`](https://github.com/qemus/qemu)项目提供的脚本安装与配置QEMU/KVM环境和macOS虚拟机。

QEMU/KVM环境和macOS虚拟机的实际安装配置脚本在[`dockur/macos`](https://github.com/dockur/macos)和[`qemus/qemu`](https://github.com/qemus/qemu)Docker镜像项目中。如果你只需要在Linux下的Docker中运行macOS，或在Windows WSL2环境下的Docker中运行macOS，那么建议你直接使用[`dockur/macos`](https://github.com/dockur/macos)，非常便捷。

如果你需要在Windows WSL或Hyper-V环境下安装QEMU/KVM环境并运行macOS，并且想在非Docker环境下控制QEMU/KVM、Nginx等环境的安装与配置细节，那么本项目的脚本非常适合这类需求。

#### 拉取本项目脚本
```shell
git clone --depth 1 --branch main --single-branch https://github.com/longhuan1999/macos-kvm.git
```

#### 设置环境变量
```shell
# 环境变量控制着macOS的安装与配置
# 请仔细阅读`.env.example`文件
cp .env.example .env
vim .env
```

#### 执行脚本
```shell
chmod +x begin.sh && sudo ./begin.sh
```

#### 更新脚本
```shell
git stash && git pull --rebase
```

### WSL2

#### WSL2 配置
```.wslconfig
[wsl2]
# 开启嵌套虚拟化
nestedVirtualization=true
# 关闭WSL2 Linux自带的DNS隧道，由`kholia/OSX-KVM`项目下配置的dnsmasq启用DNS隧道
dnsTunneling=false
```

#### 宿主机配置路由（WSL和QEMU/KVM同为NAT模式等情况下）
```shell
route -p add 172.31.14.0 mask 255.255.255.0 172.30.14.254
```

#### Windows下[USB直通](https://learn.microsoft.com/zh-cn/windows/wsl/connect-usb)到WSL或Hyper-V
```PowerShell
# 服务端
usbipd bind --busid 2-4 --force
# 重启usbipd服务
# WSL2 (https://learn.microsoft.com/zh-cn/windows/wsl/connect-usb)
usbipd attach --wsl --busid 2-4

# Hyper-V等其他
usbip attach --remote=<主机 IP> --busid=2-4

# macOS 客户端[安装和运行usbfluxd](https://github.com/sickcodes/docker-osx#connect-to-a-host-running-usbfluxd)
sudo usbfluxd -f -r <USB主机 IP>:5000
```
