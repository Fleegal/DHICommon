 /*----------------------------------------------------------------------------
functions_utility.sas

Description
    Adds a package of general use functions to a data set of compiled SAS
    routines.

Author: Nathan Werth <nwerth@pa.gov>
Date created: 2016-08-03

Output
    Work.Functions.Utility
        Package of compiled custom SAS routines.

Additonal notes
    The compiled function data set will ultimately be copied to a directory
    where all DHI staff have access.
 ----------------------------------------------------------------------------*/


 /*----------------------------------------------------------------
    These macros are meant to be used with the run_macro function
 ----------------------------------------------------------------*/

/* Calls a function with two arguments and stores the result */
%MACRO call_binary_function;
    /* Remove any punctuation, like quotes, or spaces from the function name */
    %Let function_ = %sysfunc(compress(&function., , PS));
    %Let result = %sysfunc(&function_.(&&a., &&b.));
%Mend call_binary_function;


 /* Calls a function with one argument and stores the result */
%MACRO call_unary_function;
    /* Remove any punctuation, like quotes, or spaces from the function name */
    %Let function_ = %sysfunc(compress(&function., , PS));
    %Let result = %sysfunc(&function_.(&&a., &&b.));
%Mend call_unary_function;


 /*----------------------------------------------------------------
    Function definitions
 ----------------------------------------------------------------*/
