#!/bin/bash
# get_tabs_tsv.sh - Get all Safari tabs in TSV format
# Usage: ./get_tabs_tsv.sh
# Output: window<tab>tabindex<tab>url<tab>title (one per line)

osascript -e '
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
end tell'
