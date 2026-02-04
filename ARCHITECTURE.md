# Architecture & Design

## Overview

The Job Queue Manager extension provides centralized management of Job Queue Entries across multiple companies in Business Central. This document explains the architecture and design decisions.

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      Source Company                             │
│  ┌────────────────────────────────────────────────────────┐    │
│  │ Job Queue Entry (Standard BC Table)                    │    │
│  │ - SystemId (Guid)                                      │    │
│  │ - Object Type to Run                                   │    │
│  │ - Object ID to Run                                     │    │
│  │ - Recurring settings, schedule, etc.                   │    │
│  └────────────────┬───────────────────────────────────────┘    │
│                   │                                              │
│                   │ Referenced by                                │
│                   ▼                                              │
│  ┌────────────────────────────────────────────────────────┐    │
│  │ Job Queue Company Mapping (Custom Table 50101)         │    │
│  │ - Job Queue Entry ID → Source Entry                    │    │
│  │ - Company Name → Target Company                        │    │
│  │ - Sync Status                                          │    │
│  │ - Target Job Queue Entry ID → Created Entry           │    │
│  └────────────────┬───────────────────────────────────────┘    │
└───────────────────┼──────────────────────────────────────────┬─┘
                    │                                          │
                    │ Creates/Updates                          │
                    │                                          │
                    ▼                                          │
┌─────────────────────────────────────────────────┐           │
│              Target Company A                   │           │
│  ┌────────────────────────────────────────────┐ │           │
│  │ Job Queue Entry (Replicated)               │ │           │
│  │ - SystemId (New Guid)                      │ │           │
│  │ - Same settings as source                  │ │           │
│  └────────────────────────────────────────────┘ │           │
└─────────────────────────────────────────────────┘           │
                                                               │
┌─────────────────────────────────────────────────┐           │
│              Target Company B                   │           │
│  ┌────────────────────────────────────────────┐ │           │
│  │ Job Queue Entry (Replicated)               │ │           │
│  │ - SystemId (New Guid)                      │ │           │
│  │ - Same settings as source                  │ │           │
│  └────────────────────────────────────────────┘ │           │
└─────────────────────────────────────────────────┘           │
                                                               │
                    ... More Target Companies ...              │
                                                               │
                    ┌──────────────────────────────────────────┘
                    │ Managed by
                    ▼
       ┌────────────────────────────────┐
       │ Job Queue Manager Codeunit     │
       │ (Cod50100)                     │
       │ - CheckJobQueueSync()          │
       │ - SyncJobQueueToCompanies()    │
       │ - PopulateExistingJobQueues()  │
       └────────────────────────────────┘
```

## Core Components

### Tables

#### 1. Job Queue Manager Setup (Table 50100)
- **Purpose:** Store global settings for the extension
- **Key Fields:**
  - Primary Key (singleton record)
  - Auto Sync Enabled
  - Last Sync Date Time
- **Usage:** Configuration page backing table

#### 2. Job Queue Company Mapping (Table 50101)
- **Purpose:** Map source job queue entries to target companies
- **Key Fields:**
  - Job Queue Entry ID (link to source)
  - Company Name (target company)
  - Sync Status (tracking field)
  - Target Job Queue Entry ID (link to created entry)
  - Object Type/ID to Run (cached for display)
- **Key Design Decisions:**
  - Composite primary key (Entry ID + Company Name) ensures one mapping per company per entry
  - Sync Status is an Option field for easy filtering
  - Target Job Queue Entry ID allows reverse lookup

### Codeunit

#### Job Queue Manager (Codeunit 50100)

**Main Functions:**

1. **CheckJobQueueSync(JobQueueEntryID: Guid): Boolean**
   - Validates synchronization status across all mapped companies
   - Compares key fields between source and target entries
   - Updates Sync Status field in mappings
   - Returns true if all mappings are in sync

2. **SyncJobQueueToCompanies(JobQueueEntryID: Guid)**
   - Replicates job queue entry to all mapped companies
   - Deletes existing entries before creating new ones
   - Updates mapping records with new Target Job Queue Entry ID
   - Sets sync status and timestamp

3. **PopulateExistingJobQueues()**
   - Scans all companies for existing job queue entries
   - Creates mapping records for entries not yet tracked
   - Useful for initial setup or migration

**Helper Functions:**

- **CompareJobQueueEntries()**: Compares critical fields between two entries
- **CopyJobQueueEntry()**: Transfers fields from source to target entry

### Pages

#### 1. Job Queue Manager (Page 50100)
- **Type:** Card page
- **Purpose:** Main configuration interface
- **Actions:**
  - Populate Existing Job Queues
  - Open Company Mappings

#### 2. Job Queue Company Mapping (Page 50101)
- **Type:** List page
- **Purpose:** View and manage mappings
- **Features:**
  - Color-coded sync status
  - Check Sync Status action
  - Sync to Companies action
- **UI Enhancement:** StyleExpr for visual status indication

### Page Extensions

#### Job Queue Entry Extension (PageExt 50100)
- **Extends:** Standard Job Queue Entries page
- **Adds Actions:**
  - Manage Across Companies (opens filtered mapping page)
  - Add Company Mapping (quick add)

## Data Flow

### Sync Operation Flow

```
1. User triggers Sync
   ↓
