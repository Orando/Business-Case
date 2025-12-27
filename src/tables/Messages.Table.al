table 50801 Messages
{
    Caption = 'Messages';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; Payload; Blob)
        {
            Caption = 'Payload';
        }
        field(3; "Content Type"; Text[20])
        {
            Caption = 'Content Type';
        }
        field(4; Status; Enum Status)
        {
            Caption = 'Status';
        }
        field(5; Direction; Enum Direction)
        {
            Caption = 'Direction';
        }
        field(6; "Message Type"; Enum "Message Type")
        {
            Caption = 'Message Type';
        }
        field(7; "Received Date Time"; DateTime)
        {
            Caption = 'Received Date Time';
            Editable = false;
        }
        field(8; "Processed Date Time"; DateTime)
        {
            Caption = 'Processed Date Time';
            Editable = false;
        }
        field(9; "External Reference"; Code[50])
        {
            Caption = 'External Reference';
        }


    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}
