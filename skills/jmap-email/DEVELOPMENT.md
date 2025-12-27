# JMAP Email - Development Guide

Guide for writing custom JMAP operations and extending the skill.

## Quick Start

Basic pattern for all operations:

```typescript
import { createJamClient, getAccountId, JMAP_OPTIONS } from "./utils/jmap-client.ts";

const jam = createJamClient();
const accountId = await getAccountId(jam);

// Your JMAP operations here
```

Execute with:
```bash
node scripts/your_script.ts
```

**Why use utils/jmap-client?**
- Automatic environment variable validation with helpful error messages
- Consistent JMAP options across all scripts
- Simplified account ID handling

## Core Principles

1. Output compact, human-readable results instead of verbose JSON
2. Check `scripts/` for existing utilities before writing new code
3. Request only needed email properties
4. Use utilities from `scripts/utils/`:
   - `jmap-client.ts` - Client creation, account ID, and JMAP options
   - `format-email.ts` - Email formatting and display functions

## Common Workflows

### Email Search Workflow

Copy and track progress:
```
Email Search:
- [ ] Step 1: Search for email IDs
- [ ] Step 2: Get email details with minimal properties
- [ ] Step 3: Format output concisely
```

**Step 1: Search for email IDs**

Use existing script or write inline query with appropriate filters (from, to, subject, date ranges, keywords).

**Step 2: Get email details**

Only request needed properties: `["subject", "from", "receivedAt", "preview"]` for summaries, or add `"textBody"` for content.

**Step 3: Format output**

Use `printEmailList()` or `printEmailDetailed()` from `utils/format-email.ts`.

### Blob Download Workflow

For downloading raw email messages (RFC 5322 format):

Copy and track progress:
```
Blob Download:
- [ ] Step 1: Get email with blobId and size properties
- [ ] Step 2: Check size against limit (default 1MB)
- [ ] Step 3: Download blob if under limit
- [ ] Step 4: Convert to base64 (only if requested)
```

**Important**: Check email size before downloading to avoid context overflow. Default max: 1MB.

## Available Operations

**Search & Retrieve**:
- Search emails by sender, recipient, subject, keywords, dates
- Get specific emails by ID
- Get email threads
- List mailboxes
- Filter by JMAP keywords: `$seen` (read), `$flagged` (starred), `$draft`, `$answered`

**Modify** (write operations):
- Mark emails as read/unread, flagged/unflagged
- Move emails between mailboxes
- Delete emails

**Blobs**:
- Download raw email messages (RFC 5322 format)
- Upload binary data

## Context Efficiency

**Avoid**: Verbose JSON dumps from jmap-jam responses
**Prefer**: Compact, formatted summaries using utils

Example transformation:
```typescript
// Bad: Return entire email object
console.log(JSON.stringify(email, null, 2));

// Good: Use formatting utilities
import { printEmailDetailed } from "./utils/format-email.ts";
printEmailDetailed(email);
```

## TypeScript Integration

JMAP API calls require a `@ts-ignore` comment because jmap-jam types don't expose the options parameter. Use `JMAP_OPTIONS` from utils:

```typescript
import { createJamClient, getAccountId, JMAP_OPTIONS } from "./utils/jmap-client.ts";

const jam = createJamClient();
const accountId = await getAccountId(jam);

const [result] = await jam.api.Email.get({
  accountId,
  ids: emailIds,
  properties: ["subject", "from"],
// @ts-ignore - jmap-jam ProxyAPI types don't expose options param (runtime supports it)
}, JMAP_OPTIONS);
```

## Resources

- **API Reference**: See [reference.md](reference.md) for all JMAP methods and parameters
- **Code Examples**: See [examples.md](examples.md) for complete working code
- **Utility Scripts**: Check `scripts/` directory for ready-to-use tools
