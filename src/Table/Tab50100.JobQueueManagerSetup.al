table 50100 "Job Queue Manager Setup"
{
    DataClassification = CustomerContent;
    Caption = 'Job Queue Manager Setup';

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Primary Key';
        }
        field(2; "Auto Sync Enabled"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Auto Sync Enabled';
        }
        field(3; "Last Sync Date Time"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Last Sync Date Time';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}
