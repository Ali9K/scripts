#!/bin/bash
#This is an script for installing docker on debian based distro's

#variables
source .env

PACKAGES_TO_REMOVE=(docker.io docker-doc docker-compose podman-docker containerd runc)

# DOCKER_SOURCE_LIST_URL must be in .env
# GPG_URL must be in .env
DOCKER_SOURCE_LIST_COMPONENT=stable
ARCH="$(dpkg --print-architecture)"
DEBIAN_CODENAME="$(. /etc/os-release && echo "$VERSION_CODENAME")"

PACKAGES_TO_INSTALL=(docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin)

#pretasks
for pkgs in "${PACKAGES_TO_REMOVE[@]}" ; do
	sudo apt-get remove -qq $pkgs ;
done

echo "Add Docker's GPG key: "
sudo apt-get update -qq
sudo apt-get install ca-certificates curl -y -qq
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL $GPG_URL -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo "Add the repository to Apt sources:"
sudo tee /etc/apt/sources.list.d/docker.list <<EOF
deb [arch=$ARCH signed-by=/etc/apt/keyrings/docker.asc] $DOCKER_SOURCE_LIST_URL $DEBIAN_CODENAME $DOCKER_SOURCE_LIST_COMPONENT
EOF

sudo apt-get update

for pkgs in "${PACKAGES_TO_INSTALL[@]}" ; do
	sudo apt-get install -qq -y $pkgs ;
done

sudo systemctl start docker

sudo systemctl enable docker

#post-installation steps for Docker Engine
sudo groupadd -f docker

sudo usermod -aG docker $USER

newgrp docker
