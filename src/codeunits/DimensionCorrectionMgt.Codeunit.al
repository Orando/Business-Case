namespace BusinessCase.BusinessCase;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.GeneralLedger.Account;
using System.Threading;
using System.EMail;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.Dimension.Correction;

codeunit 50804 "Dimension Correction Mgt."
{
    trigger OnRun()
    begin
        RunDimensionCorrection(false);
    end;

    var
        BusinessCaseSetup: Record "Business Case Setup";
        CorrectionLog: Record "Dimension Correction Log";
        TotalProcessed: Integer;
        TotalSuccess: Integer;
        TotalFailed: Integer;
        TotalSkipped: Integer;

    procedure RunDimensionCorrection(ManualExecution: Boolean)
    var
        GLEntry: Record "G/L Entry";
        DimensionCorrection: Record "Dimension Correction";
        FromDate: Date;
        ToDate: Date;
    begin
        Initialize();

        if not BusinessCaseSetup.Get() then
            Error('Dimension Correction Setup not found. Please configure the setup.');


        if not ManualExecution then
            if not BusinessCaseSetup."Enable Auto Correction" then
                exit;

        // Calculate date range
        ToDate := Today;
        FromDate := CalcDate('<-' + Format(BusinessCaseSetup."Days to Process") + 'D>', ToDate);

        // Update last run info
        UpdateLastRunInfo(true);

        // Process corrections
        ProcessGLEntriesForCorrection(FromDate, ToDate, ManualExecution);

        // Update final status
        UpdateLastRunInfo(false);

        // Send notification if enabled
        if BusinessCaseSetup."Enable Email Notification" then
            SendNotificationEmail(ManualExecution);

        ShowSummaryMessage(ManualExecution);
    end;

    local procedure Initialize()
    begin
        TotalProcessed := 0;
        TotalSuccess := 0;
        TotalFailed := 0;
        TotalSkipped := 0;
    end;

    local procedure ProcessGLEntriesForCorrection(FromDate: Date; ToDate: Date; ManualExecution: Boolean)
    var
        GLEntry: Record "G/L Entry";
        ExecutionType: Option Manual,Automatic;
    begin
        if ManualExecution then
            ExecutionType := ExecutionType::Manual
        else
            ExecutionType := ExecutionType::Automatic;

        // Get all G/L entries in date range
        GLEntry.SetRange("Posting Date", FromDate, ToDate);

        if GLEntry.FindSet() then
            repeat
                TotalProcessed += 1;

                // Check if account is eligible for correction
                if IsAccountEligibleForCorrection(GLEntry."G/L Account No.") then begin
                    // Get dimension corrections that should be applied
                    if ShouldCorrectEntry(GLEntry) then begin
                        if ProcessEntryCorrection(GLEntry, ExecutionType) then
                            TotalSuccess += 1
                        else
                            TotalFailed += 1;
                    end else begin
                        TotalSkipped += 1;
                        LogSkippedEntry(GLEntry, ExecutionType);
                    end;
                end else begin
                    TotalSkipped += 1;
                    LogSkippedEntry(GLEntry, ExecutionType);
                end;

                // Commit every 100 records to avoid long transactions
                if TotalProcessed mod 100 = 0 then
                    Commit();

            until GLEntry.Next() = 0;
    end;

    local procedure IsAccountEligibleForCorrection(GLAccountNo: Code[20]): Boolean
    var
        GLAccountRule: Record "G/L Account";
    begin
        // If no rules exist, allow all accounts
        if not GLAccountRule.Get(GLAccountNo) then
            exit(true);

        // Check if correction is allowed
        exit(GLAccountRule."Allow Correction");
    end;

    local procedure ShouldCorrectEntry(GLEntry: Record "G/L Entry"): Boolean
    var
        DimensionCorrection: Record "Dimension Correction";
        DimCorrectionEntryLog: Record "Dim Correction Entry Log";
    begin
        // Check if there are any pending dimension corrections
        DimensionCorrection.SetRange(Status, DimensionCorrection.Status::Completed);
        if not DimensionCorrection.FindSet() then
            exit(false);

        // Check if this entry is already corrected
        repeat
            DimCorrectionEntryLog.SetRange("Dimension Correction Entry No.", DimensionCorrection."Entry No.");
            DimCorrectionEntryLog.SetRange("Start Entry No.", GLEntry."Entry No.");
            if DimCorrectionEntryLog.FindFirst() then
                exit(false);
        until DimensionCorrection.Next() = 0;

        exit(true);
    end;

    local procedure ProcessEntryCorrection(GLEntry: Record "G/L Entry"; ExecutionType: Option): Boolean
    var
        DimensionCorrection: Record "Dimension Correction";
        TempSelectedDimCorrection: Record "Dimension Correction" temporary;
    begin
        // Get applicable dimension corrections
        DimensionCorrection.SetRange(Status, DimensionCorrection.Status::Completed);

        if not DimensionCorrection.FindSet() then
            exit(false);

        repeat
            // Check if this correction applies to this G/L account
            if IsCorrectionApplicable(DimensionCorrection, GLEntry."G/L Account No.") then begin
                TempSelectedDimCorrection := DimensionCorrection;
                TempSelectedDimCorrection.Insert();
            end;
        until DimensionCorrection.Next() = 0;

        // Apply corrections
        if TempSelectedDimCorrection.FindSet() then
            repeat
                if ApplySingleCorrection(TempSelectedDimCorrection, GLEntry, ExecutionType) then
                    exit(true);
            until TempSelectedDimCorrection.Next() = 0;


        exit(false);
    end;

    local procedure IsCorrectionApplicable(DimensionCorrection: Record "Dimension Correction"; GLAccountNo: Code[20]): Boolean
    var
        GLAccountRule: Record "G/L Account";
        DimCorrectionRuleDetail: Record "Dimension Correction Rules";
        DimCorrectionChange: Record "Dim Correction Change";
    begin
        // If no specific rules for this account, allow all corrections
        if not GLAccountRule.Get(GLAccountNo) then
            exit(true);

        // Check correction type rules
        case GLAccountRule."Correction Type" of
            GLAccountRule."Correction Type"::"All Dimensions":
                exit(true);

            GLAccountRule."Correction Type"::"Specific Dimensions Only":
                begin
                    // Check if any dimension in correction matches included dimensions
                    DimCorrectionChange.SetRange("Dimension Correction Entry No.", DimensionCorrection."Entry No.");
                    if DimCorrectionChange.FindSet() then
                        repeat
                            DimCorrectionRuleDetail.SetRange("G/L Account No.", GLAccountNo);
                            DimCorrectionRuleDetail.SetRange("Dimension Code", DimCorrectionChange."Dimension Code");
                            DimCorrectionRuleDetail.SetRange(Action, DimCorrectionRuleDetail.Action::Include);
                            if DimCorrectionRuleDetail.FindFirst() then
                                exit(true);
                        until DimCorrectionChange.Next() = 0;
                    exit(false);
                end;

            GLAccountRule."Correction Type"::"Exclude Specific Dimensions":
                begin
                    // Check if any dimension in correction is excluded
                    DimCorrectionChange.SetRange("Dimension Correction Entry No.", DimensionCorrection."Entry No.");
                    if DimCorrectionChange.FindSet() then
                        repeat
                            DimCorrectionRuleDetail.SetRange("G/L Account No.", GLAccountNo);
                            DimCorrectionRuleDetail.SetRange("Dimension Code", DimCorrectionChange."Dimension Code");
                            DimCorrectionRuleDetail.SetRange(Action, DimCorrectionRuleDetail.Action::Exclude);
                            if DimCorrectionRuleDetail.FindFirst() then
                                exit(false); // Excluded dimension found
                        until DimCorrectionChange.Next() = 0;
                    exit(true); // No excluded dimensions found
                end;
        end;

        exit(true);
    end;

    local procedure ApplySingleCorrection(DimensionCorrection: Record "Dimension Correction"; GLEntry: Record "G/L Entry"; ExecutionType: Option): Boolean
    var
        DimCorrectionChange: Record "Dim Correction Change";
        OldDimensionValue: Code[20];
        NewDimensionValue: Code[20];
    begin
        //standard BC Dimension Correction Management
        DimCorrectionChange.SetRange("Dimension Correction Entry No.", DimensionCorrection."Entry No.");
        if DimCorrectionChange.FindSet() then
            repeat
                OldDimensionValue := GetCurrentDimensionValue(GLEntry, DimCorrectionChange."Dimension Code");
                NewDimensionValue := DimCorrectionChange."New Value";

                if OldDimensionValue <> NewDimensionValue then
                    // Log the correction
                    LogCorrection(
                        GLEntry."Entry No.",
                        GLEntry."G/L Account No.",
                        DimCorrectionChange."Dimension Code",
                        OldDimensionValue,
                        NewDimensionValue,
                        DimensionCorrection."Entry No.",
                        ExecutionType);
            until DimCorrectionChange.Next() = 0;

        exit(true);
    end;

    local procedure GetCurrentDimensionValue(GLEntry: Record "G/L Entry"; DimensionCode: Code[20]): Code[20]
    var
        DimensionSetEntry: Record "Dimension Set Entry";
    begin
        DimensionSetEntry.SetRange("Dimension Set ID", GLEntry."Dimension Set ID");
        DimensionSetEntry.SetRange("Dimension Code", DimensionCode);
        if DimensionSetEntry.FindFirst() then
            exit(DimensionSetEntry."Dimension Value Code");

        exit('');
    end;

    local procedure LogCorrection(GLEntryNo: Integer; GLAccountNo: Code[20]; DimCode: Code[20]; OldValue: Code[20]; NewValue: Code[20]; DimCorrectionID: Integer; ExecutionType: Option)
    begin
        Clear(CorrectionLog);
        CorrectionLog.Init();
        CorrectionLog."Correction Date" := Today;
        CorrectionLog."Correction Time" := Time;
        CorrectionLog."User ID" := UserId;
        CorrectionLog."Execution Type" := ExecutionType;
        CorrectionLog."G/L Entry No." := GLEntryNo;
        CorrectionLog."G/L Account No." := GLAccountNo;
        CorrectionLog."Dimension Code" := DimCode;
        CorrectionLog."Old Dimension Value" := OldValue;
        CorrectionLog."New Dimension Value" := NewValue;
        CorrectionLog.Status := CorrectionLog.Status::Success;
        CorrectionLog."Dimension Correction ID" := DimCorrectionID;
        CorrectionLog.Insert(true);
    end;

    local procedure LogSkippedEntry(GLEntry: Record "G/L Entry"; ExecutionType: Option)
    begin
        Clear(CorrectionLog);
        CorrectionLog.Init();
        CorrectionLog."Correction Date" := Today;
        CorrectionLog."Correction Time" := Time;
        CorrectionLog."User ID" := UserId;
        CorrectionLog."Execution Type" := ExecutionType;
        CorrectionLog."G/L Entry No." := GLEntry."Entry No.";
        CorrectionLog."G/L Account No." := GLEntry."G/L Account No.";
        CorrectionLog.Status := CorrectionLog.Status::Skipped;
        CorrectionLog.Insert(true);
    end;

    local procedure UpdateLastRunInfo(IsStarting: Boolean)
    begin
        if not BusinessCaseSetup.Get() then
            exit;

        if IsStarting then begin
            BusinessCaseSetup."Last Run Date" := Today;
            BusinessCaseSetup."Last Run Time" := Time;
            BusinessCaseSetup."Last Run Status" := BusinessCaseSetup."Last Run Status"::" ";
            BusinessCaseSetup."Last Error Message" := '';
        end else
            if TotalFailed = 0 then
                BusinessCaseSetup."Last Run Status" := BusinessCaseSetup."Last Run Status"::Success
            else if TotalSuccess > 0 then
                BusinessCaseSetup."Last Run Status" := BusinessCaseSetup."Last Run Status"::"Partially Completed"
            else
                BusinessCaseSetup."Last Run Status" := BusinessCaseSetup."Last Run Status"::Error;

        BusinessCaseSetup.Modify(true);
    end;

    local procedure SendNotificationEmail(ManualExecution: Boolean)
    var
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        ExecutionTypeText: Text;
        Subject: Text;
        Body: Text;
        HtmlBody: Text;
        StatusStyle: Text;
        BodyLbl: Label 'Dimension Correction Summary<br/><br/>Execution Type: <strong>%1</strong><br/>Date: <strong>%2</strong><br/>Time: <strong>%3</strong><br/><br/><strong>Results:</strong><br/>Total Processed: %4<br/>Success: <span style="color: green;">%5</span><br/>Failed: <span style="color: red;">%6</span><br/>Skipped: <span style="color: orange;">%7</span><br/><br/>', Comment = '%1 %2 %3 %4 %5 %6 %7';
        FooterLbl: Label '<hr/><small>This is an automated notification from Glovo Business Central Integration.<br/>Please do not reply to this email.</small>';
    begin
        if BusinessCaseSetup."Notification Email" = '' then
            exit;

        if ManualExecution then
            ExecutionTypeText := 'Manual'
        else
            ExecutionTypeText := 'Automatic';

        Subject := StrSubstNo('Dimension Correction %1 Execution - %2', ExecutionTypeText, Today);

        // Create HTML formatted body
        Body := StrSubstNo(BodyLbl, ExecutionTypeText, Today, Time, TotalProcessed, TotalSuccess, TotalFailed, TotalSkipped);

        // Add status-based styling
        if TotalFailed > 0 then
            StatusStyle := '<div><strong>Attention Required:</strong> Some corrections failed. Please review the logs.</div>'
        else
            if TotalSkipped > 0 then
                StatusStyle := '<div><strong>Information:</strong> Some entries were skipped based on account rules.</div>'
            else
                StatusStyle := '<div><strong>Success:</strong> All corrections completed successfully.</div>';

        HtmlBody := '<html><body>Glovo Business Central - Dimension Correction Report</h2>' +
                   Body + StatusStyle + FooterLbl + '</body></html>';

        // Create and send email
        EmailMessage.Create(BusinessCaseSetup."Notification Email", Subject, HtmlBody, true);

        if Email.Send(EmailMessage) then
            // Log successful email send
            BusinessCaseSetup."Last Error Message" := ''
        else begin
            // Log email send failure
            BusinessCaseSetup."Last Error Message" := 'Failed to send notification email';
            BusinessCaseSetup.Modify(true);
        end;
    end;

    local procedure ShowSummaryMessage(ManualExecution: Boolean)
    var
        MessageText: Text;
        MessageLbl: Label 'Dimension Correction Completed\n\n Total Processed: %1\n Success: %2\n Failed: %3\n Skipped: %4', comment = '%1 %2 %3 %4';
    begin
        if not ManualExecution then
            exit;

        MessageText := StrSubstNo(MessageLbl, TotalProcessed, TotalSuccess, TotalFailed, TotalSkipped);
        Message(MessageText);
    end;

    procedure SetupJobQueue()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        if not BusinessCaseSetup.Get() then begin
            BusinessCaseSetup.Init();
            BusinessCaseSetup."Primary Key" := '';
            BusinessCaseSetup.Insert(true);
        end;

        // Delete existing job queue entry
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"Dimension Correction Mgt.");
        JobQueueEntry.DeleteAll(true);

        // Create new job queue entry
        JobQueueEntry.Init();
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := Codeunit::"Dimension Correction Mgt.";
        JobQueueEntry."Job Queue Category Code" := BusinessCaseSetup."Job Queue Category Code";
        JobQueueEntry.Description := 'Automated Dimension Correction';
        JobQueueEntry."Recurring Job" := true;
        JobQueueEntry."Run on Mondays" := true;
        JobQueueEntry."Run on Tuesdays" := true;
        JobQueueEntry."Run on Wednesdays" := true;
        JobQueueEntry."Run on Thursdays" := true;
        JobQueueEntry."Run on Fridays" := true;
        JobQueueEntry."Run on Saturdays" := true;
        JobQueueEntry."Run on Sundays" := true;
        JobQueueEntry."Starting Time" := BusinessCaseSetup."Execution Time";
        JobQueueEntry."Maximum No. of Attempts to Run" := 3;
        JobQueueEntry.Status := JobQueueEntry.Status::Ready;
        JobQueueEntry.Insert(true);

        Message('Job Queue Entry created successfully. It will run every night at %1', BusinessCaseSetup."Execution Time");
    end;
}
