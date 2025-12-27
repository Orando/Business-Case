namespace BusinessCase.BusinessCase;

using Microsoft.Finance.GeneralLedger.Account;

pageextension 50803 "G/L Account Card" extends "G/L Account Card"
{
    layout
    {
        addafter(General)
        {
            group(Correction)
            {
                field("Allow Correction"; Rec."Allow Correction")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Allow Correction field.';
                }
                field("Correction Type"; Rec."Correction Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Correction Type field.';
                }
                field("Require Approval"; Rec."Require Approval")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Require Approval field.';
                }
                field("Last Correction Date"; Rec."Last Correction Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Last Correction Date field.';
                }
                field("Reason Code Required"; Rec."Reason Code Required")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Reason Code Required field.';
                }
            }
        }
    }
}
