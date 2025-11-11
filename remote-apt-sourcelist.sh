#!/bin/bash
#This is an script for upfdate apt sources list

read -p "Enter the server name from ~/.ssh/config: " SERVER
read -p "Enter the URL of source list: " URL
echo "This is your URL: $URL"

echo "Connecting to $SERVER..."
ssh -o BatchMode=yes -o ConnectTimeout=5 "$SERVER" bash -c "'
  cd /tmp
  wget -O repo.list $URL
  sudo mv repo.list /etc/apt/sources.list.d/repo.list
  sudo apt update
'"

echo "Finish"
