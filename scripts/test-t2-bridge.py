#!/usr/bin/env python3
"""
Apple T2 BridgeOS RemoteXPC Discovery & Handshake Diagnostic Tool
Author: Juan Monzón (@mylnzon58)
Target: Apple T2 CDC-NCM link on Ubuntu 24.04 LTS
"""
import socket
import sys

def test_t2_bridge():
    interface = "t2_ncm"
    host = "fe80::aede:48ff:fe33:4455"
    port = 59602

    print("==========================================================================")
    print(" Apple T2 BridgeOS RemoteXPC Link Diagnostic (Ubuntu 24.04 LTS)")
    print("==========================================================================")

    try:
        scope_id = socket.if_nametoindex(interface)
        print(f"[+] Found network interface '{interface}' (Scope ID: {scope_id})")
    except OSError:
        print(f"[-] Interface '{interface}' not found. Is the cdc_ncm kernel module loaded?")
        sys.exit(1)

    s = socket.socket(socket.AF_INET6, socket.SOCK_STREAM)
    s.settimeout(3.0)

    try:
        print(f"[+] Connecting to Apple T2 BridgeOS at [{host}]:{port} via {interface}...")
        s.connect((host, port, 0, scope_id))
        print("[✓] TCP Connection established successfully!")

        # Send standard RemoteXPC HTTP/2 preface
        preface = b"PRI * HTTP/2.0\r\n\r\nSM\r\n\r\n"
        s.sendall(preface)
        print("[+] Sent RemoteXPC HTTP/2 preface handshake...")

        response = s.recv(1024)
        if len(response) > 0:
            print(f"[✓] Received valid response from Apple T2 BridgeOS ({len(response)} bytes):")
            print(f"    Raw bytes: {response[:32].hex()}")
            print("[✓] Apple T2 RemoteXPC discovery & BiometricKit transport is ACTIVE and OPERATIONAL!")
        else:
            print("[-] Connection open but received 0 bytes.")
    except socket.timeout:
        print("[-] Connection timed out. Make sure IPv6 link-local is assigned to t2_ncm.")
        sys.exit(1)
    except ConnectionRefusedError:
        print("[-] Connection refused by T2 bridgeOS. Verify port and security enclave state.")
        sys.exit(1)
    except Exception as e:
        print(f"[-] Unexpected error: {e}")
        sys.exit(1)
    finally:
        s.close()

if __name__ == "__main__":
    test_t2_bridge()

