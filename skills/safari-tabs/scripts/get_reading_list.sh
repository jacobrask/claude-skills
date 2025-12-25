#!/bin/bash
# get_reading_list.sh - Export Safari Reading List
# Usage: ./get_reading_list.sh [format]
# Formats: tsv (default), markdown, json

format="${1:-tsv}"

# Reading list is stored in ~/Library/Safari/Bookmarks.plist
plist_path="$HOME/Library/Safari/Bookmarks.plist"

if [ ! -f "$plist_path" ]; then
    echo "Error: Bookmarks.plist not found at $plist_path" >&2
    exit 1
fi

# Use plutil to convert and Python to parse
python3 << EOF
import plistlib
import json
import sys
from pathlib import Path

plist_path = Path.home() / "Library/Safari/Bookmarks.plist"

try:
    with open(plist_path, 'rb') as f:
        plist = plistlib.load(f)
except Exception as e:
    print(f"Error reading plist: {e}", file=sys.stderr)
    sys.exit(1)

def find_reading_list(data):
    """Recursively find the Reading List in the bookmark structure"""
    if isinstance(data, dict):
        if data.get('Title') == 'com.apple.ReadingList':
            return data.get('Children', [])
        for value in data.values():
            result = find_reading_list(value)
            if result is not None:
                return result
    elif isinstance(data, list):
        for item in data:
            result = find_reading_list(item)
            if result is not None:
                return result
    return None

reading_list = find_reading_list(plist)

if not reading_list:
    print("No reading list items found", file=sys.stderr)
    sys.exit(0)

items = []
for item in reading_list:
    url = item.get('URLString', '')
    uri_dict = item.get('URIDictionary', {})
    title = uri_dict.get('title', '')
    preview = item.get('PreviewText', '')
    date_added = item.get('ReadingList', {}).get('DateAdded', '')
    
    items.append({
        'url': url,
        'title': title,
        'preview': preview[:100] + '...' if len(preview) > 100 else preview,
        'date_added': str(date_added) if date_added else ''
    })

format_type = "$format"

if format_type == 'json':
    print(json.dumps({'reading_list': items, 'count': len(items)}, indent=2))

elif format_type == 'markdown':
    print("# Safari Reading List")
    print(f"\\n{len(items)} items\\n")
    for item in items:
        print(f"- [{item['title']}]({item['url']})")
        if item['preview']:
            print(f"  > {item['preview']}")

else:  # tsv
    print("url\\ttitle\\tdate_added")
    for item in items:
        print(f"{item['url']}\\t{item['title']}\\t{item['date_added']}")

EOF
