#!/bin/bash
# create_event.sh - Create a new calendar event
# Usage:
#   ./create_event.sh TITLE START_DATE END_DATE [CALENDAR] [LOCATION] [DESCRIPTION]
#
# Date Format: YYYY-MM-DD HH:MM (24-hour format)
#
# Examples:
#   ./create_event.sh "Team Meeting" "2025-12-26 14:00" "2025-12-26 15:00"
#   ./create_event.sh "Lunch" "2025-12-27 12:00" "2025-12-27 13:00" "Work"
#   ./create_event.sh "Conference" "2025-12-28 09:00" "2025-12-28 17:00" "Work" "San Francisco" "Annual conference"

set -e

# Check required arguments
if [ $# -lt 3 ]; then
    echo "Usage: $0 TITLE START_DATE END_DATE [CALENDAR] [LOCATION] [DESCRIPTION]" >&2
    echo "" >&2
    echo "Date Format: YYYY-MM-DD HH:MM (24-hour format)" >&2
    echo "" >&2
    echo "Examples:" >&2
    echo "  $0 \"Team Meeting\" \"2025-12-26 14:00\" \"2025-12-26 15:00\"" >&2
    echo "  $0 \"Lunch\" \"2025-12-27 12:00\" \"2025-12-27 13:00\" \"Work\"" >&2
    exit 1
fi

title="$1"
start_date="$2"
end_date="$3"
calendar="${4:-Calendar}"  # Default to "Calendar" if not specified
location="${5:-}"
description="${6:-}"

# Parse date components from YYYY-MM-DD HH:MM format
parse_date() {
    local input_date="$1"
    # Validate format first
    if ! date -j -f "%Y-%m-%d %H:%M" "$input_date" > /dev/null 2>&1; then
        echo "Error: Invalid date format '$input_date'. Expected: YYYY-MM-DD HH:MM" >&2
        exit 1
    fi

    # Extract components
    local year=$(date -j -f "%Y-%m-%d %H:%M" "$input_date" "+%Y")
    local month=$(date -j -f "%Y-%m-%d %H:%M" "$input_date" "+%-m")
    local day=$(date -j -f "%Y-%m-%d %H:%M" "$input_date" "+%-d")
    local hour=$(date -j -f "%Y-%m-%d %H:%M" "$input_date" "+%-H")
    local minute=$(date -j -f "%Y-%m-%d %H:%M" "$input_date" "+%-M")

    echo "$year $month $day $hour $minute"
}

read start_year start_month start_day start_hour start_minute <<< $(parse_date "$start_date")
read end_year end_month end_day end_hour end_minute <<< $(parse_date "$end_date")

# Escape quotes in strings for AppleScript
escape_for_applescript() {
    echo "$1" | sed 's/"/\\"/g'
}

title_esc=$(escape_for_applescript "$title")
location_esc=$(escape_for_applescript "$location")
description_esc=$(escape_for_applescript "$description")

# Build AppleScript - construct dates from components to avoid locale issues
applescript="
tell application \"Calendar\"
    set theCalendar to calendar \"$calendar\"

    -- Build start date from components
    set startDate to current date
    set year of startDate to $start_year
    set month of startDate to $start_month
    set day of startDate to $start_day
    set hours of startDate to $start_hour
    set minutes of startDate to $start_minute
    set seconds of startDate to 0

    -- Build end date from components
    set endDate to current date
    set year of endDate to $end_year
    set month of endDate to $end_month
    set day of endDate to $end_day
    set hours of endDate to $end_hour
    set minutes of endDate to $end_minute
    set seconds of endDate to 0

    make new event at end of events of theCalendar with properties {summary:\"$title_esc\", start date:startDate, end date:endDate, description:\"$description_esc\", location:\"$location_esc\"}
end tell
"

# Execute AppleScript
if osascript -e "$applescript" > /dev/null 2>&1; then
    echo "Event created successfully!"
    echo "  Calendar: $calendar"
    echo "  Title: $title"
    echo "  Start: $start_date"
    echo "  End: $end_date"
    if [ -n "$location" ]; then
        echo "  Location: $location"
    fi
    if [ -n "$description" ]; then
        echo "  Description: $description"
    fi
else
    echo "Error: Failed to create event" >&2
    echo "Check that calendar '$calendar' exists" >&2
    exit 1
fi
