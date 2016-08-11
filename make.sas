 /*----------------------------------------------------------------------------
make.sas

Description
    Runs all DHICommon SAS programs necessary to create the SAS catalogs and
	datasets in the shared resource directory. Also copies the folder with all SAS
	macro programs to the same directory.

Author: nwerth <nwerth@pa.gov>
Date created: 2016-06-21
Last modified: 2016-06-21

Input
	A lot

Output
    A lot

Additonal notes
    This program uses relative file paths to work within the project. Because
	SAS cannot reliably handle relative file paths, this program should only be
	executed through make.cmd in the project's main directory.
 ----------------------------------------------------------------------------*/

%Include "SAS\macros\check_if_directory.sas";


%MACRO run_sas_programs(run_dirs = SAS\functions SAS\formats);
	%Do i = 1 %to %sysfunc(countw(&run_dirs., %str( )));
		%Let dirpath = %scan(&run_dirs., &i., %str( ));
		%Put &dirpath.;
		/*--- Only for the testing ---*/
		*%Let dirpath = "C:\users\nwerth\documents\visual studio 2015\projects\DHICommon&dirpath.";
		/*----------------------------*/
		%Put is a directory? %check_if_directory(&dirpath.);
		%If %check_if_directory(&dirpath.) %then %do;
			%Let ref = tempref;
			%Let rc_filename = %sysfunc(filename(ref, &dirpath.));
			%Let id = %sysfunc(dopen(&ref.));
			%Let member_count = %sysfunc(dcount(&id.));
			%If &member_count. %then %do j = 1 %to &member_count.;
				%Let member_name = %susfunc(dread(&id., &j.));
				%Put Including "&member_name.";
				%Include "&member_name.";
			%End;
			%Let rc_close = %sysfunc(dclose(&id.));
			%Let rc_deref = %sysfunc(filename(ref));
		%End;
	%End;
%Mend;


%run_sas_programs();

%Put All done!;

