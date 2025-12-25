# Safari Tabs Skill

Comprehensive Safari browser management via AppleScript and system APIs for Claude Code.

## Overview

This skill enables Claude to interact with your Safari browser to:
- Analyze and organize open tabs
- Export tabs to multiple formats
- Find and close duplicate tabs
- Access Safari Reading List and Bookmarks
- Search browser history
- Perform bulk tab operations

## Requirements

- **OS:** macOS (tested on macOS 12+)
- **Browser:** Safari
- **Permissions:** System Automation permissions for Safari

## Installation

See the [Installation Guide](../../docs/INSTALLATION.md) for detailed instructions.

**Quick install:**
```bash
cp safari-tabs.skill ~/.claude/skills/
```

## Usage Examples

Once installed, simply ask Claude to help with Safari-related tasks. The skill will automatically activate.

### Analyzing Your Tabs

```
"What tabs do I have open in Safari?"
"Show me a summary of my open tabs"
"Analyze my Safari tabs and group them by topic"
```

### Managing Tabs

```
"I have too many tabs open, help me organize them"
"Close all duplicate tabs in Safari"
"Close all tabs from reddit.com"
"Find tabs I haven't looked at in a while"
```

### Exporting Data

```
"Export my Safari tabs to markdown"
"Save my open tabs as a JSON file"
"Create an HTML bookmark file from my current tabs"
"Export my Safari reading list"
```

### Finding Information

```
"What's in my Safari reading list?"
"Show me all my bookmarks about React"
"Search my browser history for articles about AI"
"Which domains do I have the most tabs from?"
```

### Bulk Operations

```
"Open all URLs from this file in Safari"
"Close all tabs except the ones from github.com"
"Show me duplicate tabs and close the extras"
```

## Available Scripts

All scripts are in the `scripts/` directory and can be invoked by Claude or run manually:

### Tab Management
- `get_tabs.sh` - Get all open tabs (raw output)
- `get_tabs_tsv.sh` - Get tabs as TSV (window, tab, URL, title)
- `close_tabs.sh` - Close specific tabs by window/tab index
- `close_by_pattern.sh` - Close tabs matching a URL pattern
- `find_duplicates.sh` - Find and optionally close duplicate tabs

### Export Formats
- `export_tabs_json.sh` - Export tabs to JSON with metadata
- `export_tabs_csv.sh` - Export tabs to CSV format
- `export_tabs_markdown.sh` - Export tabs to markdown (multiple formats)
- `export_tabs_html.sh` - Export as HTML bookmarks file (importable)

### Analysis
- `domain_stats.sh` - Analyze tabs by domain with category detection

### Safari Data Access
- `get_reading_list.sh` - Export Safari Reading List
- `get_bookmarks.sh` - Export Safari Bookmarks (tree/flat/JSON)
- `search_history.sh` - Search Safari browsing history

### Utilities
- `open_urls.sh` - Open URLs from file or stdin

## Manual Usage

You can also use the scripts directly from the command line:

### Export tabs to markdown
```bash
./scripts/export_tabs_markdown.sh list
./scripts/export_tabs_markdown.sh table
./scripts/export_tabs_markdown.sh checklist
./scripts/export_tabs_markdown.sh grouped
```

### Find duplicates
```bash
./scripts/find_duplicates.sh          # Just report
./scripts/find_duplicates.sh --close  # Find and close
```

### Domain statistics
```bash
./scripts/domain_stats.sh
```

### Reading list
```bash
./scripts/get_reading_list.sh tsv
./scripts/get_reading_list.sh markdown
./scripts/get_reading_list.sh json
```

### Search history
```bash
./scripts/search_history.sh "keyword"
./scripts/search_history.sh "keyword" --days 7
```

## Permissions

On first use, macOS will request permission for automation:

1. A dialog will appear asking to allow control of Safari
2. Click **OK** to grant permission
3. Alternatively, manually configure in:
   **System Settings → Privacy & Security → Automation**

## Privacy

All tab data stays local on your machine. The skill:
- Only accesses Safari data you explicitly request
- Does not send data to external services
- Processes tab titles and URLs locally
- Does not access page content unless explicitly requested

## Output Formats

### TSV (Tab-Separated Values)
```
window	tab	url	title
1	1	https://github.com	GitHub
1	2	https://google.com	Google
```

### JSON
```json
{
  "tabs": [
    {
      "window": 1,
      "tab": 1,
      "url": "https://github.com",
      "title": "GitHub",
      "domain": "github.com"
    }
  ],
  "summary": {
    "total_tabs": 42,
    "total_windows": 3,
    "unique_domains": 15
  }
}
```

### Markdown
```markdown
## Window 1
- [GitHub](https://github.com)
- [Google](https://google.com)

## Window 2
- [Stack Overflow](https://stackoverflow.com)
```

### CSV
```csv
window,tab,domain,title,url
1,1,github.com,GitHub,https://github.com
1,2,google.com,Google,https://google.com
```

## Troubleshooting

### "Safari is not running"
```bash
osascript -e 'tell application "Safari" to activate'
```

### Permission denied
Grant automation permissions:
**System Settings → Privacy & Security → Automation → [Your Terminal] → Safari**

### Scripts not executable
```bash
chmod +x scripts/*.sh
```

## Development

The skill is structured as:
```
safari-tabs/
├── SKILL.md           # Skill definition for Claude
├── README.md          # This file
└── scripts/           # Shell scripts
    ├── get_tabs.sh
    ├── export_*.sh
    └── ...
```

To modify:
1. Edit files in `skills/safari-tabs/`
2. Rebuild: `cd skills/safari-tabs && zip -r ../../safari-tabs.skill .`
3. Reinstall: `cp safari-tabs.skill ~/.claude/skills/`

## Contributing

Contributions welcome! Please:
1. Test on macOS with Safari
2. Ensure scripts are POSIX-compliant
3. Update SKILL.md if adding new capabilities
4. Include usage examples

## License

MIT License - see [LICENSE](../../LICENSE)
