function isExcel = is_Excel_file( pathname, filename, hObject, progressbar )
% checks if pathname/filename is an Excel file
% if not, it produces and error message, and returns 0
% otherwise it returns 1

    status = xlsfinfo([pathname,filename]);
    isExcel = 0;
    if isempty(status)
        errordlg(['Input file (',filename,') is not an Excel file'],...
            'Invalid data file','modal');
        close(progressbar);
        uicontrol(hObject);
        return
    end
    isExcel = 1;