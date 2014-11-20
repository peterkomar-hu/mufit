function save_misc( handles, pathname, filename )
% exports misc data to pathname/filename Excel file, sheet 'Misc'

    header = { 'fit_begin', 'fit_end', 'n0' };
    data = [handles.fit_begin, handles.fit_end, handles.n0];
    xlswrite([pathname,filename], header, 'Misc', 'A1');
    xlswrite([pathname,filename], data, 'Misc', 'A2');

