# This is an sript to ping SimServer from office
#!/bin/bash

source .env 
# SIMSERVER must be in .env


for simserver in "${SIMSERVER[@]}"; do
	if ping -c 3 "$simserver" &>/dev/null; then
		echo "$simserver is up from office"
	else
		echo "$simserver is down from office"
	fi
done

