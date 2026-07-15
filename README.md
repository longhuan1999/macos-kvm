# macos-kvm
本项目旨在为使用[`kholia/OSX-KVM`](https://github.com/kholia/OSX-KVM)项目在`QEMU/KVM`环境下运行`macOS`虚拟机的需求，提供初始安装环境(**基于apt包管理的Linux发行版**)，并利用[`dockur/macos`](https://github.com/dockur/macos)和[`qemus/qemu`](https://github.com/qemus/qemu)项目提供的脚本安装与配置`QEMU/KVM`环境和`macOS`虚拟机。

`QEMU/KVM`环境和`macOS`虚拟机的实际安装配置脚本在[`dockur/macos`](https://github.com/dockur/macos)和[`qemus/qemu`](https://github.com/qemus/qemu)`Docker`镜像项目中。如果你只需要在`Linux`下的`Docker`中运行`macOS`，或在`Windows WSL2`环境下的`Docker`中运行`macOS`，那么建议你直接使用[`dockur/macos`](https://github.com/dockur/macos)，非常便捷。

如果你需要在`Windows WSL`或`Hyper-V`环境下安装`QEMU/KVM`环境并运行`macOS`，并且想在非`Docker`环境下控制`QEMU/KVM`、`Nginx`等环境的安装与配置细节，那么本项目的脚本非常适合这类需求。

#### 拉取本项目脚本
```shell
git clone --depth 1 --branch main --single-branch https://github.com/longhuan1999/macos-kvm.git && cd macos-kvm
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

Windows：在`Windows`命令行中执行以下命令
```PowerShell
# 服务端
usbipd bind --busid 2-4 --force
# 重启usbipd服务
```

WSL2：[参考此处](https://learn.microsoft.com/zh-cn/windows/wsl/connect-usb)，在`Windows`命令行中执行以下命令
```PowerShell
usbipd attach --wsl --busid 2-4
```

Hyper-V：在`Hyper-V`虚拟机命令行中执行以下命令
```shell
usbip attach --remote=<主机 IP> --busid=2-4
```

### 转接iPhone到macOS虚拟机中

#### 方法一：使用[usbfluxd](https://github.com/sickcodes/docker-osx#usbfluxd-iphone-usb---network-style-passthrough-osx-kvm-docker-osx)

在`WSL2`和`Hyper-V`等虚拟机中执行以下命令
```shell
# WSL2和Hyper-V等其他[安装和运行usbfluxd](https://github.com/corellium/usbfluxd)
# 请不要跳过安装brew和brew安装编译环境，直接编译usbfluxd
# 会报错：configure: error: The file /libplist-2.0.a passed to --with-static-libplist does not exist
chmod +x usbfluxd-install.sh && env ./usbfluxd-install.sh
```

在`macOS`虚拟机中执行以下命令
```shell
# macOS 客户端[安装和运行usbfluxd](https://github.com/sickcodes/docker-osx#connect-to-a-host-running-usbfluxd)
sudo usbfluxd -f -r <USB主机 IP>:5000
```

#### 方法二：使用[usb-over-ethernet](https://www.eltima.com/products/usb-over-ethernet/)

详情请参考[usb-over-ethernet](https://www.eltima.com/products/usb-over-ethernet/)网站的说明
