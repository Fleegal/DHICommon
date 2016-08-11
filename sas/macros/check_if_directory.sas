 /*
Macro function to test if a filepath is for a directory.
Returns 1 if it is a directory path, otherwise 0.

If path has spaces, enclose it in quotes.
 */

%MACRO check_if_directory(path);
	%Let ref = tempref;
	%Let rc_filename = %sysfunc(filename(ref, &path.));
	%Let id = %sysfunc(dopen(&ref.));
	%Let result = %eval(&id. > 0);
	%Let rc_close = %sysfunc(dclose(&id.));
	%Let rc_deref = %sysfunc(filename(ref));
	&result.
%Mend test_if_dir;
