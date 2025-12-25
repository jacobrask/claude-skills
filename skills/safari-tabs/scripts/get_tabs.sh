#!/bin/bash
# get_tabs.sh - Get all Safari tabs in JSON format
# Usage: ./get_tabs.sh

osascript -e '
use framework "Foundation"
use scripting additions

tell application "Safari"
    set tabData to current application'"'"'s NSMutableArray'"'"'s new()
    
    set windowIndex to 1
    repeat with w in windows
        set tabIndex to 1
        repeat with t in tabs of w
            set tabInfo to current application'"'"'s NSDictionary'"'"'s dictionaryWithObjectsAndKeys_(¬
                windowIndex, "window", ¬
                tabIndex, "tab", ¬
                (URL of t), "url", ¬
                (name of t), "title")
            (tabData'"'"'s addObject:tabInfo)
            set tabIndex to tabIndex + 1
        end repeat
        set windowIndex to windowIndex + 1
    end repeat
    
    set jsonData to current application'"'"'s NSJSONSerialization'"'"'s dataWithJSONObject:tabData options:1 |error|:(missing value)
    set jsonString to current application'"'"'s NSString'"'"'s alloc()'"'"'s initWithData:jsonData encoding:(current application'"'"'s NSUTF8StringEncoding)
    return jsonString as text
end tell'
