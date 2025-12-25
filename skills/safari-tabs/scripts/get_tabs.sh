#!/bin/bash
# get_tabs.sh - Get Safari tabs with flexible filtering and formatting
# Usage:
#   ./get_tabs.sh [options] [format]
#
# Options:
#   -w, --window N         Get tabs from window N only
#   -m, --match "text"     Get tabs from window containing "text" in any tab title
#
# Formats:
#   tsv (default)         Tab-separated: window<tab>index<tab>url<tab>title
#   markdown              Markdown links: - [title](url)
#   json                  JSON array of tab objects
#
# Examples:
#   ./get_tabs.sh                          # All tabs as TSV
#   ./get_tabs.sh markdown                 # All tabs as markdown
#   ./get_tabs.sh -w 1 markdown            # Window 1 as markdown
#   ./get_tabs.sh --match "Handbook" json  # Window with "Handbook" tab as JSON

set -e

# Parse arguments
window_num=""
match_text=""
format="tsv"

while [ $# -gt 0 ]; do
    case "$1" in
        -w|--window)
            window_num="$2"
            shift 2
            ;;
        -m|--match)
            match_text="$2"
            shift 2
            ;;
        tsv|markdown|json)
            format="$1"
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [options] [format]"
            echo ""
            echo "Options:"
            echo "  -w, --window N         Get tabs from window N only"
            echo "  -m, --match \"text\"     Get tabs from window containing \"text\""
            echo ""
            echo "Formats: tsv (default), markdown, json"
            echo ""
            echo "Examples:"
            echo "  $0                          # All tabs as TSV"
            echo "  $0 markdown                 # All tabs as markdown"
            echo "  $0 -w 1 markdown            # Window 1 as markdown"
            echo "  $0 --match \"Handbook\" json  # Window with \"Handbook\" as JSON"
            exit 0
            ;;
        *)
            echo "Unknown argument: $1" >&2
            echo "Use --help for usage information" >&2
            exit 1
            ;;
    esac
done

# Get all tabs (using simple TSV format for parsing)
all_tabs=$(osascript -e '
tell application "Safari"
    set output to ""
    set windowIndex to 1
    repeat with w in windows
        set tabIndex to 1
        repeat with t in tabs of w
            set tabURL to URL of t
            set tabName to name of t
            -- Escape tabs in title
            set AppleScript'"'"'s text item delimiters to tab
            set tabName to text items of tabName
            set AppleScript'"'"'s text item delimiters to " "
            set tabName to tabName as text
            set AppleScript'"'"'s text item delimiters to ""

            set output to output & windowIndex & tab & tabIndex & tab & tabURL & tab & tabName & linefeed
            set tabIndex to tabIndex + 1
        end repeat
        set windowIndex to windowIndex + 1
    end repeat
    return output
end tell')

# Filter tabs if requested
if [ -n "$match_text" ]; then
    # Find window containing the matching text
    window_num=$(echo "$all_tabs" | grep -i "$match_text" | head -1 | awk -F'tab' '{print $1}')
    if [ -z "$window_num" ]; then
        echo "Error: No window found with tab matching '$match_text'" >&2
        exit 1
    fi
fi

if [ -n "$window_num" ]; then
    filtered_tabs=$(echo "$all_tabs" | awk -F'tab' -v win="$window_num" '$1 == win')
else
    filtered_tabs="$all_tabs"
fi

# Output in requested format
case "$format" in
    tsv)
        echo "$filtered_tabs"
        ;;

    markdown)
        echo "$filtered_tabs" | awk -F'tab' '{
            if ($3 != "") {
                printf "- [%s](%s)\n", $4, $3
            }
        }'
        ;;

    json)
        echo "["
        first=1
        while IFS= read -r line; do
            if [ -n "$line" ]; then
                window=$(echo "$line" | awk -F'tab' '{print $1}')
                tab=$(echo "$line" | awk -F'tab' '{print $2}')
                url=$(echo "$line" | awk -F'tab' '{print $3}')
                title=$(echo "$line" | awk -F'tab' '{print $4}')

                if [ -n "$url" ]; then
                    if [ $first -eq 0 ]; then
                        echo ","
                    fi
                    first=0
                    # Escape quotes in title and URL for JSON
                    title_escaped=$(echo "$title" | sed 's/"/\\"/g')
                    url_escaped=$(echo "$url" | sed 's/"/\\"/g')
                    printf '  {"window": %d, "tab": %d, "url": "%s", "title": "%s"}' "$window" "$tab" "$url_escaped" "$title_escaped"
                fi
            fi
        done <<< "$filtered_tabs"
        echo ""
        echo "]"
        ;;

    *)
        echo "Unknown format: $format" >&2
        echo "Available formats: tsv, markdown, json" >&2
        exit 1
        ;;
esac
