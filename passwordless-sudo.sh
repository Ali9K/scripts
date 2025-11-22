#!/bin/bash
#This is an script for making sudo passwordless

#variables
read -p "Enter the USER name: " USER
SUDOERS_FILE="/etc/sudoers.d/$USER"

# Check for root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root (sudo)." >&2
    exit 1
fi

# Backup existing sudoers file if it exists
if [[ -f "$SUDOERS_FILE" ]]; then
    cp "$SUDOERS_FILE" "${SUDOERS_FILE}.bak"
    echo "Existing sudoers file backed up to ${SUDOERS_FILE}.bak"
fi

# Write passwordless sudo entry safely
echo "$USER ALL=(ALL) NOPASSWD:ALL" > "$SUDOERS_FILE"
chmod 0440 "$SUDOERS_FILE"

echo "Passwordless sudo enabled for user $USER."
echo "Done! Close and reopen your terminal (or start a new session) to use sudo without a password."
