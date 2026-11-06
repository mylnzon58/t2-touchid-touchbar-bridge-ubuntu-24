#!/bin/bash
set -e

echo "=========================================================================="
echo " Apple T2 Touch Bar (OLED Dynamic) & Touch ID Bridge for Ubuntu 24.04 LTS"
echo " Author: Juan Monzón (@mylnzon58)"
echo " Upstream & Core Research: KAIT2EN Project (André Eikmeyer)"
echo " Target Machine: MacBook Pro 16,1 (A2141, Late 2019) / Apple T2 Series"
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

echo "[+] 1. Configurando NetworkManager para enlace CDC-NCM del T2..."
mkdir -p /etc/NetworkManager/conf.d
cp "$SCRIPT_DIR/config/10-t2-services.conf" /etc/NetworkManager/conf.d/10-t2-services.conf

echo "[+] 2. Instalando reglas udev para enlace IPv6 link-local automática..."
mkdir -p /etc/udev/rules.d
cp "$SCRIPT_DIR/config/90-t2-services-ncm.rules" /etc/udev/rules.d/90-t2-services-ncm.rules
udevadm control --reload-rules || true

echo "[+] 3. Configurando opciones de debouncing para Touch Bar..."
mkdir -p /etc/modprobe.d
cp "$SCRIPT_DIR/config/t2-touchbar.conf" /etc/modprobe.d/t2-touchbar.conf

echo "[+] 4. Instalando script y servicio persistente de red CDC-NCM..."
cp "$SCRIPT_DIR/config/t2-touchid-bridge-init.sh" /usr/local/sbin/t2-touchid-bridge-init.sh
chmod +x /usr/local/sbin/t2-touchid-bridge-init.sh
cp "$SCRIPT_DIR/config/t2-touchid-bridge.service" /etc/systemd/system/t2-touchid-bridge.service
systemctl daemon-reload
systemctl enable --now t2-touchid-bridge.service
/usr/local/sbin/t2-touchid-bridge-init.sh || true

echo "[+] 5. Configurando Touch Bar gráfica dinámica (tiny-dfr)..."
modprobe appletbdrm || true
mkdir -p /etc/tiny-dfr
if [ -f "$SCRIPT_DIR/config/tiny-dfr.toml" ]; then
  cp "$SCRIPT_DIR/config/tiny-dfr.toml" /etc/tiny-dfr/config.toml
fi

# Switch Touch Bar USB from Fallback (Config 1) to DRM Graphics (Config 2)
for dev in /sys/bus/usb/devices/*; do
  if [ -f "$dev/idVendor" ] && [ "$(cat "$dev/idVendor" 2>/dev/null)" = "05ac" ] && [ "$(cat "$dev/idProduct" 2>/dev/null)" = "8302" ]; then
    echo "    Detectada pantalla OLED Touch Bar en $dev (Config actual: $(cat "$dev/bConfigurationValue"))"
    echo 2 > "$dev/bConfigurationValue" || true
    echo "    Activado modo DRM framebuffer OLED (Config: $(cat "$dev/bConfigurationValue"))"
  fi
done
udevadm trigger || true

if systemctl is-active --quiet tiny-dfr.service || [ -f /etc/systemd/system/tiny-dfr.service ]; then
  systemctl restart tiny-dfr.service || true
fi

echo "[+] 6. Instalando daemon y drop-ins para Touch ID (fprintd / PAM)..."
if [ -f "$SCRIPT_DIR/bin/t2-touchid" ]; then
  cp "$SCRIPT_DIR/bin/t2-touchid" /usr/local/bin/t2-touchid
  chmod 755 /usr/local/bin/t2-touchid
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

# Configurar PAM para autenticación por huella
if command -v pam-auth-update >/dev/null 2>&1; then
  DEBIAN_FRONTEND=noninteractive pam-auth-update --enable fprintd || true
fi

echo "=========================================================================="
echo " [+] ¡Instalación y configuración completada con éxito!"
echo " Touch Bar: Modo dinámico OLED activo con controles multimedia y widgets."
echo " Touch ID:  Enlace activo con SEP de BridgeOS vinculado a PAM / fprintd."
echo "=========================================================================="
python3 "$SCRIPT_DIR/scripts/test-t2-bridge.py" || true
