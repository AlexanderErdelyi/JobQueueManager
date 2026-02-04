pageextension 52000 "JQM Job Queue Entry Ext" extends "Job Queue Entries"
{
    actions
    {
        addlast(Processing)
        {
            action(ManageAcrossCompanies)
            {
                ApplicationArea = All;
                Caption = 'Manage Across Companies';
                ToolTip = 'Manage this job queue entry across multiple companies.';
                Image = CompanyInformation;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    JobQueueCompanyMapping: Record "JQM Job Queue Company Mapping";
                    JobQueueCompanyMappingPage: Page "JQM Job Queue Company Mapping";
                begin
                    JobQueueCompanyMapping.SetRange("Job Queue Entry ID", Rec.SystemId);
                    JobQueueCompanyMappingPage.SetTableView(JobQueueCompanyMapping);
                    JobQueueCompanyMappingPage.Run();
                end;
            }
            action(AddCompanyMapping)
            {
                ApplicationArea = All;
                Caption = 'Add Company Mapping';
                ToolTip = 'Add a mapping to sync this job queue to another company.';
                Image = Add;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    JobQueueCompanyMapping: Record "JQM Job Queue Company Mapping";
                    CompanyInfo: Record Company;
                    CompanyName: Text[30];
                begin
                    if CompanyInfo.FindSet() then begin
                        JobQueueCompanyMapping.Init();
                        JobQueueCompanyMapping."Job Queue Entry ID" := Rec.SystemId;
                        JobQueueCompanyMapping."Object Type to Run" := Rec."Object Type to Run";
                        JobQueueCompanyMapping."Object ID to Run" := Rec."Object ID to Run";
                        JobQueueCompanyMapping."Sync Status" := JobQueueCompanyMapping."Sync Status"::" ";
                        JobQueueCompanyMapping.Insert(true);
                        Message('Company mapping added. Please specify the target company.');
                    end;
                end;
            }
        }
    }
}
