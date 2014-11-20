function read_value = read_pos_edit( hObject )
% reads edit field if it is a positive number
% returns -1 if it's not

    input = str2double(get(hObject,'string'));
    if ~ispositive(input)
        errordlg('You must enter a positive numeric value','Invalid Input','modal')
        uicontrol(hObject)
        read_value = -1;
        return
    else
        read_value = input;
    end

