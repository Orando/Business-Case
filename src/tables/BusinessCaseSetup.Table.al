table 50802 "Business Case Setup"
{
    Caption = 'Business Case Setup';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            AllowInCustomizations = Never;
            Caption = 'Primary Key';
        }
        field(2; "Activate"; Boolean)
        {

        }
        field(3; "Customer Template Code"; Code[20])
        {
            TableRelation = "Customer Templ.".Code;
        }
        field(4; "Vendor Template Code"; Code[20])
        {
            TableRelation = "Vendor Templ.".Code;
        }
        field(5; "Auto Create Associated Vendor"; Boolean)
        {
            Caption = 'Auto Create Associated Vendor';
        }
        field(6; "Fiscal Data Endpoint"; Code[250])
        {
            Caption = 'Fiscal Data Endpoint';
        }
        field(7; "Transaction Data Endpoint"; Code[250])
        {
            Caption = 'Transaction Data Endpoint';
        }
        field(8; "API Key"; Text[250])
        {
            Caption = 'API Key';
            DataClassification = ToBeClassified;
        }
        field(9; "Commission Item No."; Code[20])
        {
            Caption = 'Commission Item No.';
            TableRelation = Item;
        }
        field(10; "AdsGMO Item No."; Code[20])
        {
            Caption = 'AdsGMO Item No.';
            TableRelation = Item;
        }
        field(11; "Default Customer No."; Code[20])
        {

        }
        field(12; "Enable Auto Correction"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Enable Auto Correction';
        }
        field(13; "Job Queue Category Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Job Queue Category Code';
            TableRelation = "Job Queue Category";
        }
        field(14; "Days to Process"; Integer)
        {

        }
        field(15; "Enable Email Notification"; Boolean)
        {

        }
        field(16; "Last Run Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Last Run Date';
            Editable = false;
        }
        field(17; "Last Run Time"; Time)
        {
            DataClassification = CustomerContent;
            Caption = 'Last Run Time';
            Editable = false;
        }
        field(18; "Last Run Status"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Last Run Status';
            OptionMembers = " ",Success,Error,"Partially Completed";
            OptionCaption = ' ,Success,Error,Partially Completed';
            Editable = false;
        }
        field(19; "Last Error Message"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Last Error Message';
            Editable = false;
        }

        field(20; "Notification Email"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Notification Email';
            ExtendedDatatype = EMail;
        }
        field(21; "Execution Time"; Time)
        {
            DataClassification = CustomerContent;
            Caption = 'Execution Time';
            InitValue = 020000T; // 2:00 AM
        }
    }
    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}
