# SwiftBar Scripts

## Menu Structure

Keep the menu bar clean by using hierarchical structure:

- **First line**: menu bar icon only (counts, status, emoji)
- **Submenus**: prefix items with `--` to nest under category headers
- **Separators**: use `---` to organize sections
- **Notifications**: use for lists of 4+ items instead of cluttering the menu

## Basic Pattern

```bash
#!/bin/bash

echo "🔔 3"  # Menu bar icon
echo "---"

# Submenu section
echo "Category Name"
echo "--Item 1 | bash=/path/to/script"
echo "--Item 2 | href=..."

echo "---"
echo "Settings"
echo "--Refresh | refresh=true"
```

## Do's & Don'ts

✅ **Do**
- Single, compact top-level indicator
- Use `--` prefix for submenu items
- Organize with category headers and `---` separators
- Use notifications for detailed lists

❌ **Don't**
- Multiple top-level items without separation
- List many items directly in the menu
- Verbose text in the menu bar icon
- Create unstable menu sizes with dynamic content

## Notifications

For longer content, use SwiftBar notifications:

```
swiftbar://notify?plugin=script.sh&title=Title&body=Content%20here
```

URL encode special characters (space = `%20`, newline = `%0A`).