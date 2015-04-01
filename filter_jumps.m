function [downedge, upedge, edge, smooth_begin, smooth_end] = filter_jumps(handles)
% finds up and down jumps, as well as smooth regions using the filter's
% settings and the data

    % read from handle variables
    col_t = handles.col_t;
    col_n = handles.col_n;
    t = handles.data(:,col_t); 
    n = handles.data(:,col_n);
    i_end = length(t);

    % subtracting the expected slope of width/period
    n_tilted = n - handles.width * t / handles.period;

    % finding regions where n varies a lot
    downedge = [];
    upedge = [];
    edge = [];
    
    i_window_begin = 1;
    i_window_end = 1;
    while i_window_end < i_end;
         % set length of the window at least handles.twindow
         while t(i_window_end) - t(i_window_begin) < handles.twindow && ...
                 i_window_end < i_end
            i_window_end = i_window_end +1;
         end
         
         % set the vertical bounds of the window
         max_window = max( n_tilted( i_window_begin: i_window_end ) );
         min_window = min( n_tilted( i_window_begin: i_window_end ) );
         
         % check if the curve exits the bounds inside the window then
         % it's an edge
         if max_window - min_window > handles.nwindow         
             i_window_center = floor( ( i_window_begin + i_window_end )/2 );         
             edge = [ edge; i_window_center ];
             % determine the sign of the jump and store it
             if n_tilted(i_window_begin) < n_tilted(i_window_end)
                 upedge = [upedge; i_window_center];
             else
                 downedge = [downedge; i_window_center];
             end
         end
        
         % shift the window by one timepoint
         i_window_begin = i_window_begin + 1;
    end

    % finding a more accurate rising time
    i_rising = find_rising_index(t, handles.risingtime);
    k = 1;
    % find the first jump after the previous rising time point
    if k < length(edge)
        while edge(k) < i_rising && k < length(edge)
            k = k + 1;
        end
        % increase the rising time up to the jump
        while i_rising < edge(k)
            i_rising = i_rising + 1;
        end
        i_rising = i_rising - 1;
    end

    % setting the start of smooth region for the rising exponential
    CUTOFF_risingfitstart = ceil(i_rising - i_rising/3);

    % containers for bounds of smooth regions
    smooth_begin = [];
    smooth_end =[];

    % adding the rising exponential
    smooth_begin = [smooth_begin; CUTOFF_risingfitstart];
    smooth_end = [smooth_end; i_rising];

    % adding the regions from the oscillating part
    for k = 1 : ( length(edge)-1 )
        % check if the region is long enough
        if  t(edge(k+1)) - t(edge(k)) > handles.minlength ...
                && edge(k) > i_rising
           smooth_begin = [smooth_begin;  edge(k)];
           smooth_end = [smooth_end; edge(k+1)];        
        end
    end
    % last oscillation period (which is likely to be terminated by i_end)
     k = length(edge);
     if k > 0
         if t(i_end) - t(edge(k)) > handles.minlength ...
                 && edge(k) > i_rising
             smooth_begin = [smooth_begin; edge(k)];
             smooth_end = [smooth_end; i_end];
         end
     end
    % display the number of smooth regions
    num_of_regions = length(smooth_begin);
    set(handles.checkbox_smoothregions, ...
        'String',['smooth regions (',int2str(num_of_regions) ,')'])
