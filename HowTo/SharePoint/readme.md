# Process to lock down search for Sharepoint

## 1. Site Searchability Setting
This controls whether the site itself appears in Microsoft Search and Copilot.
How to check and change it (manually)
- Go to the SharePoint site.
- Click ⚙️ Settings (top-right).
- Click Site information → View all site settings (or “Site settings” if the option is visible)
- Scroll down to the Search section.
- Click Search and offline availability.

Set this:
```
Allow this site to appear in search results?
```
```
No
```
- Click OK or Save.

## This prevents site-level indexing.

## 2. Library Searchability Settings
Each document library has its own indexing setting — even if the site is indexable, a library can be hidden (or vice-versa).
You'll need to check the Document Library (the actual files), and possibly Site Pages.
How to check and change (manually)
Check the Documents library:
- Open the Documents library.
- Click ⚙️ Settings → Library settings.
- Click Advanced settings.
- Scroll to the section:
```
Allow items from this document library to appear in search results?
```
```
No
```
- Save.

## 3. Check Site Pages (if you have pages you don't want indexed):
- Go to Site contents.
- Open Site Pages library.
- Settings → Library settings → Advanced settings.
- Same option as above:
```
Allow items from this library to appear in search results?
```
```
No
```
- Save

## 4. Permissions
Permissions override indexing.
Even if:
✔ The site indexing is OFF, and
✔ The library indexing is OFF…
If the site has:
❗ Everyone except external users
or
❗ All authenticated users

ANY user in your tenant can still see file names or surface content via Graph (Copilot).

You MUST remove that group.

### How to fix permissions (manually)
- Go to the SharePoint site.
- Click ⚙️ Settings → Site permissions.
- Look for:
```
"Everyone except external users"
```
```
"CompanyName Members" (if it includes all employees)
```
```
"All authenticated users"
```
- Click the dropdown next to it.
- Choose Remove or Remove from group.
- Verify inheritance (important!)
- On the permissions page, click Advanced permission settings.
- You should see groups like:
    - Site Owners
    - Site Members
    - Site Visitors
- Ensure "Everyone except external users" is NOT in any group.
- If you see them in:
    - Visitors → remove
    - Members → remove
    - Owners → immediately remove (critical)

Only the intended M365 group or specific users should remain.