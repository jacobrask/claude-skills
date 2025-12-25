#!/bin/bash
# domain_stats.sh - Analyze Safari tabs by domain
# Usage: ./domain_stats.sh

tabs=$(osascript -e '
tell application "Safari"
    set output to ""
    repeat with w in windows
        repeat with t in tabs of w
            set output to output & (URL of t) & linefeed
        end repeat
    end repeat
    return output
end tell')

total_tabs=$(echo "$tabs" | grep -c "http")

echo "=== Safari Tab Statistics ==="
echo ""
echo "Total tabs: $total_tabs"
echo ""
echo "=== Tabs by Domain ==="
echo ""

# Extract domains and count
echo "$tabs" | grep -E "^https?://" | \
    sed -E 's|https?://([^/]+).*|\1|' | \
    sed 's/^www\.//' | \
    sort | uniq -c | sort -rn | \
    while read count domain; do
        percent=$((count * 100 / total_tabs))
        bar=$(printf '%*s' $((count)) '' | tr ' ' '█')
        printf "%3d (%2d%%) %s %s\n" "$count" "$percent" "$bar" "$domain"
    done

echo ""
echo "=== Top Level Domain Distribution ==="
echo ""

echo "$tabs" | grep -E "^https?://" | \
    sed -E 's|https?://([^/]+).*|\1|' | \
    sed 's/^www\.//' | \
    sed -E 's/.*\.([a-z]+)$/\1/' | \
    sort | uniq -c | sort -rn | head -10 | \
    while read count tld; do
        printf "%3d  .%s\n" "$count" "$tld"
    done

echo ""
echo "=== Potential Categories ==="
echo ""

# Common category patterns
declare -A categories
categories["Social"]="twitter.com|x.com|facebook.com|instagram.com|linkedin.com|reddit.com|mastodon"
categories["Video"]="youtube.com|vimeo.com|netflix.com|twitch.tv"
categories["News"]="news|nytimes.com|washingtonpost.com|bbc.com|cnn.com|reuters.com"
categories["Dev/Tech"]="github.com|stackoverflow.com|developer.|docs.|api.|localhost"
categories["Shopping"]="amazon.com|ebay.com|shop|store|buy"
categories["Email"]="mail.google|outlook|mail.yahoo"
categories["Docs"]="docs.google|notion.so|dropbox|drive.google"

for category in "${!categories[@]}"; do
    pattern="${categories[$category]}"
    count=$(echo "$tabs" | grep -iE "$pattern" | wc -l | tr -d ' ')
    if [ "$count" -gt 0 ]; then
        echo "$category: $count tabs"
    fi
done
