 /*----------------------------------------------------------------------------
test_functions_utility.sas

Description
    Tests for routines created by functions_utility.sas. If any test fails,
    then the program is aborted.

Author: Nathan Werth <nwerth@pa.gov>
Date created: 2016-08-03

Input
    OPTIONS CMPLIB = Work.Functions
        The Work.Functions data set of compiled functions must be in the CMPLIB
        search path. Specifically, the package Work.Functions.Utility must be
        available.

 ----------------------------------------------------------------------------*/

DATA test_identicalc;
    Input
        @1 expected 1.
        @2 array_value_01 2.
        @4 array_value_02 2.
        @6 array_value_03 2.
        @8 array_value_04 2.
        @10 array_value_05 2.;    
    Array input_array [5] array_value_01-array_value_05;
    result = identicaln(input_array);
    If result ^= expected then abort;
    Datalines;
1 3 3 3 3 3
0 3 3 3 0 3
0   3 3 3 3
1          
;
Run;


DATA test_identicalc;
    Input
        @1 expected 1.
        @2 array_value_01 $Char1.
        @3 array_value_02 $Char1.
        @4 array_value_03 $Char1.
        @5 array_value_04 $Char1.
        @6 array_value_05 $Char1.;    
    Array input_array [5] $ array_value_01-array_value_05;
    result = identicalc(input_array);
    If result ^= expected then abort;
    Datalines;
1AAAAA
0BAAAA
0 AAAA
1     
;
Run;


DATA test_capitalize_first;
    Length
        unchanged_input input_string expected $ 40;
    Input
        @1 input_string $Char40.
        @41 expected $Char40.;
    unchanged_input = input_string;
    Call capitalize_first(input_string);
    If input_string ^= expected then abort;
    Datalines;
non-empty string                        Non-empty string                        
    starting with blanks                    Starting with blanks                
11223n start with number = no change    11223n start with number = no change    
...ellipses                             ...Ellipses                             
keep the UPPERCASE                      Keep the UPPERCASE                      
Not changed at all                      Not changed at all                      
                                                                                
;
Run;


DATA test_pad_beginning;
    Length
        result_total result_01-result_05 8
        original_length_01 padded_length_01 expected_length_01 $ 1
        original_length_02 padded_length_02 expected_length_02 $ 2
        original_length_03 padded_length_03 expected_length_03 $ 3
        original_length_04 padded_length_04 expected_length_04 $ 4
        original_length_05 padded_length_05 expected_length_05 $ 5;
    Input
        @5 original_length_01 $Char1.
        @4 original_length_02 $Char2.
        @3 original_length_03 $Char3.
        @2 original_length_04 $Char4.
        @1 original_length_05 $Char5.
        @10 expected_length_01 $Char1.
        @9 expected_length_02 $Char2.
        @8 expected_length_03 $Char3.
        @7 expected_length_04 $Char4.
        @6 expected_length_05 $Char5.;

    Array original_var [5] $ original_length_01-original_length_05;
    Array padded_var [5] $ padded_length_01-padded_length_05;
    Array expected_var [5] $ expected_length_01-expected_length_05;
    Array result_var [5] result_01-result_05;
    Do i = 1 to dim(original_var);
        padded_var[i] = original_var[i];
        Call pad_beginning(padded_var[i], '0');
        result_var[i] = (padded_var[i] = expected_var[i]);
    End;
    passed_test = (result_var[1] and identicaln(result_var));
    If not passed_test then abort;
    Datalines;
          
    500005
   4500045
  34500345
 234502345
1234512345
;
Run;


DATA test_randsequence;
    Call streaminit(8118);
    Length
        lower upper stepby 8
        expected_sequence $ 50
        result_character $ 8
        value_j $ 8;
    Input
        @1 lower 8.
        @10 upper 8.
        @19 stepby 8.
        @28 expected_sequence $Char50.;
    Do i = 1 to 10;
        result = randsequence(lower, upper, stepby);
        result_character = strip(put(result, 8.1));
        matched_value = 0;
        Do j = 1 to countw(expected_sequence, ',') while(matched_value = 0);
            value_j = strip(scan(expected_sequence, j, ','));
            If result_character = value_j then
                matched_value = 1;
        End;
        If not matched_value then abort;
    End;
    Datalines;
       1        5        1                                1.0,2.0,3.0,4.0,5.0
       4        8        1                                4.0,5.0,6.0,7.0,8.0
      10       25        5                                10.0,15.0,20.0,25.0
      -2       -2        1                              -2.0,-1.0,0.0,1.0,2.0
       1       -5        1                   -5.0,-4.0,-3.0,-2.0,-1.0,0.0,1.0
       1      5.5        1                                1.0,2.0,3.0,4.0,5.0
       1        2      0.1        1.0,1.1,1.2,1.3,1.4,1.5,1.6,1.7,1.8,1.9,2.0
