#! /usr/bin/env bash
#This is an script for upfdate apt sources list

read -p "Enter an URL for downloading source list: " URL
echo "This is your URL: $URL"

echo "Downloading..."
wget -O /etc/apt/sources.list.d/repo.list $URL
sudo apt update
echo "Finish"


