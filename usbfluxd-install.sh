#!/usr/bin/env bash
set -Eeuo pipefail

[ "$(id -u)" -eq "0" ] && echo "Script must be executed without root privileges." && exit 12

CUR_DIR="$(dirname "$0")"
cd $CUR_DIR || exit 1
CUR_DIR="$(pwd)"
echo "Script directory: $CUR_DIR"
echo "Current directory: $(pwd)"

echo "ENV: $(env)"

{ eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"; brew --version; rc=$?; } || :
if (( rc != 0 )); then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if grep -q "/home/linuxbrew/.linuxbrew/bin/brew shellenv bash" ~/.bashrc; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"
    else
        echo >> ~/.bashrc
        echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"' >> ~/.bashrc
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"
    fi
fi

if [ ! -f "/usr/local/sbin/usbfluxd" ]; then
    # 安装build-essential、usbmuxd和bubblewrap
    # 如果缺失build-essential，brew 安装 gcc会失败
    # 如果缺失bubblewrap， blew install/upgrade等命令处理依赖会异常缓慢
    sudo apt update && sudo apt install -y build-essential g++ make usbmuxd bubblewrap avahi-daemon
    echo "请不要跳过安装brew和brew安装编译环境，直接编译usbfluxd"
    echo "会报错：configure: error: The file /libplist-2.0.a passed to --with-static-libplist does not exist"
    brew install make automake autoconf libtool pkg-config gcc libimobiledevice --verbose --debug
    git clone https://github.com/corellium/usbfluxd.git /tmp/usbfluxd
    cd /tmp/usbfluxd
    ./autogen.sh
    make
    sudo make install
    cd $CUR_DIR || exit 1
    rm -rf /tmp/usbfluxd
    echo "Current directory: $(pwd)"
fi

chmod +x restart-usbfluxd.sh && sudo ./restart-usbfluxd.sh
