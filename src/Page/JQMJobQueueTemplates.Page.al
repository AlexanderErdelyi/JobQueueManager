page 52002 "JQM Job Queue Templates"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "JQM Job Queue Template";
    Caption = 'Job Queue Templates';
    CardPageId = "JQM Job Queue Template Card";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the entry number.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description of the job queue template.';
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
                field("Parameter String"; Rec."Parameter String")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the parameter string.';
                }
                field("Recurring Job"; Rec."Recurring Job")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if this is a recurring job.';
                }
                field("No. of Companies"; Rec."No. of Companies")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of companies mapped to this template.';
                }
                field("Has Configuration Differences"; Rec."Has Configuration Differences")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the same job exists in different companies with different configurations.';
                    StyleExpr = DifferenceStyle;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ManageCompanies)
            {
                ApplicationArea = All;
                Caption = 'Manage Companies';
                ToolTip = 'Manage which companies should have this job queue entry.';
                Image = Company;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    JobQueueCompanyMapping: Record "JQM Job Queue Company Mapping";
                    CompanyMappingPage: Page "JQM Job Queue Company Mapping";
                begin
                    JobQueueCompanyMapping.SetRange("Template Entry No.", Rec."Entry No.");
                    CompanyMappingPage.SetTableView(JobQueueCompanyMapping);
                    CompanyMappingPage.Run();
                end;
            }
            action(PopulateExisting)
            {
                ApplicationArea = All;
                Caption = 'Initial Population';
                ToolTip = 'Populate templates from existing job queue entries in all companies.';
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    JobQueueMgr: Codeunit "JQM Job Queue Manager";
                begin
                    if Confirm('This will scan all companies and populate templates. Continue?') then begin
                        JobQueueMgr.PopulateTemplatesFromAllCompanies();
                        CurrPage.Update(false);
                    end;
                end;
            }
            action(SyncToCompanies)
            {
                ApplicationArea = All;
                Caption = 'Sync to Companies';
                ToolTip = 'Synchronize this template to all mapped companies.';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    JobQueueMgr: Codeunit "JQM Job Queue Manager";
                begin
                    if Confirm('Do you want to sync this template to all mapped companies?') then begin
                        JobQueueMgr.SyncTemplateToCompanies(Rec."Entry No.");
                        CurrPage.Update(false);
                    end;
                end;
            }
        }
    }

    var
        DifferenceStyle: Text;

    trigger OnAfterGetRecord()
    begin
        SetDifferenceStyle();
    end;

    local procedure SetDifferenceStyle()
    begin
        if Rec."Has Configuration Differences" then
            DifferenceStyle := 'Unfavorable'
        else
            DifferenceStyle := 'Standard';
    end;
}
