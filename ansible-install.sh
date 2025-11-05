#!/bin/bash
#This is an script for installng ansible on debian based distro's

# variables
PACKAGES_TO_INSTALL=(python3 pipx)

# install
echo "apt update..."
sudo apt update -qq

echo "Install dependencies..."
for pkgs in "${PACKAGES_TO_INSTALL[@]}" ; do
	sudo apt install -qq -y "$pkgs" ;
done

echo "Install full ansible..."
pipx install --include-deps ansible

echo "Add path"
pipx ensurepath

echo "Done! Close and reopen your terminal to use 'ansible' command."
