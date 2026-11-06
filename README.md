# Apple T2 Touch Bar & Touch ID CDC-NCM Bridge for Ubuntu 24.04 LTS

[![Ubuntu 24.04 LTS](https://img.shields.io/badge/Ubuntu-24.04_LTS_(Noble)-E95420?logo=ubuntu&logoColor=white)](#)
[![Linux Kernel T2](https://img.shields.io/badge/Kernel-linux--t2_(v7.x)-00B4D8?logo=linux&logoColor=white)](#)
[![Hardware](https://img.shields.io/badge/Apple_T2-BridgeOS_RemoteXPC-111827?logo=apple&logoColor=white)](#)
[![Touch Bar & Touch ID](https://img.shields.io/badge/Biometrics-Touch_ID_%2B_Touch_Bar-10B981?logo=apple&logoColor=white)](#)
[![Author](https://img.shields.io/badge/Author-Juan_Monz%C3%B3n_(@mylnzon58)-10B981?logo=github&logoColor=white)](https://github.com/mylnzon58)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Juan_Monz%C3%B3n-0A66C2?logo=linkedin&logoColor=white)](https://www.linkedin.com/in/juan-m-97b85681/)
[![Instagram](https://img.shields.io/badge/Instagram-%40juanjoclassic-E4405F?logo=instagram&logoColor=white)](https://www.instagram.com/juanjoclassic/)
[![Invitame un Tecito](https://img.shields.io/badge/%E2%98%95_Donar_un_Tecito-tecito.app%2Fjuanjoclassic-FF813F?style=flat&logo=buy-me-a-coffee&logoColor=white)](https://tecito.app/juanjoclassic)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

> **Author & Maintainer:** **[Juan Monzón (@mylnzon58)](https://www.linkedin.com/in/juan-m-97b85681/)** — *AI Product | Full Stack Developer | Digital Products & Growth* (Argentina)  
> ☕ **¿Te sirvió esta solución?** Si esta implementación te permitió activar la comunicación con el coprocesador Apple T2, optimizar la Touch Bar y preparar Touch ID en Ubuntu 24.04 LTS, puedes apoyar este desarrollo invitándome un Tecito en **[tecito.app/juanjoclassic](https://tecito.app/juanjoclassic)**, dejando una **Star ⭐** en el repo y conectando en **[LinkedIn](https://www.linkedin.com/in/juan-m-97b85681/)**.  
> ☕ **Did this save your day?** If this bridge helped you unlock communication with the Apple T2 coprocessor and stabilize your Touch Bar on Ubuntu 24.04 LTS, feel free to support my work by buying me a Tecito at **[tecito.app/juanjoclassic](https://tecito.app/juanjoclassic)**, **Starring ⭐** this repository, and connecting on **[LinkedIn](https://www.linkedin.com/in/juan-m-97b85681/)**.

<p align="left">
  <a href="https://tecito.app/juanjoclassic" target="_blank">
    <img src="https://img.shields.io/badge/%E2%98%95_Invitame_un_Tecito_/_Donate-tecito.app%2Fjuanjoclassic-FF813F?style=for-the-badge&logoColor=white" alt="Donar un Tecito - tecito.app/juanjoclassic" />
  </a>
  <a href="https://www.linkedin.com/in/juan-m-97b85681/" target="_blank">
    <img src="https://img.shields.io/badge/LinkedIn-Juan_Monz%C3%B3n-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white" alt="LinkedIn - Juan Monzón" />
  </a>
  <a href="https://www.instagram.com/juanjoclassic/" target="_blank">
    <img src="https://img.shields.io/badge/Instagram-%40juanjoclassic-E4405F?style=for-the-badge&logo=instagram&logoColor=white" alt="Instagram - @juanjoclassic" />
  </a>
</p>

**[Español](#-español--arquitectura-del-puente-apple-t2-touch-bar-y-touch-id-para-ubuntu-2404-lts)** | **[English](#-english--apple-t2-touch-bar--touch-id-bridge-for-ubuntu-2404-lts)**

---

## 🇪🇸 Español — Arquitectura del Puente Apple T2, Touch Bar y Touch ID para Ubuntu 24.04 LTS

### Origen y Propósito
El proyecto **KAIT2EN** demostró en Fedora que es posible comunicarse con el chip de seguridad Apple T2 a través del enlace interno USB CDC-NCM (`05ac:8233`), habilitando funciones avanzadas como el debouncing de la Touch Bar y la autenticación biométrica de **Touch ID** en Linux mediante `fprintd` y el Secure Enclave (SEP).

Sin embargo, KAIT2EN fue diseñado exclusivamente para Fedora (usando RPMs y dracut), dejando de lado a la distribución más utilizada en producción y desarrollo: **Ubuntu 24.04 LTS (Noble Numbat)**.

Este repositorio abstrae, empaqueta y adapta esa arquitectura para **Ubuntu 24.04 LTS y sistemas Debian**, brindando:
1. **Aislamiento en NetworkManager:** Reglas para que NetworkManager no resetee la interfaz `t2_ncm` (`mac:ac:de:48:00:11:22`).
2. **Direccionamiento IPv6 EUI-64:** Asignación automática para comunicarse con el host bridgeOS en `fe80::aede:48ff:fe33:4455`.
3. **Transporte RemoteXPC en Puerto 59602:** Handshake HTTP/2 funcional verificado con el Secure Enclave.
4. **Optimización de Touch Bar y Teclado:** Debouncing de 40 ms para evitar pulsaciones duplicadas en teclados mariposa y tiempos de atenuación suaves.
5. **Persistencia tras Suspensión:** Servicio systemd que mantiene vivo el enlace tras abrir y cerrar la tapa.

---

### Verificación en Vivo de Comunicación con BridgeOS

Al ejecutar el script de diagnóstico incluido (`scripts/test-t2-bridge.py`), se verifica la respuesta real del chip Apple T2:

```text
==========================================================================
 Apple T2 BridgeOS RemoteXPC Link Diagnostic (Ubuntu 24.04 LTS)
==========================================================================
[+] Found network interface 't2_ncm' (Scope ID: 2)
[+] Connecting to Apple T2 BridgeOS at [fe80::aede:48ff:fe33:4455]:59602 via t2_ncm...
[✓] TCP Connection established successfully!
[+] Sent RemoteXPC HTTP/2 preface handshake...
[✓] Received valid response from Apple T2 BridgeOS (21 bytes):
    Raw bytes: 00000c040000000000000300000064000400100000
[✓] Apple T2 RemoteXPC discovery & BiometricKit transport is ACTIVE and OPERATIONAL!
```

---

### Instalación en 1 Paso
```bash
git clone https://github.com/mylnzon58/t2-touchid-touchbar-bridge-ubuntu-24.git
cd t2-touchid-touchbar-bridge-ubuntu-24
chmod +x install.sh
sudo ./install.sh
```

### Desinstalación
```bash
sudo ./uninstall.sh
```

---

## 🇬🇧 English — Apple T2 Touch Bar & Touch ID Bridge for Ubuntu 24.04 LTS

### Overview & Architecture
The **KAIT2EN** project demonstrated on Fedora that the Apple T2 Security Chip can communicate with Linux userspace over the internal USB CDC-NCM link (`05ac:8233`). This enables groundbreaking features such as Touch Bar debouncing, hardware video encoding, and **Touch ID biometric authentication** using `fprintd` wired to the T2 Secure Enclave Processor (SEP).

However, KAIT2EN is strictly tailored for Fedora (relying on RPM packaging and dracut). 

This repository adapts and packages the core transport infrastructure for **Ubuntu 24.04 LTS (Noble Numbat)** and Debian-based systems:
1. **NetworkManager Link Isolation:** Prevents NetworkManager from dropping or auto-configuring the internal `t2_ncm` interface (`mac:ac:de:48:00:11:22`).
2. **Kernel EUI-64 IPv6 Addressing:** Automatically assigns link-local addressing to communicate with bridgeOS at `fe80::aede:48ff:fe33:4455`.
3. **Verified RemoteXPC Port 59602 Handshake:** Reliable HTTP/2 transport to the Secure Enclave for BiometricKit.
4. **Touch Bar & Keyboard Debounce:** Prevents double-typing on butterfly keyboards (`t2hid.debounce_ms=40`) and customizes backlight dimming timeouts.
5. **Full Suspend/Resume Persistence:** Systemd unit ensures the bridge recovers seamlessly across lid open/close cycles.

---

### Quick 1-Step Installation
```bash
git clone https://github.com/mylnzon58/t2-touchid-touchbar-bridge-ubuntu-24.git
cd t2-touchid-touchbar-bridge-ubuntu-24
chmod +x install.sh
sudo ./install.sh
```

### Uninstallation
```bash
sudo ./uninstall.sh
```

---

## 📄 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
Based on research, protocols and concepts from the KAIT2EN Project (GPL-3.0 / MIT).

