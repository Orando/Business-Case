table 50803 "Dimension Correction Rules"
{
    Caption = 'Dimension Correction Rules';
    DataClassification = ToBeClassified;


    fields
    {
        field(1; "G/L Account No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'G/L Account No.';
            TableRelation = "G/L Account";
        }
        field(2; "Line No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Line No.';
        }
        field(10; "Dimension Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Dimension Code';
            TableRelation = Dimension;
        }
        field(20; Action; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Action';
            OptionMembers = Include,Exclude;
            OptionCaption = 'Include,Exclude';
        }
    }

    keys
    {
        key(PK; "G/L Account No.", "Line No.")
        {
            Clustered = true;
        }
    }
}
