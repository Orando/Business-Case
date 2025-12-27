

page 50801 "Message Log Card"
{
    ApplicationArea = All;
    Caption = 'Message Log Card';
    PageType = Card;
    SourceTable = "Glovo Integration Logs";

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

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
            }
            group(ErrorInfo)
            {
                Caption = 'Error Information';
                Visible = Rec.Status = Rec.Status::Failed;
                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the error message';
                    MultiLine = true;
                    StyleExpr = ErrorStyle;
                }

            }
            group(MessageContent)
            {
                Caption = 'Message Content';
                field(Payload; Rec."JSON Content")
                {
                    ApplicationArea = All;
                    Caption = 'Content';
                    MultiLine = true;
                    Editable = false;
                    ToolTip = 'Shows the message content';
                }
            }
            group(Metadata)
            {
                Caption = 'Metadata';

                field("Search Text"; Rec."Search Text")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the search text';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        SetStyles();
    end;

    var
        MessageContentText: Text;
        StatusStyle: Text;
        ErrorStyle: Text;

    local procedure SetStyles()
    begin
        case Rec.Status of
            Rec.Status::Processed:
                StatusStyle := 'Favorable';
            Rec.Status::Failed:
                begin
                    StatusStyle := 'Unfavorable';
                    ErrorStyle := 'Unfavorable';
                end;
            Rec.Status::Acknowledged:
                StatusStyle := 'Ambiguous';
        end;
    end;
}
