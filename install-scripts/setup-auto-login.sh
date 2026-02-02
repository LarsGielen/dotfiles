#!/bin/bash

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
   echo "Please run as root (use sudo)"
   exit 1
fi

# Prompt for the username
read -p "Enter the username you want to auto-login: " TARGET_USER

# Check if the user actually exists
if id "$TARGET_USER" &>/dev/null; then
    echo "Configuring auto-login for: $TARGET_USER"
    
    # Create the systemd override directory for getty on tty1
    mkdir -p /etc/systemd/system/getty@tty1.service.d/
    
    # Create the override file
    cat <<EOF > /etc/systemd/system/getty@tty1.service.d/override.conf
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin $TARGET_USER --noclear %I \$TERM
EOF

    echo "Success! Auto-login configured on tty1."
else
    echo "Error: User '$TARGET_USER' does not exist."
    exit 1
fi