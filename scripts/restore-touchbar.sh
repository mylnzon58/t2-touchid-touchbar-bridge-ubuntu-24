#!/usr/bin/env bash
# Restaura el modo básico de teclas iluminadas (Esc + F1-F12) en la sesión actual
for dev in /sys/bus/usb/devices/*; do
  if [ -f "$dev/idVendor" ] && [ "$(cat "$dev/idVendor" 2>/dev/null)" = "05ac" ] && [ "$(cat "$dev/idProduct" 2>/dev/null)" = "8302" ]; then
    echo "Restaurando Touch Bar a modo hardware básico en $dev..."
    echo 1 > "$dev/bConfigurationValue" || true
    echo "Touch Bar restaurada (Config: $(cat "$dev/bConfigurationValue"))"
  fi
done

