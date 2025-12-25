---
name: safari-tabs
description: Interact with Safari browser tabs, reading list, bookmarks, and history via AppleScript. Use when the user asks to analyze, organize, summarize, deduplicate, close, export, or manage their Safari tabs. Also handles reading list, bookmarks, and history searches. Triggers include "my tabs", "open tabs", "Safari tabs", "clean up my browser", "what tabs do I have open", "organize my tabs", "too many tabs", "reading list", "bookmarks", "browser history", "export tabs". Requires macOS with Safari.
---

# Safari Tabs

Comprehensive Safari browser management via AppleScript and system APIs.

## Available Scripts

| Script | Purpose |
|--------|---------|
| `get_tabs_tsv.sh` | Get all tabs as TSV (window, tab, url, title) |
| `export_tabs_json.sh` | Export tabs to JSON with metadata |
| `export_tabs_csv.sh` | Export tabs to CSV format |
| `export_tabs_markdown.sh` | Export tabs to markdown (list/table/checklist/grouped) |
| `export_tabs_html.sh` | Export as HTML bookmarks file (importable) |
| `find_duplicates.sh` | Find and optionally close duplicate tabs |
| `domain_stats.sh` | Analyze tabs by domain with category detection |
| `close_tabs.sh` | Close specific tabs by window,tab index |
| `close_by_pattern.sh` | Close tabs matching a URL pattern |
| `open_urls.sh` | Open URLs from file or stdin |
| `get_reading_list.sh` | Export Safari Reading List |
| `get_bookmarks.sh` | Export Safari Bookmarks (tree/flat/json) |
| `search_history.sh` | Search Safari browsing history |

## Export Formats

### Markdown Export
```bash
./scripts/export_tabs_markdown.sh [format]
```
Formats:
- `list` (default): Grouped by window with markdown links
- `table`: Markdown table with window, title, URL
- `checklist`: Checkbox list for review
- `grouped`: Organized by domain

### JSON Export
```bash
./scripts/export_tabs_json.sh
```
Returns structured JSON with tab metadata, domains, and counts.

### CSV Export
```bash
./scripts/export_tabs_csv.sh
```
Standard CSV: window, index, domain, title, url

### HTML Bookmarks Export
```bash
./scripts/export_tabs_html.sh > tabs.html
```
Netscape bookmark format—importable into any browser.

## Reading Tabs

Get all open tabs across all windows:

```bash
osascript -e '
tell application "Safari"
    set output to ""
    set windowIndex to 1
    repeat with w in windows
        set tabIndex to 1
        repeat with t in tabs of w
            set output to output & windowIndex & "," & tabIndex & "," & (URL of t) & "	" & (name of t) & linefeed
            set tabIndex to tabIndex + 1
        end repeat
        set windowIndex to windowIndex + 1
    end repeat
    return output
end tell'
```

Output format: `windowIndex,tabIndex,URL<tab>title` per line.

## Reading Tab Groups

Safari tab groups (requires macOS Monterey+):

```bash
osascript -e '
tell application "Safari"
    set output to ""
    repeat with tg in tab groups of front window
        set groupName to name of tg
        repeat with t in tabs of tg
            set output to output & groupName & "	" & (URL of t) & "	" & (name of t) & linefeed
        end repeat
    end repeat
    return output
end tell'
```

## Actions

### Close a specific tab

```bash
osascript -e 'tell application "Safari" to close tab TABINDEX of window WINDOWINDEX'
```

### Close tabs by URL pattern

```bash
osascript -e '
tell application "Safari"
    repeat with w in windows
        set tabsToClose to {}
        repeat with t in tabs of w
            if URL of t contains "PATTERN" then
                set end of tabsToClose to t
            end if
        end repeat
        repeat with t in tabsToClose
            close t
        end repeat
    end repeat
end tell'
```

### Open a URL in new tab

```bash
osascript -e 'tell application "Safari" to make new tab at end of tabs of front window with properties {URL:"https://example.com"}'
```

### Get current tab info

```bash
osascript -e 'tell application "Safari" to return URL of current tab of front window & linefeed & name of current tab of front window'
```

## Analysis Workflow

1. **Fetch tabs** using the read script above
2. **Parse output** into structured list (window, tab index, URL, title)
3. **Analyze**:
   - Group by domain
   - Identify duplicates (same URL) and near-duplicates (same article, different sites)
   - Categorize by topic using titles/URLs
   - Flag stale content (news articles, old docs)
   - Identify clusters (multiple tabs on same topic)
4. **Report** with:
   - Summary stats (total tabs, tabs per window, top domains)
   - Categorized list with suggested actions
   - Duplicate list with "keep this one" recommendations
   - Suggested Safari Tab Groups structure
5. **Act** on user approval:
   - Close specified tabs
   - Report which tabs remain

## Interactive Commands

After initial analysis, support follow-up requests:
- "Close all the news tabs"
- "Keep only the React documentation"
- "Summarize what I'm researching"
- "Which tabs are duplicates?"
- "Group these by project"

## Error Handling

If Safari is not running:
```bash
osascript -e 'tell application "Safari" to activate'
```

Check if accessible:
```bash
osascript -e 'tell application "Safari" to count windows'
```

## Privacy Note

Tab data stays local. Only titles and URLs are processed—page content is not accessed unless the user explicitly asks to fetch and summarize specific pages.

## Duplicate Detection

```bash
./scripts/find_duplicates.sh          # Find duplicates
./scripts/find_duplicates.sh --close  # Find and close duplicates
```
Identifies tabs with matching URLs (normalized). Keeps first occurrence.

## Domain Analysis

```bash
./scripts/domain_stats.sh
```
Shows:
- Tab count per domain with visual bars
- TLD distribution
- Category detection (Social, Video, News, Dev, Shopping, etc.)

## Reading List Access

```bash
./scripts/get_reading_list.sh [format]
```
Formats: `tsv` (default), `markdown`, `json`

Reads from `~/Library/Safari/Bookmarks.plist`.

## Bookmarks Access

```bash
./scripts/get_bookmarks.sh [format]
```
Formats: `tree` (default), `flat`, `json`

## History Search

```bash
./scripts/search_history.sh [term] [--days N]
```
Searches Safari history. Requires Safari to be closed (or copies the database).

## Opening URLs

```bash
./scripts/open_urls.sh urls.txt
./scripts/open_urls.sh --new-window urls.txt
cat urls.md | ./scripts/open_urls.sh
```
Extracts URLs from any text (handles markdown links, plain URLs, etc.).
