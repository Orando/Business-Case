

page 50803 "Fiscal Messages API"
{
    APIGroup = 'integration';
    APIPublisher = 'businessCase';
    APIVersion = 'v1.0';
    ApplicationArea = All;
    Caption = 'fiscalMessagesAPI';
    DelayedInsert = true;
    EntityName = 'fiscalMessage';
    EntitySetName = 'fiscalMessages';
    PageType = API;
    SourceTable = Messages;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(payload; PayloadText)
                {
                    Caption = 'PayloadText';
                }
                field(contentType; Rec."Content Type")
                {
                    Caption = 'Content Type';
                }
                field(messageType; Rec."Message Type")
                {
                    Caption = 'Message Type';
                }
                field(externalReference; Rec."External Reference")
                {
                    Caption = 'External Reference';
                }
            }
        }
    }

    var
        PayloadText: Text;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        IntegrationManagement: Codeunit "Integration Management";
        OutStream: OutStream;
    begin
        Rec.Status := Rec.Status::Received;
        Rec.Direction := Rec.Direction::Inbound;
        Rec."Received Date Time" := CurrentDateTime();

        if Rec."Message Type" = Rec."Message Type"::"Fiscal Data" then
            IntegrationManagement.ProcessFiscalData(Rec);

        if Rec."Message Type" = Rec."Message Type"::"Transaction Data" then
            IntegrationManagement.FnProcessTransactionData(Rec);


        if PayloadText <> '' then begin
            Rec.Payload.CreateOutStream(OutStream, TextEncoding::UTF8);
            OutStream.WriteText(PayloadText);
        end;
    end;

    trigger OnModifyRecord(): Boolean
    var
        OutStream: OutStream;
    begin
        if PayloadText <> '' then begin
            Clear(Rec.Payload);
            Rec.Payload.CreateOutStream(OutStream, TextEncoding::UTF8);
            OutStream.WriteText(PayloadText);
        end;
    end;

    trigger OnAfterGetRecord()
    var
        InStream: InStream;
    begin
        PayloadText := '';
        if Rec.Payload.HasValue then begin
            Rec.Payload.CreateInStream(InStream, TextEncoding::UTF8);
            InStream.ReadText(PayloadText);
        end;
    end;

    trigger OnNewRecord(belowxRec: Boolean)
    var
        MessageLogger: Codeunit "Log Processor";
    begin
        MessageLogger.FnLogToMessageLogs(Rec);
    end;
}
