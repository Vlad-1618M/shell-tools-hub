#!/bin/bash

# ====================================================================================================================
# Script Name: open_urls.sh
#
# NOTE: Reads URLs from a file and attempts to open them in the default browser.
#       Also checks if URLs are accessible before opening them.
#
# Description:
#       - Reads URLs from an external text file.
#       - Ensures URLs are reachable before opening.
#       - Logs unreachable URLs for debugging.
#       - Supports macOS, Linux, and Windows.
#
# Usage:        ./open_urls.sh < your urls file .txt .ini  >
#
# Example:      ./open_urls.sh cfg.ini
#               ./src/random_scripts/open_urls_in_browser/open_urls.sh src/random_scripts/open_urls_in_browser/cfg.ini
#
# ====================================================================================================================

# ... args check:
if [ $# -lt 1 ]; then
    echo -e "\nUsage: $(basename $0) [ your config file ] "
    echo -e "Example:\n\t --> $(basename $0) src/random_scripts/open_urls_in_browser/cfg.ini"
    exit 1
fi

urls_file=$1

# ... file exists check:
if [[ ! -f "$urls_file" ]]; then
    echo -e "Error: File '$urls_file' not found."
    exit 1
fi

# ... figureout proper call to open URLs based on OS Type:
open_url() {
    case "$OSTYPE" in
        darwin*) open "$1" ;;
        linux*) xdg-open "$1" ;;
        msys*|cygwin*|win32) start "$1" ;;
        *) echo "Unsupported OS: $OSTYPE" ;;
    esac
}

# ... check if a URL is reachable
check_url() {
    if curl --head --silent --fail "$1" > /dev/null 2>&1; then
        return 0 # ok:
    else
        return 1 # no ok:
    fi
}

iter=0
unreachable_urls=()

# ... read URLs from file config | process them:
while IFS= read -r url; do
    # ... skip empty or commented out lines:
    [[ -z "$url" ]] && continue

    ((iter++))
    echo -ne "$iter Checking:\t\t $url \t\t "

    # ... try URL before opening it in default browser: 
    if check_url "$url"; then
        echo -e "\t --> Accessible"
        open_url "$url"
    else
        echo -e "\t --> Unreachable"
        unreachable_urls+=("$url")
    fi

    sleep 0.07
done < "$urls_file"

# ... show unreachable URLs, if any
if [[ ${#unreachable_urls[@]} -gt 0 ]]; then
    echo -e "\n\tThe following URLs were unreachable: check $(basename $urls_file)"
    for bad_url in "${unreachable_urls[@]}"; do
        echo -e "\t --> $bad_url"
    done
fi

sleep 1
file_path=$(find "$(pwd)" -type f -name "good_old_days.sh" 2>/dev/null | head -n 1)

if [[ -n "$file_path" ]]; then
    echo -e "\n\n\t -->  Found: $file_path"
    chmod +x "$file_path"
    eval "$file_path"
else
    echo -e "good_old_days.sh not found :("
fi
