#!/bin/bash
# export_tabs_markdown.sh - Export Safari tabs to markdown
# Usage: ./export_tabs_markdown.sh [format]
# Formats: list (default), table, checklist, grouped

format="${1:-list}"

tabs=$(osascript -e '
tell application "Safari"
    set output to ""
    set windowIndex to 1
    repeat with w in windows
        set tabIndex to 1
        repeat with t in tabs of w
            set tabURL to URL of t
            set tabName to name of t
            -- Escape pipes and brackets for markdown
            set AppleScript'\''s text item delimiters to "|"
            set tabName to text items of tabName
            set AppleScript'\''s text item delimiters to "\\|"
            set tabName to tabName as text
            set AppleScript'\''s text item delimiters to ""
            
            set output to output & windowIndex & "	" & tabIndex & "	" & tabURL & "	" & tabName & linefeed
            set tabIndex to tabIndex + 1
        end repeat
        set windowIndex to windowIndex + 1
    end repeat
    return output
end tell')

date_str=$(date "+%Y-%m-%d %H:%M")

case "$format" in
    list)
        echo "# Safari Tabs - $date_str"
        echo ""
        current_window=""
        echo "$tabs" | while IFS=$'\t' read -r window tab url title; do
            if [ -n "$url" ]; then
                if [ "$window" != "$current_window" ]; then
                    [ -n "$current_window" ] && echo ""
                    echo "## Window $window"
                    echo ""
                    current_window="$window"
                fi
                echo "- [$title]($url)"
            fi
        done
        ;;
    
    table)
        echo "# Safari Tabs - $date_str"
        echo ""
        echo "| Window | Title | URL |"
        echo "|--------|-------|-----|"
        echo "$tabs" | while IFS=$'\t' read -r window tab url title; do
            if [ -n "$url" ]; then
                echo "| $window | $title | $url |"
            fi
        done
        ;;
    
    checklist)
        echo "# Safari Tabs - $date_str"
        echo ""
        echo "Review and check off tabs to close:"
        echo ""
        echo "$tabs" | while IFS=$'\t' read -r window tab url title; do
            if [ -n "$url" ]; then
                echo "- [ ] [$title]($url)"
            fi
        done
        ;;
    
    grouped)
        echo "# Safari Tabs - $date_str"
        echo ""
        echo "$tabs" | while IFS=$'\t' read -r window tab url title; do
            if [ -n "$url" ]; then
                # Extract domain
                domain=$(echo "$url" | sed -E 's|https?://([^/]+).*|\1|' | sed 's/^www\.//')
                echo "$domain	$title	$url"
            fi
        done | sort | awk -F'\t' '
        BEGIN { current_domain = "" }
        {
            if ($1 != current_domain) {
                if (current_domain != "") print ""
                print "## " $1
                print ""
                current_domain = $1
            }
            print "- [" $2 "](" $3 ")"
        }'
        ;;
    
    *)
        echo "Unknown format: $format"
        echo "Available formats: list, table, checklist, grouped"
        exit 1
        ;;
esac
