#!/bin/bash
# Script to generate random numeric, alphanumeric, and alphanumeric-with-symbols passwords
set -e

echo "1) Hex Password"
echo "2) Alphanumeric Password"
read -p "Choose an option: " choice
read -p "Choose the length of password: " length
echo "-------------------------------------------------------------------------"

if [ "$choice" -eq 1 ]; then
    pw=$(openssl rand -hex "$length")
    echo "Generated password: $pw"

elif [ "$choice" -eq 2 ]; then
    pw=$(openssl rand -base64 "$length")
    echo "Generated password: $pw"

else
    echo "Invalid option"
fi
echo "-------------------------------------------------------------------------"
