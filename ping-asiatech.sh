# This is an sript to ping AsiaTech from office
#!/bin/bash

ASIATECH=(31.7.78.144 31.7.78.127)

for asiatech in "${ASIATECH[@]}"; do
	if ping -c 3 "$asiatech" &>/dev/null; then
		echo "$asiatech is up from office"
	else
		echo "$asiatech is down from office"
	fi
done

