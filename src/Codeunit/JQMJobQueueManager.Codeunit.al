codeunit 52000 "JQM Job Queue Manager"
{
    procedure CheckJobQueueSync(JobQueueEntryID: Guid): Boolean
    var
        SourceJobQueueEntry: Record "Job Queue Entry";
        TargetJobQueueEntry: Record "Job Queue Entry";
        JobQueueCompanyMapping: Record "JQM Job Queue Company Mapping";
        CompanyInfo: Record Company;
        IsInSync: Boolean;
    begin
        if not SourceJobQueueEntry.GetBySystemId(JobQueueEntryID) then
            exit(false);

        IsInSync := true;
        JobQueueCompanyMapping.SetRange("Job Queue Entry ID", JobQueueEntryID);
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
                            if not CompareJobQueueEntries(SourceJobQueueEntry, TargetJobQueueEntry) then begin
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

    procedure SyncJobQueueToCompanies(JobQueueEntryID: Guid)
    var
        SourceJobQueueEntry: Record "Job Queue Entry";
        TargetJobQueueEntry: Record "Job Queue Entry";
        JobQueueCompanyMapping: Record "JQM Job Queue Company Mapping";
        CompanyInfo: Record Company;
    begin
        if not SourceJobQueueEntry.GetBySystemId(JobQueueEntryID) then
            Error('Source Job Queue Entry not found.');

        JobQueueCompanyMapping.SetRange("Job Queue Entry ID", JobQueueEntryID);
        if JobQueueCompanyMapping.FindSet() then
            repeat
                if CompanyInfo.Get(JobQueueCompanyMapping."Company Name") then begin
                    TargetJobQueueEntry.ChangeCompany(JobQueueCompanyMapping."Company Name");
                    
                    if not IsNullGuid(JobQueueCompanyMapping."Target Job Queue Entry ID") then begin
                        if TargetJobQueueEntry.GetBySystemId(JobQueueCompanyMapping."Target Job Queue Entry ID") then
                            TargetJobQueueEntry.Delete();
                    end;

                    CopyJobQueueEntry(SourceJobQueueEntry, TargetJobQueueEntry, JobQueueCompanyMapping."Company Name");
                    
                    JobQueueCompanyMapping."Target Job Queue Entry ID" := TargetJobQueueEntry.SystemId;
                    JobQueueCompanyMapping."Sync Status" := JobQueueCompanyMapping."Sync Status"::Synced;
                    JobQueueCompanyMapping."Last Sync Date Time" := CurrentDateTime;
                    JobQueueCompanyMapping.Modify();
                end;
            until JobQueueCompanyMapping.Next() = 0;

        Message('Job Queue Entry has been synced to %1 companies.', JobQueueCompanyMapping.Count);
    end;

    procedure PopulateExistingJobQueues()
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueCompanyMapping: Record "JQM Job Queue Company Mapping";
        CompanyInfo: Record Company;
        CurrentCompanyName: Text[30];
    begin
        CurrentCompanyName := CopyStr(CompanyName, 1, 30);
        
        if CompanyInfo.FindSet() then
            repeat
                if CompanyInfo.Name <> CurrentCompanyName then begin
                    JobQueueEntry.ChangeCompany(CompanyInfo.Name);
                    if JobQueueEntry.FindSet() then
                        repeat
                            if not JobQueueCompanyMapping.Get(JobQueueEntry.SystemId, CompanyInfo.Name) then begin
                                JobQueueCompanyMapping.Init();
                                JobQueueCompanyMapping."Job Queue Entry ID" := JobQueueEntry.SystemId;
                                JobQueueCompanyMapping."Company Name" := CompanyInfo.Name;
                                JobQueueCompanyMapping."Target Job Queue Entry ID" := JobQueueEntry.SystemId;
                                JobQueueCompanyMapping."Object Type to Run" := JobQueueEntry."Object Type to Run";
                                JobQueueCompanyMapping."Object ID to Run" := JobQueueEntry."Object ID to Run";
                                JobQueueCompanyMapping."Sync Status" := JobQueueCompanyMapping."Sync Status"::"Not Created";
                                JobQueueCompanyMapping.Insert();
                            end;
                        until JobQueueEntry.Next() = 0;
                end;
            until CompanyInfo.Next() = 0;

        Message('Existing Job Queue Entries have been populated.');
    end;

    local procedure CompareJobQueueEntries(SourceEntry: Record "Job Queue Entry"; TargetEntry: Record "Job Queue Entry"): Boolean
    begin
        exit(
            (SourceEntry."Object Type to Run" = TargetEntry."Object Type to Run") and
            (SourceEntry."Object ID to Run" = TargetEntry."Object ID to Run") and
            (SourceEntry."Recurring Job" = TargetEntry."Recurring Job") and
            (SourceEntry."Run on Mondays" = TargetEntry."Run on Mondays") and
            (SourceEntry."Run on Tuesdays" = TargetEntry."Run on Tuesdays") and
            (SourceEntry."Run on Wednesdays" = TargetEntry."Run on Wednesdays") and
            (SourceEntry."Run on Thursdays" = TargetEntry."Run on Thursdays") and
            (SourceEntry."Run on Fridays" = TargetEntry."Run on Fridays") and
            (SourceEntry."Run on Saturdays" = TargetEntry."Run on Saturdays") and
            (SourceEntry."Run on Sundays" = TargetEntry."Run on Sundays") and
            (SourceEntry."Starting Time" = TargetEntry."Starting Time") and
            (SourceEntry."Ending Time" = TargetEntry."Ending Time") and
            (SourceEntry."No. of Minutes between Runs" = TargetEntry."No. of Minutes between Runs")
        );
    end;

    local procedure CopyJobQueueEntry(SourceEntry: Record "Job Queue Entry"; var TargetEntry: Record "Job Queue Entry"; CompanyName: Text[30])
    begin
        TargetEntry.ChangeCompany(CompanyName);
        TargetEntry.Init();
        TargetEntry.TransferFields(SourceEntry, false);
        TargetEntry."User ID" := UserId;
        TargetEntry.Status := TargetEntry.Status::"On Hold";
        TargetEntry.Insert(true);
    end;
}
