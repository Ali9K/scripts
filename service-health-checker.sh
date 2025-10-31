#!/bin/bash

# This is a service health checker script

read -p "Enter the server name from ~/.ssh/config: " SERVER
read -p "Enter the service name: " SERVICE

echo "Connecting to $SERVER..."
ssh -o BatchMode=yes -o ConnectTimeout=5 "$SERVER" bash -c "'
  if systemctl is-active --quiet $SERVICE; then
    echo \"✅ $SERVICE is running.\"
  else
    echo \"❌ $SERVICE is not running.\"
    systemctl status $SERVICE --no-pager -l | head -n 10
  fi
'"

echo "Finish"

