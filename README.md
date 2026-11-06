# Apple T2 Touch Bar (OLED Dinámica Zero-Reboot) & Touch ID Bridge para Ubuntu 24.04 LTS

[![Ubuntu 24.04 LTS](https://img.shields.io/badge/Ubuntu-24.04_LTS_(Noble)-E95420?logo=ubuntu&logoColor=white)](#)
[![Linux Kernel T2](https://img.shields.io/badge/Kernel-linux--t2_(v7.x)-00B4D8?logo=linux&logoColor=white)](#)
[![Zero Reboot](https://img.shields.io/badge/Touch_Bar-Zero--Reboot_Live_Activation-10B981?logo=apple&logoColor=white)](#)
[![Touch ID Biometrics](https://img.shields.io/badge/Biometrics-Touch_ID_%2B_PAM_sudo-10B981?logo=apple&logoColor=white)](#)
[![Author](https://img.shields.io/badge/Author-Juan_Monz%C3%B3n_(@mylnzon58)-10B981?logo=github&logoColor=white)](https://github.com/mylnzon58)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Juan_Monz%C3%B3n-0A66C2?logo=linkedin&logoColor=white)](https://www.linkedin.com/in/juan-m-97b85681/)
[![Instagram](https://img.shields.io/badge/Instagram-%40juanjoclassic-E4405F?logo=instagram&logoColor=white)](https://www.instagram.com/juanjoclassic/)
[![Invitame un Tecito](https://img.shields.io/badge/%E2%98%95_Donar_un_Tecito-tecito.app%2Fjuanjoclassic-FF813F?style=flat&logo=buy-me-a-coffee&logoColor=white)](https://tecito.app/juanjoclassic)
[![License: GPL-3.0](https://img.shields.io/badge/License-GPL--3.0-blue.svg)](LICENSE)

> **Author & Maintainer:** **[Juan Monzón (@mylnzon58)](https://www.linkedin.com/in/juan-m-97b85681/)** — *AI Product | Full Stack Developer | Digital Products & Growth* (Argentina)  
> **Upstream Research & Core Protocols:** **[André Eikmeyer / KAIT2EN Project](https://github.com/kaiT2en)** & **[Aditya Garg](https://github.com/AdityaGarg8)**  
> ☕ **¿Te sirvió esta solución?** Si esta implementación te permitió activar la Touch Bar OLED interactiva sin reiniciar y habilitar Touch ID para `sudo` en Ubuntu 24.04 LTS, puedes apoyar este desarrollo invitándome un Tecito en **[tecito.app/juanjoclassic](https://tecito.app/juanjoclassic)**, dejando una **Star ⭐** en el repo y conectando en **[LinkedIn](https://www.linkedin.com/in/juan-m-97b85681/)**.  
> ☕ **Did this save your day?** If this bridge helped you unlock dynamic OLED Touch Bar graphics with zero reboots and enable Touch ID biometric authentication for `sudo` on Ubuntu 24.04 LTS, feel free to support my work by buying me a Tecito at **[tecito.app/juanjoclassic](https://tecito.app/juanjoclassic)**, **Starring ⭐** this repository, and connecting on **[LinkedIn](https://www.linkedin.com/in/juan-m-97b85681/)**.

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

**[Español](#-español--arquitectura-recursos-instalados-y-activación-zero-reboot)** | **[English](#-english--architecture-installed-resources--zero-reboot-activation)**

---

## 🇪🇸 Español — Arquitectura, Recursos Instalados y Activación Zero-Reboot

### 1. El Avance: Activación de Touch Bar OLED Dinámica "Zero-Reboot" (Sin Reiniciar)
Hasta ahora, la documentación de la comunidad indicaba que para pasar del modo básico estático de la Touch Bar (Esc y F1-F12) al modo gráfico dinámico era obligatorio reiniciar el equipo. Si se cambiaba en caliente, el kernel arrojaba `appletbdrm failed with error -110 (ETIMEDOUT)` y la pantalla se apagaba.

**Descubrimos la secuencia exacta para activarla en vivo en una sesión activa sin reiniciar:**
1. Desconfigurar el endpoint USB escribiendo `0` en `bConfigurationValue` para vaciar los buffers del controlador virtual `bce-vhci`.
2. Establecer `bConfigurationValue = 2` (modo DRM Framebuffer OLED).
3. Recargar el módulo del kernel: `modprobe -r appletbdrm && modprobe appletbdrm`.
4. El kernel sincroniza limpiamente con el hardware:
   ```text
   [drm] Initialized appletbdrm 1.0.0 for 7-6:2.1 on minor 0
   ```
5. El daemon `tiny-dfr` toma el control de `/dev/dri/card*` y enciende la interfaz táctil con widgets en tiempo real.

---

### 2. Recursos y Componentes Instalados en el Sistema

El instalador automatizado gestiona e integra los siguientes recursos en Ubuntu 24.04 LTS:

| Componente | Tipo / Ruta | Función en el Sistema |
| :--- | :--- | :--- |
| **`tiny-dfr-adv`** | Paquete APT (`0.3.1-1-noble`) | Daemon userspace que renderiza la interfaz visual interactiva en la pantalla OLED. |
| **`config.toml`** | `/etc/tiny-dfr/config.toml` | Configuración con `SpecialExtendedMode=true`: reloj 24h, batería, lanzador de apps y controles táctiles. |
| **`appletbdrm`** | Driver Kernel (`appletbdrm.ko`) | Expone la pantalla OLED de la Touch Bar como dispositivo DRM en `/dev/dri/card*`. |
| **`t2-touchid`** | Binario Rust (`/usr/local/bin/t2-touchid`) | Daemon compilado nativamente que comunica Linux con el Secure Enclave (SEP) de Apple T2. |
| **`t2-touchid.conf`** | `/etc/kait2en/t2-touchid.conf` | Configuración de usuario para vinculación biométrica automática (`zeeroj` / `auto`). |
| **`t2-touchid.service`** | `/etc/systemd/system/t2-touchid.service` | Servicio systemd persistente que escucha peticiones de verificación de huella. |
| **`fprintd-t2-touchid.conf`** | `/etc/systemd/system/fprintd.service.d/` | Drop-in que conecta `libfprint` al socket virtual `/run/t2-touchid/fprint.sock`. |
| **`fprintd` / `libpam-fprintd`** | Paquetes oficiales Ubuntu | Módulo PAM (`pam_fprintd.so`) para autenticar `sudo` y login con huella dactilar. |
| **`10-t2-services.conf`** | `/etc/NetworkManager/conf.d/` | Regla para aislar la interfaz interna USB CDC-NCM (`mac:ac:de:48:00:11:22`). |
| **`90-t2-services-ncm.rules`** | `/etc/udev/rules.d/` | Asigna IPv6 EUI-64 link-local para dialogar con BridgeOS en `port 59602`. |
| **`t2-touchbar.conf`** | `/etc/modprobe.d/` | Debouncing de teclado y sensibilidad de Touch Bar (`double_press_switch_time=250`). |

---

### 3. Touch ID: Funcionamiento y Verificación en Vivo

```text
$ fprintd-list $USER
found 1 devices
Device at /net/reactivated/Fprint/Device/0
Using device /net/reactivated/Fprint/Device/0
Fingerprints for user zeeroj on Virtual device with storage and identification:
 - #0: right-index-finger
```

Cuando ejecutas `sudo` en cualquier terminal:
```text
$ sudo apt update
Deslice su dedo índice derecho por el lector de huellas dactilares
```
* **Apoyas tu dedo** sobre el sensor en la esquina superior derecha: autenticación en **0.2 segundos**.
* **Presionas `Esc`**: cancela de inmediato y pide contraseña sin esperar tiempos de espera.

---

### 4. Instalación Automatizada (1 Solo Paso)
```bash
git clone https://github.com/mylnzon58/t2-touchid-touchbar-bridge-ubuntu-24.git
cd t2-touchid-touchbar-bridge-ubuntu-24
chmod +x install.sh
sudo ./install.sh
```

---

## 🇬🇧 English — Architecture, Installed Resources & Zero-Reboot Activation

### 1. The Breakthrough: Zero-Reboot OLED Dynamic Touch Bar Activation
Previously, upstream documentation indicated that switching the Touch Bar from fallback HID keys (Esc & F1-F12) to dynamic OLED graphics required a mandatory cold reboot. Any live switch attempt resulted in `appletbdrm failed with error -110 (ETIMEDOUT)` and a blank screen.

**We uncovered the exact hardware handshake to activate it live with ZERO reboots:**
1. Unconfigure the USB endpoint by writing `0` to `bConfigurationValue` to purge `bce-vhci` buffers.
2. Set `bConfigurationValue = 2` (OLED DRM Framebuffer mode).
3. Safely reload the kernel module: `modprobe -r appletbdrm && modprobe appletbdrm`.
4. The kernel synchronizes cleanly with the T2 hardware:
   ```text
   [drm] Initialized appletbdrm 1.0.0 for 7-6:2.1 on minor 0
   ```
5. The `tiny-dfr` daemon binds to `/dev/dri/card*` and projects real-time dynamic widgets instantly.

---

### 2. Installed System Resources & Integration Mapping

The automated installer manages and deploys the following resources on Ubuntu 24.04 LTS:

| Resource | Path / Package | Function |
| :--- | :--- | :--- |
| **`tiny-dfr-adv`** | APT package (`0.3.1-1-noble`) | Userspace daemon rendering vector UI & widgets on the OLED Touch Bar. |
| **`config.toml`** | `/etc/tiny-dfr/config.toml` | UI layout: 24h clock, battery meter, app shortcuts, and media/volume keys. |
| **`appletbdrm`** | Kernel driver (`appletbdrm.ko`) | Exposes the OLED panel as a native DRM display device in `/dev/dri/card*`. |
| **`t2-touchid`** | Rust binary (`/usr/local/bin/t2-touchid`) | Native daemon bridging Linux with the Apple T2 Secure Enclave Processor (SEP). |
| **`t2-touchid.conf`** | `/etc/kait2en/t2-touchid.conf` | Configuration binding pre-enrolled macOS identities to the Linux account. |
| **`t2-touchid.service`** | `/etc/systemd/system/t2-touchid.service` | Systemd service managing biometric authentication requests. |
| **`fprintd-t2-touchid.conf`** | `/etc/systemd/system/fprintd.service.d/` | Drop-in routing `libfprint` to virtual socket `/run/t2-touchid/fprint.sock`. |
| **`fprintd` / `libpam-fprintd`** | Ubuntu upstream packages | Standard PAM integration (`pam_fprintd.so`) for fingerprint-enabled `sudo` & login. |
| **`10-t2-services.conf`** | `/etc/NetworkManager/conf.d/` | Isolates the internal CDC-NCM link (`mac:ac:de:48:00:11:22`) from NetworkManager. |
| **`90-t2-services-ncm.rules`** | `/etc/udev/rules.d/` | Automatically configures IPv6 EUI-64 link-local for BridgeOS communication on port 59602. |
| **`t2-touchbar.conf`** | `/etc/modprobe.d/` | Butterfly keyboard debouncing filter (`double_press_switch_time=250`). |

---

### 3. Native Touch ID Verification

Whenever `sudo` or the login prompt requests credentials:
```text
$ sudo apt update
Deslice su dedo índice derecho por el lector de huellas dactilares
```
- Rest your finger on the sapphire Touch ID sensor: **authenticated in 0.2 seconds**.
- Press **`Esc`**: immediately aborts the scan and falls back to password entry without timeout.

---

### 4. 1-Step Installation
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
- Upstream Research, RemoteXPC protocols, and BiometricKit reverse engineering by **André Eikmeyer** / **[KAIT2EN Project](https://github.com/kaiT2en)** (GPL-3.0-or-later).
- Ubuntu 24.04 LTS Noble port, Zero-Reboot activation handshake, installer, and packaging by **Juan Monzón (@mylnzon58)** (GPL-3.0-or-later).
