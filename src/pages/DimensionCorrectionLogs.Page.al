namespace BusinessCase.BusinessCase;

page 50804 "Dimension Correction Logs"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Dimension Correction Logs';
    PageType = List;
    SourceTable = "Dimension correction Log";

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
                field("Correction Date"; Rec."Correction Date")
                {
                    ToolTip = 'Specifies the value of the Correction Date field.', Comment = '%';
                }
                field("Correction Time"; Rec."Correction Time")
                {
                    ToolTip = 'Specifies the value of the Correction Time field.', Comment = '%';
                }
                field("User ID"; Rec."User ID")
                {
                    ToolTip = 'Specifies the value of the User ID field.', Comment = '%';
                }
                field("Execution Type"; Rec."Execution Type")
                {
                    ToolTip = 'Specifies the value of the Execution Type field.', Comment = '%';
                }
                field("G/L Entry No."; Rec."G/L Entry No.")
                {
                    ToolTip = 'Specifies the value of the G/L Entry No. field.', Comment = '%';
                }
                field("G/L Account No."; Rec."G/L Account No.")
                {
                    ToolTip = 'Specifies the value of the G/L Account No. field.', Comment = '%';
                }
                field("Dimension Code"; Rec."Dimension Code")
                {
                    ToolTip = 'Specifies the value of the Dimension Code field.', Comment = '%';
                }
                field("Old Dimension Value"; Rec."Old Dimension Value")
                {
                    ToolTip = 'Specifies the value of the Old Dimension Value field.', Comment = '%';
                }
                field("New Dimension Value"; Rec."New Dimension Value")
                {
                    ToolTip = 'Specifies the value of the New Dimension Value field.', Comment = '%';
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies the value of the Status field.', Comment = '%';
                }
                field("Error Message"; Rec."Error Message")
                {
                    ToolTip = 'Specifies the value of the Error Message field.', Comment = '%';
                }
                field("Dimension Correction ID"; Rec."Dimension Correction ID")
                {
                    ToolTip = 'Specifies the value of the Dimension Correction ID field.', Comment = '%';
                }
            }
        }
    }
}
