---
name: knowledge-base
description: Manage your personal knowledge base of curated resources, bookmarks, and excerpts. Triggers include "knowledge base", "kb", "add to knowledge", "add tabs to", "what do I have on", "what do we know about", "find resources about". Use with safari-tabs skill for bulk ingestion from Safari windows. Location is ~/knowledge/.
---

# Knowledge Base

A topic-based collection of curated links, excerpts, and notes at `~/knowledge/`.

## Structure

```
~/knowledge/
├── _index.md          # Topic listing + recent activity
├── _inbox.md          # Unprocessed items
├── topics/*.md        # Articles, concepts, best practices
├── tools/*.md         # Software, libraries, utilities (organized by use case)
└── archive/YYYY-MM/   # Full article content (link rot protection)
```

## Entry Formats

### Topics (Articles & Concepts)

When adding a resource to a topic file:

```markdown
**[Title](url)** — Author (company/context)

Concise summary integrating the main points and key takeaways. Keep it flowing—no need for structured sections, bullets, or quotes unless they genuinely add clarity.

Additional context or explanation as needed.
```

**Summary length**: Keep summaries to 1-2 short paragraphs, unless the source is exceptionally long, important and insightful. Focus on core insights. Be extremely concise. Sacrifice grammar for the sake of concision.

### Tools (Software & Libraries)

When adding software, utilities, or libraries to a tools file:

```markdown
### [tool-name](url)

**Platform:** macOS / JavaScript / Web Service
**Install:** `npm install tool-name` / Download from website / Browser extension
**Use case:** Brief description of what problem it solves

1-2 paragraph summary of why it's useful, key features, and when to use it.

**Alternatives:** other-tool (reason to choose), another-tool (different tradeoff)
```

Tools are organized by **use case** in `~/knowledge/tools/` (e.g., `testing.md`, `productivity.md`, `terminal.md`).

This includes libraries, CLI tools, desktop applications, web services, browser extensions, and other software.

## Adding Resources

### From Safari Windows (with safari-tabs skill)

1. Get tabs from a specific window using `get_tabs.sh` (filter by window number or match by tab title)
2. **Process in batches of 8-10 tabs** to avoid context overflow
3. For each batch:
   - Fetch content from each URL with web_fetch
   - Read existing topic files to understand categories
   - Route each tab to the appropriate topic based on content
   - Archive full content for very substantial or unique articles
   - Add items that don't fit existing topics to `_inbox.md`
4. Update `_index.md` with activity after all batches complete

Recommended command: `get_tabs.sh markdown` or `get_tabs.sh -w N markdown` for window N.

**Context management**: When processing large numbers of tabs (>10), work in batches to avoid filling context with fetched content. Process batch 1, write to files, then continue with batch 2.

### Quality Control for Bulk Additions

When adding a large number of links at once, **pause and ask the user** if you encounter:
- Links that seem out of place compared to the other links being added
- Low-quality content (listicles, marketing pages, thin content)
- Resources that don't contain substantive information useful for a knowledge base
- Duplicate or highly similar content to what's already being added
- Links that appear to be errors or accidental inclusions

This prevents cluttering the knowledge base with content that doesn't meet the curation standard.

### Failed Fetches

When processing multiple links, some may fail to fetch (403 errors, timeouts, etc.):
- Note which links failed to fetch and the error type
- Continue processing successful fetches
- At the end, present a summary:
  - **Successfully added**: List of titles/URLs that were fetched and added
  - **Failed to fetch**: List each failed URL with its error code (e.g., "https://example.com - 403 Forbidden")
- **Ask the user** if you should still add the failed links to the knowledge base without summaries (just title and URL)

### GitHub Projects and Gists

When encountering GitHub repositories or gists:
- **Pause and ask the user** if they want to include them
- **Repositories** typically go to `tools/` organized by use case
- **Gists** may be code examples, snippets, or mini-articles—ask user for routing
- Use the tools format (structured metadata) for software/libraries
- Only proceed with summarization after user confirms

Desktop applications, web services, and other software should also use the tools format.

### Routing Rules

**For articles and concepts:**
- Read the description at the top of each topic file—it defines scope
- Match by content, not just title keywords
- When uncertain between topics, prefer the more specific one
- If no topic fits well, add to `_inbox.md` with a suggested topic name
- Offer to create new topics if multiple items cluster around a theme
- **Large topics**: If a topic file becomes very large (>500 lines or >30 entries), ask the user to split it into more specific topics to avoid filling context unnecessarily

**For tools and software:**
- Route software/libraries/utilities to `tools/` by use case
- Desktop apps, CLI tools, libraries, web services all go in `tools/`
- Articles **about** tools go to `topics/` (e.g., "How to use React" → topics)
- Tool documentation typically skipped—just add the tool entry itself
- Consider creating new use-case categories if needed (e.g., `tools/productivity.md`, `tools/terminal.md`)

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

## File Formats

### Topic File Format

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

### Tools File Format

```markdown
---
tags: [category1, category2]
updated: YYYY-MM-DD
---

# Use Case Name

Software and tools for [specific use case]. This helps with routing and finding the right tool for a problem.

---

### [tool-name](url)

**Platform:** macOS
**Install:** Download from website
**Use case:** Specific problem this solves

Why it's useful and when to use it...

**Alternatives:** alternative-1 (why choose), alternative-2 (different tradeoff)

---

### [another-tool](url)

**Platform:** JavaScript
**Install:** `npm install another-tool`
**Use case:** Different problem in same category

Summary...

**Alternatives:** ...
```

## Updating _index.md

After adding resources:
```markdown
## Topics
- **[topic-name.md](topics/topic-name.md)** — Brief description

## Tools
- **[use-case.md](tools/use-case.md)** — Software and tools for [use case]
```

## Usage

**Finding tools before web search:**
When asked to find software, a library, or tool for a specific task:
1. First check `tools/` for relevant use-case files
2. Search existing tools that match the requirement
3. Only perform web search if knowledge base doesn't have suitable options

This allows leveraging curated, previously-vetted software before searching the web.

## Commands

- **Add tabs from window:** Ingest all tabs from a Safari window
- **What do I have on X:** Search topics for relevant resources
- **What do we know about X:** Search topics for relevant resources
- **Find resources about X:** Search topics for relevant resources
- **Find a tool/app for X:** Search tools/ first, then web search if needed
- **Add this to knowledge base:** Add current URL or pasted content
