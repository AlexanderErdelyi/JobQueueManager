page 52004 "JQM Job Queue Company Sync"
{
    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = "JQM Job Queue Company Mapping";
    Caption = 'Companies';
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Company Name"; Rec."Company Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the company name.';
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
