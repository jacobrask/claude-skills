#!/bin/bash
# export_tabs_html.sh - Export Safari tabs as HTML bookmarks file
# Usage: ./export_tabs_html.sh
# Output is compatible with browser bookmark import

date_str=$(date "+%Y-%m-%d %H:%M:%S")
timestamp=$(date "+%s")

cat << 'HEADER'
<!DOCTYPE NETSCAPE-Bookmark-file-1>
<!-- This is an automatically generated file.
     It will be read and overwritten.
     DO NOT EDIT! -->
<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">
<TITLE>Safari Tabs Export</TITLE>
<H1>Safari Tabs Export</H1>
HEADER

echo "<DL><p>"

osascript -e '
tell application "Safari"
    set output to ""
    set windowIndex to 1
    repeat with w in windows
        set output to output & "WINDOW:" & windowIndex & linefeed
        repeat with t in tabs of w
            set tabURL to URL of t
            set tabTitle to name of t
            -- Basic HTML entity escaping
            set AppleScript'\''s text item delimiters to "&"
            set titleParts to text items of tabTitle
            set AppleScript'\''s text item delimiters to "&amp;"
            set tabTitle to titleParts as text
            set AppleScript'\''s text item delimiters to "<"
            set titleParts to text items of tabTitle
            set AppleScript'\''s text item delimiters to "&lt;"
            set tabTitle to titleParts as text
            set AppleScript'\''s text item delimiters to ">"
            set titleParts to text items of tabTitle
            set AppleScript'\''s text item delimiters to "&gt;"
            set tabTitle to titleParts as text
            set AppleScript'\''s text item delimiters to ""
            
            set output to output & "TAB:" & tabURL & "	" & tabTitle & linefeed
        end repeat
        set windowIndex to windowIndex + 1
    end repeat
    return output
end tell' | while IFS= read -r line; do
    if [[ "$line" == WINDOW:* ]]; then
        window_num="${line#WINDOW:}"
        echo "    <DT><H3 ADD_DATE=\"$timestamp\">Window $window_num</H3>"
        echo "    <DL><p>"
    elif [[ "$line" == TAB:* ]]; then
        tab_data="${line#TAB:}"
        url="${tab_data%%	*}"
        title="${tab_data#*	}"
        if [ -n "$url" ]; then
            echo "        <DT><A HREF=\"$url\" ADD_DATE=\"$timestamp\">$title</A>"
        fi
    fi
done

# Close any open DL tags
echo "    </DL><p>"
echo "</DL><p>"
