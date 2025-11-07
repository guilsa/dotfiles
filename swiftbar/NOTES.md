# Nov 7

See option A and B below regarding menu hierarchy system.

Option B (Current): Each script you create will add another icon. Good for 2-3 max.
- filereminders.1d.sh → 📬 3 (when active)
- Future: calendar-reminders.1d.sh → 📅 2 (when active)

Option A (If needed later): Build ONE master script:
```bash
# reminders-hub.1d.sh - the ONLY active script
#!/bin/bash

# Check mail (inline or source a .sh that outputs counts only)
mail_count=$(find /path -name '*!.pdf' | wc -l)

# Check calendar (your future logic)
calendar_count=...

# Aggregate and display
total=$((mail_count + calendar_count))
if [ "$total" -eq 0 ]; then exit 0; fi

echo "🔔 $total"
echo "---"
echo "Mail Reminders ($mail_count)"
echo "--Open Mail Folder"
echo "---"
echo "Calendar ($calendar_count)"
echo "--View Calendar"
```