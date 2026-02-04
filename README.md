# Job Queue Manager

A Business Central AL extension for centralized management of Job Queue Entries across multiple companies.

## Overview

This extension helps manage Job Queue Entries across multiple companies in Business Central. Instead of manually creating the same job queue entries in each company, you can:
- Define job queue entries in one central location
- Specify which companies should have copies of these entries
- Check synchronization status across companies
- Sync entries to maintain consistency
- Populate existing job queue entries from all companies

## Features

### 1. Centralized Management
- Manage job queue entries from a single location
- Map which companies should receive copies of each job queue entry

### 2. Synchronization Status
- Check if job queue entries are in sync across companies
- Visual indicators show sync status:
  - **Synced**: Entry is identical in the target company
  - **Out of Sync**: Entry exists but has different settings
  - **Not Created**: Entry doesn't exist in the target company

### 3. Sync Functionality
- One-click sync to replicate job queue entries to target companies
- Compares key settings:
  - Object Type and ID
  - Recurring settings
  - Run days (Monday-Sunday)
  - Start/End times
  - Minutes between runs

### 4. Population
- Import existing job queue entries from all companies
- Helps with initial setup when implementing the extension

## Usage

### Setup
1. Open **Job Queue Manager** from the search
2. Configure settings (optional: enable auto-sync)

### Managing Job Queues

#### From Job Queue Entries Page:
1. Open **Job Queue Entries**
2. Select a job queue entry
3. Click **Add Company Mapping** to add target companies
4. Click **Manage Across Companies** to view/edit mappings

#### From Company Mappings:
1. Open **Job Queue Company Mapping**
2. Create new mappings by specifying:
   - Source Job Queue Entry ID
   - Target Company Name
3. Use **Check Sync Status** to verify synchronization
4. Use **Sync to Companies** to replicate entries

### Initial Population
1. Open **Job Queue Manager**
2. Click **Populate Existing Job Queues**
3. Review populated mappings in **Company Mappings**

## Object IDs

- **Table 50100**: Job Queue Manager Setup
- **Table 50101**: Job Queue Company Mapping
- **Page 50100**: Job Queue Manager
- **Page 50101**: Job Queue Company Mapping
- **Codeunit 50100**: Job Queue Manager
- **Page Extension 50100**: Job Queue Entry Extension

## Installation

1. Download or clone this repository
2. Open in Visual Studio Code with AL Language extension
3. Update `app.json` with your:
   - Publisher name
   - Server settings in `.vscode/launch.json`
4. Press F5 to compile and deploy

## Technical Notes

- Uses Business Central API version 22.0+
- Requires NoImplicitWith feature
- Objects use ID range 50100-50149
- Data classification: CustomerContent

## License

This extension is provided as-is for use in Business Central environments.

## Support

For issues or feature requests, please open an issue in the repository.