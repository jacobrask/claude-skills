#!/bin/bash
# open_urls.sh - Open URLs in Safari from a file or stdin
# Usage: ./open_urls.sh [file]
#        echo "url1\nurl2" | ./open_urls.sh
#        ./open_urls.sh urls.txt
# Options:
#   --new-window    Open in a new window (default: current window)
#   --background    Don't activate Safari

new_window=false
background=false
file=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --new-window)
            new_window=true
            shift
            ;;
        --background)
            background=true
            shift
            ;;
        *)
            file="$1"
            shift
            ;;
    esac
done

# Read URLs from file or stdin
if [ -n "$file" ] && [ -f "$file" ]; then
    urls=$(cat "$file")
elif [ ! -t 0 ]; then
    urls=$(cat)
else
    echo "Usage: $0 [--new-window] [--background] [file]"
    echo "       echo 'url1' | $0"
    exit 1
fi

# Extract URLs (handle markdown links, plain URLs, etc.)
clean_urls=$(echo "$urls" | grep -oE 'https?://[^[:space:]"\)>]+' | sort -u)

count=$(echo "$clean_urls" | grep -c "http")

if [ "$count" -eq 0 ]; then
    echo "No URLs found"
    exit 1
fi

echo "Opening $count URL(s)..."

first=true
while IFS= read -r url; do
    [ -z "$url" ] && continue
    
    if [ "$new_window" = true ] && [ "$first" = true ]; then
        osascript -e "tell application \"Safari\" to make new document with properties {URL:\"$url\"}"
        first=false
    else
        osascript -e "tell application \"Safari\" to make new tab at end of tabs of front window with properties {URL:\"$url\"}"
    fi
done <<< "$clean_urls"

if [ "$background" = false ]; then
    osascript -e 'tell application "Safari" to activate'
fi

echo "Done."
