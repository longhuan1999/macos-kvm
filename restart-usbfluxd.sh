#!/usr/bin/env bash
set -Eeuo pipefail

[ "$(id -u)" -ne "0" ] && echo "Script must be executed with root privileges." && exit 12

cd "$(dirname "$0")" || exit 1
echo "Current directory: $(pwd)"

{ killall usbfluxd; }  || :
{ killall socat; }  || :
systemctl restart usbmuxd
{ avahi-daemon; }  || :
usbfluxd -f -n &> /var/log/usbfluxd.log &
socat tcp-listen:5000,fork unix-connect:/var/run/usbmuxd &> /var/log/socat.log &
