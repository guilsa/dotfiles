#!/bin/bash

# Set the mail folder path
MAIL_DIR="/Users/gui/Documents/Mail"

# Find all PDF files ending with ! before .pdf
# Using a while loop to handle old bash and special characters
reminder_files=()
while IFS= read -r -d '' file; do
    reminder_files+=("$file")
done < <(find "$MAIL_DIR" -type f \( -name '*!.pdf' -o -name '*!.PDF' \) -print0 2>/dev/null)

# Count reminder files
count=${#reminder_files[@]}

# Display menu bar item with visual cue
if [ "$count" -gt 0 ]; then
    echo "📬 $count | color=orange"
else
    echo "✅"
fi

echo "---"

# Submenu
echo "File Reminders"

if [ "$count" -gt 0 ]; then
    for file in "${reminder_files[@]}"; do
        filename=$(basename "$file")
        echo "--$filename | bash=/usr/bin/open param1=\"$file\" terminal=false refresh=true"
    done
else
    echo "--No pending reminders | color=#999999"
fi

echo "---"
echo "Refresh Now | refresh=true"