#!/usr/bin/env bash
set -Eeuo pipefail

[ "$(id -u)" -ne "0" ] && echo "Script must be executed with root privileges." && exit 12

cd "$(dirname "$0")" || exit 1
echo "Current directory: $(pwd)"

# 加载 .env 文件
set -a
if [ -f .env ]; then
  source .env
else
  if [ -f .env.example ]; then
    cp .env.example .env
    echo "Created .env file from .env.example"
    source .env
  fi
fi
set +a
echo "ENV: $(env)"

# ================= 1. 安装系统依赖 =================
echo "Installing or updating required system packages..."
apt update
apt -y install make unzip wget p7zip-full mtools nginx websocketd \
    python3 python3-websockify curl iproute2 iptables dnsmasq passt \
    netcat-openbsd util-linux git vim net-tools screen novnc \
    ovmf uml-utilities libguestfs-tools dmg2img genisoimage \
    qemu-system-x86 qemu-utils


# ================= 2. 定义变量 =================
VERSION_ARG="0.0"
VERSION_OPENCORE="1.0.7"
REPO_OPENCORE="https://github.com/acidanthera/OpenCorePkg"

VERSION_VM_HIDE="2.0.0"
VERSION_KVM_OPENCORE="0.7"
VERSION_OSX_KVM="326053dd61f49375d5dfb28ee715d38b04b5cd8e"
REPO_VM_HIDE="https://github.com/Carnations-Botanica/VMHide"
REPO_KVM_OPENCORE="https://github.com/LongQT-sea/OpenCore-ISO"
REPO_OSX_KVM="https://raw.githubusercontent.com/kholia/OSX-KVM"

# ================= 3. 创建所需目录和脚本环境 =================
mkdir -p /usr/local/bin /usr/share/OVMF /run /assets /storage
if [ ! -d "quemus-qemu/src" ] || [ ! -d "dockur-macos/src" ]; then
    git submodule update --init
fi
chmod -R 755 quemus-qemu/src && cp -a -f "quemus-qemu/src/." /run/
chmod -R 755 quemus-qemu/web && cp -a -f "quemus-qemu/web/." /var/www/
cp -f quemus-qemu/web/conf/defaults.json /usr/share/novnc/defaults.json && chmod 644 /usr/share/novnc/defaults.json
cp -f quemus-qemu/web/conf/mandatory.json /usr/share/novnc/mandatory.json && chmod 644 /usr/share/novnc/mandatory.json
cp -f quemus-qemu/web/conf/nginx.conf /etc/nginx/default.conf && chmod 644 /etc/nginx/default.conf
cp -f dockur-macos/assets/config.plist /assets/config.plist && chmod 644 /assets/config.plist
cp -f dockur-macos/src/entry.sh /run/entry.sh && chmod 755 /run/entry.sh
cp -f dockur-macos/src/install.sh /run/install.sh && chmod 755 /run/install.sh
cp -f dockur-macos/src/boot.sh /run/boot.sh && chmod 755 /run/boot.sh
cp -f dockur-macos/src/cpu.sh /run/cpu.sh && chmod 755 /run/cpu.sh

# ================= 4. 检测并提取 macserial =================
MACSERIAL_BIN="/usr/local/bin/macserial"
if [ ! -f "$MACSERIAL_BIN" ]; then
    echo "macserial not found. Downloading to /tmp/opencore.zip..."
    wget --no-check-certificate -cO /tmp/opencore.zip $REPO_OPENCORE/releases/download/$VERSION_OPENCORE/OpenCore-$VERSION_OPENCORE-RELEASE.zip
    echo "Extracting OpenCore-$VERSION_OPENCORE-RELEASE.zip to /tmp/oc..."
    unzip -o -q /tmp/opencore.zip -d /tmp/oc
    mv -f /tmp/oc/Utilities/macserial/macserial.linux "$MACSERIAL_BIN"
    chmod 755 "$MACSERIAL_BIN"
    rm -rf /tmp/oc /tmp/opencore.zip
    echo "macserial extraction completed."
