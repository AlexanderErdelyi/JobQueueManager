page 52005 "JQM Config Differences"
{
    PageType = CardPart;
    ApplicationArea = All;
    SourceTable = "JQM Job Queue Template";
    Caption = 'Configuration Differences';
    Editable = false;

    layout
    {
        area(Content)
        {
            group(Summary)
            {
                Caption = 'Summary';

                field("Has Configuration Differences"; Rec."Has Configuration Differences")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if there are configuration differences across companies.';
                    Style = Unfavorable;
                    StyleExpr = Rec."Has Configuration Differences";
                }
                field("Configuration Difference Note"; Rec."Configuration Difference Note")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies details about which companies have different configurations.';
                    MultiLine = true;
                    ShowCaption = false;
                }
            }
            group(Details)
            {
                Caption = 'Details';
                Visible = Rec."Has Configuration Differences";

                field(DifferenceDetails; DifferenceDetailsText)
                {
                    ApplicationArea = All;
                    Caption = 'Affected Fields';
                    ToolTip = 'Shows which configuration fields differ across companies.';
                    MultiLine = true;
                    ShowCaption = true;
                }
            }
        }
    }

    var
        DifferenceDetailsText: Text;

    trigger OnAfterGetRecord()
    begin
        CalculateDifferenceDetails();
    end;

    local procedure CalculateDifferenceDetails()
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueCompanyMapping: Record "JQM Job Queue Company Mapping";
        CompanyInfo: Record Company;
        Differences: List of [Text];
        DiffText: Text;
    begin
        DifferenceDetailsText := '';

        if not Rec."Has Configuration Differences" then
            exit;

        // Compare template configuration with each company's job queue entry
        JobQueueCompanyMapping.SetRange("Template Entry No.", Rec."Entry No.");
        if JobQueueCompanyMapping.FindSet() then
            repeat
                if CompanyInfo.Get(JobQueueCompanyMapping."Company Name") then begin
                    JobQueueEntry.ChangeCompany(CompanyInfo.Name);
                    if not IsNullGuid(JobQueueCompanyMapping."Target Job Queue Entry ID") then begin
                        if JobQueueEntry.GetBySystemId(JobQueueCompanyMapping."Target Job Queue Entry ID") then begin
                            // Compare template fields with job queue entry fields, considering exceptions
                            if (Rec."Recurring Job" <> JobQueueEntry."Recurring Job") and
                               (not JobQueueCompanyMapping."Allow Recurring Job Exception") then
                                if not Differences.Contains('Recurring Job') then
                                    Differences.Add('Recurring Job');

                            if (Rec."Starting Time" <> JobQueueEntry."Starting Time") or
                               (Rec."Ending Time" <> JobQueueEntry."Ending Time") then
                                if not JobQueueCompanyMapping."Allow Time Exception" then
                                    if not Differences.Contains('Starting/Ending Time') then
                                        Differences.Add('Starting/Ending Time');

                            if (Rec."No. of Minutes between Runs" <> JobQueueEntry."No. of Minutes between Runs") and
                               (not JobQueueCompanyMapping."Allow Minutes Between Exception") then
                                if not Differences.Contains('Minutes between Runs') then
                                    Differences.Add('Minutes between Runs');

                            if ((Rec."Run on Mondays" <> JobQueueEntry."Run on Mondays") or
                               (Rec."Run on Tuesdays" <> JobQueueEntry."Run on Tuesdays") or
                               (Rec."Run on Wednesdays" <> JobQueueEntry."Run on Wednesdays") or
                               (Rec."Run on Thursdays" <> JobQueueEntry."Run on Thursdays") or
                               (Rec."Run on Fridays" <> JobQueueEntry."Run on Fridays") or
                               (Rec."Run on Saturdays" <> JobQueueEntry."Run on Saturdays") or
                               (Rec."Run on Sundays" <> JobQueueEntry."Run on Sundays")) and
                               (not JobQueueCompanyMapping."Allow Weekday Exception") then
                                if not Differences.Contains('Weekdays') then
                                    Differences.Add('Weekdays');
                        end;
                    end;
                end;
            until JobQueueCompanyMapping.Next() = 0;

        // Build the difference text
        foreach DiffText in Differences do begin
            if DifferenceDetailsText <> '' then
                DifferenceDetailsText += ', ';
            DifferenceDetailsText += DiffText;
        end;

        if DifferenceDetailsText = '' then
            DifferenceDetailsText := 'No specific differences detected';
    end;
}
