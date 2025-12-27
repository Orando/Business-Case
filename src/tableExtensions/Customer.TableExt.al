
using Microsoft.Sales.Customer;
using Microsoft.Purchases.Vendor;

tableextension 50800 Customer extends Customer
{
    fields
    {
        field(50200; "Last Updated Date/Time"; DateTime)
        {
            Caption = 'Last Updated Date/Time';
            DataClassification = CustomerContent;
        }
        field(50201; "Actor External ID"; Code[20])
        {
            Caption = 'Actorexternal ID ';
            DataClassification = CustomerContent;
        }
        field(50202; "Associated Vendor No."; Code[20])
        {
            TableRelation = Vendor;
            Editable = false;
        }
    }
}
