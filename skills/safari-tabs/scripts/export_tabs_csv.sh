#!/bin/bash
# export_tabs_csv.sh - Export Safari tabs to CSV
# Usage: ./export_tabs_csv.sh

echo "window,index,domain,title,url"

osascript -e '
tell application "Safari"
    set output to ""
    set windowIndex to 1
    repeat with w in windows
        set tabIndex to 1
        repeat with t in tabs of w
            set tabURL to URL of t
            set tabTitle to name of t
            
            -- Extract domain
            set tid to AppleScript'\''s text item delimiters
            set AppleScript'\''s text item delimiters to "//"
            try
                set domainPart to text item 2 of tabURL
                set AppleScript'\''s text item delimiters to "/"
                set theDomain to text item 1 of domainPart
            on error
                set theDomain to ""
            end try
            set AppleScript'\''s text item delimiters to tid
            
            -- Escape quotes in title for CSV
            set AppleScript'\''s text item delimiters to "\""
            set titleParts to text items of tabTitle
            set AppleScript'\''s text item delimiters to "\"\""
            set escapedTitle to titleParts as text
            set AppleScript'\''s text item delimiters to ""
            
            set output to output & windowIndex & "," & tabIndex & ",\"" & theDomain & "\",\"" & escapedTitle & "\",\"" & tabURL & "\"" & linefeed
            set tabIndex to tabIndex + 1
        end repeat
        set windowIndex to windowIndex + 1
    end repeat
    return output
end tell'
