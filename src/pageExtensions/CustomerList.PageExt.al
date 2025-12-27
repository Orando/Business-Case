

using Microsoft.Sales.Customer;

pageextension 50801 "Customer List" extends "Customer List"
{
    layout
    {
        addafter("No.")
        {
            field("ActorExternal ID "; Rec."Actor External ID")
            {
                ApplicationArea = All;
                Caption = 'Actorexternal ID ';
                Editable = false;
                ToolTip = 'Specifies the value of the Actorexternal ID  field.';
            }
        }

    }
}
