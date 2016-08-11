 /*
Connect to the shared SAS resources for the division.

Author: Nathan Werth <nwerth@pa.gov>
Date created: 2016-05-02
Last modified: 2016-06-02

Input
    added_formats (macro variable)
        Space-separated listing of format catalogs to add to the search path.
    added_function_data (macro variable)
        Space-separated listing of function libraries to add to the search path.

Output/Effects
    DHI (libref)
        Library which stores the Division of Health Informatics' shared data.
    %add_unpathed_members
        Macro function that appends format catalogs and function libraries to
        the search paths if they were not already in them.
    Added formats
        All formats listed in "added_formats" are added to the format search
        list.
    Added functions
        All functions in the datasets listed in "added_function_data" are added
        to the function search list.

Additonal notes
    The format catalogs were created by a 32-bit version of SAS, so they cannot
    be used by 64-bit versions. The macro "Reformat_64bit" included below has
    64-bit versions just recreate the formats using datasets output by
    PROC FORMAT.
 */

 /* Read in a macro function to only add new formats/function libraries to
    search paths */
%include "//dhhbgbitfp914.prod.dh.lcl/ddp_share/DHI/Shared_SAS_Resources/Macros/add_unpathed_members.sas";

Libname DHI "//dhhbgbitfp914.prod.dh.lcl/ddp_share/DHI/Shared_SAS_Resources";

%add_unpathed_members(formats = DHI.Common_Formats,
                      function_data = DHI.Functions);
%sysmacdelete add_unpathed_members;
 /* ------------------------------------------------------------------------
    The format catalogs are 32-bit, so it needs rebuilt on 64-bit systems.
 -------------------------------------------------------------------------*/
%Include "//dhhbgbitfp914.prod.dh.lcl/ddp_share/DHI/Shared_SAS_Resources/Macros/Reformat_64bit.sas";
%reformat_64bit(DHI);
%sysmacdelete reformat_64bit;
