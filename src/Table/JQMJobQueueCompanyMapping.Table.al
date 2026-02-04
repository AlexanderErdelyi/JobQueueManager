table 52001 "JQM Job Queue Company Mapping"
{
    DataClassification = CustomerContent;
    Caption = 'Job Queue Company Mapping';

    fields
    {
        field(1; "Job Queue Entry ID"; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Job Queue Entry ID';
            TableRelation = "Job Queue Entry".SystemId;
        }
        field(2; "Company Name"; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Company Name';
            TableRelation = Company.Name;
        }
        field(3; "Sync Status"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Sync Status';
            OptionMembers = " ",Synced,"Out of Sync","Not Created";
            OptionCaption = ' ,Synced,Out of Sync,Not Created';
        }
        field(4; "Last Sync Date Time"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Last Sync Date Time';
        }
        field(5; "Target Job Queue Entry ID"; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Target Job Queue Entry ID';
        }
        field(10; "Object Type to Run"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Object Type to Run';
            OptionMembers = " ",Report,Codeunit;
            OptionCaption = ' ,Report,Codeunit';
        }
        field(11; "Object ID to Run"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Object ID to Run';
        }
    }

    keys
    {
        key(PK; "Job Queue Entry ID", "Company Name")
        {
            Clustered = true;
        }
    }
}
