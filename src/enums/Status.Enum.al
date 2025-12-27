

enum 50801 Status
{
    Extensible = true;

    value(0; Received)
    {
        Caption = 'Received';
    }
    value(1; Processing)
    {
        Caption = 'Processing';
    }
    value(2; Processed)
    {
        Caption = 'Processed';
    }
    value(3; Failed)
    {
        Caption = 'Failed';
    }
    value(4; Sent)
    {
        Caption = 'Sent';
    }
    value(5; Acknowledged)
    {
        Caption = 'Acknowledged';
    }
}
