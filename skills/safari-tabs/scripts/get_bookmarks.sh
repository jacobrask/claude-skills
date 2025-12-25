#!/bin/bash
# get_bookmarks.sh - Export Safari bookmarks
# Usage: ./get_bookmarks.sh [format]
# Formats: tree (default), flat, json

format="${1:-tree}"

plist_path="$HOME/Library/Safari/Bookmarks.plist"

if [ ! -f "$plist_path" ]; then
    echo "Error: Bookmarks.plist not found" >&2
    exit 1
fi

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

def process_bookmarks(data, depth=0, flat_list=None):
    """Recursively process bookmark structure"""
    if flat_list is None:
        flat_list = []
    
    results = []
    
    if isinstance(data, dict):
        # Skip Reading List
        if data.get('Title') == 'com.apple.ReadingList':
            return results
        
        web_type = data.get('WebBookmarkType', '')
        
        if web_type == 'WebBookmarkTypeLeaf':
            # This is a bookmark
            url = data.get('URLString', '')
            title = data.get('URIDictionary', {}).get('title', data.get('Title', 'Untitled'))
            results.append({
                'type': 'bookmark',
                'title': title,
                'url': url,
                'depth': depth
            })
            flat_list.append({'title': title, 'url': url})
            
        elif web_type == 'WebBookmarkTypeList' or 'Children' in data:
            # This is a folder
            title = data.get('Title', 'Untitled')
            if title and title != 'com.apple.ReadingList':
                folder = {
                    'type': 'folder',
                    'title': title,
                    'depth': depth,
                    'children': []
                }
                for child in data.get('Children', []):
                    folder['children'].extend(process_bookmarks(child, depth + 1, flat_list))
                if folder['children'] or title in ['BookmarksBar', 'BookmarksMenu']:
                    results.append(folder)
    
    elif isinstance(data, list):
        for item in data:
            results.extend(process_bookmarks(item, depth, flat_list))
    
    return results

flat_bookmarks = []
tree = process_bookmarks(plist, flat_list=flat_bookmarks)

format_type = "$format"

def print_tree(items, prefix=""):
    for i, item in enumerate(items):
        is_last = i == len(items) - 1
        current_prefix = prefix + ("└── " if is_last else "├── ")
        next_prefix = prefix + ("    " if is_last else "│   ")
        
        if item['type'] == 'folder':
            print(f"{current_prefix}📁 {item['title']}")
            print_tree(item.get('children', []), next_prefix)
        else:
            print(f"{current_prefix}🔗 {item['title']}")

if format_type == 'json':
    output = {
        'bookmarks': tree,
        'total_bookmarks': len(flat_bookmarks)
    }
    print(json.dumps(output, indent=2))

elif format_type == 'flat':
    print("title\\turl")
    for bm in flat_bookmarks:
        print(f"{bm['title']}\\t{bm['url']}")

else:  # tree
    print("Safari Bookmarks")
    print(f"({len(flat_bookmarks)} bookmarks)\\n")
    print_tree(tree)

EOF
