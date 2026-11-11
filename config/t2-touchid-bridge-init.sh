#!/bin/bash
# /usr/local/sbin/t2-touchid-bridge-init.sh
# Initializes Apple T2 CDC-NCM IPv6 link-local networking and Touch Bar parameters on Ubuntu 24.04 LTS
set -e

if [ -d /sys/class/net/t2_ncm ]; then
    # 1. Disable DAD so the link-local IPv6 address is immediately operational (not stuck in tentative)
    sysctl -w net.ipv6.conf.t2_ncm.accept_dad=0 >/dev/null 2>&1 || true

    # 2. Configure link and EUI-64 mode
    ip link set dev t2_ncm addrgenmode eui64 2>/dev/null || true
    ip link set dev t2_ncm up 2>/dev/null || true

    # 3. Assign link-local IPv6 address with nodad to eliminate "Cannot assign requested address (os error 99)"
    ip -6 addr replace fe80::aede:48ff:fe00:1122/64 dev t2_ncm nodad 2>/dev/null || \
    ip -6 addr add fe80::aede:48ff:fe00:1122/64 dev t2_ncm nodad 2>/dev/null || true

    # 4. Wait up to 3 seconds for non-tentative operational status
    for i in {1..6}; do
        if ip -6 addr show dev t2_ncm 2>/dev/null | grep -q "fe80::" && ! ip -6 addr show dev t2_ncm 2>/dev/null | grep -q "tentative"; then
            break
        fi
        sleep 0.5
    done
fi
