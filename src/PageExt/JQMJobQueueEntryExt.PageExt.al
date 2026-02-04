pageextension 52000 "JQM Job Queue Entry Ext" extends "Job Queue Entries"
{
    actions
    {
        addlast(Processing)
        {
            action(OpenTemplateManager)
            {
                ApplicationArea = All;
                Caption = 'Job Queue Template Manager';
                ToolTip = 'Open the job queue template manager to manage job queues across companies.';
                Image = Template;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    JobQueueTemplatesPage: Page "JQM Job Queue Templates";
                begin
                    JobQueueTemplatesPage.Run();
                end;
            }
        }
    }
}
