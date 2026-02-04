page 50101 "Job Queue Company Mapping"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Job Queue Company Mapping";
    Caption = 'Job Queue Company Mapping';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Job Queue Entry ID"; Rec."Job Queue Entry ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Job Queue Entry ID.';
                }
                field("Company Name"; Rec."Company Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the target company name.';
                }
                field("Object Type to Run"; Rec."Object Type to Run")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the object type to run.';
                }
                field("Object ID to Run"; Rec."Object ID to Run")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the object ID to run.';
                }
                field("Sync Status"; Rec."Sync Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the synchronization status.';
                    StyleExpr = SyncStatusStyle;
                }
                field("Last Sync Date Time"; Rec."Last Sync Date Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the last sync occurred.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CheckSync)
            {
                ApplicationArea = All;
                Caption = 'Check Sync Status';
                ToolTip = 'Check if the job queue entries are in sync.';
                Image = CheckList;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    JobQueueMgr: Codeunit "Job Queue Manager";
                    JobQueueEntryID: Guid;
                begin
                    if Rec."Job Queue Entry ID" <> JobQueueEntryID then begin
                        if JobQueueMgr.CheckJobQueueSync(Rec."Job Queue Entry ID") then
                            Message('All mappings are in sync.')
                        else
                            Message('Some mappings are out of sync. Please review and sync.');
                        CurrPage.Update(false);
                    end;
                end;
            }
            action(SyncToCompanies)
            {
                ApplicationArea = All;
                Caption = 'Sync to Companies';
                ToolTip = 'Synchronize the job queue entry to target companies.';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    JobQueueMgr: Codeunit "Job Queue Manager";
                    JobQueueEntryID: Guid;
                begin
                    if Rec."Job Queue Entry ID" <> JobQueueEntryID then begin
                        if Confirm('Do you want to sync this job queue entry to all mapped companies?') then begin
                            JobQueueMgr.SyncJobQueueToCompanies(Rec."Job Queue Entry ID");
                            CurrPage.Update(false);
                        end;
                    end;
                end;
            }
        }
    }

    var
        SyncStatusStyle: Text;

    trigger OnAfterGetRecord()
    begin
        SetSyncStatusStyle();
    end;

    local procedure SetSyncStatusStyle()
    begin
        case Rec."Sync Status" of
            Rec."Sync Status"::Synced:
                SyncStatusStyle := 'Favorable';
            Rec."Sync Status"::"Out of Sync":
                SyncStatusStyle := 'Unfavorable';
            Rec."Sync Status"::"Not Created":
                SyncStatusStyle := 'Attention';
            else
                SyncStatusStyle := 'Standard';
        end;
    end;
}
