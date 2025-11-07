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

# Exit early if no reminders (keeps menu bar clean)
if [ "$count" -eq 0 ]; then
    exit 0
fi

# Build notification body with list of files
notification_body=""
for file in "${reminder_files[@]}"; do
    filename=$(basename "$file" | sed 's/!\.pdf$//')
    notification_body="${notification_body}• ${filename}"$'\n'
done

# Trigger native macOS notification
osascript -e "display notification \"$notification_body\" with title \"📬 Mail Reminders ($count)\""

# Display menu bar item (only shows when reminders exist)
echo "📬 $count"

echo "---"

# Submenu section
echo "Mail Reminders"
echo "--Open Mail Folder | bash=/usr/bin/open param1=\"$MAIL_DIR\" terminal=false"

echo "---"
echo "Refresh Now | refresh=true"