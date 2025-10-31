#!/bin/bash

echo "Change DNS"
echo
read -p "Enter nameserver(s) separated by spaces: " -a NAMESERVER
echo "You entered: ${NAMESERVER[@]}"
echo
for nameserver in "${NAMESERVER[@]}"; do
	echo "nameserver $nameserver" >> ./resolv.conf
done
echo
echo "Done! Your resolv.conf file should look like this:"
echo
echo
cat ./resolv.conf
echo "Update and Upgrade"
echo
sudo sh -c "apt-get update && apt-get -y upgrade && apt-get -y dist-upgrade"
echo
echo "Done!"
