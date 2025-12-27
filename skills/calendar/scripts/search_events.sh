#!/bin/bash
# search_events.sh - Search calendar events by keyword
# Usage:
#   ./search_events.sh QUERY [options] [format]
#
# Options:
#   -c, --calendar NAME  Filter by calendar name
#
# Formats:
#   tsv (default)        Tab-separated values
#   markdown             Markdown formatted list
#   json                 JSON array
#
# Examples:
#   ./search_events.sh "meeting"
#   ./search_events.sh "dentist" markdown
#   ./search_events.sh -c "Work" "standup" json

set -e

# Check required arguments
if [ $# -lt 1 ]; then
    echo "Usage: $0 QUERY [options] [format]" >&2
    echo "" >&2
    echo "Options:" >&2
    echo "  -c, --calendar NAME  Filter by calendar name" >&2
    echo "" >&2
    echo "Formats: tsv (default), markdown, json" >&2
    exit 1
fi

query="$1"
shift

calendar_filter=""
format="tsv"

# Parse remaining arguments
while [ $# -gt 0 ]; do
    case "$1" in
        -c|--calendar)
            calendar_filter="$2"
            shift 2
            ;;
        tsv|markdown|json)
            format="$1"
            shift
            ;;
        *)
            echo "Unknown argument: $1" >&2
            exit 1
            ;;
    esac
done

# Escape query for AppleScript
query_esc=$(echo "$query" | sed 's/"/\\"/g')

# Build AppleScript
if [ -n "$calendar_filter" ]; then
    # Search specific calendar
    applescript="
tell application \"Calendar\"
    set theCalendar to calendar \"$calendar_filter\"
    set matchingEvents to {}
    set allEvents to every event of theCalendar

    repeat with anEvent in allEvents
        set eventTitle to summary of anEvent
        set eventDesc to description of anEvent

        -- Check if query is in title or description
        if eventTitle contains \"$query_esc\" or eventDesc contains \"$query_esc\" then
            set calName to name of theCalendar
            set eventStart to start date of anEvent
            set eventEnd to end date of anEvent
            set eventLoc to location of anEvent

            set eventInfo to calName & \"|\" & eventTitle & \"|\" & eventStart & \"|\" & eventEnd & \"|\" & eventLoc & \"|\" & eventDesc
            set end of matchingEvents to eventInfo
        end if
    end repeat

    set AppleScript's text item delimiters to linefeed
    set output to matchingEvents as text
    set AppleScript's text item delimiters to \"\"
    return output
end tell
"
else
    # Search all calendars
    applescript="
tell application \"Calendar\"
    set matchingEvents to {}

    repeat with aCalendar in calendars
        set calName to name of aCalendar
        set allEvents to every event of aCalendar

        repeat with anEvent in allEvents
            set eventTitle to summary of anEvent
            set eventDesc to description of anEvent

            -- Check if query is in title or description
            if eventTitle contains \"$query_esc\" or eventDesc contains \"$query_esc\" then
                set eventStart to start date of anEvent
                set eventEnd to end date of anEvent
                set eventLoc to location of anEvent

                set eventInfo to calName & \"|\" & eventTitle & \"|\" & eventStart & \"|\" & eventEnd & \"|\" & eventLoc & \"|\" & eventDesc
                set end of matchingEvents to eventInfo
            end if
        end repeat
    end repeat

    set AppleScript's text item delimiters to linefeed
    set output to matchingEvents as text
    set AppleScript's text item delimiters to \"\"
    return output
end tell
"
fi

# Execute AppleScript and get results
result=$(osascript -e "$applescript")

# Handle empty results
if [ -z "$result" ] || [ "$result" = '""' ]; then
    case "$format" in
        tsv|markdown)
            echo "No events found matching '$query'"
            ;;
        json)
            echo "[]"
            ;;
    esac
    exit 0
fi

# Format output
case "$format" in
    tsv)
        while IFS='|' read -r cal title start end loc desc; do
            [ -n "$cal" ] && printf "%s\t%s\t%s\t%s\t%s\t%s\n" "$cal" "$title" "$start" "$end" "$loc" "$desc"
        done <<< "$result"
        ;;

    markdown)
        echo "# Search Results for \"$query\""
        echo ""
        while IFS='|' read -r cal title start end loc desc; do
            if [ -n "$cal" ]; then
                echo "## $title"
                echo "- Calendar: $cal"
                echo "- Start: $start"
                echo "- End: $end"
                if [ -n "$loc" ] && [ "$loc" != "missing value" ]; then
                    echo "- Location: $loc"
                fi
                if [ -n "$desc" ] && [ "$desc" != "missing value" ]; then
                    echo "- Description: $desc"
                fi
                echo ""
            fi
        done <<< "$result"
        ;;

    json)
        echo "["
        first=1
        while IFS='|' read -r cal title start end loc desc; do
            if [ -n "$cal" ]; then
                if [ $first -eq 0 ]; then
                    echo ","
                fi
                first=0

                # Escape quotes for JSON
                cal_esc=$(echo "$cal" | sed 's/"/\\"/g')
                title_esc=$(echo "$title" | sed 's/"/\\"/g')
                start_esc=$(echo "$start" | sed 's/"/\\"/g')
                end_esc=$(echo "$end" | sed 's/"/\\"/g')
                loc_esc=$(echo "$loc" | sed 's/"/\\"/g')
                desc_esc=$(echo "$desc" | sed 's/"/\\"/g')

                printf '  {"calendar": "%s", "title": "%s", "start": "%s", "end": "%s", "location": "%s", "description": "%s"}' \
                    "$cal_esc" "$title_esc" "$start_esc" "$end_esc" "$loc_esc" "$desc_esc"
            fi
        done <<< "$result"
        echo ""
        echo "]"
        ;;

    *)
        echo "Unknown format: $format" >&2
        exit 1
        ;;
esac
