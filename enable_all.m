function enable_all(handles)
% enables all user interface fields (except the save figure button)

    set(handles.popupmenu1,'enable','on');
    set(handles.popupmenu2,'enable','on');

    set(handles.checkbox_risingtime,'enable','on');
    set(handles.checkbox_width,'enable','on');
    set(handles.checkbox_midline,'enable','on');
    set(handles.checkbox_period,'enable','on');
    set(handles.checkbox_show,'enable','on');
    set(handles.edit_risingtime,'enable','on');
    set(handles.edit_width,'enable','on');
    set(handles.edit_midline,'enable','on');
    set(handles.edit_period,'enable','on');

    set(handles.popupmenu_twindow,'enable','on');
    set(handles.popupmenu_nwindow,'enable','on');
    set(handles.popupmenu_minlength,'enable','on');
    set(handles.checkbox_jumps,'enable','on');
    set(handles.checkbox_smoothregions,'enable','on');
    set(handles.edit_twindow,'enable','on');
    set(handles.edit_nwindow,'enable','on');
    set(handles.edit_minlength,'enable','on');

    set(handles.edit_conflevel,'enable','on');
    set(handles.edit_chi,'enable','on');
    set(handles.popupmenu_model,'enable','on');
    set(handles.checkbox_confint,'enable','on');
    set(handles.pushbutton_oscfit,'enable','on');
    set(handles.checkbox_showoscfit,'enable','on');

    set(handles.pushbutton_savedata,'enable','on');
    set(handles.pushbutton_savefigures,'enable','off');

    set(handles.popupmenu_muplot,'enable','on');
