table 52002 "JQM Job Queue Template"
{
    DataClassification = CustomerContent;
    Caption = 'Job Queue Template';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; Description; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
        field(3; "Object Type to Run"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Object Type to Run';
            OptionMembers = " ",Report,Codeunit;
            OptionCaption = ' ,Report,Codeunit';
        }
        field(4; "Object ID to Run"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Object ID to Run';
        }
        field(5; "Parameter String"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Parameter String';
        }
        field(10; "Recurring Job"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Recurring Job';
        }
        field(11; "Run on Mondays"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Run on Mondays';
        }
        field(12; "Run on Tuesdays"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Run on Tuesdays';
        }
        field(13; "Run on Wednesdays"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Run on Wednesdays';
        }
        field(14; "Run on Thursdays"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Run on Thursdays';
        }
        field(15; "Run on Fridays"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Run on Fridays';
        }
        field(16; "Run on Saturdays"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Run on Saturdays';
        }
        field(17; "Run on Sundays"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Run on Sundays';
        }
        field(20; "Starting Time"; Time)
        {
            DataClassification = CustomerContent;
            Caption = 'Starting Time';
        }
        field(21; "Ending Time"; Time)
        {
            DataClassification = CustomerContent;
            Caption = 'Ending Time';
        }
        field(22; "No. of Minutes between Runs"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'No. of Minutes between Runs';
            MinValue = 0;
        }
        field(30; "Has Configuration Differences"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Has Configuration Differences';
            Editable = false;
        }
        field(31; "Configuration Difference Note"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Configuration Difference Note';
            Editable = false;
        }
        field(40; "No. of Companies"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("JQM Job Queue Company Mapping" where("Template Entry No." = field("Entry No.")));
            Caption = 'No. of Companies';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(ObjectKey; "Object Type to Run", "Object ID to Run", "Parameter String")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Entry No.", Description, "Object Type to Run", "Object ID to Run")
        {
        }
    }
}
