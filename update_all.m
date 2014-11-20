function handles = update_all(handles)
% updates estimates, filter and plots

    % update handles
    [handles.risingtime, handles.width, handles.midline, handles.period] ...
            = estimate_update(handles);

    %updating filter
    [handles.twindow, handles.nwindow, handles.minlength] = filter_update(handles);

    % filter
    [handles.downedge, handles.upedge, handles.edge, ...
        handles.smooth_begin, handles.smooth_end] = filter_jumps(handles);

    % plot 
    plot_nt(handles)
