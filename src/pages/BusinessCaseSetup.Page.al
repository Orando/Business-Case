
using Microsoft.Finance.Dimension.Correction;
using BusinessCase.BusinessCase;

page 50802 "Business Case Setup"
{
    ApplicationArea = All;
    Caption = 'Business Case Setup';
    PageType = Card;
    SourceTable = "Business Case Setup";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field(Activate; Rec.Activate)
                {
                    ToolTip = 'Specifies the value of the Activate field.', Comment = '%';
                }
                field("Auto Create Vendor"; Rec."Auto Create Associated Vendor")
                {
                    ToolTip = 'Specifies the value of the Auto Create Vendor field.', Comment = '%';
                }
            }
            group(Templates)
            {
                Caption = 'Templates';
                field("Customer Template Code"; Rec."Customer Template Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer template';
                }
                field("Vendor Template Code"; Rec."Vendor Template Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the vendor template';
                }
            }
            group(Items)
            {
                Caption = 'Transaction Items';
                field("Commission Item No."; Rec."Commission Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the item for commission lines';
                }
                field("AdsGMO Item No."; Rec."AdsGMO Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the item for advertising lines';
                }
            }
            group(ENDPOINT)
            {
                Caption = 'Endpoint Configuration';

                field("API Endpoint URL"; Rec."Fiscal Data Endpoint")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Fiscal Data endpoint URL';
                }
                field("Transaction Data Endpoint"; Rec."Transaction Data Endpoint")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the transaction data endpoint URL';
                }
                field("API Key"; Rec."API Key")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the API key';
                    ExtendedDatatype = Masked;
                }
            }

            group(DimmensionCorrection)
            {
                Caption = 'Dimension Correction';

                field("Enable Auto Correction"; Rec."Enable Auto Correction")
                {
                    ApplicationArea = All;
                    ToolTip = 'Enable automatic dimension correction via job queue';
                }
                field("Days to Process"; Rec."Days to Process")
                {
                    ApplicationArea = All;
                    ToolTip = 'Number of days to look back for G/L entries to correct';
                }
            }
            group("Job Queue")
            {
                Caption = 'Job Queue Settings';

                field("Job Queue Category Code"; Rec."Job Queue Category Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Job Queue Category Code field.';
                }
                field("Execution Time"; Rec."Execution Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Time of day when automatic correction should run';
                }
            }
            group(Notification)
            {
                Caption = 'Notification';

                field("Enable Email Notification"; Rec."Enable Email Notification")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Enable Email Notification field.';
                }
                field("Notification Email"; Rec."Notification Email")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Notification Email field.';
                }
            }
            group("Last Run")
            {
                Caption = 'Last Run Information';

                field("Last Run Date"; Rec."Last Run Date")
                {
                    ApplicationArea = All;
                    Style = Attention;
                    StyleExpr = Rec."Last Run Status" = Rec."Last Run Status"::Error;
                    ToolTip = 'Specifies the value of the Last Run Date field.';
                }
                field("Last Run Time"; Rec."Last Run Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Last Run Time field.';
                }
                field("Last Run Status"; Rec."Last Run Status")
                {
                    ApplicationArea = All;
                    Style = Favorable;
                    StyleExpr = Rec."Last Run Status" = Rec."Last Run Status"::Success;
                    ToolTip = 'Specifies the value of the Last Run Status field.';
                }
                field("Last Error Message"; Rec."Last Error Message")
                {
                    ApplicationArea = All;
                    MultiLine = true;
                    ToolTip = 'Specifies the value of the Last Error Message field.';
                }
            }

        }
    }

    actions
    {
        area(Processing)
        {
            action(SetupJobQueue)
            {
                ApplicationArea = All;
                Caption = 'Setup Job Queue';
                Image = Job;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Create or update the job queue entry for automatic dimension correction';

                trigger OnAction()
                var
                    DimCorrectionMgt: Codeunit "Dimension Correction Mgt.";
                begin
                    DimCorrectionMgt.SetupJobQueue();
                end;
            }
            action(RunManually)
            {
                ApplicationArea = All;
                Caption = 'Run Correction Now';
                Image = ExecuteBatch;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Run dimension correction manually';

                trigger OnAction()
                var
                    DimCorrectionMgt: Codeunit "Dimension Correction Mgt";
                begin
                    if Confirm('Do you want to run dimension correction now?', false) then
                        DimCorrectionMgt.Run();
                end;
            }
            action(ViewLogs)
            {
                ApplicationArea = All;
                Caption = 'View Correction Logs';
                Image = Log;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = page "Dimension Correction Logs";
                ToolTip = 'Executes the View Correction Logs action.';
            }

        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}
