#!/bin/bash
# close_tabs.sh - Close specific Safari tabs
# Usage: ./close_tabs.sh "1,2" "1,5" "2,1"  (window,tab pairs)
# Closes tabs in reverse order to preserve indices

# Build AppleScript to close tabs
script='tell application "Safari"
'

# Collect all tab references, we'll close in reverse order
tabs_to_close=""
for pair in "$@"; do
    window=$(echo "$pair" | cut -d',' -f1)
    tab=$(echo "$pair" | cut -d',' -f2)
    tabs_to_close="$tabs_to_close $window,$tab"
done

# Sort in reverse order (higher indices first) to preserve indices while closing
sorted=$(echo $tabs_to_close | tr ' ' '\n' | sort -t',' -k1,1nr -k2,2nr)

for pair in $sorted; do
    window=$(echo "$pair" | cut -d',' -f1)
    tab=$(echo "$pair" | cut -d',' -f2)
    script="$script    close tab $tab of window $window
"
done

script="$script end tell"

osascript -e "$script"
echo "Closed $(echo "$@" | wc -w | tr -d ' ') tab(s)"
