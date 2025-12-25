#!/bin/bash
# find_duplicates.sh - Find duplicate tabs in Safari
# Usage: ./find_duplicates.sh [--close]
# With --close flag, closes duplicate tabs (keeps first occurrence)

close_mode=false
if [ "$1" == "--close" ]; then
    close_mode=true
fi

# Get all tabs
tabs=$(osascript -e '
tell application "Safari"
    set output to ""
    set windowIndex to 1
    repeat with w in windows
        set tabIndex to 1
        repeat with t in tabs of w
            set output to output & windowIndex & "," & tabIndex & "," & (URL of t) & "	" & (name of t) & linefeed
            set tabIndex to tabIndex + 1
        end repeat
        set windowIndex to windowIndex + 1
    end repeat
    return output
end tell')

# Find duplicates by URL
echo "=== Duplicate Tabs Analysis ==="
echo ""

declare -A url_first_seen
declare -a duplicates

while IFS=$'\t' read -r location title; do
    if [ -z "$location" ]; then continue; fi
    
    window=$(echo "$location" | cut -d',' -f1)
    tab=$(echo "$location" | cut -d',' -f2)
    url=$(echo "$location" | cut -d',' -f3-)
    
    # Normalize URL (remove trailing slash, fragment)
    normalized_url=$(echo "$url" | sed 's/#.*//' | sed 's|/$||')
    
    if [ -n "${url_first_seen[$normalized_url]}" ]; then
        echo "DUPLICATE: $title"
        echo "  URL: $url"
        echo "  Location: Window $window, Tab $tab"
        echo "  First seen: ${url_first_seen[$normalized_url]}"
        echo ""
        duplicates+=("$window,$tab")
    else
        url_first_seen[$normalized_url]="Window $window, Tab $tab"
    fi
done <<< "$tabs"

dup_count=${#duplicates[@]}

if [ $dup_count -eq 0 ]; then
    echo "No duplicate tabs found."
else
    echo "=== Summary ==="
    echo "Found $dup_count duplicate tab(s)"
    
    if [ "$close_mode" = true ]; then
        echo ""
        echo "Closing duplicates..."
        
        # Close in reverse order to preserve indices
        for ((i=${#duplicates[@]}-1; i>=0; i--)); do
            loc="${duplicates[$i]}"
            window=$(echo "$loc" | cut -d',' -f1)
            tab=$(echo "$loc" | cut -d',' -f2)
            osascript -e "tell application \"Safari\" to close tab $tab of window $window"
        done
        
        echo "Closed $dup_count duplicate tab(s)"
    else
        echo ""
        echo "Run with --close to close duplicate tabs"
    fi
fi
