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

## Architecture: Multiple Scripts vs Unified Aggregator

**The SwiftBar Reality:**
Each script file = one menu bar icon. SwiftBar has NO built-in aggregation feature.

On limited screen space (13" laptop), choosing between two architectures:

### Option A: Unified Aggregator (Single Icon) - Custom Solution
- **Build ONE script** that sources/combines multiple modules
- Single top-level icon: `🔔 5` (combines all categories)
- Dropdown contains all reminder types as sections
- **Implementation**: Create `reminders-hub.1d.sh` that sources individual module scripts
- **Pros**: Minimal menu bar footprint (1 icon), centralized control
- **Cons**: More complex; all categories under generic label; tight coupling; one refresh rate for all
- **Best for**: Many (4+) reminder categories, very limited screen space

### Option B: Independent Scripts (Multiple Icons) - Standard SwiftBar Pattern
- Each category is separate script: `filereminders.1d.sh`, `calendar.1d.sh`
- Each creates own menu bar icon: `📬 3`, `📋 2`, `⚠️ 1`
- Each icon appears only when count > 0 (`exit 0` otherwise)
- **Implementation**: Follow coding standard below for all scripts
- **Pros**: Clear category identity; instant visual scan; truly independent; different refresh rates
- **Cons**: Multiple icons when multiple categories active
- **Best for**: 2-3 categories max, modular development, acceptable screen space

**Current Decision**: Starting with **Option B** to prototype and evaluate real-world icon density. Can refactor to Option A if menu bar becomes too crowded.

### Coding Standard for Option B (Independent Scripts)
All scripts must follow this pattern to keep menu bar clean:
```bash
#!/bin/bash

# ... calculate count ...

# EXIT if nothing to show (critical!)
if [ "$count" -eq 0 ]; then
    exit 0
fi

# Show icon only when needed
echo "📬 $count"
echo "---"
# ... rest of menu ...
```

### File Organization
- **Active scripts**: Place in main directory (loaded by SwiftBar)
- **Examples/disabled**: Use `examples/` folder or `.` prefix to hide from SwiftBar
- Example: `examples/.notify-example.10s.sh` won't load

## Notifications

For longer content, use SwiftBar notifications:

```
swiftbar://notify?plugin=script.sh&title=Title&body=Content%20here
```

URL encode special characters (space = `%20`, newline = `%0A`).