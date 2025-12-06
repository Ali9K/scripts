#!/usr/bin/env bash
# This script sets up base configs for a Debian server.

# Variables
source .env

# Check for root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root (sudo)." >&2
    exit 1
fi

# ****************************** STEP 1 ******************************
echo "****************************** Updating apt source list ******************************"
printf '\n'
read -rp "Do you want to update apt source list (Y or N)? " RUN_STEP_1

if [[ "$RUN_STEP_1" == "Y" || "$RUN_STEP_1" == "y" ]]; then
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

elif [[ "$RUN_STEP_1" == "N" || "$RUN_STEP_1" == "n" ]]; then
    echo "Skipping Step 1..."
else
    echo "Incorrect option, skipping Step 1..."
fi

printf '\n\n\n'

# ****************************** STEP 2 ******************************
echo "****************************** Install some packages ******************************"
printf '\n'
read -rp "Do you want to install base packages (Y or N)? " RUN_STEP_2

if [[ "$RUN_STEP_2" == "Y" || "$RUN_STEP_2" == "y" ]]; then
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

    echo "iptables-persistent iptables-persistent/autosave_v4 boolean $IPT_PERSISTENT" | debconf-set-selections
    echo "iptables-persistent iptables-persistent/autosave_v6 boolean $IPT_PERSISTENT" | debconf-set-selections
    DEBIAN_FRONTEND=noninteractive apt-get install -y iptables-persistent > /dev/null 2>&1

elif [[ "$RUN_STEP_2" == "N" || "$RUN_STEP_2" == "n" ]]; then
    echo "Skipping Step 2..."
else
    echo "Incorrect option, skipping Step 2..."
fi

printf '\n\n\n'

# ****************************** STEP 3 ******************************
echo "****************************** Add SSH key ******************************"
printf '\n'
read -rp "Do you want to add SSH keys (Y or N)? " RUN_STEP_3

if [[ "$RUN_STEP_3" == "Y" || "$RUN_STEP_3" == "y" ]]; then
    echo "Create .ssh directory if it doesn't exist"
    mkdir -p "$SSH_DIR"
    chmod 700 "$SSH_DIR"
    chown "$SCRIPT_USER":"$SCRIPT_USER" "$SSH_DIR"
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

elif [[ "$RUN_STEP_3" == "N" || "$RUN_STEP_3" == "n" ]]; then
    echo "Skipping Step 3..."
else
    echo "Incorrect option, skipping Step 3..."
fi

printf '\n\n\n'

# ****************************** STEP 4 ******************************
echo "****************************** sshd config hardening ******************************"
printf '\n'
read -rp "Do you want to update sshd config (Y or N)? " RUN_STEP_4

if [[ "$RUN_STEP_4" == "Y" || "$RUN_STEP_4" == "y" ]]; then
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

elif [[ "$RUN_STEP_4" == "N" || "$RUN_STEP_4" == "n" ]]; then
    echo "Skipping Step 4..."
else
    echo "Incorrect option, skipping Step 4..."
fi

printf '\n\n\n'

# ****************************** STEP 5 ******************************
echo "****************************** Set iptables ******************************"
printf '\n'
read -rp "Do you want to configure iptables (Y or N)? " RUN_STEP_5

if [[ "$RUN_STEP_5" == "Y" || "$RUN_STEP_5" == "y" ]]; then
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

    echo "Configuring Docker forwarding rules..."
    iptables -A FORWARD -i docker0 -o docker0 -j $IPTABLES_DOCKER_FORWARD
    iptables -A FORWARD -i docker0 ! -o docker0 -j $IPTABLES_DOCKER_FORWARD
    iptables -A FORWARD -o docker0 -m conntrack --ctstate RELATED,ESTABLISHED -j $IPTABLES_DOCKER_FORWARD

    if command -v netfilter-persistent >/dev/null 2>&1; then
        netfilter-persistent save
    else
        iptables-save > /etc/iptables/rules.v4
        ip6tables-save > /etc/iptables/rules.v6
    fi

elif [[ "$RUN_STEP_5" == "N" || "$RUN_STEP_5" == "n" ]]; then
    echo "Skipping Step 5..."
else
    echo "Incorrect option, skipping Step 5..."
fi

printf '\n\n\n'

# ****************************** STEP 6 ******************************
echo "****************************** Install docker ******************************"
printf '\n'
read -rp "Do you want to install Docker (Y or N)? " INSTALL_DOCKER

if [[ "$INSTALL_DOCKER" == "Y" || "$INSTALL_DOCKER" == "y" ]]; then
    echo "Sourcing Docker install script..."
    source ./docker-install.sh
elif [[ "$INSTALL_DOCKER" == "N" || "$INSTALL_DOCKER" == "n" ]]; then
    echo "Skipping Docker installation"
else
    echo "Incorrect option, please enter Y(es) or N(o)"
fi

echo "****************************** Finished ******************************"
printf '\n'