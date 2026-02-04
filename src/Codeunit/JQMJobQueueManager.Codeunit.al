codeunit 52000 "JQM Job Queue Manager"
{
    procedure PopulateTemplatesFromAllCompanies()
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueTemplate: Record "JQM Job Queue Template";
        JobQueueCompanyMapping: Record "JQM Job Queue Company Mapping";
        CompanyInfo: Record Company;
        TempJobQueueEntry: Record "Job Queue Entry" temporary;
        TemplateEntryNo: Integer;
        JobKey: Text[500];
        JobKeyDict: Dictionary of [Text[500], Integer];
        ConfigDifferences: Dictionary of [Integer, Boolean];
        DifferenceNotes: Dictionary of [Integer, Text[250]];
        CompanyCount: Integer;
    begin
        // First pass: collect all unique job definitions
        if CompanyInfo.FindSet() then
            repeat
                JobQueueEntry.ChangeCompany(CompanyInfo.Name);
                if JobQueueEntry.FindSet() then
                    repeat
                        // Create unique key: Object Type + Object ID + Parameter String
                        JobKey := Format(JobQueueEntry."Object Type to Run") + '|' + 
                                Format(JobQueueEntry."Object ID to Run") + '|' + 
                                JobQueueEntry."Parameter String";
                        
                        if not JobKeyDict.ContainsKey(JobKey) then begin
                            // Create new template
                            JobQueueTemplate.Init();
                            JobQueueTemplate."Object Type to Run" := JobQueueEntry."Object Type to Run";
                            JobQueueTemplate."Object ID to Run" := JobQueueEntry."Object ID to Run";
                            JobQueueTemplate."Parameter String" := CopyStr(JobQueueEntry."Parameter String", 1, 250);
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
                            TempJobQueueEntry.TransferFields(JobQueueEntry, false);
                            TempJobQueueEntry."Entry No." := JobQueueTemplate."Entry No.";
                            TempJobQueueEntry.Insert();
                        end else begin
                            // Template already exists, check for configuration differences
                            TemplateEntryNo := JobKeyDict.Get(JobKey);
                            if TempJobQueueEntry.Get(TemplateEntryNo) then begin
                                if not CompareJobQueueSettings(TempJobQueueEntry, JobQueueEntry) then begin
                                    ConfigDifferences.Set(TemplateEntryNo, true);
                                    DifferenceNotes.Set(TemplateEntryNo, 
                                        BuildDifferenceNote(TempJobQueueEntry, JobQueueEntry, CompanyInfo.Name));
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
                    if DifferenceNotes.ContainsKey(JobQueueTemplate."Entry No.") then
                        JobQueueTemplate."Configuration Difference Note" := DifferenceNotes.Get(JobQueueTemplate."Entry No.");
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
                            if not CompareTemplateWithJobQueue(SourceTemplate, TargetJobQueueEntry) then begin
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

    local procedure CompareTemplateWithJobQueue(Template: Record "JQM Job Queue Template"; JobQueue: Record "Job Queue Entry"): Boolean
    begin
        exit(
            (Template."Object Type to Run" = JobQueue."Object Type to Run") and
            (Template."Object ID to Run" = JobQueue."Object ID to Run") and
            (Template."Recurring Job" = JobQueue."Recurring Job") and
            (Template."Run on Mondays" = JobQueue."Run on Mondays") and
            (Template."Run on Tuesdays" = JobQueue."Run on Tuesdays") and
            (Template."Run on Wednesdays" = JobQueue."Run on Wednesdays") and
            (Template."Run on Thursdays" = JobQueue."Run on Thursdays") and
            (Template."Run on Fridays" = JobQueue."Run on Fridays") and
            (Template."Run on Saturdays" = JobQueue."Run on Saturdays") and
            (Template."Run on Sundays" = JobQueue."Run on Sundays") and
            (Template."Starting Time" = JobQueue."Starting Time") and
            (Template."Ending Time" = JobQueue."Ending Time") and
            (Template."No. of Minutes between Runs" = JobQueue."No. of Minutes between Runs")
        );
    end;

    local procedure BuildDifferenceNote(Entry1: Record "Job Queue Entry"; Entry2: Record "Job Queue Entry"; CompanyName: Text[30]): Text[250]
    var
        Note: Text[250];
    begin
        Note := 'Different in ' + CompanyName + ': ';
        
        if Entry1."Recurring Job" <> Entry2."Recurring Job" then
            Note += 'Recurring, ';
        if Entry1."Starting Time" <> Entry2."Starting Time" then
            Note += 'Start Time, ';
        if Entry1."Ending Time" <> Entry2."Ending Time" then
            Note += 'End Time, ';
        if Entry1."No. of Minutes between Runs" <> Entry2."No. of Minutes between Runs" then
            Note += 'Frequency, ';
        if (Entry1."Run on Mondays" <> Entry2."Run on Mondays") or
           (Entry1."Run on Tuesdays" <> Entry2."Run on Tuesdays") or
           (Entry1."Run on Wednesdays" <> Entry2."Run on Wednesdays") or
           (Entry1."Run on Thursdays" <> Entry2."Run on Thursdays") or
           (Entry1."Run on Fridays" <> Entry2."Run on Fridays") or
           (Entry1."Run on Saturdays" <> Entry2."Run on Saturdays") or
           (Entry1."Run on Sundays" <> Entry2."Run on Sundays") then
            Note += 'Run Days, ';
        
        if StrLen(Note) > 2 then
            Note := CopyStr(Note, 1, StrLen(Note) - 2); // Remove trailing comma and space
        
        exit(Note);
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
