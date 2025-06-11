# AD cleanup:

⸻

1. Start with a user audit
→ Pull a list of all enabled/disabled user accounts
→ Identify stale accounts (check last logon date, password last set, etc.)
→ Cross-reference with HR or department heads before removing anything

⸻

2. Check group memberships
→ Look for nested or redundant groups
→ Document what each group is actually used for
→ Remove users who’ve changed roles (especially from high-permission groups)

⸻

3. Review GPOs
→ Archive or remove unused Group Policy Objects
→ Watch for conflicting or overlapping policies
→ Keep naming consistent and intentional

⸻

4. Clean up stale computer objects
→ Use PowerShell or AD tools to find machines that haven’t connected in 30+ days
→ Confirm with inventory systems before disabling

⸻

5. Document EVERYTHING
→ Every user removed
→ Every policy changed
→ Every group adjusted