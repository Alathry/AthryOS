#!/bin/bash

LOGFILE="systemd_update.log"
exec > >(tee -a "$LOGFILE") 2>&1

echo "===== $(date '+%Y-%m-%d %H:%M:%S') - Systemd Configuration Update ====="

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}ERROR:${NC} This script must be run with root privileges (sudo)."
   exit 1
fi

SOURCE_FILE="system.conf"
TARGET_DIR="/etc/systemd"
TARGET_FILE="$TARGET_DIR/system.conf"
BACKUP_FILE="$TARGET_FILE.bak"

if [[ ! -f "$SOURCE_FILE" ]]; then
    echo -e "${RED}ERROR:${NC} Local source file '$SOURCE_FILE' not found in the current directory."
    exit 1
fi

echo -e "${BLUE}INFO:${NC} Creating backup of the existing configuration..."
if [[ -f "$TARGET_FILE" ]]; then
    if sudo cp "$TARGET_FILE" "$BACKUP_FILE"; then
        echo -e "${GREEN}SUCCESS:${NC} Existing file backed up to $BACKUP_FILE"
    else
        echo -e "${RED}ERROR:${NC} Failed to create a backup file. Aborting operation."
        exit 1
    fi
else
    echo -e "${BLUE}INFO:${NC} No existing system.conf found at target. Skipping backup."
fi

echo -e "${BLUE}INFO:${NC} Deploying new system.conf configuration..."
if sudo cp "$SOURCE_FILE" "$TARGET_FILE"; then
    echo -e "${GREEN}SUCCESS:${NC} New configuration successfully deployed to $TARGET_FILE"
else
    echo -e "${RED}ERROR:${NC} Failed to copy new configuration to $TARGET_FILE"
    exit 1
fi

echo -e "${BLUE}INFO:${NC} Reloading systemd manager configuration..."
if sudo systemctl daemon-reload; then
    echo -e "${GREEN}SUCCESS:${NC} Systemd daemon reloaded successfully."
else
    echo -e "${RED}ERROR:${NC} Failed to reload systemd daemon."
fi

echo "===== Finished: $(date '+%Y-%m-%d %H:%M:%S') ====="
exit 0
