function disable_all(handles)
% disables all user interface fields except the load data buttons

    set(handles.popupmenu1,'enable','off');
    set(handles.popupmenu2,'enable','off');

    set(handles.checkbox_risingtime,'enable','off');
    set(handles.checkbox_width,'enable','off');
    set(handles.checkbox_midline,'enable','off');
    set(handles.checkbox_period,'enable','off');
    set(handles.checkbox_show,'enable','off');
    set(handles.edit_risingtime,'enable','off');
    set(handles.edit_width,'enable','off');
    set(handles.edit_midline,'enable','off');
    set(handles.edit_period,'enable','off');

    set(handles.popupmenu_twindow,'enable','off');
    set(handles.popupmenu_nwindow,'enable','off');
    set(handles.popupmenu_minlength,'enable','off');
    set(handles.checkbox_jumps,'enable','off');
    set(handles.checkbox_smoothregions,'enable','off');
    set(handles.edit_twindow,'enable','off');
    set(handles.edit_nwindow,'enable','off');
    set(handles.edit_minlength,'enable','off');

    set(handles.edit_conflevel,'enable','off');
    set(handles.edit_chi,'enable','off');
    set(handles.popupmenu_model,'enable','off');
    set(handles.checkbox_confint,'enable','off');
    set(handles.pushbutton_oscfit,'enable','off');
    set(handles.checkbox_showoscfit,'enable','off');

    set(handles.pushbutton_savedata,'enable','off');
    set(handles.pushbutton_savefigures,'enable','off');

    set(handles.popupmenu_muplot,'enable','off');
