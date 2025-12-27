

using Microsoft.Finance.Dimension.Correction;
using System.Security.User;

codeunit 50801 "Events Handler"
{

    [EventSubscriber(ObjectType::Page, Page::"Dimension Corrections", OnOpenPageEvent, '', false, false)]
    local procedure FnOnOpenPageEvent(var Rec: Record "Dimension Correction")
    var
        UserSetup: Record "User Setup";
        Text001Err: label 'Dimension Correction is not allowed for your user. Please contact your administrator.';
    begin
        if UserSetup.Get(UserId) then
            if not UserSetup."Run Dimension Correction" then
                Error(Text001Err);
    end;

}
