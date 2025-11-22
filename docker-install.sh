#!/bin/bash
#This is an script for installing docker on debian based distro's

#variables
source .env

PACKAGES_TO_REMOVE=(docker.io docker-doc docker-compose podman-docker containerd runc)
PACKAGES_TO_INSTALL=(docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin)

#pretasks
for pkgs in "${PACKAGES_TO_REMOVE[@]}" ; do
	apt-get remove -qq $pkgs > /dev/null ;
done

echo "Add Docker's GPG key: "
apt-get update -qq > /dev/null
apt-get install ca-certificates curl -y > /dev/null
install -m 0755 -d /etc/apt/keyrings
curl -fsSL $GPG_URL -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo "Add the repository to Apt sources:"
tee /etc/apt/sources.list.d/docker.list <<EOF
deb [arch=$ARCH signed-by=/etc/apt/keyrings/docker.asc] $DOCKER_SOURCE_LIST_URL $DEBIAN_CODENAME $DOCKER_SOURCE_LIST_COMPONENT
EOF

apt-get update > /dev/null

for pkgs in "${PACKAGES_TO_INSTALL[@]}" ; do
	apt-get install -qq -y $pkgs > /dev/null ;
done

systemctl start docker

systemctl enable docker

#post-installation steps for Docker Engine
groupadd -f docker

usermod -aG docker $USER

echo "Logout and login again to use Docker without sudo."
