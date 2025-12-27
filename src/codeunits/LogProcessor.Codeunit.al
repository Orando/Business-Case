

codeunit 50802 "Log Processor"
{
    procedure LogError(EntryNo: Integer; ErrorText: Text)
    var
        GlovoIntegrationLogs: Record "Glovo Integration Logs";
    begin
        if not GlovoIntegrationLogs.Get(EntryNo) then
            exit;

        GlovoIntegrationLogs."Status" := GlovoIntegrationLogs."Status"::Failed;
        GlovoIntegrationLogs."Error Message" := ErrorText;
        GlovoIntegrationLogs."Processed At" := CurrentDateTime;
        GlovoIntegrationLogs.Modify(true);
    end;

    procedure FnLogToMessageLogs(var IntegrationMessage: Record Messages)
    var
        GlovoIntegrationLogs: Record "Glovo Integration Logs";
        MessageID: Code[20];
        SearchText: Text[250];
    begin

        MessageID := CopyStr(Format(IntegrationMessage."Entry No."), 1, MaxStrLen(MessageID));

        GlovoIntegrationLogs.Init();
        GlovoIntegrationLogs."Message ID" := MessageID;
        GlovoIntegrationLogs.Direction := IntegrationMessage.Direction;
        GlovoIntegrationLogs.Status := IntegrationMessage.Status;
        GlovoIntegrationLogs."JSON Content" := IntegrationMessage.Payload;
        GlovoIntegrationLogs."Message Type" := IntegrationMessage."Message Type";

        // Processed At: set to current time
        GlovoIntegrationLogs."Processed At" := CurrentDateTime();

        // Build a short searchable text from payload and content type
        SearchText := '';
        if IntegrationMessage.Payload.HasValue then
            SearchText := CopyStr(Format(IntegrationMessage.Payload), 1, MaxStrLen(GlovoIntegrationLogs."Search Text"));
        if (IntegrationMessage."Content Type" <> '') and (SearchText = '') then
            SearchText := CopyStr(IntegrationMessage."Content Type", 1, MaxStrLen(GlovoIntegrationLogs."Search Text"));

        GlovoIntegrationLogs.Validate("Search Text", SearchText);

        // Default values
        GlovoIntegrationLogs."Error Message" := '';

        GlovoIntegrationLogs.Insert();
    end;

    procedure UpdateLogError(var LogEntry: Record "Glovo Integration Logs"; ErrorMsg: Text)
    begin
        LogEntry.Status := LogEntry.Status::Failed;
        LogEntry."Error Message" := CopyStr(ErrorMsg, 1, 250);
        LogEntry.Modify();
    end;
}
