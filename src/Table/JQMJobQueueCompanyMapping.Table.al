table 52001 "JQM Job Queue Company Mapping"
{
    DataClassification = CustomerContent;
    Caption = 'Job Queue Company Mapping';

    fields
    {
        field(1; "Template Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Template Entry No.';
            TableRelation = "JQM Job Queue Template"."Entry No.";
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
        field(6; "Source Job Queue Entry ID"; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Source Job Queue Entry ID';
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
        key(PK; "Template Entry No.", "Company Name")
        {
            Clustered = true;
        }
    }
}
