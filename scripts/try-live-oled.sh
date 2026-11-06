#!/usr/bin/env bash
set -e

DEV=""
for d in /sys/bus/usb/devices/*; do
  if [ -f "$d/idVendor" ] && [ "$(cat "$d/idVendor" 2>/dev/null)" = "05ac" ] && [ "$(cat "$d/idProduct" 2>/dev/null)" = "8302" ]; then
    DEV="$d"
    break
  fi
done

if [ -z "$DEV" ]; then
  echo "[-] Touch Bar USB device not found."
  exit 1
fi

echo "[+] Encontrado dispositivo Touch Bar en $DEV (Config actual: $(cat "$DEV/bConfigurationValue"))"

# 1. Unconfigure to 0 to flush endpoint buffers
echo "[+] Reseteando endpoint USB (Config 0)..."
echo 0 > "$DEV/bConfigurationValue" || true
sleep 1

# 2. Set Configuration 2 (DRM Display mode)
echo "[+] Conmutando a USB Configuration 2 (OLED Display)..."
echo 2 > "$DEV/bConfigurationValue" || true
sleep 1

# 3. Reload appletbdrm driver cleanly
echo "[+] Recargando módulo de kernel appletbdrm..."
modprobe -r appletbdrm 2>/dev/null || true
sleep 1
modprobe appletbdrm
sleep 2

# 4. Trigger udev
udevadm control --reload
udevadm trigger --subsystem-match=drm || true
udevadm trigger --subsystem-match=usb || true
sleep 1

# 5. Check if DRM card or alias was registered
DISPLAY_FOUND=false
for card in /sys/class/drm/card[0-9]*; do
  if [ -d "$card/device/driver" ] && [ "$(basename "$(readlink -f "$card/device/driver" 2>/dev/null)")" = "appletbdrm" ]; then
    DISPLAY_FOUND=true
    echo "[✓] ¡Pantalla OLED detectada exitosamente por appletbdrm en $card!"
    break
  fi
done

if [ "$DISPLAY_FOUND" = true ] || [ -e /dev/tiny_dfr_display ]; then
  echo "[+] Iniciando daemon gráfico tiny-dfr..."
  systemctl restart tiny-dfr.service || true
  sleep 1
  systemctl status tiny-dfr.service --no-pager || true
  echo "[✓] ¡Touch Bar activada en modo dinámico OLED con widgets!"
else
  echo "[!] appletbdrm no pudo sincronizar en caliente (requiere reinicio en frío del chip T2)."
  echo "[+] Restaurando Touch Bar a modo básico (Config 1) para mantenerla encendida..."
  echo 1 > "$DEV/bConfigurationValue" || true
  echo "[✓] Touch Bar restaurada a teclas normales (Esc + F1-F12)."
fi

