#!/bin/bash
# get_events.sh - Get calendar events with flexible filtering and formatting
# Usage:
#   ./get_events.sh [options] [format]
#
# Options:
#   --today              Get today's events
#   --week               Get next 7 days
#   --days N             Get next N days
#   -c, --calendar NAME  Filter by calendar name
#
# Formats:
#   tsv (default)        Tab-separated values
#   markdown             Markdown formatted list
#   json                 JSON array
#
# Examples:
#   ./get_events.sh                    # Today's events as TSV
#   ./get_events.sh markdown           # Today's events as markdown
#   ./get_events.sh --week markdown    # Next 7 days
#   ./get_events.sh --days 14 json     # Next 14 days as JSON
#   ./get_events.sh -c "Work" markdown # Work calendar only

set -e

# Default values
days=0  # 0 means today only
calendar_filter=""
format="tsv"

# Parse arguments
while [ $# -gt 0 ]; do
    case "$1" in
        --today)
            days=0
            shift
            ;;
        --week)
            days=7
            shift
            ;;
        --days)
            days="$2"
            shift 2
            ;;
        -c|--calendar)
            calendar_filter="$2"
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
            echo "  --today              Get today's events"
            echo "  --week               Get next 7 days"
            echo "  --days N             Get next N days"
            echo "  -c, --calendar NAME  Filter by calendar name"
            echo ""
            echo "Formats: tsv (default), markdown, json"
            exit 0
            ;;
        *)
            echo "Unknown argument: $1" >&2
            exit 1
            ;;
    esac
done

# Build AppleScript
if [ -n "$calendar_filter" ]; then
    # Query specific calendar
    applescript="
tell application \"Calendar\"
    set theCalendar to calendar \"$calendar_filter\"
    set todayStart to (current date) - (time of (current date))
    set todayEnd to todayStart + ($days * days) + (24 * hours) - 1

    set eventList to {}
    set theEvents to every event of theCalendar whose start date ≥ todayStart and start date ≤ todayEnd

    repeat with anEvent in theEvents
        set calName to name of theCalendar
        set eventTitle to summary of anEvent
        set eventStart to start date of anEvent
        set eventEnd to end date of anEvent
        set eventLoc to location of anEvent
        set eventDesc to description of anEvent

        set eventInfo to calName & \"|\" & eventTitle & \"|\" & eventStart & \"|\" & eventEnd & \"|\" & eventLoc & \"|\" & eventDesc
        set end of eventList to eventInfo
    end repeat

    set AppleScript's text item delimiters to linefeed
    set output to eventList as text
    set AppleScript's text item delimiters to \"\"
    return output
end tell
"
else
    # Query all calendars
    applescript="
tell application \"Calendar\"
    set todayStart to (current date) - (time of (current date))
    set todayEnd to todayStart + ($days * days) + (24 * hours) - 1

    set eventList to {}

    repeat with aCalendar in calendars
        set calName to name of aCalendar
        set theEvents to every event of aCalendar whose start date ≥ todayStart and start date ≤ todayEnd

        repeat with anEvent in theEvents
            set eventTitle to summary of anEvent
            set eventStart to start date of anEvent
            set eventEnd to end date of anEvent
            set eventLoc to location of anEvent
            set eventDesc to description of anEvent

            set eventInfo to calName & \"|\" & eventTitle & \"|\" & eventStart & \"|\" & eventEnd & \"|\" & eventLoc & \"|\" & eventDesc
            set end of eventList to eventInfo
        end repeat
    end repeat

    set AppleScript's text item delimiters to linefeed
    set output to eventList as text
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
            echo "No events found"
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
