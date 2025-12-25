#!/bin/bash
# export_tabs_json.sh - Export Safari tabs to JSON
# Usage: ./export_tabs_json.sh

osascript -e '
use framework "Foundation"
use scripting additions

tell application "Safari"
    set tabData to current application'\''s NSMutableArray'\''s new()
    
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
            
            set tabInfo to current application'\''s NSDictionary'\''s dictionaryWithObjectsAndKeys_(¬
                windowIndex, "window", ¬
                tabIndex, "index", ¬
                tabURL, "url", ¬
                tabTitle, "title", ¬
                theDomain, "domain")
            (tabData'\''s addObject:tabInfo)
            set tabIndex to tabIndex + 1
        end repeat
        set windowIndex to windowIndex + 1
    end repeat
    
    set exportData to current application'\''s NSDictionary'\''s dictionaryWithObjectsAndKeys_(¬
        (current date) as text, "exportDate", ¬
        (count of windows), "windowCount", ¬
        (count of tabData), "tabCount", ¬
        tabData, "tabs")
    
    set jsonData to current application'\''s NSJSONSerialization'\''s dataWithJSONObject:exportData options:1 |error|:(missing value)
    set jsonString to current application'\''s NSString'\''s alloc()'\''s initWithData:jsonData encoding:(current application'\''s NSUTF8StringEncoding)
    return jsonString as text
end tell'
