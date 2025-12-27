

using Microsoft.Finance.GeneralLedger.Ledger;

tableextension 50802 "G/L Entry" extends "G/L Entry"
{
    fields
    {
        field(50200; "Allow Dimension Correction"; Boolean)
        {
            Caption = 'Allow Dimension Correction';
            DataClassification = ToBeClassified;
        }
    }
}
