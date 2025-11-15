# This is an sript to ping the gateways from office
#!/bin/bash

source .env 
# GATEWAYS must be in .env

for gateway in "${GATEWAYS[@]}"; do
	if ping -c 3 "$gateway" &>/dev/null; then
		echo "$gateway is up from office"
	else
		echo "$gateway is down from office"
	fi
done
