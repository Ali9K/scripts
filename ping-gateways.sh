# This is an sript to ping the gateways from office
#!/bin/bash

GATEWAYS=(172.30.14.33 172.30.15.33 172.30.16.33 172.30.17.33 172.30.18.33)

for gateway in "${GATEWAYS[@]}"; do
	if ping -c 3 "$gateway" &>/dev/null; then
		echo "$gateway is up from office"
	else
		echo "$gateway is up from office"
	fi
done
