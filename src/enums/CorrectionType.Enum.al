namespace BusinessCase.BusinessCase;

enum 50803 "Correction Type"
{
    Extensible = true;
    
    value(0; "All Dimensions")
    {
        Caption = 'All Dimensions';
    }
    value(1; "Specific Dimensions Only")
    {
        Caption = 'Specific Dimensions Only';
    }
    value(2; "Exclude Specific Dimensions")
    {
        Caption = 'Exclude Specific Dimensions';
    }
}
