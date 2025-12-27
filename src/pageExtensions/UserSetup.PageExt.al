

using System.Security.User;

pageextension 50802 "User Setup" extends "User Setup"
{
    layout
    {
        addlast(Content)
        {
            field("Run Dimension Correction"; Rec."Run Dimension Correction")
            {
                ApplicationArea = All;
                Caption = 'Run Dimension Correction';
                ToolTip = 'Specifies the value of the Run Dimension Correction field.';
            }
        }
    }
}
