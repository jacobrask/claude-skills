#!/bin/bash
# list_calendars.sh - List all macOS calendars
# Usage:
#   ./list_calendars.sh [format]
#
# Formats:
#   tsv (default)   Tab-separated list
#   json            JSON array
#
# Examples:
#   ./list_calendars.sh
#   ./list_calendars.sh json

set -e

format="${1:-tsv}"

case "$format" in
    tsv)
        osascript -e 'tell application "Calendar" to get name of calendars' | tr ', ' '\n'
        ;;

    json)
        calendars=$(osascript -e 'tell application "Calendar" to get name of calendars')
        echo "["
        first=1
        IFS=', ' read -ra CALS <<< "$calendars"
        for cal in "${CALS[@]}"; do
            if [ $first -eq 0 ]; then
                echo ","
            fi
            first=0
            printf '  "%s"' "$cal"
        done
        echo ""
        echo "]"
        ;;

    *)
        echo "Unknown format: $format" >&2
        echo "Available formats: tsv, json" >&2
        exit 1
        ;;
esac
