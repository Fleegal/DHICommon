

 /* Rebuild each format catalog linked */
%MACRO reformat_64bit(format_lib);
    %Local needs_rebuilt shared_catalogs;
    Filename rb_oscmd pipe "wmic os get osarchitecture";
    %Let needs_rebuilt = 0;

    DATA _NULL_;
        Infile rb_oscmd;
        Input pipe_output $;
        If find(pipe_output, '64-bit') then
            Call symput("needs_rebuilt", "1");
    Run;

    Filename rb_oscmd clear;

    /* Determine which shared format catalogs are linked */
    %If &needs_rebuilt. %then %do;
        DATA _NULL_;
            Set SAShelp.VOption;
            Where lowcase(optname) = "fmtsearch";
            Length catalog_list $ 512;
            Retain catalog_list '';
            setting = lowcase(setting);
            Do i = 1 to countw(setting, ' ()');
                catalog = scan(setting, i, ' ()');
                If find(catalog, lowcase("&format_lib..")) then do;
                    catalog_list = catx(" ", catalog_list, catalog);
                    Call symput("shared_catalogs", catalog_list);
                End;
            End;
        Run;

        %Put Rebuilding the following format catalogs from data:;
        %Put &shared_catalogs.;

        /* The datasets have the same name as the catalogs */
        %Do j = 1 %to %sysfunc(countw(&shared_catalogs., ' '));
            PROC FORMAT cntlin = %scan(&shared_catalogs., &j., ' ');
            Run;
        %End;
    %End;
%Mend reformat_64bit;
