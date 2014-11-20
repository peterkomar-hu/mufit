function handles = read_param( handles, varname, varvalue )
% reads parameters from a pair of lists, names and values
    
    jmax = length(varname);    
    for j = 1:jmax 
        if strcmp(varname(j), 'time_window')
            handles.twindow_numeric = varvalue(j);
            set(handles.edit_twindow,'String',num2str(handles.twindow_numeric));
        elseif strcmp(varname(j), 'time_window_unit')
            if varvalue(j) > 1.5
                set(handles.popupmenu_twindow,'value', 2);
            else
                set(handles.popupmenu_twindow,'value', 1);
            end
        elseif strcmp(varname(j), 'noise_limit')
            handles.nwindow_numeric = varvalue(j);
            set(handles.edit_nwindow,'String',num2str(handles.nwindow_numeric));
        elseif strcmp(varname(j), 'noise_limit_unit')
             if varvalue(j) > 1.5
                set(handles.popupmenu_nwindow,'value', 2);
             else
                set(handles.popupmenu_nwindow,'value', 1);
             end
       elseif strcmp(varname(j), 'min_length')
            handles.minlength_numeric = varvalue(j);
            set(handles.edit_minlength,'String',num2str(handles.minlength_numeric));
       elseif strcmp(varname(j), 'min_length_unit')
             if varvalue(j) > 1.5
                set(handles.popupmenu_minlength,'value', 2);
             else
                 set(handles.popupmenu_minlength,'value', 1);
             end
       elseif strcmp(varname(j), 'exp_mu_change_percent')
            handles.chi = varvalue(j)/100;
            set(handles.edit_chi,'String',num2str(handles.chi * 100));
       elseif strcmp(varname(j), 'model')
            if varvalue(j) > 1.5
                set(handles.popupmenu_model,'value', 2);
            else
                set(handles.popupmenu_model,'value', 1);
             end
       elseif strcmp(varname(j), 'conf_level')
            handles.conflevel = varvalue(j);
            set(handles.edit_conflevel,'String',num2str(handles.conflevel));
        elseif strcmp(varname(j), 'show_estimate')
            if varvalue(j) > 0.5
                set(handles.checkbox_show,'value', 1);
            else
                set(handles.checkbox_show,'value', 0);
            end
        elseif strcmp(varname(j), 'show_jumps')
            if varvalue(j) > 0.5
                set(handles.checkbox_jumps,'value', 1);
            else
                set(handles.checkbox_jumps,'value', 0);
            end
        elseif strcmp(varname(j), 'show_smoothregions')
            if varvalue(j) < 0.5
                set(handles.checkbox_smoothregions,'value', 0);
            else
                set(handles.checkbox_smoothregions,'value', 1); 
            end
        elseif strcmp(varname(j), 'show_fit')
            if varvalue(j) < 0.5
                set(handles.checkbox_showoscfit,'value', 0);
            else
                set(handles.checkbox_showoscfit,'value', 1);
            end
        elseif strcmp(varname(j), 'show_confint')
            if varvalue(j) < 0.5
                set(handles.checkbox_confint,'value', 0);
            else
                set(handles.checkbox_confint,'value', 1);
            end
        elseif strcmp(varname(j), 'mu_or_dtime')
            if varvalue(j) > 1.5
                set(handles.popupmenu_muplot,'value', 2);
            else
                set(handles.popupmenu_muplot,'value', 1);
            end
        elseif strcmp(varname(j), 'iter_precision')
            handles.eps = varvalue(j);
        elseif strcmp(varname(j), 'iter_maxstep')
            handles.itermax = varvalue(j);
%         else
%             if length(handles.t_fit) < 1 || isempty(handles.t_fit)
%                 errorstring = [varname(j), ' ', char(varvalue(j)),' is unrecognized'];
%                 warndlg('Unrecognized variable in ini file',errorstring,'modal')
%                 uicontrol(hObject)
%             end
        end
    end
