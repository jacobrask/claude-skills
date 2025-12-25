#!/bin/bash
# close_by_pattern.sh - Close Safari tabs matching a URL pattern
# Usage: ./close_by_pattern.sh "pattern"
# Example: ./close_by_pattern.sh "reddit.com"

pattern="$1"

if [ -z "$pattern" ]; then
    echo "Usage: $0 <url-pattern>"
    exit 1
fi

osascript -e "
tell application \"Safari\"
    set closedCount to 0
    repeat with w in windows
        set tabsToClose to {}
        repeat with t in tabs of w
            if URL of t contains \"$pattern\" then
                set end of tabsToClose to t
            end if
        end repeat
        repeat with t in tabsToClose
            close t
            set closedCount to closedCount + 1
        end repeat
    end repeat
    return closedCount
end tell"