PROC FCMP outlib = Work.Functions.Utility;
    /*------------------------------------------------------------------------
    Check if all numeric values in an array are equal.

    Arguments
        num_array
            Name of the numeric array containing the values to check.

    Return
        Numeric value: 0 if any two values given are not equal, otherwise 1.
        If less than two values are given, then 1 is returned.
    */
    Function identicaln(num_array[*]);
        If dim(num_array) > 1 then do i = 2 to dim(num_array);
            If num_array{i} ^= num_array{1} then return(0);
        End;
        Return(1);
    Endsub;

    /*------------------------------------------------------------------------
    Check if all character values in an array are equal.

    Arguments
        char_array
            Name of the character array containing the values to check.

    Return
        Numeric value: 0 if any two values given are not equal, otherwise 1.
        If less than two values are given, then 1 is returned.
    */
    Function identicalc(char_array[*] $);
        If dim(char_array) > 1 then do i = 2 to dim(char_array);
            If char_array{i} ^= char_array{1} then return(0);
        End;
        Return(1);
    Endsub;

    /*------------------------------------------------------------------------
    Capitalize the first word of a character value.

    Arguments
        charvar
            Character variable

    Return
        The value of charvar where the first character of the first word is
        capitalized
    */
    Subroutine capitalize_first(charvar $);
        Outargs charvar;
        first_word = scan(charvar, 1);
        first_letter = substr(first_word, 1, 1);
        first_letter_position = find(charvar, first_letter);
        substr(charvar, first_letter_position, 1) = upcase(first_letter);
    Endsub;

    /*------------------------------------------------------------------------
    Extend a character variable's value to that variable's length by adding
    padding characters to the beginning.

    Arguments
        charvar
            Character variable to be extended
        pad_character
            Character value of length 1 to use as padding

    Return
        The value of charvar will be changed to be length lengthm(charvar), with
        the necessary number of pad_character added to the beginning to make it
        this length. Missing values are preserved.

    Example
        DATA test;
            Length county_fips $ 3;
            Do county_fips = '3', '23', '123';
                unpadded_value = county_fips;
                Call pad_beginning(county_fips, '0');
                Put "Old:" unpadded_value $3. " New:" county_fips;
            End;
        Run;
        *Old: 3   New: 003;
        *Old: 23  New: 023;
        *Old: 123 New: 123;
    */
    Subroutine pad_beginning(charvar $, pad_character $);
        Outargs charvar;
        pad_single_character = substr(pad_character, 1, 1);
        stripped_length = lengthn(strip(charvar));
        If not missing(charvar) and stripped_length < lengthm(charvar) then do;
            padding_length = lengthm(charvar) - stripped_length;
            padding = repeat(pad_single_character, padding_length - 1);
            charvar = substr(padding, 1, padding_length) || strip(charvar);
        End;
    Endsub;

    /*------------------------------------------------------------------------
    Choose a random number from a sequence.

    Required arguments
        low
            (numeric) Lower closed bound of possible return values
        high
            (numeric) Upper open bound of possible return values
        step
            (numeric) Increment between the possible values

    Details
        Retuns a random number from the sequence generated by
        `low` + i * `step`, where i = 0, 1, 2, ..., k, and
        `low` + k * `step` <= `high`.

    Examples
        *** Integer between 1 and 100 ***;
        randsequence(1, 100, 1)
        *** Integer between 18 and 75 ***;
        randsequence(18, 75, 1)
        *** Odd number under 100 (1, 3, 5, ..., or 99) ***;
        randsequence(1, 99, 2)
        *** Number between 4.3 and 16, by 0.5 (4.3, 4.8, ..., 15.8) ***;
        randsequence(4.3, 16, 0.5)
    */
    Function randsequence(low, high, step);
        step_range = floor((high - low) / step) + 1;
        step_count = floor(rand('UNIFORM') * step_range);
        return(low + step * step_count);
    Endsub;

    /*------------------------------------------------------------------------
    Sorts the values of any array. Behaves similarly to the SORTN function,
    but also works with dynamic arrays.

    Arguments
        narray
            (numeric array) Array to be sorted

    Return
        The values of the narray will be rearranged in ascending order.

    Details
        Sort order is determined by the hashed values of narray.
    */
    Subroutine sortn_dynamic(narray[*]);
        Outargs narray;
        Length value count 8;
        Declare hash value_hash(ordered: 'a');
        rc = value_hash.defineKey('value');
        rc = value_hash.defineData('value', 'count');
        rc = value_hash.defineDone();
        Do i = 1 to dim(narray);
            value = narray[i];
            rc = value_hash.find();
            If rc then count = 1;
            Else count = count + 1;
            rc = value_hash.replace();
        End;
        Declare hiter value_hiter('value_hash');
        index = 1;
        Do while(index <= dim(narray));
            rc = value_hiter.next();
            Do k = 1 to count;
                narray[index] = value;
                index = index + 1;
            End;
        End;
        /* Hash persists between calls, so clear when done */
        rc = value_hash.clear();
    Endsub;

    /*------------------------------------------------------------------------
    Extract the base file name from a file path.

    Arguments
        filepath
            (character value) Physical file location
    Return
        (character) The name of the file given by filepath.
    */
    Function basename(filepath $) $ 260;
        Length norm_path $ 260;
        norm_path = tranwrd(filepath, '\', '/');
        file_pieces = countw(norm_path, '/');
        base_name = scan(norm_path, file_pieces, '/');
        Return(strip(base_name));
    Endsub;

    /*------------------------------------------------------------------------
    Extract the directory path from a file path.

    Arguments
        filepath
            (character value) Physical file location
    Return
        (character) The physical location of the directory containing filepath.
    */
    Function dirname(filepath $) $ 260;
        Length filepath_ $ 260;
        filepath_ = strip(filepath);
        base_name = basename(filepath_);
        path_length = lengthn(filepath_);
        base_length = lengthn(base_name);
        dir_name = substr(filepath_, 1,  path_length - base_length - 1);
        Return(strip(dir_name));
    Endsub;

    /*------------------------------------------------------------------------
    Collapse a numeric array to a single value by cumulatively applying a
    binary function to its values, from left to right.

    Arguments
        function
            (character value) Name of a function which takes two numeric
            arguments.
        narray
            (numeric array) Array of numeric values to collapse

    Return
        (numeric) The final value from the cumulative application of the
        function.

    Example

    DATA _NULL_;
        Array myarray[4] (30 16 8 5);
        sum_result = reducen("sum", myarray);
        Put sum_result = "= ((30 + 16) + 8) + 5 [should be 59]";
        mod_result = reducen("mod", myarray);
        Put mod_result = "= mod(mod(mod(30, 16), 8), 5) [should be 1]";
    Run;
    */
    Function reducen(function $, narray[*]);
        Length result 8;
        If dim(narray) = 0 then return(.);
        If dim(narray) = 1 then return(narray[1]);
        result = narray[1];
        Do i = 2 to dim(narray);
            a = result;
            b = narray[i];
            rc = run_macro('call_binary_function', function, a, b, result);
        End;
        Return(result);
    Endsub;

    /*------------------------------------------------------------------------
    Collapse a character array to a single value by cumulatively applying a
    binary function to its values, from left to right.

    Arguments
        function
            (character value) Name of a function which takes two character
            arguments.
        carray
            (character array) Array of character values to collapse

    Return
        (character) The final value from the cumulative application of
        the function. The default length in 2048.

    Example

    DATA _NULL_;
        Array myarray[4] $ ("my" "name" "is" "John");
        sum_result = reducec("sum", myarray);
        Put sum_result = "= ((30 + 16) + 8) + 5 [should be 59]";
        mod_result = reducen("mod", myarray);
        Put mod_result = "= mod(mod(mod(30, 16), 8), 5) [should be 1]";
    Run;
    */
    Function reducec(function $, carray[*] $) $ 2048;
        Length result $ 2048;
        If dim(carray) = 0 then return(.);
        If dim(carray) = 1 then return(carray[1]);
        result = carray[1];
        Do i = 2 to dim(carray);
            a = result;
            b = carray[i];
            rc = run_macro('call_binary_function', function, a, b, result);
        End;
        Return(result);
    Endsub;
Run;
