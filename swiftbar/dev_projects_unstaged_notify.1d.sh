#!/bin/bash

# Scans first-level subdirectories in /Users/gui/dev for git repos with uncommitted changes
# and displays them in SwiftBar menu. Clicking opens iTerm2 in that directory.

DEV_DIR="/Users/gui/dev"
declare -a repos_with_changes=()

# Scan first-level subdirectories only (depth 1)
for dir in "$DEV_DIR"/*/; do
    # Skip if not a directory
    [ ! -d "$dir" ] && continue

    # Skip if not a git repo
    [ ! -d "$dir/.git" ] && continue

    # Check git status
    cd "$dir" || continue

    # Check for any changes (staged, unstaged, or untracked)
    if ! git diff-index --quiet HEAD -- 2>/dev/null || \
       [ -n "$(git ls-files --others --exclude-standard)" ]; then
        # Extract just the directory name
        repo_name=$(basename "$dir")
        repos_with_changes+=("$repo_name|$dir")
    fi
done

# Count repos with changes
count=${#repos_with_changes[@]}

# Exit if nothing to show (keeps menu bar clean)
if [ "$count" -eq 0 ]; then
    exit 0
fi

# Menu bar icon
echo "⚠️ $count"
echo "---"

# Menu items
echo "Dev Projects with Uncommitted Changes"
for repo_info in "${repos_with_changes[@]}"; do
    IFS='|' read -r repo_name repo_path <<< "$repo_info"

    # Open iTerm2 in the repo directory when clicked
    echo "--$repo_name | bash='$0' param1=open param2='$repo_path' terminal=false refresh=true"
done

echo "---"
echo "Refresh | refresh=true"

# Handle the "open" action
if [ "$1" = "open" ] && [ -n "$2" ]; then
    repo_path="$2"

    # Launch iTerm2 with the specified directory
    osascript <<EOF
tell application "iTerm"
    activate
    create window with default profile
    tell current session of current window
        write text "cd '$repo_path'"
        write text "clear"
        write text "git status"
    end tell
end tell
EOF
fi
