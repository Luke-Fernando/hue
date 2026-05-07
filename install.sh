#!/bin/bash

RED='\033[0;31m'
NC='\033[0m'

print_rainbow_benner() {
    local logo='                                                  
▄▄▄▄  ▄▄▄  ▄▄▄▄      ▄▄
▀███  ███  ███▀      ██
 ███  ███  ███ ▄█▀█▄ ██ ▄████ ▄███▄ ███▄███▄ ▄█▀█▄
 ███▄▄███▄▄███ ██▄█▀ ██ ██    ██ ██ ██ ██ ██ ██▄█▀
  ▀████▀████▀  ▀█▄▄▄ ██ ▀████ ▀███▀ ██ ██ ██ ▀█▄▄▄
                     ██        
                    ▀██▀▀ ▄███▄
                     ██   ██ ██
                     ██   ▀███▀
              ▄▄▄   ▄▄▄
              ███   ███
              █████████ ██ ██ ▄█▀█▄
              ███▀▀▀███ ██ ██ ██▄█▀
              ███   ███ ▀██▀█ ▀█▄▄▄ 
                                                    
'
    local colors=(196 202 208 214 220 226 190 154 118 82 46 47 48 49 50 51 45 39 33 27 21 57 93 129 165 201)
    local i=0

    # Loop through the logo character by character
    while IFS= read -r -n1 char; do
        if [[ "$char" == "" ]]; then
            echo "" # New line
        else
            # Print the character with a color from our array
            printf "\e[38;5;%sm%s" "${colors[$i % ${#colors[@]}]}" "$char"
            ((i++))
        fi
    done <<< "$logo"
    printf "\e[0m\n" # Reset color at the end
}

echo "Installing Hue styling engine..."

if [ ! -f "src/hue.sh" ]; then
    echo -e "${RED}Error: src/hue.sh not found!${NC}"
    exit 1
fi

chmod +x src/hue.sh

if sudo cp src/hue.sh /usr/local/bin/hue; then
    print_rainbow_benner
else
    echo -e "${RED}Installation failed. Check permissions.${NC}"
    exit 1
fi