;
Run;


DATA test_sortn_dynamic;
    Length x1-x4 expected1-expected4 8;
    Informat x1-x4 6.;
    Input x1-x4 expected1-expected4;
    Array xvalues [4] x1-x4;
    Array expected [4] expected1-expected4;
    Call sortn_dynamic(xvalues);
    Do i = 1 to dim(xvalues);
        If xvalues[i] ^= expected[i] then abort;
    End;
    Drop i;
    Datalines;
     4     3     2     1     1     2     3     4
     1     2     3     4     1     2     3     4
    99 66666   888  7777    99   888  7777 66666
     1    -2     3    -4    -4    -2     1     3
     1     .     3     4     .     1     3     4
    .b    .a    .c     .     .    .a    .b    .c
;
Run;


 /* Also need to test sortn_dynamic with dynamic arrays */
PROC FCMP;
    Array test_data [1] / nosymbols;
    Call dynamic_array(test_data, 6, 8);
    rc = read_array('test_sortn_dynamic', test_data);

    Array xvalues [1] / nosymbols;
    Array expected [1] / nosymbols;
    half_column_count = dim2(test_data) / 2;
    Call dynamic_array(xvalues, half_column_count);
    Call dynamic_array(expected, half_column_count);

    Do i = 1 to dim1(test_data);
        Do j = 1 to half_column_count;
            xvalues[j] = test_data[i, j];
            expected[j] = test_data[i, j + half_column_count];
        End;
        Call sortn_dynamic(xvalues);
        Do k = 1 to half_column_count;
            If xvalues[k] ^= expected[k] then do;
                Put "Failed sortn_dynamic with dynamic arrays";
                Abort;
            End;
        End;
    End;
Run;


DATA test_basename;
    Length
        inpath
        expected
        result $ 260;
    Input
        @1 inpath $Char62.
        @64 expected $Char20.;
    expected = strip(expected);
    result = basename(inpath);
    If result ^= expected then abort;
    Datalines;
C:/users/username/documents/readfruit.sas                      readfruit.sas       
C:\program files\sashome\sasfoundation\9.4                     9.4                 
//dhhbgbitfp914.prod.dh.lcl/ddp_share                          ddp_share           
\\dhhbgbitfp914.prod.dh.lcl\ddp_share\DHI\Shared SAS Resources Shared SAS Resources
This\is\totally fake\but hey.txt                               but hey.txt         
;
Run;


DATA test_reducen;
    Input
        @1 x1 2.
        @4 x2 2.
        @7 x3 2.
        @10 x4 2.
        @13 funcname $Char32.
        @46 expected 4.;

    Array xarray [4] _temporary_;
    Array singleton [1] _temporary_;
    Array duo [2] _temporary_;
    xarray[1] = x1;
    xarray[2] = x2;
    xarray[3] = x3;
    xarray[4] = x4;
    singleton[1] = x1;
    duo[1] = x1;
    duo[2] = x2;

    result = reducen(funcname, xarray);
    result_singleton = reducen(funcname, singleton);
    result_duo = reducen(funcname, duo);

    Length expected_duo_text $ 200;
    expected_duo_text = resolve(cats(
        '%sysfunc(', funcname, '(', xarray[1], ',', xarray[2], '))'
    ));
    expected_duo = input(expected_duo_text, 12.);

    /* Allow some fuzz for floating values */
    If abs(result - expected) > 0.01 then abort;
    If result_singleton ^= xarray[1] then abort;
    If abs(result_duo - expected_duo) > 0.01 then abort;
    Datalines;
 1  1  1  1 sum                                 4
30 16  8  5 mod                                 1
 4  3  2  1 atan2                            0.41
;
Run;
