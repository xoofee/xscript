#!/bin/sh

# This script do a soft unplug and replug of the usb wifi device

sudo bash <<'EOF'
set -e
shopt -s nullglob
matches=()

for usb in /sys/bus/usb/devices/*; do
  [[ -r "$usb/idVendor" && -r "$usb/idProduct" ]] || continue
  [[ $(<"$usb/idVendor"):$(<"$usb/idProduct") == 0bda:818b ]] || continue
  matches+=("$usb")
done

if (( ${#matches[@]} != 1 )); then
  printf 'Expected one Realtek USB Wi-Fi adapter, found %d\n' "${#matches[@]}" >&2
  exit 1
fi

authorized="${matches[0]}/authorized"
trap 'echo 1 > "$authorized"' EXIT
echo 0 > "$authorized"
sleep 2
echo 1 > "$authorized"
trap - EXIT
EOF
