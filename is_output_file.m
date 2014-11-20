function isoutputfile = is_output_file( pathname, filename, hObject, progressbar )
    [~,sheets] = xlsfinfo([pathname,filename]);
% checks if pathname/filename is a proper output file produced previously
% by mufit
% if it's not, it produces and error message and returns 0
% otherwise it returns 1
    
    sheet_raw = 0;
    sheet_parameters = 0;
    sheet_fit = 0;
    sheet_misc = 0;
    for j = 1 : length(sheets)
        if strcmp(sheets(j),'Raw')
            sheet_raw = 1;
        elseif strcmp(sheets(j),'Parameters')
            sheet_parameters = 1;
        elseif strcmp(sheets(j),'Fit')
            sheet_fit = 1;
        elseif strcmp(sheets(j),'Misc')
            sheet_misc = 1;
        end
    end
    
    isoutputfile = 0;
    if ~(sheet_raw && sheet_parameters && sheet_fit && sheet_misc)
            errordlg(['File (',filename,') is not a mufit output file, or it is corrupted'],...
            'Invalid data file','modal');
        close(progressbar);
        uicontrol(hObject);
        return;
    end
    isoutputfile = 1;
    