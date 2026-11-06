#!/bin/bash
# /usr/local/sbin/t2-touchid-bridge-init.sh
# Initializes Apple T2 CDC-NCM IPv6 link-local networking and Touch Bar parameters on Ubuntu 24.04 LTS
set -e

if [ -d /sys/class/net/t2_ncm ]; then
    ip link set dev t2_ncm addrgenmode eui64 2>/dev/null || true
    ip link set dev t2_ncm up 2>/dev/null || true
    ip -6 addr add fe80::aede:48ff:fe00:1122/64 dev t2_ncm 2>/dev/null || true
fi

