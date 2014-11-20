function read_value = read_pos_edit_w_checkbox( hObject, checkbox_handle )
% reads edit field if it's a positive number, and unchecks the
% corresponding 'Auto' chekcbox.

    input = str2double(get(hObject,'string'));
    if ~ispositive(input)
        errordlg('You must enter a positive numeric value','Invalid Input','modal')
        uicontrol(hObject)
        return
    else
        read_value = input;
        set( checkbox_handle,'Value',0 );
    end
