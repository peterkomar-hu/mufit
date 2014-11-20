function [twindow, nwindow, minlength] = filter_update(handles)
% updates the values for filter paramters by reading it from the edit
% fields on the user interface

    % time window
    twindow = handles.twindow_numeric;
    if get(handles.popupmenu_twindow,'Value') == 1
        twindow = twindow * handles.period;
    end

    % noise limit
    nwindow = handles.nwindow_numeric;
    if get(handles.popupmenu_nwindow,'Value') == 1
        nwindow = nwindow * handles.width;
    end

    % min length of smooth regions
    minlength = handles.minlength_numeric;
    if get(handles.popupmenu_minlength,'Value') == 1
        minlength = minlength * handles.period;
    end
