 /*----------------------------------------------------------------------------
formats_population.sas

Description
    Create a SAS data set with definitions of format to use with the shared DHI
	population data sets.

Author: Nathan Werth <nwerth@pa.gov>
Date created: 2016-08-03

Output
	Work.Population_Formats
		Data set with the population formats.

Additonal notes
    The data set will ultimately be combined with other format data sets and
	copied to a shared drive all DHI staff can access.
 ----------------------------------------------------------------------------*/

PROC FORMAT cntlout = Population_Formats;
	Value $Pop_Race_Fmt
		'A' = 'Asian/PI'
		'B' = 'black'
		'H' = 'Hispanic'
		'M' = 'multi-race'
		'O' = 'other'
		'T' = 'total'
		'W' = 'white';
Run;
