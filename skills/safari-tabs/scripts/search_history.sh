#!/bin/bash
# search_history.sh - Search Safari browsing history
# Usage: ./search_history.sh [search_term] [--days N]
# History is stored in ~/Library/Safari/History.db

search_term=""
days=7

while [[ $# -gt 0 ]]; do
    case "$1" in
        --days)
            days="$2"
            shift 2
            ;;
        *)
            search_term="$1"
            shift
            ;;
    esac
done

history_db="$HOME/Library/Safari/History.db"

if [ ! -f "$history_db" ]; then
    echo "Error: History.db not found" >&2
    echo "Safari may need to be closed to access history" >&2
    exit 1
fi

# Copy database to avoid locking issues
tmp_db="/tmp/safari_history_$$.db"
cp "$history_db" "$tmp_db" 2>/dev/null

if [ ! -f "$tmp_db" ]; then
    echo "Error: Could not copy history database" >&2
    echo "Try closing Safari first" >&2
    exit 1
fi

# Calculate date threshold (Safari uses Core Data timestamp: seconds since 2001-01-01)
# Core Data epoch is 978307200 seconds after Unix epoch
core_data_offset=978307200
now=$(date +%s)
threshold=$((now - core_data_offset - days * 86400))

if [ -n "$search_term" ]; then
    echo "=== Safari History: '$search_term' (last $days days) ==="
    query="SELECT 
        datetime(v.visit_time + 978307200, 'unixepoch', 'localtime') as visit_date,
        i.url,
        v.title
    FROM history_visits v
    JOIN history_items i ON v.history_item = i.id
    WHERE v.visit_time > $threshold
    AND (i.url LIKE '%$search_term%' OR v.title LIKE '%$search_term%')
    ORDER BY v.visit_time DESC
    LIMIT 100"
else
    echo "=== Safari History (last $days days) ==="
    query="SELECT 
        datetime(v.visit_time + 978307200, 'unixepoch', 'localtime') as visit_date,
        i.url,
        v.title
    FROM history_visits v
    JOIN history_items i ON v.history_item = i.id
    WHERE v.visit_time > $threshold
    ORDER BY v.visit_time DESC
    LIMIT 100"
fi

echo ""

sqlite3 -separator $'\t' "$tmp_db" "$query" 2>/dev/null | \
while IFS=$'\t' read -r date url title; do
    echo "[$date] $title"
    echo "  $url"
    echo ""
done

# Cleanup
rm -f "$tmp_db"
