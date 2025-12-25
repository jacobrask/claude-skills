# Claude Skills Collection

A curated collection of skills for [Claude Code](https://claude.com/claude-code), Anthropic's official CLI for Claude.

## Available Skills

### Safari Tabs
**Comprehensive Safari browser management via AppleScript**

Interact with Safari browser tabs, reading list, bookmarks, and history. Analyze, organize, summarize, deduplicate, close, export, or manage your Safari tabs with powerful automation.

**Features:**
- Export tabs to multiple formats (JSON, CSV, Markdown, HTML)
- Find and close duplicate tabs
- Analyze tabs by domain with category detection
- Access Safari Reading List and Bookmarks
- Search browser history
- Close tabs by pattern matching
- Open URLs from files

**Requirements:** macOS with Safari

[View Documentation](./skills/safari-tabs/) | [Download](./safari-tabs.skill)

---

## Installation

### Quick Install

1. Download the `.skill` file for the skill you want
2. Place it in your Claude Code skills directory:
   - macOS/Linux: `~/.claude/skills/`
   - Or your project's `.claude/` directory for project-specific skills

### Manual Installation

See [Installation Guide](./docs/INSTALLATION.md) for detailed instructions.

## Usage

Once installed, skills are automatically available in Claude Code conversations. Simply reference Safari-related tasks:

- "Show me my open Safari tabs"
- "Clean up duplicate tabs"
- "Export my tabs to markdown"
- "What's in my Safari reading list?"
- "Close all tabs from reddit.com"

Claude will automatically invoke the appropriate skill based on your request.

## Development

Each skill is packaged as a `.skill` file (ZIP archive) containing:
- `SKILL.md` - Skill definition and documentation
- `scripts/` - Executable scripts (bash, AppleScript, etc.)

To modify a skill:
1. Navigate to `skills/<skill-name>/`
2. Edit the files
3. Rebuild using: `cd skills/<skill-name> && zip -r ../../<skill-name>.skill .`

## Contributing

Contributions welcome! Please:
1. Follow the existing skill structure
2. Include comprehensive documentation
3. Test on macOS (for Safari-specific skills)
4. Submit a pull request

## License

MIT License - see [LICENSE](./LICENSE) for details.

## About Claude Skills

Skills extend Claude Code with specialized capabilities for specific tasks. They can:
- Execute system scripts and commands
- Provide domain-specific knowledge
- Automate complex workflows
- Integrate with local applications

Learn more at [Claude Code Documentation](https://github.com/anthropics/claude-code).
