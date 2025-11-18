# Debian Server Base Setup Script

This Bash script automates the initial setup and hardening of a Debian server. It performs common tasks such as updating apt sources, installing packages, configuring SSH, setting up iptables, and optionally installing Docker.

## Features

1. **Update APT sources**  
   Configures default, updates, backports, and security repositories.

2. **Install essential packages**  
   Installs a predefined list of packages from `.env`.

3. **SSH key management**  
   Creates `.ssh` directory, adds multiple SSH public keys, and prevents duplicates.

4. **SSHD hardening**  
   Updates `sshd_config` to enforce security best practices (disable root login, set port, configure authentication methods, etc.).

5. **Firewall setup with iptables**  
   Configures default policies, allows specific ports, loopback, and established connections.

6. **Optional Docker installation**  
   Prompts the user to install Docker via a separate script (`docker-install.sh`).

## Prerequisites

- Debian-based server
- Run as **root** (`sudo`)
- `.env` file containing required variables:

```bash
APT_TARGET=
APT_URL=
APT_SECURITY_URL=
DEBIAN_CODENAME=
APT_COMPONENTS=
PACKAGES_TO_INSTALL=()
SSH_DIR=
USER_SSH=
AUTH_KEYS=
SSHD_CONFIG=
BACKUP_SSHD=
PORT=
PERMIT_ROOT_LOGIN=
MAX_AUTH_TRIES=
PUBKEY_AUTH=
PASSWORD_AUTH=
EMPTY_PASS=
KBD_INTERACTIVE_AUTH=
KERBEROS_AUTH=
GSS_AUTH=
USE_PAM=
X11_FORWARDING=
PRINT_MOTD=
IPTABLES_INPUT=
IPTABLES_FORWARD=
IPTABLES_OUTPUT=
IPTABLES_ALLOW_PORTS=()

