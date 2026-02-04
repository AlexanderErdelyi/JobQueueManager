# Job Queue Manager

A Business Central AL extension for centralized management of Job Queue Entries across multiple companies using a template-based approach.

## Overview

This extension helps manage Job Queue Entries across multiple companies in Business Central. Instead of manually creating the same job queue entries in each company, you can:
- Use templates to define job queue entries in one central location
- Automatically detect duplicate jobs across companies
- Identify configuration differences in the same job across companies
- Specify which companies should have copies of each template
- Check synchronization status across companies
- Sync templates to maintain consistency across companies

## Features

### 1. Template-Based Management
- Define job queue templates that represent unique job definitions (Object Type + Object ID + Parameter String)
- Create templates manually or populate from existing job queue entries across all companies
- Each template consolidates job definitions that are the same across multiple companies

### 2. Intelligent Initial Population
- Scans all companies for existing job queue entries
- Automatically groups identical jobs (same Object Type, Object ID, and Parameter String)
- Creates only ONE template per unique job definition, even if it exists in multiple companies
- Detects configuration differences (recurring settings, schedule, frequency) across companies
- Flags templates where the same job has different configurations in different companies

### 3. Configuration Difference Detection
- Compares recurring job settings across companies:
  - Recurring Job enabled/disabled
  - Run days (Monday-Sunday)
  - Start/End times
  - Minutes between runs
- Visual indicators show which templates have configuration differences
- Detailed notes explain what settings differ and in which company

### 4. Synchronization Status
- Check if job queue entries are in sync across companies
- Visual indicators show sync status:
  - **Synced**: Entry is identical in the target company
  - **Out of Sync**: Entry exists but has different settings
  - **Not Created**: Entry doesn't exist in the target company

### 5. Sync Functionality
- One-click sync to replicate templates to target companies
- Creates job queue entries from templates in selected companies
- Compares key settings to ensure consistency

## Usage

### Initial Setup & Population

1. Open **Job Queue Manager** from the search
2. Click **Initial Population** to scan all companies
3. The system will:
   - Scan all companies for job queue entries
   - Create templates for unique job definitions
   - Create company mappings showing which companies have each job
   - Flag templates with configuration differences

### Managing Templates

1. Open **Job Queue Templates** from the Job Queue Manager
2. Review templates - look for the "Has Configuration Differences" flag
3. Click on a template to see details and configuration difference notes
4. Use **Manage Companies** to see which companies have this job
5. Use **Sync to Companies** to synchronize the template to mapped companies

### Working with Company Mappings

1. Open **Job Queue Company Mapping** from the Job Queue Manager
2. View which templates are mapped to which companies
3. Check sync status for each mapping
4. Use **Check Sync Status** to verify synchronization
5. Use **Sync to Companies** to replicate entries

### From Standard Job Queue Entries Page

1. Open **Job Queue Entries**
2. Click **Job Queue Template Manager** to open the template management system

## Object IDs

- **Table 52000**: Job Queue Manager Setup
- **Table 52001**: Job Queue Company Mapping
- **Table 52002**: Job Queue Template (NEW)
- **Page 52000**: Job Queue Manager
- **Page 52001**: Job Queue Company Mapping
- **Page 52002**: Job Queue Templates (NEW)
- **Page 52003**: Job Queue Template Card (NEW)
- **Codeunit 52000**: Job Queue Manager
- **Page Extension 52000**: Job Queue Entry Extension

## Installation

1. Download or clone this repository
2. Open in Visual Studio Code with AL Language extension
3. Update `app.json` with your:
   - Publisher name
   - Server settings in `.vscode/launch.json`
4. Press F5 to compile and deploy

## Technical Notes

- Uses Business Central API version 25.0+
- Requires NoImplicitWith feature
- Objects use ID range 52000-52999
- Data classification: CustomerContent
- Template-based architecture consolidates duplicate job definitions

## Key Concepts

### Templates
Templates represent unique job definitions identified by:
- Object Type to Run
- Object ID to Run  
- Parameter String

Each template stores the configuration for a job and can be mapped to multiple companies.

### Company Mappings
Mappings connect templates to target companies, tracking:
- Which companies should have the job
- The SystemId of the actual Job Queue Entry in that company
- Sync status for each company

### Configuration Differences
When the same job exists in multiple companies with different settings (e.g., different schedules), the template is flagged with "Has Configuration Differences" and a note explains what differs.

## License

This extension is provided as-is for use in Business Central environments.

## Support

For issues or feature requests, please open an issue in the repository.