# Claude Skills Collection

A collection of skills for [Claude Code](https://claude.com/claude-code).

## Skills

- **[Safari Tabs](./skills/safari-tabs/)** - Safari browser management via AppleScript (macOS)
- **[Knowledge Base](./skills/knowledge-base/)** - Personal knowledge base for curated resources
- **[JMAP Email](./skills/jmap-email/)** - Email operations for JMAP servers (FastMail, Cyrus IMAP, Stalwart)

See individual skill directories for documentation and installation instructions.

## Installation

```bash
git clone https://github.com/jacobrask/claude-skills.git
cd claude-skills

# Symlink skills to ~/.claude/skills/
ln -s $(pwd)/skills/safari-tabs ~/.claude/skills/safari-tabs
ln -s $(pwd)/skills/knowledge-base ~/.claude/skills/knowledge-base
ln -s $(pwd)/skills/jmap-email ~/.claude/skills/jmap-email
```
