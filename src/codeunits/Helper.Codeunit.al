namespace BusinessCase.BusinessCase;

using Microsoft.Foundation.NoSeries;
using Microsoft.Purchases.Setup;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Inventory.Item;
using System.IO;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;

codeunit 50803 Helper
{
    procedure GetJsonValue(JsonObject: JsonObject; KeyName: Text): Text
    var
        JsonToken: JsonToken;
    begin
        if JsonObject.Get(KeyName, JsonToken) then
            exit(JsonToken.AsValue().AsText());
        exit('');
    end;

    procedure GenerateVendorNo(Customer: Record Customer): Code[20]
    var
        VendorSetup: Record "Purchases & Payables Setup";
        NoSeriesMgt: Codeunit "No. Series";
        VendorNo: Code[20];
    begin
        VendorSetup.Get();
        VendorSetup.TestField("Vendor Nos.");
        VendorNo := NoSeriesMgt.GetNextNo(VendorSetup."Vendor Nos.", WorkDate(), true);
        exit(VendorNo);
    end;

    procedure LinkCustomerVendor(var Customer: Record Customer; var Vendor: Record Vendor)
    begin
        Customer."Associated Vendor No." := Vendor."No.";
        Customer.Modify(true);

        Vendor."Associated Customer No." := Customer."No.";
        Vendor.Modify(true);
    end;

    procedure ApplyVendorTemplate(var Vendor: Record Vendor; TemplateCode: Code[20])
    var
        ConfigTemplateHeader: Record "Config. Template Header";
        ConfigTemplateMgt: Codeunit "Config. Template Management";
        RecRef: RecordRef;
    begin
        if not ConfigTemplateHeader.Get(TemplateCode) then
            exit;

        RecRef.GetTable(Vendor);
        ConfigTemplateMgt.UpdateRecord(ConfigTemplateHeader, RecRef);
        RecRef.SetTable(Vendor);
        Vendor.Modify(true);
    end;

    procedure ValidateVATPostingSetup()
    var
        Customer: Record Customer;
        CommissionItem: Record Item;
        AdsGMOItem: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        BusinessCaseSetupRec: Record "Business Case Setup";
        IntegrationManagement: Codeunit "Integration Management";
    begin
        IntegrationManagement.GetBusinessSetup();

        if not Customer.Get(BusinessCaseSetupRec."Default Customer No.") then
            exit;

        if not CommissionItem.Get(BusinessCaseSetupRec."Commission Item No.") then
            exit;

        if not AdsGMOItem.Get(BusinessCaseSetupRec."AdsGMO Item No.") then
            exit;

        // Check Commission Item VAT Setup
        if not VATPostingSetup.Get(
            Customer."VAT Bus. Posting Group",
            CommissionItem."VAT Prod. Posting Group") then
            Error('VAT Posting Setup missing for:\nVAT Bus. Group: %1\nVAT Prod. Group: %2\n\nPlease configure in VAT Posting Setup.',
                Customer."VAT Bus. Posting Group",
                CommissionItem."VAT Prod. Posting Group");

        // Check AdsGMO Item VAT Setup
        if not VATPostingSetup.Get(
            Customer."VAT Bus. Posting Group",
            AdsGMOItem."VAT Prod. Posting Group") then
            Error('VAT Posting Setup missing for:\nVAT Bus. Group: %1\nVAT Prod. Group: %2\n\nPlease configure in VAT Posting Setup.',
                Customer."VAT Bus. Posting Group",
                AdsGMOItem."VAT Prod. Posting Group");
    end;

}
