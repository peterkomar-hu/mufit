function handles = read_inifile(filenamestr, handles)
% reads default values from filenamestr

    inifile = fopen(filenamestr, 'r');
    if inifile > 0
        inidata = textscan(inifile, '%s %f');
        fclose(inifile);

        varname = inidata{1};
        varvalue = inidata{2};

        handles = read_param( handles, varname, varvalue );
    end
