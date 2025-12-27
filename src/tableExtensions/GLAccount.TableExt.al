namespace BusinessCase.BusinessCase;

using Microsoft.Finance.GeneralLedger.Account;

tableextension 50805 "G/L Account" extends "G/L Account"
{
    fields
    {
        field(50800; "Allow Correction"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Allow Correction';
            InitValue = true;
        }
        field(50801; "Correction Type"; enum "Correction Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Correction Type';

        }
        field(50802; "Require Approval"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Require Approval';
        }
        field(50803; "Last Correction Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Last Correction Date';
            Editable = false;
        }
        field(50804; "Reason Code Required"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Reason Code Required';
        }
    }
}
