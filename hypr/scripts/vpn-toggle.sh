#!/bin/bash
IFACE="proton"

if ip link show "$IFACE" >/dev/null 2>&1; then
    # Disconnect VPN
    notify-send -a "System" "VPN" "Disconnecting VPN..."
    if sudo wg-quick down "$IFACE" >/dev/null 2>&1; then
        notify-send -a "System" "VPN" "VPN Disconnected"
        CLASS="disconnected"
    else
        notify-send -a -u critical "VPN" "Failed to disconnect VPN!"
        CLASS="error"
    fi
else
    # Connect VPN
    notify-send -a "System" "VPN" "Connecting VPN..."
    if sudo wg-quick up "$IFACE" >/dev/null 2>&1; then
        # Wait until interface exists and is up
        for i in {1..5}; do
            sleep 1
            if ip link show "$IFACE" >/dev/null 2>&1; then
                break
            fi
        done
        notify-send -a "System" "VPN" "VPN Connected"
        CLASS="connected"
    else
        notify-send -a -u critical "VPN" "Failed to connect VPN!"
        CLASS="error"
    fi
fi

# Update Waybar
echo "{\"text\": \"󰖂\", \"class\": \"$CLASS\", \"tooltip\": \"VPN $CLASS\"}" | tee /tmp/waybar-vpn.json
pkill -SIGRTMIN+8 waybar