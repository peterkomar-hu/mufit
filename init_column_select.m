function handles = init_column_select( handles, number_of_columns )
% initializes the popmenu fileds for selecting dataset, using the
% handels.header, which contains the header strings read in from the
% datafile

    if length(handles.header) < number_of_columns
        % label columns as 'column 1', 'column 2', ...
        set(handles.popupmenu1,'String', 1 : number_of_columns )
        set(handles.popupmenu2,'String', 1 : number_of_columns )
        for k = 1 : number_of_columns
            handles.header = {handles.header, ['column ', int2str(k)]};
        end
    else
        % label columns with strings from the header row
        set(handles.popupmenu1,'String', handles.header )
        set(handles.popupmenu2,'String', handles.header )
    end
    % pick column 1 for x by default
    set(handles.popupmenu1,'Value',1);
    handles.col_t = 1;
    % pick column 2 for y by default
    set(handles.popupmenu2,'Value',2);
    handles.col_n = 2;