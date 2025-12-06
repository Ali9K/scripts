# Debian Server Base Setup Script

This Bash script automates the initial setup and hardening of a Debian server. It performs common tasks such as updating apt sources, installing packages, configuring SSH, setting up iptables, and optionally installing Docker.

## Features

The script is designed to be **fully interactive**, asking for confirmation before executing each of the following 7 steps:

1.  **Update APT sources** Configures default, updates, backports, and security repositories.

2.  **Install essential packages** Installs a predefined list of packages from `.env`, including `iptables-persistent`.

3.  **Configure Passwordless Sudo** Enables `NOPASSWD` sudo access for the user defined in `.env` by creating a safe configuration in `/etc/sudoers.d/`.

4.  **SSH key management** Creates `.ssh` directory, interactively prompts to add multiple SSH public keys, and prevents duplicates.

5.  **SSHD hardening** Updates `sshd_config` to enforce security best practices (disable root login, set port, configure authentication methods, etc.) and restarts the SSH service.

6.  **Firewall setup with iptables** Configures default policies (`INPUT`, `FORWARD`, `OUTPUT`), allows specific ports, loopback, established connections, and saves the rules using `netfilter-persistent` or `iptables-save`.

7.  **Optional Docker installation** Prompts the user to install **Docker Engine** by sourcing a separate script (`docker-install.sh`), which includes adding the GPG key, setting up the repository, installing core Docker packages, enabling the service, and adding the user to the `docker` group.

---

## Prerequisites

-   Debian-based server
-   Run as **root** (`sudo`)
-   `.env` file containing required variables:

```bash
APT_TARGET=
APT_URL=
APT_SECURITY_URL=
DEBIAN_CODENAME=
APT_COMPONENTS=
PACKAGES_TO_INSTALL=()
SCRIPT_USER=
SSH_DIR=
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
IPT_PERSISTENT=

# Docker-specific variables (used in docker-install.sh)
GPG_URL=
ARCH=
DOCKER_SOURCE_LIST_URL=
DOCKER_SOURCE_LIST_COMPONENT=