else
    chmod 755 "$MACSERIAL_BIN"
    rm -rf /tmp/oc /tmp/opencore.zip
    echo "macserial already exists, skipping..."
fi

# ================= 5. 检测并下载 OVMF 固件 =================
echo "Checking OVMF firmware files..."
# 定义所有需要的 OVMF 文件，及其下载源
declare -A OVMF_MAP=(
    ["/usr/share/OVMF/OVMF_CODE.fd"]="$REPO_OSX_KVM/$VERSION_OSX_KVM/OVMF_CODE.fd"
    ["/usr/share/OVMF/OVMF_VARS.fd"]="$REPO_OSX_KVM/$VERSION_OSX_KVM/OVMF_VARS.fd"
    ["/usr/share/OVMF/OVMF_VARS-1024x768.fd"]="$REPO_OSX_KVM/$VERSION_OSX_KVM/OVMF_VARS-1024x768.fd"
    ["/usr/share/OVMF/OVMF_VARS-1920x1080.fd"]="$REPO_OSX_KVM/$VERSION_OSX_KVM/OVMF_VARS-1920x1080.fd"
)

NEED_DOWNLOAD_OVMF=false
for dest_file in "${!OVMF_MAP[@]}"; do
    if [ ! -f "$dest_file" ]; then
        NEED_DOWNLOAD_OVMF=true
        break
    fi
done

if [ "$NEED_DOWNLOAD_OVMF" = true ]; then
    echo "Downloading missing OVMF firmware files..."
    for dest_file in "${!OVMF_MAP[@]}"; do
        if [ ! -f "$dest_file" ]; then
            src_url="${OVMF_MAP[$dest_file]}"
            echo "Fetching $src_url -> $dest_file"
            wget --no-check-certificate -cO "$dest_file".download "$src_url"
            mv "$dest_file".download "$dest_file"
        fi
    done
    chmod 644 /usr/share/OVMF/*.fd
    chmod 755 /run/*
    echo "OVMF firmware download completed."
else
    chmod 644 /usr/share/OVMF/*.fd
    chmod 755 /run/*
    echo "All OVMF firmware files already exist, skipping..."
fi

# ================= 6. 检测并下载 VMHide =================
VMH_ZIP="/vmh.zip"
if [ ! -f "$VMH_ZIP" ]; then
    echo "VMHide zip not found. Downloading to $VMH_ZIP..."
    wget --no-check-certificate -cO "$VMH_ZIP".download $REPO_VM_HIDE/releases/download/$VERSION_VM_HIDE/VMHide-$VERSION_VM_HIDE-RELEASE.zip
    mv "$VMH_ZIP".download "$VMH_ZIP"
    echo "VMHide download completed."
else
    echo "VMHide zip already exists, skipping..."
fi

# ================= 7. 检测并下载 OpenCore ISO =================
OPENCORE_ISO="/opencore.iso"
if [ ! -f "$OPENCORE_ISO" ]; then
    echo "OpenCore ISO not found. Downloading to $OPENCORE_ISO..."
    wget --no-check-certificate -cO "$OPENCORE_ISO".download $REPO_KVM_OPENCORE/releases/download/v$VERSION_KVM_OPENCORE/LongQT-OpenCore-v$VERSION_KVM_OPENCORE.iso
    mv "$OPENCORE_ISO".download "$OPENCORE_ISO"
    echo "OpenCore ISO download completed."
else
    echo "OpenCore ISO already exists, skipping..."
fi

# ================= 8. 写入版本信息 =================
echo "$VERSION_ARG" > /etc/version

# 从apple下载文件不再需要代理，开启代理反而可能会导致下载失败
export -n HTTP_PROXY HTTPS_PROXY ALL_PROXY http_proxy https_proxy all_proxy GATEWAY_PROXY

. /run/entry.sh
