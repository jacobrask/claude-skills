# Installation Guide

## Installing Claude Skills

Claude Code skills can be installed globally (available in all projects) or locally (project-specific).

### Global Installation

Install skills globally to use them across all your projects:

1. **Create the skills directory** (if it doesn't exist):
   ```bash
   mkdir -p ~/.claude/skills
   ```

2. **Download the skill file** from this repository:
   - Download the `.skill` file for the skill you want (e.g., `safari-tabs.skill`)

3. **Copy to the skills directory**:
   ```bash
   cp safari-tabs.skill ~/.claude/skills/
   ```

4. **Verify installation**:
   Start a new Claude Code session and the skill should be automatically available.

### Project-Specific Installation

Install skills for a specific project only:

1. **Create a `.claude` directory** in your project root:
   ```bash
   mkdir -p .claude/skills
   ```

2. **Copy the skill file**:
   ```bash
   cp safari-tabs.skill .claude/skills/
   ```

3. **Add to `.gitignore`** (optional):
   If you don't want to commit skills to your repository:
   ```bash
   echo ".claude/skills/*.skill" >> .gitignore
   ```

## Installing from Source

To install directly from this repository:

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/claude-skills.git
cd claude-skills

# Copy the skill you want
cp safari-tabs.skill ~/.claude/skills/

# Or copy all skills
cp *.skill ~/.claude/skills/
```

## Building Skills from Source

If you want to modify a skill or build from the source files:

```bash
# Navigate to the skill directory
cd skills/safari-tabs

# Package it as a .skill file
zip -r ../../safari-tabs.skill .

# Install it
cp ../../safari-tabs.skill ~/.claude/skills/
```

## Updating Skills

To update a skill:

1. Download the latest `.skill` file
2. Replace the existing file in `~/.claude/skills/`
3. Restart Claude Code (if currently running)

## Uninstalling Skills

Simply remove the `.skill` file:

```bash
rm ~/.claude/skills/safari-tabs.skill
```

## Troubleshooting

### Skill not recognized

- Ensure the `.skill` file is in the correct directory
- Check that the filename ends with `.skill`
- Restart Claude Code
- Verify the skill file isn't corrupted (it should be a valid ZIP file)

### Permission errors (macOS)

Safari-related skills require permission to control Safari via AppleScript:

1. Open **System Settings** → **Privacy & Security** → **Automation**
2. Find **Claude Code** (or your terminal app)
3. Enable **Safari** checkbox

Alternatively, the first time you run a Safari command, macOS will prompt for permission.

### Script execution errors

If scripts aren't executing:

```bash
# Make scripts executable (if installed from source)
chmod +x ~/.claude/skills/safari-tabs/scripts/*.sh
```

## Verifying Installation

You can verify a skill is properly installed by:

1. Starting a Claude Code session
2. Asking: "Do you have the safari-tabs skill installed?"
3. Claude should confirm and describe the skill's capabilities

Or check the file directly:

```bash
# List installed skills
ls -la ~/.claude/skills/

# Verify it's a valid ZIP
unzip -l ~/.claude/skills/safari-tabs.skill
```

## Platform Requirements

### Safari Tabs Skill
- **OS:** macOS only
- **Application:** Safari browser
- **Permissions:** System Automation permissions for Safari

## Getting Help

If you encounter issues:

1. Check this documentation
2. Review the skill-specific README in `skills/<skill-name>/`
3. Open an issue on [GitHub](https://github.com/YOUR_USERNAME/claude-skills/issues)
