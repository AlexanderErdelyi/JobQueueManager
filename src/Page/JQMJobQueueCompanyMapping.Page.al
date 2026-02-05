page 52001 "JQM Job Queue Company Mapping"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "JQM Job Queue Company Mapping";
    Caption = 'Job Queue Company Mapping';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Template Entry No."; Rec."Template Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Template Entry No.';
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
                field("Allow Recurring Job Exception"; Rec."Allow Recurring Job Exception")
                {
                    ApplicationArea = All;
                    ToolTip = 'Allow this company to have a different Recurring Job setting than the template.';
                }
                field("Allow Weekday Exception"; Rec."Allow Weekday Exception")
                {
                    ApplicationArea = All;
                    ToolTip = 'Allow this company to run on different weekdays than the template.';
                }
                field("Allow Time Exception"; Rec."Allow Time Exception")
                {
                    ApplicationArea = All;
                    ToolTip = 'Allow this company to have different start/end times than the template.';
                }
                field("Allow Minutes Between Exception"; Rec."Allow Minutes Between Exception")
                {
                    ApplicationArea = All;
                    ToolTip = 'Allow this company to have different minutes between runs than the template.';
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
                    JobQueueMgr: Codeunit "JQM Job Queue Manager";
                begin
                    if Rec."Template Entry No." <> 0 then begin
                        if JobQueueMgr.CheckTemplateSync(Rec."Template Entry No.") then
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
                ToolTip = 'Synchronize the template to target companies.';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    JobQueueMgr: Codeunit "JQM Job Queue Manager";
                begin
                    if Rec."Template Entry No." <> 0 then begin
                        if Confirm('Do you want to sync this template to all mapped companies?') then begin
                            JobQueueMgr.SyncTemplateToCompanies(Rec."Template Entry No.");
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
