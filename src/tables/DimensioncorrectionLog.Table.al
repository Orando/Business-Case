table 50804 "Dimension correction Log"
{
    Caption = 'Dimension correction Log';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(10; "Correction Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Correction Date';
        }
        field(20; "Correction Time"; Time)
        {
            DataClassification = CustomerContent;
            Caption = 'Correction Time';
        }
        field(30; "User ID"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'User ID';
        }
        field(40; "Execution Type"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Execution Type';
            OptionMembers = Manual,Automatic;
            OptionCaption = 'Manual,Automatic';
        }
        field(50; "G/L Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'G/L Entry No.';
            TableRelation = "G/L Entry";
        }
        field(60; "G/L Account No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'G/L Account No.';
        }
        field(70; "Dimension Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Dimension Code';
        }
        field(80; "Old Dimension Value"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Old Dimension Value';
        }
        field(90; "New Dimension Value"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'New Dimension Value';
        }
        field(100; Status; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Status';
            OptionMembers = Success,Failed,Skipped;
            OptionCaption = 'Success,Failed,Skipped';
        }
        field(110; "Error Message"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Error Message';
        }
        field(120; "Dimension Correction ID"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Dimension Correction ID';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(SK1; "Correction Date", "Correction Time")
        {
        }
        key(SK2; "G/L Entry No.")
        {
        }
    }
}
