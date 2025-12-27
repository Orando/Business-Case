

page 50800 Logs
{
    ApplicationArea = All;
    Caption = 'Logs';
    CardPageId = "Message Log Card";
    PageType = List;
    Editable = false;
    SourceTable = "Glovo Integration Logs";
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of the Entry No. field.', Comment = '%';
                }
                field("Message ID"; Rec."Message ID")
                {
                    ToolTip = 'Specifies the value of the Message ID field.', Comment = '%';
                }
                field(Direction; Rec.Direction)
                {
                    ToolTip = 'Specifies the value of the Direction field.', Comment = '%';
                }
                field("Processed At"; Rec."Processed At")
                {
                    ToolTip = 'Specifies the value of the Processed At field.', Comment = '%';
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies the value of the Status field.', Comment = '%';
                }
                field(Payload; Rec."JSON Content")
                {
                    ToolTip = 'Specifies the value of the Payload field.', Comment = '%';
                }
                field("Search Text"; Rec."Search Text")
                {
                    ToolTip = 'Specifies the value of the Search Text field.', Comment = '%';
                }
                field("Error Message"; Rec."Error Message")
                {
                    ToolTip = 'Specifies the value of the Error Message field.';
                }
            }
        }
    }
}
