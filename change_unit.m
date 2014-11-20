function numeric_value = change_unit( popmenu_handle, ...
                                edit_handle, ...
                                real_value, ...
                                default_unit )
% CHANGE_UNIT catches the user's action of changing the unit through
% popmenu_handle. It returns the new numeric value and displays in the the
% corresponding edit_handle field.

    if get(popmenu_handle,'Value') == 1
        % 1: unit = default unit
        numeric_value = real_value / default_unit;
    else
        % 2: unit = bare unity
        numeric_value = real_value;
    end
    set(edit_handle,'String',num2str(numeric_value));


