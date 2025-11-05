#!/bin/bash
#This is an script for installing docker on debian based distro's

#variables
PACKAGES_TO_REMOVE=(docker.io docker-doc docker-compose podman-docker containerd runc)

GPG_URL=https://download.docker.com/linux/debian/gpg

DOCKER_SOURCE_LIST_URL=https://download.docker.com/linux/debian
DOCKER_SOURCE_LIST_TYPE=deb
DOCKER_SOURCE_LIST_COMPONENT=stable

PACKAGES_TO_INSTALL=(docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin)

#pretasks
for pkgs in "${PACKAGES_TO_REMOVE[@]}" ; do
	sudo apt remove $pkgs ;
done

echo "Add Docker's GPG key: "
sudo apt update
sudo apt install ca-certificates curl -y 
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL $GPG_URL -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo "Add the repository to Apt sources:"
sudo tee /etc/apt/sources.list.d/docker.list <<EOF
Types: $DOCKER_SOURCE_LIST_TYPE
URIs: $DOCKER_SOURCE_LIST_URL
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: $DOCKER_SOURCE_LIST_COMPONENT
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update

for pkgs in "${PACKAGES_TO_INSTALL[@]}" ; do
	sudo apt install -y $pkgs ;
done

sudo systemctl start docker

sudo systemctl enable docker

sudo systemctl status docker

#post-installation steps for Docker Engine
sudo groupadd -f docker

sudo usermod -aG docker $USER

newgrp docker
