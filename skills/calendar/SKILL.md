---
name: calendar
description: Interact with Apple Calendar via AppleScript. Use when the user asks to check calendar, view events, create events, manage schedule, find free time, or list calendars. Triggers include "my calendar", "my schedule", "calendar events", "create event", "add to calendar", "what's on my calendar", "free time", "available slots", "upcoming events", "today's events". Requires macOS with Calendar.app.
---

# Calendar

Apple Calendar management via AppleScript.

## Key Scripts

| Script | Purpose |
|--------|---------|
| `list_calendars.sh` | List all available calendars (TSV/JSON) |
| `get_events.sh` | Get events with date range filtering (TSV/markdown/JSON) |
| `create_event.sh` | Create new calendar event |
| `search_events.sh` | Search events by keyword |

## List Calendars

```bash
list_calendars.sh           # Simple list
list_calendars.sh json      # JSON format
```

## Getting Events

```bash
get_events.sh                    # Today's events as TSV
get_events.sh markdown           # Today's events as markdown
get_events.sh --today            # Today's events (TSV)
get_events.sh --week markdown    # Next 7 days
get_events.sh --days 14 json     # Next 14 days
get_events.sh -c "Work"          # Filter by calendar
```

## Creating Events

```bash
create_event.sh "Meeting Title" "2025-12-26 14:00" "2025-12-26 15:00"
create_event.sh "Lunch" "2025-12-27 12:00" "2025-12-27 13:00" "Work"
create_event.sh "Conference" "2025-12-28 09:00" "2025-12-28 17:00" "Work" "San Francisco" "Annual conference"
```

Parameters: `title startDate endDate [calendar] [location] [description]`

## Search Events

```bash
search_events.sh "meeting"
search_events.sh "dentist" markdown
search_events.sh -c "Work" "standup"
```

## Output Formats

- **TSV**: Tab-separated (calendar, title, start, end, location, description)
- **Markdown**: Formatted list with dates and times
- **JSON**: Structured data for processing

**Privacy**: Event data stays local. Calendar.app data accessed via AppleScript only.

## Important Notes

**NEVER delete calendar events without explicit user confirmation.** This skill currently does not include a delete script - if the user requests deletion, always ask for confirmation first and warn about the permanent nature of the action.
