# Usage Guide - Job Queue Manager Extension

This guide provides step-by-step instructions for using the Job Queue Manager extension.

## Table of Contents
1. [Initial Setup](#initial-setup)
2. [Populating Existing Job Queues](#populating-existing-job-queues)
3. [Creating Company Mappings](#creating-company-mappings)
4. [Checking Sync Status](#checking-sync-status)
5. [Synchronizing to Companies](#synchronizing-to-companies)
6. [Common Scenarios](#common-scenarios)

## Initial Setup

### First Time Configuration

1. **Open Job Queue Manager**
   - Use the search function (Alt+Q) and type "Job Queue Manager"
   - Click on the result to open the setup page

2. **Configure Settings**
   - Enable "Auto Sync Enabled" if you want automatic synchronization (future feature)
   - The "Last Sync Date Time" shows the last synchronization timestamp

## Populating Existing Job Queues

If you have existing job queue entries in multiple companies, you can populate them into the manager.

1. Open **Job Queue Manager**
2. Click **Actions** > **Populate Existing Job Queues**
3. The system will scan all companies and create mapping records
4. A confirmation message will appear when complete

**What this does:**
- Scans all companies in your Business Central environment
- Creates mapping records for existing job queue entries
- Sets initial status to "Not Created" (will be updated on first check)

## Creating Company Mappings

### Method 1: From Job Queue Entries Page

1. Navigate to **Job Queue Entries**
2. Select the job queue entry you want to replicate
3. Click **Manage Across Companies** to see existing mappings
4. Click **Add Company Mapping** to create a new mapping
5. Edit the new record to specify:
   - Target Company Name
   - Verify Object Type and Object ID are correct

### Method 2: From Company Mappings Page

1. Open **Job Queue Company Mapping** page
2. Click **New**
3. Fill in the fields:
   - **Job Queue Entry ID**: Select the source job queue entry
   - **Company Name**: Select the target company
   - **Object Type to Run**: Report or Codeunit
   - **Object ID to Run**: The ID of the object to run
4. Save the record

## Checking Sync Status

1. Open **Job Queue Company Mapping**
2. Select one or more mapping records
3. Click **Check Sync Status**
4. The system will:
   - Check if entries exist in target companies
   - Compare settings if they exist
   - Update the "Sync Status" field

**Status Values:**
- **Synced** (Green): Entry matches perfectly
- **Out of Sync** (Red): Entry exists but settings differ
- **Not Created** (Yellow): Entry doesn't exist in target company
- **Blank**: Not yet checked

## Synchronizing to Companies

1. Open **Job Queue Company Mapping**
2. Filter to a specific Job Queue Entry ID if desired
3. Click **Sync to Companies**
4. Confirm the action
5. The system will:
   - Delete any existing entries in target companies (if they exist)
   - Create new entries with matching settings
   - Update sync status and timestamp

**Important Notes:**
- Synced entries are created with status "On Hold"
- You must manually set them to "Ready" in each company
- The User ID will be set to the current user performing the sync

## Common Scenarios

### Scenario 1: New Job Queue for Multiple Companies

**Goal:** Create a new job queue entry and deploy it to 5 companies.

**Steps:**
1. Create the job queue entry in your main company
2. Go to **Job Queue Entries** and find your entry
3. Click **Add Company Mapping** 5 times (once per company)
4. Edit each mapping to specify the target company
5. Click **Sync to Companies** to deploy
6. Go to each target company and set the status to "Ready"

### Scenario 2: Update Existing Job Queue Settings

**Goal:** You changed the schedule on a job queue and need to update all companies.

**Steps:**
1. Modify the source job queue entry in your main company
2. Open **Job Queue Company Mapping**
3. Filter to your Job Queue Entry ID
4. Click **Check Sync Status** to verify they're "Out of Sync"
5. Click **Sync to Companies** to update all companies
6. Verify the changes in target companies

### Scenario 3: Audit Job Queues Across Companies

**Goal:** Check if job queues match across all companies.

**Steps:**
1. Open **Job Queue Manager**
2. Click **Populate Existing Job Queues** (if not done recently)
3. Open **Job Queue Company Mapping**
4. Click **Check Sync Status**
5. Filter by "Sync Status" = "Out of Sync" to see discrepancies
6. Review and decide whether to sync or update manually

### Scenario 4: Remove Job Queue from Multiple Companies

**Goal:** A job queue is no longer needed and should be removed from all companies.

**Steps:**
1. Open **Job Queue Company Mapping**
2. Filter to the Job Queue Entry ID
3. Note all target companies
4. Manually go to each company and delete the job queue entry
5. Delete the mapping records
6. Delete the source job queue entry

## Fields Reference

### Job Queue Company Mapping

| Field | Description |
|-------|-------------|
| Job Queue Entry ID | GUID of the source job queue entry |
| Company Name | Target company where the entry should be replicated |
| Sync Status | Current synchronization status |
| Last Sync Date Time | When the last sync occurred |
| Target Job Queue Entry ID | GUID of the created entry in target company |
| Object Type to Run | Report or Codeunit |
| Object ID to Run | ID of the object to run |

## What Gets Synchronized

The sync function copies these fields from source to target:
- Object Type to Run
- Object ID to Run
- Recurring Job settings
- Run on Days (Monday - Sunday)
- Starting Time
- Ending Time
- No. of Minutes between Runs
- Description
- Maximum No. of Attempts to Run
- Rerun Delay (sec.)
- And other standard Job Queue Entry fields

## Limitations and Best Practices

### Limitations
- Cannot sync job queue log entries (only the entry itself)
- User ID in target companies is set to the sync user
- Status is always set to "On Hold" after sync
- Cannot automatically handle object ID differences between environments

### Best Practices
- Always check sync status before syncing
- Review "Out of Sync" entries before deciding to sync
- Keep object IDs consistent across companies
- Document which job queues are managed centrally
- Regularly audit sync status
- Test in a non-production environment first

## Troubleshooting

### Issue: Sync fails with permission error
**Solution:** Ensure you have write permissions in all target companies

### Issue: Entry shows "Out of Sync" but settings look the same
**Solution:** Check all fields, including description and timing settings. Some fields may not be visible on the page.

### Issue: Cannot find job queue entry after sync
**Solution:** The entry is created with status "On Hold". Check the Job Queue Entries page in the target company and filter appropriately.

### Issue: Populate function doesn't find entries
**Solution:** Ensure you have read permissions in all companies and that job queue entries actually exist.

## Support

For issues, questions, or feature requests, please:
1. Check this guide first
2. Review the main README.md
3. Open an issue in the GitHub repository
