#!/usr/bin/env bash
# This script sets up base configs for a Debian server.

# Variables
source .env

# Check for root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root (sudo)." >&2
    exit 1
fi

# Apt source list
echo "****************************** 1)Updating apt source list ******************************"
printf '\n'
echo "Updating apt default source list..."
tee "$APT_TARGET" > /dev/null <<EOF
deb $APT_URL $DEBIAN_CODENAME $APT_COMPONENTS
EOF

tee -a "$APT_TARGET" > /dev/null <<EOF
deb $APT_URL ${DEBIAN_CODENAME}-updates $APT_COMPONENTS
deb $APT_URL ${DEBIAN_CODENAME}-proposed-updates $APT_COMPONENTS
deb $APT_URL ${DEBIAN_CODENAME}-backports $APT_COMPONENTS
EOF

# Apt security source list
echo "Updating apt security source list..."
tee -a "$APT_TARGET" > /dev/null <<EOF
deb $APT_SECURITY_URL ${DEBIAN_CODENAME}-security $APT_COMPONENTS
EOF

echo "apt-get update..."
apt-get update > /dev/null

printf '\n\n\n'

echo "****************************** 2)Install some packages ******************************"
printf '\n'
FAILED_PACKAGES=()

if [ ${#PACKAGES_TO_INSTALL[@]} -gt 0 ]; then
    for pkg in "${PACKAGES_TO_INSTALL[@]}"; do
        if apt-get install -y "$pkg" > /dev/null 2>&1; then
            echo "✓ Installed: $pkg"
        else
            echo "✗ FAILED: $pkg"
            FAILED_PACKAGES+=("$pkg")
        fi
    done
fi

printf '\n\n\n'

echo "****************************** 3)Add SSH key ******************************"
printf '\n'
echo "Create .ssh directory if it doesn't exist"
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"
chown "$USER_SSH":"$USER_SSH" "$SSH_DIR"
touch $AUTH_KEYS

echo "Enter SSH public keys one by one. Type 'done' when finished."
while true; do
    read -rp "Enter SSH key: " key
    [[ "$key" == "done" ]] && break  # stop loop

    # Skip empty lines
    [[ -z "$key" ]] && continue

    # Check for duplicates
    if ! grep -qxF "$key" "$AUTH_KEYS" 2>/dev/null; then
        echo "$key" >> "$AUTH_KEYS"
        echo "Key added."
    else
        echo "Key already exists, skipping..."
    fi
done

printf '\n\n\n'

echo "****************************** 4)sshd config hardening ******************************"
printf '\n'
cp "$SSHD_CONFIG" "$BACKUP_SSHD"
echo "Backup from sshd_config created at $BACKUP_SSHD"

# Update sshd_config using sed
echo "Updating sshd configs..."
sed -i "s/^#Port .*/Port $PORT/" "$SSHD_CONFIG"
sed -i "s/^#PermitRootLogin .*/PermitRootLogin $PERMIT_ROOT_LOGIN/" "$SSHD_CONFIG"
sed -i "s/^#MaxAuthTries .*/MaxAuthTries $MAX_AUTH_TRIES/" "$SSHD_CONFIG"
sed -i "s/^#PubkeyAuthentication .*/PubkeyAuthentication $PUBKEY_AUTH/" "$SSHD_CONFIG"
sed -i "s/^#PasswordAuthentication .*/PasswordAuthentication $PASSWORD_AUTH/" "$SSHD_CONFIG"
sed -i "s/^#PermitEmptyPasswords .*/PermitEmptyPasswords $EMPTY_PASS/" "$SSHD_CONFIG"
sed -i "s/^#KbdInteractiveAuthentication .*/KbdInteractiveAuthentication $KBD_INTERACTIVE_AUTH/" "$SSHD_CONFIG"
sed -i "s/^#KerberosAuthentication .*/KerberosAuthentication $KERBEROS_AUTH/" "$SSHD_CONFIG"
sed -i "s/^#GSSAPIAuthentication .*/GSSAPIAuthentication $GSS_AUTH/" "$SSHD_CONFIG"
sed -i "s/^#UsePAM .*/UsePAM $USE_PAM/" "$SSHD_CONFIG"
sed -i "s/^#X11Forwarding .*/X11Forwarding $X11_FORWARDING/" "$SSHD_CONFIG"
sed -i "s/^#PrintMotd .*/PrintMotd $PRINT_MOTD/" "$SSHD_CONFIG"

# Restart SSH service to apply changes
systemctl restart sshd
echo "sshd_config updated and service restarted."

printf '\n\n\n'

echo "****************************** 5)Set iptables ******************************"
printf '\n'
echo "Seting default policies..."
iptables -P INPUT $IPTABLES_INPUT
iptables -P FORWARD $IPTABLES_FORWARD
iptables -P OUTPUT $IPTABLES_OUTPUT

echo "Allow loopback (localhost)..."
iptables -A INPUT -i lo -j ACCEPT

echo "Allow established/related connections"
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

echo "Allow your specific ports"
for port in "${IPTABLES_ALLOW_PORTS[@]}" ; do
	iptables -A INPUT -p tcp --dport $port -j ACCEPT ;
done

echo "Allow SSH port"
iptables -A INPUT -p tcp --dport $PORT -j ACCEPT

printf '\n\n\n'

echo "****************************** 5)Install docker ******************************"
printf '\n'
read -rp "Do you want to install Docker (Y or N)? " INSTALL_DOCKER
if [[ "$INSTALL_DOCKER" == "Y" ]]; then
    echo "Sourcing Docker install script..."
    source ../docker-install.sh
elif [[ "$INSTALL_DOCKER" == "N" ]]; then
    echo "Skipping Docker installation"
else
    echo "Incorrect option, please enter Y(es) or N(o)"
fi

echo "****************************** Finished ******************************"
printf '\n'