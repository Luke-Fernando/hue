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

show_help() {
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

[[ $# -eq 0 ]] && show_help

for argument in "$@"; do
    
    case "$argument" in
        -h|--help)    show_help ;;
        -v|--version) show_version ;;
    esac
    
    if [[ -n "$NO_COLOR" ]]; then
        [[ "${argument:0:1}" != ":" && "${argument:0:1}" != "." ]] && printf "%s " "$argument"
        continue
    fi
    
    
    first_char="${argument:0:1}"
    
    if [[ "$first_char" == ":" ]]; then
        if [[ "$GLOBAL_UPDATE" == true ]]; then
            GLOBAL_HUE+=("$argument")
        fi
        CURRENT_HUE+=("$argument")
        
        elif [[ "$first_char" == "." ]]; then
        target=":${argument:1}"
        filter_array() {
            local -n arr=$1
            local search=$2
            local temp=()
            for item in "${arr[@]}"; do
                [[ "$item" != "$search" ]] && temp+=("$item")
            done
            arr=("${temp[@]}")
        }
        
        if [[ "$GLOBAL_UPDATE" == true ]]; then
            filter_array GLOBAL_HUE "$target"
        fi
        filter_array CURRENT_HUE "$target"
    else
        GLOBAL_UPDATE=false
        active_styles=$(parse_style "${CURRENT_HUE[@]}")
        
        if [[ -n "$active_styles" ]]; then
            printf "\e[%sm%s\e[0m" "$active_styles" "$argument"
        else
            printf "%s" "$argument"
        fi
        
        CURRENT_HUE=("${GLOBAL_HUE[@]}")
    fi
done

printf "\e[0m\n"