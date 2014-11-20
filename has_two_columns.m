function hastwocolumns = has_two_columns(number_of_columns, filename, hObject, progressbar)
% checks if number_of_columns is less than two
% if so, it produces an error message for the user, and return 0
% otherwise it returns 1
    hastwocolumns = 0;
    if(number_of_columns < 2)
        errordlg(['Input file (',filename,') has less than two columns.',...
            char(10),'Data not loaded.'],'Invalid data file','modal');
        close(progressbar);
        uicontrol(hObject);
        return
    end
    hastwocolumns = 1;
    