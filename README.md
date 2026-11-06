# Apple T2 Touch Bar (OLED Dynamic) & Touch ID Bridge for Ubuntu 24.04 LTS

[![Ubuntu 24.04 LTS](https://img.shields.io/badge/Ubuntu-24.04_LTS_(Noble)-E95420?logo=ubuntu&logoColor=white)](#)
[![Linux Kernel T2](https://img.shields.io/badge/Kernel-linux--t2_(v7.x)-00B4D8?logo=linux&logoColor=white)](#)
[![Hardware](https://img.shields.io/badge/Apple_T2-BridgeOS_RemoteXPC-111827?logo=apple&logoColor=white)](#)
[![Touch Bar & Touch ID](https://img.shields.io/badge/Biometrics-Touch_ID_%2B_Touch_Bar-10B981?logo=apple&logoColor=white)](#)
[![Author](https://img.shields.io/badge/Author-Juan_Monz%C3%B3n_(@mylnzon58)-10B981?logo=github&logoColor=white)](https://github.com/mylnzon58)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Juan_Monz%C3%B3n-0A66C2?logo=linkedin&logoColor=white)](https://www.linkedin.com/in/juan-m-97b85681/)
[![Instagram](https://img.shields.io/badge/Instagram-%40juanjoclassic-E4405F?logo=instagram&logoColor=white)](https://www.instagram.com/juanjoclassic/)
[![Invitame un Tecito](https://img.shields.io/badge/%E2%98%95_Donar_un_Tecito-tecito.app%2Fjuanjoclassic-FF813F?style=flat&logo=buy-me-a-coffee&logoColor=white)](https://tecito.app/juanjoclassic)
[![License: GPL-3.0](https://img.shields.io/badge/License-GPL--3.0-blue.svg)](LICENSE)

> **Author & Maintainer:** **[Juan Monzón (@mylnzon58)](https://www.linkedin.com/in/juan-m-97b85681/)** — *AI Product | Full Stack Developer | Digital Products & Growth* (Argentina)  
> **Upstream Research & Core Protocols:** **[André Eikmeyer / KAIT2EN Project](https://github.com/kaiT2en)**  
> ☕ **¿Te sirvió esta solución?** Si esta implementación te permitió activar la Touch Bar OLED gráfica dinámica y habilitar Touch ID para `sudo` y login en Ubuntu 24.04 LTS, puedes apoyar este desarrollo invitándome un Tecito en **[tecito.app/juanjoclassic](https://tecito.app/juanjoclassic)**, dejando una **Star ⭐** en el repo y conectando en **[LinkedIn](https://www.linkedin.com/in/juan-m-97b85681/)**.  
> ☕ **Did this save your day?** If this bridge helped you unlock dynamic OLED Touch Bar graphics and enable Touch ID biometric authentication for `sudo` and login on Ubuntu 24.04 LTS, feel free to support my work by buying me a Tecito at **[tecito.app/juanjoclassic](https://tecito.app/juanjoclassic)**, **Starring ⭐** this repository, and connecting on **[LinkedIn](https://www.linkedin.com/in/juan-m-97b85681/)**.

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

**[Español](#-español--arquitectura-completa-de-touch-bar-oled-y-touch-id-para-ubuntu-2404-lts)** | **[English](#-english--complete-apple-t2-touch-bar-oled--touch-id-bridge-for-ubuntu-2404-lts)**

---

## 🇪🇸 Español — Arquitectura Completa de Touch Bar OLED y Touch ID para Ubuntu 24.04 LTS

### 1. ¿Por qué la Touch Bar muestra sólo teclas estáticas por defecto?
En Linux, la pantalla de la Touch Bar (`05ac:8302`) inicia por hardware en **USB Configuration 1** (Modo Fallback HID). En este modo, el firmware de la Touch Bar solo proyecta iconos estáticos fijos de Esc y F1-F12 sin capacidad gráfica.

Para transformarla en una pantalla **OLED gráfica dinámica** (con reloj, batería, controles multimedia táctiles, brillo de pantalla/teclado y lanzador de aplicaciones):
1. El dispositivo USB debe conmutarse a **USB Configuration 2** (`echo 2 > /sys/bus/usb/devices/.../bConfigurationValue`).
2. Se carga el módulo del kernel `appletbdrm` que expone el framebuffer DRM en `/dev/dri/card*`.
3. El daemon `tiny-dfr-adv` se enlaza a la pantalla y renderiza la interfaz vectorial con SVG nativos y soporte táctil multitouch.

### 2. ¿Cómo funciona Touch ID en Linux con el chip Apple T2?
El sensor biométrico Touch ID está conectado directamente al coprocesador Apple T2 y gobernado por el **Secure Enclave Processor (SEP)**. El SEP **no permite enrolar nuevas huellas desde Linux** por motivos de aislamiento criptográfico (keybag y catacomb).

**La solución arquitectónica:**
* Las huellas dactilares se registran previamente bajo **macOS** (en Ajustes del Sistema).
* Este puente (`t2-touchid`) se comunica con el servicio `BiometricKit` de BridgeOS sobre el enlace de red IPv6 `CDC-NCM` interno (puerto `59602`).
* Conecta el veredicto del SEP a un dispositivo virtual en `/run/t2-touchid/fprint.sock`, integrándose de forma 100% nativa con `fprintd` y `pam_fprintd.so` de Ubuntu 24.04.
* **Resultado:** Cuando ejecutas `sudo` o inicias sesión, el sensor se activa en 0.2 segundos. Al posar el dedo registrado en macOS, ¡te autenticas al instante sin escribir contraseñas! Y si presionas `Esc`, cancela y te pide la contraseña inmediatamente.

---

### Verificación en Vivo de Comunicación con BridgeOS

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

---

## 🇬🇧 English — Complete Apple T2 Touch Bar OLED & Touch ID Bridge for Ubuntu 24.04 LTS

### 1. Why does the Touch Bar only show static keys by default?
On standard Linux boots, the Touch Bar display controller (`05ac:8302`) starts in hardware **USB Configuration 1** (Fallback HID mode), presenting only static Esc and F1-F12 keys.

To activate the **dynamic OLED graphics** (displaying real-time clock, battery status, media buttons, and volume/brightness sliders):
1. The USB interface is switched to **USB Configuration 2** (`bConfigurationValue = 2`).
2. The kernel module `appletbdrm` exposes the Touch Bar display as a DRM framebuffer.
3. The userspace daemon `tiny-dfr-adv` renders the rich vector UI and listens to input touch events.

### 2. How Touch ID functions on Apple T2 under Ubuntu 24.04
The biometric sensor is managed exclusively by Apple's Secure Enclave Processor (SEP) inside the T2 chip. For security reasons, Linux cannot enroll new biometric keybags from scratch.

**How this bridge achieves native Touch ID authentication:**
* Enroll your finger(s) once in **macOS** System Settings.
* The `t2-touchid` daemon connects to BridgeOS RemoteXPC over the internal CDC-NCM IPv6 link on port `59602`.
* It interfaces with stock Ubuntu `libfprint` and `fprintd` via the virtual socket interface `/run/t2-touchid/fprint.sock`.
* **Result:** Whenever `sudo` or the login prompt requests authentication, simply tap the Touch ID sensor. The SEP verifies the match and grants authentication instantly. If you press `Esc`, it falls back directly to the password prompt.

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

### License & Attribution
- Upstream Research, RemoteXPC protocols and BiometricKit reverse engineering by **André Eikmeyer** / **[KAIT2EN Project](https://github.com/kaiT2en)** (GPL-3.0-or-later).
- Ubuntu 24.04 LTS adaptation, packaging, installer, and documentation by **Juan Monzón (@mylnzon58)** (GPL-3.0-or-later).
