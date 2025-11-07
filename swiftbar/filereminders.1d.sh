#!/bin/bash

# Set the mail folder path
MAIL_DIR="/Users/gui/Documents/Mail"

# Find all PDF files ending with ! before .pdf
reminder_files=()
while IFS= read -r -d '' file; do
    reminder_files+=("$file")
done < <(find "$MAIL_DIR" -type f \( -name '*!.pdf' -o -name '*!.PDF' \) -print0 2>/dev/null)

# Count reminder files
count=${#reminder_files[@]}

# Send notification automatically if reminders found
if [ "$count" -gt 0 ]; then
    # Build notification body with list of files
    notification_body=""
    for file in "${reminder_files[@]}"; do
        filename=$(basename "$file" | sed 's/!\.pdf$//')
        notification_body="${notification_body}• ${filename}"$'\n'
    done
    
    # Trigger native macOS notification
    osascript -e "display notification \"$notification_body\" with title \"📬 Mail Reminders ($count)\""
fi

# Display menu bar item with visual cue
if [ "$count" -gt 0 ]; then
    echo "📬 $count | color=orange"
else
    echo "✅"
fi

echo "---"

# Simple menu
if [ "$count" -gt 0 ]; then
    echo "Open Mail Folder | bash=/usr/bin/open param1=\"$MAIL_DIR\" terminal=false"
else
    echo "No pending reminders | color=#999999"
fi

echo "---"
echo "Refresh Now | refresh=true"