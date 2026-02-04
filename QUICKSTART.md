# Quick Start Guide

Get started with Job Queue Manager in 5 minutes!

## Prerequisites

- Business Central version 22.0 or higher
- Visual Studio Code with AL Language extension
- Access to a Business Central development environment
- Multiple companies in your Business Central database

## Installation Steps

### 1. Clone or Download

```bash
git clone https://github.com/AlexanderErdelyi/JobQueueManager.git
cd JobQueueManager
```

### 2. Configure Your Environment

Edit `.vscode/launch.json` and update these settings:

```json
{
  "server": "http://your-bc-server",
  "serverInstance": "BC220",  // Your BC instance name
  "port": 7049,                // Your BC port
  "authentication": "Windows"  // Or "AAD" for cloud
}
```

### 3. Update App Information

Edit `app.json` and update:

```json
{
  "publisher": "Your Company Name",
  "id": "your-unique-guid-here"  // Generate a new GUID
}
```

To generate a new GUID, use PowerShell:
```powershell
[guid]::NewGuid()
```

### 4. Download Dependencies (if needed)

If you're using dependencies:

```bash
# AL: Get-AL Extension Package
# This downloads base application symbols
```

### 5. Build and Deploy

In Visual Studio Code:
1. Open the JobQueueManager folder
2. Press `Ctrl+Shift+B` to build
3. Press `F5` to deploy and launch

Or use command line:
```bash
alc /project:"." /packagecachepath:".alpackages"
```

## First Use

### Step 1: Open Job Queue Manager

1. In Business Central, use search (Alt+Q)
2. Type "Job Queue Manager"
3. Open the setup page

### Step 2: Populate Existing Entries (Optional)

If you have existing job queues:
1. Click **Populate Existing Job Queues**
2. Wait for the confirmation message
3. Click **Company Mappings** to see populated entries

### Step 3: Create Your First Mapping

1. Go to **Job Queue Entries** page
2. Select or create a job queue entry you want to replicate
3. Click **Add Company Mapping**
4. Open the mapping record and set:
   - Target Company Name
5. Save

### Step 4: Sync to Target Company

1. Stay on the mapping or go to **Job Queue Company Mapping**
2. Find your mapping record
3. Click **Sync to Companies**
4. Confirm the action
5. ✓ Done! Entry is now in the target company

### Step 5: Activate in Target Company

1. Switch to the target company
2. Go to **Job Queue Entries**
3. Find the synced entry (Status = "On Hold")
4. Set Status to "Ready"

## Quick Commands Reference

### In Job Queue Entries Page
- **Add Company Mapping**: Quick add a new target company
- **Manage Across Companies**: View all mappings for selected entry

### In Job Queue Company Mapping Page
- **Check Sync Status**: Verify if entries are in sync
- **Sync to Companies**: Replicate entry to target companies

### In Job Queue Manager Page
- **Populate Existing Job Queues**: Import entries from all companies
- **Company Mappings**: Open the mappings list

## Common First-Time Issues

### Issue: Cannot find pages after deployment
**Solution:** Make sure the extension is installed and published. Check using:
- Extensions management page in Business Central
- Or search for the page by ID (50100)

### Issue: Permission errors
**Solution:** Ensure your user has:
- SUPER permission set, or
- Custom permission set including:
  - Read/Write on Job Queue Entry
  - Read/Write on custom tables 50100-50101
  - Read on Company table

### Issue: Cannot sync to certain companies
**Solution:** Check that:
- You have permissions in those companies
- The companies are not in a locked/restricted state
- The object IDs exist in target companies

## Next Steps

- Read [USAGE.md](USAGE.md) for detailed usage instructions
- Read [ARCHITECTURE.md](ARCHITECTURE.md) to understand the design
- Explore the code in `src/` folder
- Customize for your specific needs

## Getting Help

- Check the [README.md](README.md) for overview
- Review [USAGE.md](USAGE.md) for common scenarios
- Open an issue on GitHub for bugs or questions

## Customization Ideas

Once you're comfortable, consider:
- Adjusting the object ID range in app.json
- Adding custom fields to the mapping table
- Creating scheduled jobs for auto-sync
- Adding validation rules for your environment
- Creating reports for sync status

## Uninstallation

To remove the extension:
1. In Business Central, go to Extension Management
2. Find "Job Queue Manager"
3. Click Uninstall
4. Confirm data deletion (if you want to remove tables)

---

**Happy Job Queue Managing!** 🚀
