table 50800 "Glovo Integration Logs"
{
    Caption = 'Glovo Integration Logs';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
        }
        field(2; "Direction"; Enum Direction)
        {

        }
        field(3; "Message Type"; Enum "Message Type")
        {

        }
        field(4; "JSON Content"; Blob)
        {
            Caption = 'Raw Message Content';
        }
        field(5; "Status"; enum Status)
        {
        }
        field(6; "Error Message"; Text[250])
        { }
        field(7; "Search Text"; Text[100])
        { }
        field(8; "External ID"; Code[50])
        { }
        field(9; "Processed At"; DateTime)
        { }
        field(10; "Message ID"; Code[20])
        { }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(status; "Message Type", Status)
        {

        }
    }
}
