

using Microsoft.Sales.Document;

tableextension 50801 "Sales Line" extends "Sales Line"
{
    fields
    {
        field(50200; "Campaign ID"; Code[100])
        {
            Caption = 'Campaign ID';
            DataClassification = ToBeClassified;
        }
    }
}
