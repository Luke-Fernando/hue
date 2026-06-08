#!/bin/bash

declare -r VERSION="1.0.0"

GLOBAL_HUE=()
CURRENT_HUE=()
GLOBAL_UPDATE=true

declare -A MAIN_COLORS=([black]=0 [red]=1 [green]=2 [yellow]=3 [blue]=4 [magenta]=5 [cyan]=6 [white]=7)
declare -A TEXT_MODIFIERS=([bold]=1 [dim]=2 [italic]=3 [underline]=4 [invert]=7)

show_version() {
    echo "Hue version $VERSION"
    exit 0
}

print_rainbow_banner() {
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

    while IFS= read -r -n1 char; do
        if [[ "$char" == "" ]]; then
            echo "" # New line
        else
            printf "\e[38;5;%sm%s" "${colors[$i % ${#colors[@]}]}" "$char"
            ((i++))
        fi
    done <<< "$logo"
    printf "\e[0m\n"
}

show_help() {
    print_rainbow_banner
    echo -e "\e[1;36mUsage:\e[0m hue [modifier] [text] ..."
    echo ""
    echo -e "\e[1mMODIFIERS:\e[0m"
    echo "  :bold, :dim, :italic, :underline, :invert"
    echo "  :text-<color>         (e.g., :text-red, :text-blue-bright)"
    echo "  :bg-<color>           (e.g., :bg-green, :bg-black-bright)"
    echo "  :reset                Clears all styles"
    echo ""
    echo -e "\e[1mNEGATION:\e[0m"
    echo "  .bold, .text-red      Removes a specific style from the global state"
    echo ""
    echo -e "\e[1mOPTIONS:\e[0m"
    echo "  -h, --help            Show this help message"
    echo "  -v, --version         Show version information"
    echo ""
    echo -e "\e[1mEXAMPLES:\e[0m"
    echo '  hue :bold :text-red "Error:" "Something went wrong"'
    echo '  hue :text-green "Success" .text-green :text-white "Done"'
    exit 0
}

calc_hue() {
    local color="$1"
    local offset="$2"
    local bright=0
    
    [[ "$color" == *"-bright" ]] && bright=60 && color="${color%-bright}"
    
    if [[ -v MAIN_COLORS["$color"] ]]; then
        echo $(( offset + ${MAIN_COLORS[$color]:-9} + bright ))
    fi
}

parse_style() {
    local result_codes=()
    
    for item in "$@"; do
        local hue="${item:1}"
        local code=""
        
        if [[ -v TEXT_MODIFIERS[$hue] ]]; then
            code="${TEXT_MODIFIERS[$hue]}"
            
            elif [[ "$hue" == text-* ]]; then
            code=$(calc_hue "${hue#text-}" 30)
            
            elif [[ "$hue" == bg-* ]]; then
            code=$(calc_hue "${hue#bg-}" 40)
            
            elif [[ "$hue" == reset ]]; then
            code="0"
        fi
        [[ -n "$code" ]] && result_codes+=("$code")
    done
    ( IFS=';'; echo "${result_codes[*]}" )
}

debug_state() {
    echo "--- DEBUG ---"
    declare -p GLOBAL_HUE
    declare -p CURRENT_HUE
    declare -p MAIN_COLORS
    echo "GLOBAL_UPDATE: $GLOBAL_UPDATE"
    echo "-------------"
}

function join_by {
  local d=${1-} f=${2-}
  if shift 2; then
    printf %s "$f" "${@/#/$d}"
  fi
}

proccess_input() {
    local inputs=("$@")
    local args=()
    local buffer=""

    flush_buffer() {
        if [[ -n "$buffer" ]]; then
            args+=("$buffer")
            buffer=""
        fi
    }

    for input in "${inputs[@]}"; do
        while [[ "$input" =~ ([\:\.][a-zA-Z0-9_-]+) ]]; do
            prefix="${input%%${BASH_REMATCH[1]}*}"
            util="${BASH_REMATCH[1]}"
            suffix="${input#*${BASH_REMATCH[1]}}"
            suffix="${suffix#${suffix%%[![:space:]]*}}"

            buffer+="$prefix"
            flush_buffer

            args+=("$util")

            input="$suffix"
        done
        buffer+="$input"
    done
    flush_buffer 
    hue "${args[@]}"
}

handle_pipe() {
    if [ ! -t 0 ]; then
        local first=1
        while IFS= read -r line ; do
            if [ -n "$line" ]; then
                if (( first )); then
                    first=0
                else
                    printf '\n'
                fi            
                proccess_input "$line"
            fi
        done
    fi
}



[[ $# -eq 0 && -t 0 ]] && show_help
filter_array() {
    local -n arr=$1
    local search=$2
    local temp=()
    for item in "${arr[@]}"; do
        [[ "$item" != "$search" ]] && temp+=("$item")
    done
    arr=("${temp[@]}")
}

add_styles() {
    local arg="$1"
    if [[ "$GLOBAL_UPDATE" == true ]]; then
        GLOBAL_HUE+=("$arg")
    fi
    CURRENT_HUE+=("$arg")
}

remove_styles() {
    local arg="$1"
    target=":${arg:1}"
    if [[ "$GLOBAL_UPDATE" == true ]]; then
        filter_array GLOBAL_HUE "$target"
    fi
    filter_array CURRENT_HUE "$target"
}

apply_hue() {
    active_styles=$(parse_style "${CURRENT_HUE[@]}")
    if [[ -n "$active_styles" ]]; then
        printf "\e[%sm%s\e[0m" "$active_styles" "$argument"
    else
        printf "%s" "$argument"
    fi
}

hue() {
    for argument in "$@"; do

        case "$argument" in
            -h|--help)    show_help ;;
            -v|--version) show_version ;;
        esac

        first_char="${argument:0:1}"

        if [[ -n "$NO_COLOR" ]]; then
            [[ "$first_char" != ":" && "$first_char" != "." ]] && printf "%s " "$argument"
            continue
        fi

        if [[ "$first_char" == ":" ]]; then
            add_styles "$argument"

        elif [[ "$first_char" == "." ]]; then
            remove_styles "$argument"

        else
            GLOBAL_UPDATE=false
            apply_hue 
            CURRENT_HUE=("${GLOBAL_HUE[@]}")
        fi
    done
}


hue "$@"
GLOBAL_UPDATE=false
handle_pipe
printf "\e[0m\n"
