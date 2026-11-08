#!/bin/bash
set -e

echo "=========================================================================="
echo " Apple T2 Touch Bar (OLED Dinámica) & Touch ID Bridge para Ubuntu 24.04 LTS"
echo " Autor: Juan José Monzón (@mylnzon58)"
echo " Investigación Upstream: Proyecto KAIT2EN (André Eikmeyer) & Aditya Garg"
echo " Modelo Destino: Apple MacBook Pro 16,1 (A2141) / Serie Apple T2"
echo " Activación Zero-Reboot: Funciona en vivo de inmediato sin reiniciar"
echo "=========================================================================="

if [ "$EUID" -ne 0 ]; then
  echo "[-] Por favor ejecuta como root: sudo ./install.sh"
  exit 1
fi

REAL_USER="${SUDO_USER:-$USER}"
if [ "$REAL_USER" = "root" ]; then
  REAL_USER="zeeroj"
fi

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

echo "[+] 1. Comprobando e instalando paquetes de sistema necesarios..."
REQUIRED_PKGS=()
if ! dpkg -l | grep -q "tiny-dfr-adv"; then
  REQUIRED_PKGS+=("tiny-dfr-adv")
fi
if ! dpkg -l | grep -q "fprintd"; then
  REQUIRED_PKGS+=("fprintd" "libpam-fprintd")
fi

if [ ${#REQUIRED_PKGS[@]} -gt 0 ]; then
  echo "    Instalando paquetes: ${REQUIRED_PKGS[*]}..."
  apt update -y || true
  apt install -y "${REQUIRED_PKGS[@]}" || true
fi

echo "[+] 2. Configurando NetworkManager para enlace CDC-NCM del T2..."
mkdir -p /etc/NetworkManager/conf.d
cp "$SCRIPT_DIR/config/10-t2-services.conf" /etc/NetworkManager/conf.d/10-t2-services.conf

echo "[+] 3. Instalando reglas udev para enlace IPv6 link-local automática..."
mkdir -p /etc/udev/rules.d
cp "$SCRIPT_DIR/config/90-t2-services-ncm.rules" /etc/udev/rules.d/90-t2-services-ncm.rules
udevadm control --reload-rules || true

echo "[+] 4. Configurando opciones de debouncing para Touch Bar..."
mkdir -p /etc/modprobe.d
cp "$SCRIPT_DIR/config/t2-touchbar.conf" /etc/modprobe.d/t2-touchbar.conf

echo "[+] 5. Instalando servicio de enlace CDC-NCM para comunicación con T2 SEP..."
cp "$SCRIPT_DIR/config/t2-touchid-bridge-init.sh" /usr/local/sbin/t2-touchid-bridge-init.sh
chmod +x /usr/local/sbin/t2-touchid-bridge-init.sh
cp "$SCRIPT_DIR/config/t2-touchid-bridge.service" /etc/systemd/system/t2-touchid-bridge.service
systemctl daemon-reload
systemctl enable --now t2-touchid-bridge.service
/usr/local/sbin/t2-touchid-bridge-init.sh || true

echo "[+] 6. Configurando interfaz visual de Touch Bar (tiny-dfr)..."
mkdir -p /etc/tiny-dfr
if [ -f "$SCRIPT_DIR/config/tiny-dfr.toml" ]; then
  cp "$SCRIPT_DIR/config/tiny-dfr.toml" /etc/tiny-dfr/config.toml
fi

echo "[+] 7. Activando pantalla OLED dinámica en vivo (Secuencia Zero-Reboot)..."
TOUCHBAR_DEV=""
for dev in /sys/bus/usb/devices/*; do
  if [ -f "$dev/idVendor" ] && [ "$(cat "$dev/idVendor" 2>/dev/null)" = "05ac" ] && [ "$(cat "$dev/idProduct" 2>/dev/null)" = "8302" ]; then
    TOUCHBAR_DEV="$dev"
    echo "    Detectada Touch Bar en $TOUCHBAR_DEV. Reseteando endpoint..."
    echo 0 > "$TOUCHBAR_DEV/bConfigurationValue" || true
    sleep 1
    echo 2 > "$TOUCHBAR_DEV/bConfigurationValue" || true
    sleep 1
    echo "    Recargando driver DRM de pantalla appletbdrm..."
    modprobe -r appletbdrm 2>/dev/null || true
    sleep 1
    modprobe appletbdrm
    sleep 1
    break
  fi
done

udevadm control --reload
udevadm trigger --subsystem-match=drm || true
udevadm trigger --subsystem-match=usb || true
sleep 1

systemctl restart tiny-dfr.service || true
echo "    [✓] tiny-dfr activo y proyectando gráficos OLED en la Touch Bar."

echo "[+] 8. Instalando daemon y puente de Touch ID para fprintd y PAM..."
systemctl stop t2-touchid.service 2>/dev/null || true
if [ -f "$SCRIPT_DIR/bin/t2-touchid" ]; then
  install -m 755 "$SCRIPT_DIR/bin/t2-touchid" /usr/local/bin/t2-touchid
fi

mkdir -p /etc/kait2en
cat << EOF > /etc/kait2en/t2-touchid.conf
T2_TOUCHID_UID=auto
T2_TOUCHID_FLAGS=0
T2_TOUCHID_BIND_USER=${REAL_USER}
T2_TOUCHID_SOCKET=/run/t2-touchid/fprint.sock
EOF

cp "$SCRIPT_DIR/config/t2-touchid.service" /etc/systemd/system/t2-touchid.service
mkdir -p /etc/systemd/system/fprintd.service.d
cp "$SCRIPT_DIR/config/fprintd-t2-touchid.conf" /etc/systemd/system/fprintd.service.d/fprintd-t2-touchid.conf

systemctl daemon-reload
systemctl enable --now t2-touchid.service || true
systemctl restart fprintd.service || true

if command -v pam-auth-update >/dev/null 2>&1; then
  DEBIAN_FRONTEND=noninteractive pam-auth-update --enable fprintd || true
fi

echo "=========================================================================="
echo " [+] ¡Instalación y activación completada con éxito (Zero-Reboot)!"
echo " Touch Bar:  Modo gráfico OLED dinámico activo (reloj, widgets, multimedia)."
echo " Touch ID:   Sensor biométrico enlazado con PAM para 'sudo' y autenticación."
echo "--------------------------------------------------------------------------"
echo " 💙 Mensaje del autor / Author's note:"
echo " Soy Juan José Monzón (@mylnzon58), desarrollador argentino y padre de una niña y un niño pequeño."
echo " Intento vivir de lo que amo (el desarrollo de software y tecnología), y quise compartir"
echo " esta solución de forma abierta para ayudar a quienes tienen este modelo de Mac con Linux."
echo ""
echo " ⭐ Si este proyecto encendió tu Touch Bar y Touch ID en Linux, déjame una estrella en GitHub:"
echo " 👉 https://github.com/mylnzon58/t2-touchid-touchbar-bridge-ubuntu-24"
echo " ¡Muchas gracias por tu apoyo! / Thank you for your support!"
echo "=========================================================================="
python3 "$SCRIPT_DIR/scripts/test-t2-bridge.py" || true
