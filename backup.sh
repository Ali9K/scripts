# This is an script for backup a directory
#!/bin/bash

read -p "Enter directory path for backing up: " BACKUP_DIR

echo "$BACKUP_DIR"

read -p "Enter a path to store backup files: " DEST_PATH

echo "$DEST_PATH"

read -p "Enter a name for backup file: " NAME

MONTH=$(date +%B)
YEAR=$(date +%G)

tar czf $BACKUP_DIR/$YEAR-$MONTH-$NAME.tgz $BACKUP_DIR
echo "Backup finished"
