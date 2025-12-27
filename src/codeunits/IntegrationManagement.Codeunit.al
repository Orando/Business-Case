
using Microsoft.Purchases.Vendor;
using Microsoft.Inventory.Item;
using Microsoft.Sales.Document;
using Microsoft.Sales.Customer;
using System.IO;
using BusinessCase.BusinessCase;

codeunit 50800 "Integration Management"
{
    var
        BusinessCaseSetupRec: Record "Business Case Setup";
        LogProcessor: Codeunit "Log Processor";
        Helper: Codeunit Helper;
        ConfigTemplateMgt: Codeunit "Config. Template Management";

    procedure GetBusinessSetup()
    begin
        if not BusinessCaseSetupRec.Get() then
            BusinessCaseSetupRec.Init();
    end;

    procedure ProcessFiscalData(var MessagesPar: Record Messages)
    var
        JsonObject: JsonObject;
        MessageContent: Text;
        CustomerNo: Code[20];
        InStream: InStream;
    begin
        GetBusinessSetup();

        if not MessagesPar.Payload.HasValue then begin
            LogProcessor.LogError(MessagesPar."Entry No.", 'Invalid Payload format in message');
            Error('Invalid JSON format in message');
        end;

        //read the payload data and convert to json
        if MessagesPar.Payload.HasValue then begin
            MessagesPar.Payload.CreateInStream(InStream, TextEncoding::UTF8);
            InStream.ReadText(MessageContent);
        end;


        if JsonObject.ReadFrom(MessageContent) then
            CreateOrUpdateCustomer(JsonObject);

        // Log success with created records
        LogProcessor.FnLogToMessageLogs(MessagesPar);
    end;

    #region Process Customer data


    local procedure CreateOrUpdateCustomer(JsonObject: JsonObject)
    var
        Customer: Record Customer;
        ActorExternalId: Code[20];
        CustTemplateCode: Code[20];
        actorType: Text;
        iban: Text;
        partnerDealType: Text;
    begin
        // Parse JSON
        actorType := Helper.GetJsonValue(JsonObject, 'actorType');

        iban := Helper.GetJsonValue(JsonObject, 'iban');
        partnerDealType := Helper.GetJsonValue(JsonObject, 'partnerDealType');

        ActorExternalId := Format(Helper.GetJsonValue(JsonObject, 'actorExternalId'));

        // Check if customer exists based on external ID 
        Customer.SetRange("Actor External ID", ActorExternalId);
        if not Customer.FindFirst() then begin
            Customer.Init();
            Customer.Insert(true);
            Customer."Actor External ID" := ActorExternalId;
        end;

        // Map Fiscal Data
        Customer.Name := CopyStr(Helper.GetJsonValue(JsonObject, 'legalName'), 1, MaxStrLen(Customer.Name));
        Customer."Post Code" := CopyStr(Helper.GetJsonValue(JsonObject, 'postalCode'), 1, MaxStrLen(Customer."Post Code"));
        Customer.City := CopyStr(Helper.GetJsonValue(JsonObject, 'cityName'), 1, MaxStrLen(Customer.City));
        Customer."Country/Region Code" := CopyStr(Helper.GetJsonValue(JsonObject, 'countryCode'), 1, MaxStrLen(Customer."Country/Region Code"));
        Customer.Address := CopyStr(Helper.GetJsonValue(JsonObject, 'addressLine1'), 1, MaxStrLen(Customer.Address));
        Customer."Address 2" := CopyStr(Helper.GetJsonValue(JsonObject, 'addressLine2'), 1, MaxStrLen(Customer."Address 2"));
        Customer."Phone No." := CopyStr(Helper.GetJsonValue(JsonObject, 'phone'), 1, MaxStrLen(Customer."Phone No."));
        Customer."E-Mail" := CopyStr(Helper.GetJsonValue(JsonObject, 'email'), 1, MaxStrLen(Customer."E-Mail"));
        Customer."VAT Registration No." := CopyStr(Helper.GetJsonValue(JsonObject, 'taxId'), 1, MaxStrLen(Customer."VAT Registration No."));

        // Track the last update time 
        Customer."Last Updated Date/Time" := CurrentDateTime;

        // Apply Template for Posting Groups 
        ApplyGlovoTemplate(Customer);

        Customer.Modify(true);

        CreateVendorFromCustomer(Customer, JsonObject);
    end;

    local procedure ApplyGlovoTemplate(var Customer: Record Customer)
    var
        ConfigTemplateHeader: Record "Config. Template Header";
        RecRef: RecordRef;
    begin
        if BusinessCaseSetupRec."Customer Template Code" <> '' then
            if ConfigTemplateHeader.Get(BusinessCaseSetupRec."Customer Template Code") then begin
                RecRef.GetTable(Customer);
                ConfigTemplateMgt.UpdateRecord(ConfigTemplateHeader, RecRef);
                RecRef.SetTable(Customer);
                Customer.Modify();
            end;
    end;

    local procedure CreateVendorFromCustomer(var Customer: Record Customer; JsonObj: JsonObject)
    begin
        GetBusinessSetup();
        if not BusinessCaseSetupRec."Auto Create Associated Vendor" then
            exit;

        //create/link Vendor record
        CreateVendorInformation(Customer, JsonObj);
    end;

    #endregion Process Customer data

    local procedure CreateVendorInformation(var Customer: Record Customer; JsonObject: JsonObject)
    var
        Vendor: Record Vendor;
        VendorCode: Code[20];
    begin
        // Check if vendor already exists
        if Customer."Associated Vendor No." <> '' then
            exit;

        VendorCode := Helper.GenerateVendorNo(Customer);

        Vendor.Init();
        Vendor."No." := VendorCode;
        Vendor.Validate(Name, Customer.Name);
        Vendor.Validate("Name 2", Customer."Name 2");

        Vendor.Validate(Address, Customer.Address);
        Vendor.Validate("Address 2", Customer."Address 2");
        Vendor.Validate(City, Customer.City);
        Vendor.Validate("Post Code", Customer."Post Code");
        Vendor.Validate("Country/Region Code", Customer."Country/Region Code");
        Vendor.Validate("Phone No.", Customer."Phone No.");
        Vendor.Validate("E-Mail", Customer."E-Mail");
        Vendor.Validate(Contact, Customer.Contact);
        Vendor.Validate("VAT Registration No.", Customer."VAT Registration No.");
        Vendor.Insert();

        // Apply template
        if BusinessCaseSetupRec."Vendor Template Code" <> '' then
            Helper.ApplyVendorTemplate(Vendor, BusinessCaseSetupRec."Vendor Template Code");

        // Link customer and vendor
        Helper.LinkCustomerVendor(Customer, Vendor);

        Vendor."Last Date Modified" := Today;
        Vendor.Modify(true);
    end;

    procedure FnProcessTransactionData(var MessagesPar: Record Messages)
    var
        SalesHeaderRec: Record "Sales Header";
        SalesLineRec: Record "Sales Line";
        ItemRec: Record Item;
        JsonObject: JsonObject;
        MessageContent: Text;
        commissionAmountText: Text;
        adsGMOText: Text;
        gmvText: Text;
        campaignId: Text;
        orderId: Text;
        orderCode: Text;
        commissionAmount: Decimal;
        adsGMO: Decimal;
        gmv: Decimal;
        InStream: InStream;
    begin
        GetBusinessSetup();

        // Read the payload data and convert to JSON
        if MessagesPar.Payload.HasValue then begin
            MessagesPar.Payload.CreateInStream(InStream, TextEncoding::UTF8);
            InStream.ReadText(MessageContent);
        end else begin
            LogProcessor.LogError(MessagesPar."Entry No.", 'Payload is empty');
            exit;
        end;

        if not JsonObject.ReadFrom(MessageContent) then begin
            LogProcessor.LogError(MessagesPar."Entry No.", 'Invalid JSON format in transaction message');
            exit;
        end;

        commissionAmountText := Helper.GetJsonValue(JsonObject, 'commissionAmount');
        adsGMOText := Helper.GetJsonValue(JsonObject, 'adsGMO');
        gmvText := Helper.GetJsonValue(JsonObject, 'gmv');
        campaignId := Helper.GetJsonValue(JsonObject, 'campaignId');
        orderId := Helper.GetJsonValue(JsonObject, 'OrderID');
        orderCode := Helper.GetJsonValue(JsonObject, 'orderCode');

        if orderId = '' then begin
            LogProcessor.LogError(MessagesPar."Entry No.", 'OrderID is missing from JSON');
            exit;
        end;

        // Convert to decimals
        if not Evaluate(commissionAmount, commissionAmountText) then
            commissionAmount := 0;
        if not Evaluate(adsGMO, adsGMOText) then
            adsGMO := 0;
        if not Evaluate(gmv, gmvText) then
            gmv := 0;

        //Check for tax configurations
        Helper.ValidateVATPostingSetup();

        // Validate configuration
        if BusinessCaseSetupRec."Default Customer No." = '' then begin
            LogProcessor.LogError(MessagesPar."Entry No.", 'Default Customer No. is not configured');
            exit;
        end;
        if BusinessCaseSetupRec."Commission Item No." = '' then begin
            LogProcessor.LogError(MessagesPar."Entry No.", 'Commission Item No. is not configured');
            exit;
        end;
        if BusinessCaseSetupRec."AdsGMO Item No." = '' then begin
            LogProcessor.LogError(MessagesPar."Entry No.", 'AdsGMO Item No. is not configured');
            exit;
        end;

        // Create sales invoice header
        if not CreateSalesHeader(SalesHeaderRec, orderId, orderCode) then
            exit;


        // Commission line (taxable) - include GMV in description
        CreateSalesCommissionLine(SalesHeaderRec, SalesLineRec, MessagesPar, commissionAmount, gmv);

        // AdsGMO line (taxable) - include Campaign ID
        CreateSalesAdsGMOLine(SalesHeaderRec, SalesLineRec, MessagesPar, adsGMO, campaignId);

        // Validate that at least one line was created
        SalesLineRec.Reset();
        SalesLineRec.SetRange("Document Type", SalesHeaderRec."Document Type");
        SalesLineRec.SetRange("Document No.", SalesHeaderRec."No.");
        if not SalesLineRec.FindFirst() then begin
            LogProcessor.LogError(MessagesPar."Entry No.",
                'No sales lines created - both commission and adsGMO are zero');
            SalesHeaderRec.Delete(true);
            exit;
        end;

        // Log success
        LogProcessor.FnLogToMessageLogs(MessagesPar);
    end;

    procedure CreateSalesHeader(var SalesHeaderRec: Record "Sales Header"; orderId: Code[20]; orderCode: Code[20]): Boolean
    begin
        GetBusinessSetup();

        BusinessCaseSetupRec.TestField("Default Customer No.");

        SalesHeaderRec.Init();
        SalesHeaderRec.Validate("Document Type", SalesHeaderRec."Document Type"::Invoice);
        SalesHeaderRec.Validate("Sell-to Customer No.", BusinessCaseSetupRec."Default Customer No.");
        SalesHeaderRec.Validate("External Document No.", orderId);

        if orderCode <> '' then
            SalesHeaderRec.Validate("Your Reference", orderCode);

        SalesHeaderRec.Insert(true);

        exit(true);
    end;

    procedure CreateSalesCommissionLine(SalesHeaderRec: Record "Sales Header"; var SalesLineRec: Record "Sales Line"; var MessagesPar: Record Messages; CommissionAmount: Decimal; gmv: Decimal)
    var
        ItemRec: Record Item;
        LineNo: Integer;
    begin
        LineNo := 10000;
        if commissionAmount <> 0 then begin
            if not ItemRec.Get(BusinessCaseSetupRec."Commission Item No.") then begin
                LogProcessor.LogError(MessagesPar."Entry No.",
                    'Commission Item No. not found: ' + BusinessCaseSetupRec."Commission Item No.");
                exit;
            end;

            Clear(SalesLineRec);
            SalesLineRec.Init();
            SalesLineRec.Validate("Document Type", SalesHeaderRec."Document Type");
            SalesLineRec.Validate("Document No.", SalesHeaderRec."No.");
            SalesLineRec."Line No." := LineNo;
            SalesLineRec.Validate(Type, SalesLineRec.Type::Item);
            SalesLineRec.Validate("No.", BusinessCaseSetupRec."Commission Item No.");
            SalesLineRec.Validate(Quantity, 1);
            SalesLineRec.Validate("Unit Price", (commissionAmount + gmv));//GMV is supposed to be included on the commission amount line
            SalesLineRec.Validate(Description,
                'Commission (Order: ' + SalesHeaderRec."External Document No." + ') | GMV: ' + Format(gmv, 0, '<Precision,2:2><Standard Format,0>'));
            SalesLineRec.Insert(true);

            LineNo += 10000;
        end;
    end;

    procedure CreateSalesAdsGMOLine(SalesHeaderRec: Record "Sales Header"; var SalesLineRec: Record "Sales Line"; var MessagesPar: Record Messages; adsGMO: Decimal; campaignId: Text)
    var
        ItemRec: Record Item;
        LineNo: Integer;
    begin
        LineNo := 10000;
        if adsGMO <> 0 then begin
            if not ItemRec.Get(BusinessCaseSetupRec."AdsGMO Item No.") then begin
                LogProcessor.LogError(MessagesPar."Entry No.",
                    'AdsGMO Item No. not found: ' + BusinessCaseSetupRec."AdsGMO Item No.");
                exit;
            end;

            Clear(SalesLineRec);
            SalesLineRec.Init();
            SalesLineRec.Validate("Document Type", SalesHeaderRec."Document Type");
            SalesLineRec.Validate("Document No.", SalesHeaderRec."No.");
            SalesLineRec."Line No." := LineNo;
            SalesLineRec.Validate(Type, SalesLineRec.Type::Item);
            SalesLineRec.Validate("No.", BusinessCaseSetupRec."AdsGMO Item No.");
            SalesLineRec.Validate(Quantity, 1);
            SalesLineRec.Validate("Unit Price", adsGMO);
            SalesLineRec.Validate(Description,
                'AdsGMO (Campaign: ' + campaignId + ') | Order: ' + SalesHeaderRec."External Document No.");
            SalesLineRec.Validate("Campaign ID", campaignId);
            SalesLineRec.Insert(true);

            LineNo += 10000;
        end;
    end;

}
