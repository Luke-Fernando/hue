#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo "Installing Hue..."

if [ ! -f "src/hue.sh" ]; then
    echo -e "${RED}Error: src/hue.sh not found!${NC}"
    exit 1
fi

chmod +x src/hue.sh

if sudo cp src/hue.sh /usr/local/bin/hue; then
    echo -e "${GREEN}SnapQL installed successfully!${NC}"
else
    echo -e "${RED}Error: Failed to install Hue!${NC}"
    exit 1
fi