#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root (sudo)." >&2
    exit 1
fi

SCRIPT_DIR="$(dirname "$0")"
DEST="/etc/NetworkManager/dispatcher.d/99-wifi-powersave-vpn"

cp "$SCRIPT_DIR/99-wifi-powersave-vpn" "$DEST"
chown root:root "$DEST"
chmod 755 "$DEST"

systemctl restart NetworkManager
echo "Installed $DEST and restarted NetworkManager."
