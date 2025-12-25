---
name: knowledge-base
description: Manage your personal knowledge base of curated resources, bookmarks, and excerpts. Triggers include "knowledge base", "kb", "add to knowledge", "add tabs to", "what do I have on", "find resources about". Use with safari-tabs skill for bulk tab ingestion. Location is ~/knowledge/.
---

# Knowledge Base

A topic-based collection of curated links, excerpts, and notes at `~/knowledge/`.

## Structure

```
~/knowledge/
├── _index.md          # Topic listing + recent activity
├── _inbox.md          # Unprocessed items
├── topics/*.md        # Topic files with resources
└── archive/YYYY-MM/   # Full article content (link rot protection)
```

## Entry Format

When adding a resource to a topic file:

```markdown
**[Title](url)** — Author (company/context)

1-3 paragraph summary integrating the main points and key takeaways. Keep it concise and flowing—no need for structured sections, bullets, or quotes unless they genuinely add clarity.

Additional context or explanation as needed.
```

## Adding Resources

### From Tab Groups (with safari-tabs skill)

1. Get tabs from the specified group via AppleScript
2. Fetch content from each URL with web_fetch
3. Read existing topic files to understand categories
4. Route each tab to the appropriate topic based on content
5. Archive full content for very substantial or unique articles
6. Add items that don't fit existing topics to `_inbox.md`
7. Update `_index.md` with activity

### Routing Rules

- Read the description at the top of each topic file—it defines scope
- Match by content, not just title keywords
- When uncertain between topics, prefer the more specific one
- If no topic fits well, add to `_inbox.md` with a suggested topic name
- Offer to create new topics if multiple items cluster around a theme

### When to Archive Full Content

Archive to `archive/YYYY-MM/filename.md` when:
- Article is substantial (>500 words of valuable content)
- Content is reference material you'd return to
- Source might disappear (personal blogs, smaller sites)
- Points being made are unique or not easily found elsewhere

Skip archiving for:
- GitHub repos (link to repo directly)
- YouTube videos
- Documentation that updates frequently
- News articles you'll reference once

Archive format:
```markdown
---
url: https://original-url.com
author: Name
archived: YYYY-MM-DD
---

# Article Title

Full content in markdown...
```

## Topic File Format

```markdown
---
tags: [tag1, tag2]
updated: YYYY-MM-DD
---

# Topic Name

Brief description of what this topic covers and its boundaries. This helps with routing future resources.

---

## Section Name

*Optional description of what this section covers.*

**[Entry Title](url)** — Author

Entry summary and key points in flowing prose...

**[Another Entry](url)** — Author

Another entry summary...

---

## Another Section

*Description if section is empty, waiting for resources.*
```

## Updating _index.md

After adding resources:
```markdown
## Topics
- **[topic-name.md](topics/topic-name.md)** — Brief description

## Recent Activity
- YYYY-MM-DD: topic-name.md (what was added)
```

## Commands

- **Add tab group:** Ingest all tabs from a Safari tab group
- **What do I have on X:** Search topics for relevant resources
- **Find resources about X:** Same as above
- **Add this to knowledge base:** Add current URL or pasted content
