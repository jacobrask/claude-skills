# JMAP Email Skill

A Claude Code skill for JMAP email access using Node.js and the jmap-jam library. This skill is more context-efficient than using an MCP server for JMAP operations.

## Setup

### 1. Install Dependencies

```bash
npm install
```

### 2. Launch Claude Code with Environment Variables

```bash
JMAP_SESSION_URL="https://api.fastmail.com/.well-known/jmap" \
JMAP_BEARER_TOKEN="your-token-here" \
JMAP_ACCOUNT_ID="your-account-id" \
claude
```

### 3. Use the Skill

The skill provides ready-to-use scripts for common email operations. Just ask Claude to search emails, move messages, list mailboxes, etc., and it will run the appropriate script from the `scripts/` directory. For advanced use cases, Claude can also write custom scripts using the patterns in `SKILL.md`.

## How It Works

1. You ask Claude to perform email operations (search, move, delete, etc.)
2. Claude selects the appropriate script from the `scripts/` directory
3. Executes it with Node 24 (built-in TypeScript support)
4. Returns formatted, concise output

For advanced use cases not covered by existing scripts, Claude can write custom TypeScript scripts using the JMAP patterns documented in `SKILL.md`.
