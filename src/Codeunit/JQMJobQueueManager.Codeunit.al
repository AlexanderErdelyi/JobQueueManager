codeunit 52000 "JQM Job Queue Manager"
{
    procedure PopulateTemplatesFromAllCompanies()
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueTemplate: Record "JQM Job Queue Template";
        ExistingTemplate: Record "JQM Job Queue Template";
        JobQueueCompanyMapping: Record "JQM Job Queue Company Mapping";
        CompanyInfo: Record Company;
        TempJobQueueEntry: Record "Job Queue Entry" temporary;
        TemplateEntryNo: Integer;
        JobKey: Text[1024];
        JobKeyDict: Dictionary of [Text[1024], Integer];
        ConfigDifferences: Dictionary of [Integer, Boolean];
        DifferenceNotes: Dictionary of [Integer, Text[250]];
        CompanyCount: Integer;
        TruncatedParamString: Text[250];
        CurrentNote: Text[250];
    begin
        // Load existing templates into dictionary to avoid duplicates
        if ExistingTemplate.FindSet() then
            repeat
                TruncatedParamString := CopyStr(ExistingTemplate."Parameter String", 1, 250);
                JobKey := Format(ExistingTemplate."Object Type to Run", 0, 9) + '|' +
                        Format(ExistingTemplate."Object ID to Run") + '|' +
                        TruncatedParamString;
                if not JobKeyDict.ContainsKey(JobKey) then begin
                    JobKeyDict.Add(JobKey, ExistingTemplate."Entry No.");
                    ConfigDifferences.Add(ExistingTemplate."Entry No.", false);
                    DifferenceNotes.Add(ExistingTemplate."Entry No.", '');

                    // Store in temp table for comparison
                    TempJobQueueEntry.TransferFields(ExistingTemplate, true);
                    TempJobQueueEntry.ID := CreateGuid();
                    TempJobQueueEntry."Entry No." := ExistingTemplate."Entry No.";
                    TempJobQueueEntry."Object Type to Run" := ExistingTemplate."Object Type to Run";
                    TempJobQueueEntry."Object ID to Run" := ExistingTemplate."Object ID to Run";
                    TempJobQueueEntry."Recurring Job" := ExistingTemplate."Recurring Job";
                    TempJobQueueEntry."Run on Mondays" := ExistingTemplate."Run on Mondays";
                    TempJobQueueEntry."Run on Tuesdays" := ExistingTemplate."Run on Tuesdays";
                    TempJobQueueEntry."Run on Wednesdays" := ExistingTemplate."Run on Wednesdays";
                    TempJobQueueEntry."Run on Thursdays" := ExistingTemplate."Run on Thursdays";
                    TempJobQueueEntry."Run on Fridays" := ExistingTemplate."Run on Fridays";
                    TempJobQueueEntry."Run on Saturdays" := ExistingTemplate."Run on Saturdays";
                    TempJobQueueEntry."Run on Sundays" := ExistingTemplate."Run on Sundays";
                    TempJobQueueEntry."Starting Time" := ExistingTemplate."Starting Time";
                    TempJobQueueEntry."Ending Time" := ExistingTemplate."Ending Time";
                    TempJobQueueEntry."No. of Minutes between Runs" := ExistingTemplate."No. of Minutes between Runs";
                    TempJobQueueEntry.Insert(true);
                end;
            until ExistingTemplate.Next() = 0;

        // First pass: collect all unique job definitions
        if CompanyInfo.FindSet() then
            repeat
                JobQueueEntry.ChangeCompany(CompanyInfo.Name);
                if JobQueueEntry.FindSet() then
                    repeat
                        // Create unique key: Object Type + Object ID + Parameter String (truncated consistently)
                        TruncatedParamString := CopyStr(JobQueueEntry."Parameter String", 1, 250);
                        JobKey := Format(JobQueueEntry."Object Type to Run", 0, 9) + '|' +
                                Format(JobQueueEntry."Object ID to Run") + '|' +
                                TruncatedParamString;

                        if not JobKeyDict.ContainsKey(JobKey) then begin
                            // Create new template
                            JobQueueTemplate.Init();
                            JobQueueTemplate."Entry No." := 0; // Allow AutoIncrement to assign
                            JobQueueTemplate."Object Type to Run" := JobQueueEntry."Object Type to Run";
                            JobQueueTemplate."Object ID to Run" := JobQueueEntry."Object ID to Run";
                            JobQueueTemplate."Parameter String" := TruncatedParamString;
                            JobQueueTemplate.Description := CopyStr(JobQueueEntry.Description, 1, 250);
                            JobQueueTemplate."Recurring Job" := JobQueueEntry."Recurring Job";
                            JobQueueTemplate."Run on Mondays" := JobQueueEntry."Run on Mondays";
                            JobQueueTemplate."Run on Tuesdays" := JobQueueEntry."Run on Tuesdays";
                            JobQueueTemplate."Run on Wednesdays" := JobQueueEntry."Run on Wednesdays";
                            JobQueueTemplate."Run on Thursdays" := JobQueueEntry."Run on Thursdays";
                            JobQueueTemplate."Run on Fridays" := JobQueueEntry."Run on Fridays";
                            JobQueueTemplate."Run on Saturdays" := JobQueueEntry."Run on Saturdays";
                            JobQueueTemplate."Run on Sundays" := JobQueueEntry."Run on Sundays";
                            JobQueueTemplate."Starting Time" := JobQueueEntry."Starting Time";
                            JobQueueTemplate."Ending Time" := JobQueueEntry."Ending Time";
                            JobQueueTemplate."No. of Minutes between Runs" := JobQueueEntry."No. of Minutes between Runs";
                            JobQueueTemplate.Insert(true);

                            JobKeyDict.Add(JobKey, JobQueueTemplate."Entry No.");
                            ConfigDifferences.Add(JobQueueTemplate."Entry No.", false);
                            DifferenceNotes.Add(JobQueueTemplate."Entry No.", '');

                            // Store first occurrence in temp table for comparison
                            TempJobQueueEntry.TransferFields(JobQueueEntry, true);
                            TempJobQueueEntry."Entry No." := JobQueueTemplate."Entry No.";
                            TempJobQueueEntry.Insert();
                        end else begin
                            // Template already exists, check for configuration differences
                            TemplateEntryNo := JobKeyDict.Get(JobKey);
                            TempJobQueueEntry.SetRange("Entry No.", TemplateEntryNo);
                            if TempJobQueueEntry.FindFirst() then begin
                                if not CompareJobQueueSettings(TempJobQueueEntry, JobQueueEntry) then begin
                                    ConfigDifferences.Set(TemplateEntryNo, true);
                                    // Append to existing note instead of replacing
                                    if DifferenceNotes.ContainsKey(TemplateEntryNo) then
                                        CurrentNote := DifferenceNotes.Get(TemplateEntryNo)
                                    else
                                        CurrentNote := '';

                                    if CurrentNote <> '' then
                                        CurrentNote += '; ';
                                    CurrentNote += CompanyInfo.Name;
                                    DifferenceNotes.Set(TemplateEntryNo, CopyStr(CurrentNote, 1, 250));
                                end;
                            end;
                        end;

                        // Create company mapping
                        TemplateEntryNo := JobKeyDict.Get(JobKey);
                        if not JobQueueCompanyMapping.Get(TemplateEntryNo, CompanyInfo.Name) then begin
                            JobQueueCompanyMapping.Init();
                            JobQueueCompanyMapping."Template Entry No." := TemplateEntryNo;
                            JobQueueCompanyMapping."Company Name" := CompanyInfo.Name;
                            JobQueueCompanyMapping."Source Job Queue Entry ID" := JobQueueEntry.SystemId;
                            JobQueueCompanyMapping."Target Job Queue Entry ID" := JobQueueEntry.SystemId;
                            JobQueueCompanyMapping."Object Type to Run" := JobQueueEntry."Object Type to Run";
                            JobQueueCompanyMapping."Object ID to Run" := JobQueueEntry."Object ID to Run";
                            // Set correct initial status based on whether config matches template
                            TempJobQueueEntry.SetRange("Entry No.", TemplateEntryNo);
                            if TempJobQueueEntry.FindFirst() then begin
                                if CompareJobQueueSettings(TempJobQueueEntry, JobQueueEntry) then
                                    JobQueueCompanyMapping."Sync Status" := JobQueueCompanyMapping."Sync Status"::Synced
                                else
                                    JobQueueCompanyMapping."Sync Status" := JobQueueCompanyMapping."Sync Status"::"Out of Sync";
                            end else
                                JobQueueCompanyMapping."Sync Status" := JobQueueCompanyMapping."Sync Status"::"Not Created";
                            JobQueueCompanyMapping.Insert();
                        end;
                    until JobQueueEntry.Next() = 0;
            until CompanyInfo.Next() = 0;

        // Update templates with configuration difference flags
        if JobQueueTemplate.FindSet() then
            repeat
                if ConfigDifferences.ContainsKey(JobQueueTemplate."Entry No.") then begin
                    JobQueueTemplate."Has Configuration Differences" := ConfigDifferences.Get(JobQueueTemplate."Entry No.");
                    if DifferenceNotes.ContainsKey(JobQueueTemplate."Entry No.") and
                       (DifferenceNotes.Get(JobQueueTemplate."Entry No.") <> '') then
                        JobQueueTemplate."Configuration Difference Note" :=
                            'Differences in: ' + DifferenceNotes.Get(JobQueueTemplate."Entry No.");
                    JobQueueTemplate.Modify();
                end;
            until JobQueueTemplate.Next() = 0;

        CompanyCount := CompanyInfo.Count;
        Message('Initial population completed. Created %1 templates from %2 companies.', JobKeyDict.Count, CompanyCount);
    end;

    procedure CheckTemplateSync(TemplateEntryNo: Integer): Boolean
    var
        SourceTemplate: Record "JQM Job Queue Template";
        TargetJobQueueEntry: Record "Job Queue Entry";
        JobQueueCompanyMapping: Record "JQM Job Queue Company Mapping";
        CompanyInfo: Record Company;
        IsInSync: Boolean;
    begin
        if not SourceTemplate.Get(TemplateEntryNo) then
            exit(false);

        IsInSync := true;
        JobQueueCompanyMapping.SetRange("Template Entry No.", TemplateEntryNo);
        if JobQueueCompanyMapping.FindSet() then
            repeat
                if CompanyInfo.Get(JobQueueCompanyMapping."Company Name") then begin
                    TargetJobQueueEntry.ChangeCompany(JobQueueCompanyMapping."Company Name");

                    if IsNullGuid(JobQueueCompanyMapping."Target Job Queue Entry ID") then begin
                        JobQueueCompanyMapping."Sync Status" := JobQueueCompanyMapping."Sync Status"::"Not Created";
                        JobQueueCompanyMapping.Modify();
                        IsInSync := false;
                    end else begin
                        if TargetJobQueueEntry.GetBySystemId(JobQueueCompanyMapping."Target Job Queue Entry ID") then begin
                            if not CompareTemplateWithJobQueue(SourceTemplate, TargetJobQueueEntry, JobQueueCompanyMapping) then begin
                                JobQueueCompanyMapping."Sync Status" := JobQueueCompanyMapping."Sync Status"::"Out of Sync";
                                JobQueueCompanyMapping.Modify();
                                IsInSync := false;
                            end else begin
                                JobQueueCompanyMapping."Sync Status" := JobQueueCompanyMapping."Sync Status"::Synced;
                                JobQueueCompanyMapping."Last Sync Date Time" := CurrentDateTime;
                                JobQueueCompanyMapping.Modify();
                            end;
                        end else begin
                            JobQueueCompanyMapping."Sync Status" := JobQueueCompanyMapping."Sync Status"::"Not Created";
                            JobQueueCompanyMapping.Modify();
                            IsInSync := false;
                        end;
                    end;
                end;
            until JobQueueCompanyMapping.Next() = 0;

        exit(IsInSync);
    end;

    procedure SyncTemplateToCompanies(TemplateEntryNo: Integer)
    var
        SourceTemplate: Record "JQM Job Queue Template";
        TargetJobQueueEntry: Record "Job Queue Entry";
        JobQueueCompanyMapping: Record "JQM Job Queue Company Mapping";
        CompanyInfo: Record Company;
        SyncCount: Integer;
    begin
        if not SourceTemplate.Get(TemplateEntryNo) then
            Error('Template not found.');

        JobQueueCompanyMapping.SetRange("Template Entry No.", TemplateEntryNo);
        if JobQueueCompanyMapping.FindSet() then
            repeat
                if CompanyInfo.Get(JobQueueCompanyMapping."Company Name") then begin
                    TargetJobQueueEntry.ChangeCompany(JobQueueCompanyMapping."Company Name");

                    if not IsNullGuid(JobQueueCompanyMapping."Target Job Queue Entry ID") then begin
                        if TargetJobQueueEntry.GetBySystemId(JobQueueCompanyMapping."Target Job Queue Entry ID") then
                            TargetJobQueueEntry.Delete();
                    end;

                    CopyTemplateToJobQueue(SourceTemplate, TargetJobQueueEntry, JobQueueCompanyMapping."Company Name");

                    JobQueueCompanyMapping."Target Job Queue Entry ID" := TargetJobQueueEntry.SystemId;
                    JobQueueCompanyMapping."Sync Status" := JobQueueCompanyMapping."Sync Status"::Synced;
                    JobQueueCompanyMapping."Last Sync Date Time" := CurrentDateTime;
                    JobQueueCompanyMapping.Modify();

                    SyncCount += 1;
                end;
            until JobQueueCompanyMapping.Next() = 0;

        Message('Template has been synced to %1 companies.', SyncCount);
    end;

    local procedure CompareJobQueueSettings(Entry1: Record "Job Queue Entry"; Entry2: Record "Job Queue Entry"): Boolean
    begin
        exit(
            (Entry1."Recurring Job" = Entry2."Recurring Job") and
            (Entry1."Run on Mondays" = Entry2."Run on Mondays") and
            (Entry1."Run on Tuesdays" = Entry2."Run on Tuesdays") and
            (Entry1."Run on Wednesdays" = Entry2."Run on Wednesdays") and
            (Entry1."Run on Thursdays" = Entry2."Run on Thursdays") and
            (Entry1."Run on Fridays" = Entry2."Run on Fridays") and
            (Entry1."Run on Saturdays" = Entry2."Run on Saturdays") and
            (Entry1."Run on Sundays" = Entry2."Run on Sundays") and
            (Entry1."Starting Time" = Entry2."Starting Time") and
            (Entry1."Ending Time" = Entry2."Ending Time") and
            (Entry1."No. of Minutes between Runs" = Entry2."No. of Minutes between Runs")
        );
    end;

    local procedure CompareTemplateWithJobQueue(Template: Record "JQM Job Queue Template"; JobQueue: Record "Job Queue Entry"; Mapping: Record "JQM Job Queue Company Mapping"): Boolean
    var
        RecurringMatch: Boolean;
        WeekdayMatch: Boolean;
        TimeMatch: Boolean;
        MinutesMatch: Boolean;
    begin
        // Check Recurring Job
        RecurringMatch := (Template."Recurring Job" = JobQueue."Recurring Job") or Mapping."Allow Recurring Job Exception";

        // Check Weekdays
        WeekdayMatch := (
            (Template."Run on Mondays" = JobQueue."Run on Mondays") and
            (Template."Run on Tuesdays" = JobQueue."Run on Tuesdays") and
            (Template."Run on Wednesdays" = JobQueue."Run on Wednesdays") and
            (Template."Run on Thursdays" = JobQueue."Run on Thursdays") and
            (Template."Run on Fridays" = JobQueue."Run on Fridays") and
            (Template."Run on Saturdays" = JobQueue."Run on Saturdays") and
            (Template."Run on Sundays" = JobQueue."Run on Sundays")
        ) or Mapping."Allow Weekday Exception";

        // Check Times
        TimeMatch := (
            (Template."Starting Time" = JobQueue."Starting Time") and
            (Template."Ending Time" = JobQueue."Ending Time")
        ) or Mapping."Allow Time Exception";

        // Check Minutes Between Runs
        MinutesMatch := (Template."No. of Minutes between Runs" = JobQueue."No. of Minutes between Runs") or
                        Mapping."Allow Minutes Between Exception";

        exit(
            (Template."Object Type to Run" = JobQueue."Object Type to Run") and
            (Template."Object ID to Run" = JobQueue."Object ID to Run") and
            RecurringMatch and
            WeekdayMatch and
            TimeMatch and
            MinutesMatch
        );
    end;

    local procedure CopyTemplateToJobQueue(Template: Record "JQM Job Queue Template"; var TargetEntry: Record "Job Queue Entry"; CompanyName: Text[30])
    begin
        TargetEntry.ChangeCompany(CompanyName);
        TargetEntry.Init();
        TargetEntry."Object Type to Run" := Template."Object Type to Run";
        TargetEntry."Object ID to Run" := Template."Object ID to Run";
        TargetEntry."Parameter String" := Template."Parameter String";
        TargetEntry.Description := Template.Description;
        TargetEntry."Recurring Job" := Template."Recurring Job";
        TargetEntry."Run on Mondays" := Template."Run on Mondays";
        TargetEntry."Run on Tuesdays" := Template."Run on Tuesdays";
        TargetEntry."Run on Wednesdays" := Template."Run on Wednesdays";
        TargetEntry."Run on Thursdays" := Template."Run on Thursdays";
        TargetEntry."Run on Fridays" := Template."Run on Fridays";
        TargetEntry."Run on Saturdays" := Template."Run on Saturdays";
        TargetEntry."Run on Sundays" := Template."Run on Sundays";
        TargetEntry."Starting Time" := Template."Starting Time";
        TargetEntry."Ending Time" := Template."Ending Time";
        TargetEntry."No. of Minutes between Runs" := Template."No. of Minutes between Runs";
        TargetEntry."User ID" := UserId;
        TargetEntry.Status := TargetEntry.Status::"On Hold";
        TargetEntry.Insert(true);
    end;

    // Legacy methods for backward compatibility
    procedure CheckJobQueueSync(JobQueueEntryID: Guid): Boolean
    begin
        // This is a legacy method - redirect to template-based method if needed
        Error('This method is deprecated. Please use CheckTemplateSync instead.');
    end;

    procedure SyncJobQueueToCompanies(JobQueueEntryID: Guid)
    begin
        // This is a legacy method - redirect to template-based method if needed
        Error('This method is deprecated. Please use SyncTemplateToCompanies instead.');
    end;

    procedure PopulateExistingJobQueues()
    begin
        // This is a legacy method - redirect to new method
        PopulateTemplatesFromAllCompanies();
    end;
}
