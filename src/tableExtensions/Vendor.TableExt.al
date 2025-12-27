namespace BusinessCase.BusinessCase;

using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;

tableextension 50804 Vendor extends Vendor
{
    fields
    {
        field(50800; "Associated Customer No."; Code[20])
        {
            Caption = 'Associated Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer;
            Editable = false;
        }
    }
}