2. Codeunit retrieves source Job Queue Entry
   ↓
3. For each mapping record:
   ↓
4. Change to target company context
   ↓
5. Delete existing target entry (if exists)
   ↓
6. Copy source entry to target company
   ↓
7. Update mapping with new Target Job Queue Entry ID
   ↓
8. Set Sync Status = Synced
   ↓
9. Record timestamp
```

### Check Status Flow

```
1. User triggers Check Sync
   ↓
2. Codeunit retrieves source Job Queue Entry
   ↓
3. For each mapping record:
   ↓
4. Change to target company context
   ↓
5. Attempt to retrieve target entry by SystemId
   ↓
6. If not found → Status = "Not Created"
   ↓
7. If found → Compare fields
   ↓
8. If match → Status = "Synced"
   ↓
9. If differ → Status = "Out of Sync"
```

## Design Decisions

### 1. Using SystemId for References
**Decision:** Use SystemId (Guid) instead of primary key fields
**Rationale:**
- Job Queue Entry uses multiple fields as primary key
- SystemId is unique, stable, and easier to reference
- Supports cross-company lookups

### 2. Status on Hold After Sync
**Decision:** Always create synced entries with Status = "On Hold"
**Rationale:**
- Prevents accidental execution before verification
- Gives administrators control over activation
- Safer approach for production environments

### 3. Comparison Fields
**Decision:** Compare specific critical fields, not all fields
**Rationale:**
- Some fields (like User ID, dates) naturally differ
- Focus on business-critical settings
- Reduces false "Out of Sync" alerts

### 4. Delete Before Create
**Decision:** Delete existing entry before creating new one during sync
**Rationale:**
- Ensures clean state
- Avoids primary key conflicts
- Simpler than update logic
- Ensures all fields are updated

### 5. Separate Mapping Table
**Decision:** Create separate mapping table instead of extending Job Queue Entry
**Rationale:**
- Cleaner separation of concerns
- Easier to manage mappings independently
- Can map same entry to multiple companies
- No impact on standard Job Queue Entry table

## Security Considerations

### Permissions Required
- Read access to Job Queue Entry in all companies
- Write access to Job Queue Entry in target companies
- Full access to Job Queue Company Mapping
- Read access to Company table

### Data Classification
- All custom fields: CustomerContent
- Appropriate for customer business data

## Extension Points

### Future Enhancements
1. **Scheduled Auto-Sync**: Use Job Queue to automatically sync on schedule
2. **Conflict Resolution**: Handle cases where manual changes were made
3. **Field Mapping**: Allow custom field mappings for different environments
4. **Audit Trail**: Track who performed syncs and what changed
5. **Bulk Operations**: Select multiple entries to sync at once
6. **Validation Rules**: Pre-sync validation of object availability
7. **Rollback**: Ability to revert sync operations
8. **Templates**: Save mapping configurations as templates

### Extensibility
The codeunit functions are public and can be called from other extensions or custom code.

## Performance Considerations

### Optimization Strategies
1. **ChangeCompany calls**: Minimized by grouping operations
2. **Bulk operations**: SetRange used to filter before iteration
3. **Lazy loading**: Only load target entries when needed
4. **No recursion**: All operations are iterative

### Scalability
- Handles multiple companies efficiently
- No significant performance impact on standard Job Queue Entry operations
- Mapping table size grows linearly with (entries × companies)

## Testing Considerations

### Test Scenarios
1. Create mapping and sync to new company
2. Modify source entry and verify "Out of Sync" detection
3. Sync updates and verify fields match
4. Delete target entry and verify "Not Created" status
5. Populate existing entries from multiple companies
6. Test with different object types (Report vs Codeunit)
7. Test with recurring and non-recurring job queues

### Edge Cases
- Empty company (no job queues)
- No permission in target company
- Invalid object IDs
- Null/empty SystemId values
- Concurrent modifications

## Dependencies

### Standard Business Central Objects
- Table: Job Queue Entry
- Table: Company
- Standard AL functions: ChangeCompany, GetBySystemId

### No External Dependencies
- Pure AL code
- No .NET interop
- No web services required
- Works offline

## Limitations

### Current Limitations
1. Cannot sync job queue log entries (history)
2. Cannot handle cross-environment syncs (different BC instances)
3. No conflict detection for concurrent modifications
4. No undo/rollback functionality
5. Limited to Report and Codeunit object types
6. Cannot sync related data (report selections, etc.)

### Working Within BC Constraints
- ChangeCompany limited to same database
- SystemId is read-only (cannot be assigned)
- Job Queue Entry uses complex primary key
- Status must be manually changed to Ready after sync
