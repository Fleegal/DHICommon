 /*----------------------------------------------------------------------------
Create_Function_Dataset.sas

Description
    Creates the DHI.Functions dataset for storing compiled functions. The
    output dataset will be totally blank, so all the "function_*.sas" programs
    will need to be run after it is created. The only reason this program
    exists is so the function dataset can be given a label and passwords.

Author: Nathan Werth <nwerth@pa.gov>
Date created: 2016-05-24
Last modified: 2016-05-24

Input
	functions_utility.sas
	functions_date.sas
		SAS programs creating specific packages for the compiled routine data
		set.

Output
    DHI.Functions
 ----------------------------------------------------------------------------*/

Options cmplib = Work.Functions;


PROC DELETE library = Work data = Functions (alter = DHI);
Run;
    

PROC FCMP outlib = Work.Functions.Documentation;
    Function get_documentation() $ 255;
        Length DHI_function_doc $ 255;
        Static DHI_function_doc;
        DHI_function_doc = catx(" ",
            "These functions were created by the Pennsylvania Department of",
            "Health's Division of Health Informatics. The Department",
            "specifically disclaims responsibility for any analyses,",
            "interpretations or conclusions."
        );
        return(DHI_function_doc);
    Endsub;
Run;


%Let project_dir =
    C:/users/&SysUserID./Documents/Visual Studio 2015/Projects/DHICommon;

%Include "&project_dir./SAS/functions/functions_utility.sas";
%Include "&project_dir./tests/test_functions_utility.sas";

%Include "&project_dir./SAS/functions/functions_date.sas";
%Include "&project_dir./tests/test_functions_date.sas";


PROC DATASETS library = Work nodetails nolist;
    Modify Functions (
        alter = DHI
        write = DHI
        label = "Compiled SAS functions created and maintained by the DHI"
    );
    Copy outlib = DHI;
        Select Functions / memtype = data;
Run;
