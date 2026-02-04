page 52000 "JQM Job Queue Manager"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "JQM Job Queue Manager Setup";
    Caption = 'Job Queue Manager';
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                
                field("Auto Sync Enabled"; Rec."Auto Sync Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if automatic synchronization is enabled.';
                }
                field("Last Sync Date Time"; Rec."Last Sync Date Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the last synchronization occurred.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(PopulateExisting)
            {
                ApplicationArea = All;
                Caption = 'Populate Existing Job Queues';
                ToolTip = 'Populate existing job queue entries from all companies.';
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    JobQueueMgr: Codeunit "JQM Job Queue Manager";
                begin
                    JobQueueMgr.PopulateExistingJobQueues();
                end;
            }
            action(OpenMappings)
            {
                ApplicationArea = All;
                Caption = 'Company Mappings';
                ToolTip = 'Open the job queue company mappings.';
                Image = Setup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    JobQueueCompanyMapping: Page "JQM Job Queue Company Mapping";
                begin
                    JobQueueCompanyMapping.Run();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec."Primary Key" := '';
            Rec.Insert();
        end;
    end;
}
