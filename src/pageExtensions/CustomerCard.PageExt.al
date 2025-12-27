namespace DefaultPublisher.GLOVOBUSINESSCASE;

using Microsoft.Sales.Customer;

pageextension 50800 CustomerCard extends "Customer Card"
{
    layout
    {
        addlast(General)
        {
            field("Last Updated Date/Time"; Rec."Last Updated Date/Time")
            {
                ApplicationArea = All;
                Caption = 'Last Updated Date/Time';
                Editable = false;
            }
        }
    }
}