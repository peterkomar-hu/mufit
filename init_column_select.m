function handles = init_column_select( handles, number_of_columns )
% initializes the popmenu fileds for selecting dataset, using the
% handels.header, which contains the header strings read in from the
% datafile

    if length(handles.header) < number_of_columns
        % label headerless columns as 'column #'
        headerstring = strjoin(handles.header, '\t');
        for k = (length(handles.header) + 1) : number_of_columns
            headerstring = sprintf('%s\t(column %s)', headerstring, int2str(k) );
        end
        handles.header = strsplit(headerstring, '\t');
    end
    set(handles.popupmenu1,'String', handles.header )
    set(handles.popupmenu2,'String', handles.header )

    % pick column 1 for x by default
    set(handles.popupmenu1,'Value',1);
    handles.col_t = 1;
    % pick column 2 for y by default
    set(handles.popupmenu2,'Value',2);
    handles.col_n = 2;