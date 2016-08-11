 /*----------------------------------------------------------------------------
format_macros

Description
    A collection of macros for use with creating and modifyign formats.

Author: Nathan Werth <nwerth@pa.gov>
Date created: 2016-05-04

Input
    None

Output
    add_capitalized_formats
        Macro function to add capitalized versions of formats to a format
        dataset.

Additonal notes
    Anything else somebody reading or running the program may benefit from
    knowing, such as URLs for papers detailing a statistical or programming
    method, or the name of the person requesting the program's data.
 ----------------------------------------------------------------------------*/

 /* Connect to the shared division data, functions, and formats */
%include "\\dhhbgbitfp914.prod.dh.lcl\ddp_share\DHI\Shared_SAS_Resources\connect_to_shared_DHI.sas";


 /*
Take a dataset of informats and/or formats created by PROC FORMAT and and add
versions of the formats where the first word of each value is capitalized.

Args
    fmt_data
        SAS dataset name for a dataset with format information. This dataset
        should meet the requirements for being used in the CNTLIN option of
        PROC FORMAT. Usually, it is the product of the CNTLOUT option of
        PROC FORMAT.
Output
    Additional format definition rows added to fmt_data. For each format that is
    not a numeric informat, a new format will be created with capitalized
    labels. The name of the new format will be the name of the old format plus
    "_CAP" at the end.

Example

    PROC FORMAT cntlout = Work.MyFormat;
        Value transportation
            1 = "planes"
            2 = "trains"
            3 = "automobiles";
    Run;

    %add_capitalized_formats(Work.MyFormat);
 */
%MACRO add_capitalized_formats(fmt_data);
    DATA &fmt_data.;
        Set &fmt_data.;
        Output;
        /* Do not add new versions of numeric informats */
        If Type ^= "I" then do;
            FmtName = cats(FmtName, "_CAP");
            Call capitalize_first(Label);
            Output;
        End;
    Run;

    PROC SORT data = &fmt_data.;
        By FmtName Start;
    Run;
%Mend add_capitalized_formats;
