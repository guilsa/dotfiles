#!/bin/bash

# Scans first-level subdirectories in /Users/gui/dev for git repos with uncommitted changes
# and repos that are out of sync with remote. Displays them in SwiftBar menu.
# Clicking opens iTerm2 in that directory.

DEV_DIR="/Users/gui/dev"
declare -a repos_with_changes=()
declare -a repos_unsynced=()

# Scan first-level subdirectories only (depth 1)
for dir in "$DEV_DIR"/*/; do
    # Skip if not a directory
    [ ! -d "$dir" ] && continue

    # Skip if not a git repo
    [ ! -d "$dir/.git" ] && continue

    # Check git status
    cd "$dir" || continue

    repo_name=$(basename "$dir")

    # Check for uncommitted changes (staged, unstaged, or untracked)
    if ! git diff-index --quiet HEAD -- 2>/dev/null || \
       [ -n "$(git ls-files --others --exclude-standard)" ]; then
        repos_with_changes+=("$repo_name|$dir")
    fi

    # Get the current branch
    current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

    if [ -n "$current_branch" ] && [ "$current_branch" != "HEAD" ]; then
        # Get the upstream branch
        upstream=$(git rev-parse --abbrev-ref "$current_branch@{upstream}" 2>/dev/null)

        if [ -n "$upstream" ]; then
            # Count commits ahead and behind
            ahead=$(git rev-list --count "$upstream..HEAD" 2>/dev/null)
            behind=$(git rev-list --count "HEAD..$upstream" 2>/dev/null)

            # If either ahead or behind, add to unsynced list
            if [ "$ahead" -gt 0 ] || [ "$behind" -gt 0 ]; then
                repos_unsynced+=("$repo_name|$dir|$ahead|$behind")
            fi
        fi
    fi
done

# Count repos
changes_count=${#repos_with_changes[@]}
unsynced_count=${#repos_unsynced[@]}

# Exit if nothing to show (keeps menu bar clean)
if [ "$changes_count" -eq 0 ] && [ "$unsynced_count" -eq 0 ]; then
    exit 0
fi

# Menu bar icon - show both counts
icon_parts=()
[ "$changes_count" -gt 0 ] && icon_parts+=("⚠️ $changes_count")
[ "$unsynced_count" -gt 0 ] && icon_parts+=("🔄 $unsynced_count")

echo "${icon_parts[*]}"
echo "---"

# First menu: Uncommitted Changes
if [ "$changes_count" -gt 0 ]; then
    echo "Dev Projects with Uncommitted Changes"
    for repo_info in "${repos_with_changes[@]}"; do
        IFS='|' read -r repo_name repo_path <<< "$repo_info"
        # Open iTerm2 in the repo directory when clicked
        echo "--$repo_name | bash='$0' param1=open param2='$repo_path' terminal=false refresh=true"
    done
    echo "---"
fi

# Second menu: Unsynced with Remote
if [ "$unsynced_count" -gt 0 ]; then
    echo "Dev Projects Unsynced with Remote"
    for repo_info in "${repos_unsynced[@]}"; do
        IFS='|' read -r repo_name repo_path ahead behind <<< "$repo_info"

        # Create a status indicator
        status=""
        [ "$ahead" -gt 0 ] && status+="↑$ahead "
        [ "$behind" -gt 0 ] && status+="↓$behind"
        status=$(echo "$status" | xargs) # trim whitespace

        # Open iTerm2 in the repo directory when clicked
        echo "--$repo_name ($status) | bash='$0' param1=open param2='$repo_path' terminal=false refresh=true"
    done
    echo "---"
fi

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
