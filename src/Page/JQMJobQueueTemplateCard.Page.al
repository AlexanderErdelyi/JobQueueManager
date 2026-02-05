page 52003 "JQM Job Queue Template Card"
{
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "JQM Job Queue Template";
    Caption = 'Job Queue Template Card';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the entry number.';
                    Editable = false;
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
            }
            group(Recurrence)
            {
                Caption = 'Recurrence';

                field("Recurring Job"; Rec."Recurring Job")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if this is a recurring job.';
                }
                field("Run on Mondays"; Rec."Run on Mondays")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the job runs on Mondays.';
                }
                field("Run on Tuesdays"; Rec."Run on Tuesdays")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the job runs on Tuesdays.';
                }
                field("Run on Wednesdays"; Rec."Run on Wednesdays")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the job runs on Wednesdays.';
                }
                field("Run on Thursdays"; Rec."Run on Thursdays")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the job runs on Thursdays.';
                }
                field("Run on Fridays"; Rec."Run on Fridays")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the job runs on Fridays.';
                }
                field("Run on Saturdays"; Rec."Run on Saturdays")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the job runs on Saturdays.';
                }
                field("Run on Sundays"; Rec."Run on Sundays")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the job runs on Sundays.';
                }
                field("Starting Time"; Rec."Starting Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the starting time for the job.';
                }
                field("Ending Time"; Rec."Ending Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ending time for the job.';
                }
                field("No. of Minutes between Runs"; Rec."No. of Minutes between Runs")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of minutes between runs.';
                }
            }
            group(Status)
            {
                Caption = 'Status';

                field("No. of Companies"; Rec."No. of Companies")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of companies mapped to this template.';
                }
                field("Has Configuration Differences"; Rec."Has Configuration Differences")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the same job exists in different companies with different configurations.';
                    Style = Unfavorable;
                    StyleExpr = Rec."Has Configuration Differences";
                }
                field("Configuration Difference Note"; Rec."Configuration Difference Note")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies details about the configuration differences.';
                    MultiLine = true;
                }
            }
            part(CompanyMappings; "JQM Job Queue Company Mapping")
            {
                ApplicationArea = All;
                Caption = 'Company Mappings';
                SubPageLink = "Template Entry No." = field("Entry No.");
                UpdatePropagation = Both;
            }
        }
        area(FactBoxes)
        {
            part(CompanySyncStatus; "JQM Job Queue Company Sync")
            {
                ApplicationArea = All;
                Caption = 'Company Sync Status';
                SubPageLink = "Template Entry No." = field("Entry No.");
            }
            part(ConfigDifferences; "JQM Config Differences")
            {
                ApplicationArea = All;
                Caption = 'Configuration Differences';
                SubPageLink = "Entry No." = field("Entry No.");
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
}
