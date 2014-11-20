function [risingtime, width, midline, period] = estimate_update(handles)
% estimates risingtime, width, midline and period from handles.data

    % read from handle variables 
    col_t = handles.col_t;
    col_n = handles.col_n;
    data = handles.data;

    % update risingtime
    risingtime = handles.risingtime;
    if get(handles.checkbox_risingtime,'Value') == 1 
        risingtime = estimate_risingtime(data, col_t, col_n);
        set(handles.edit_risingtime,'String', risingtime);
    end

    % update width
    width = handles.width;
    if get(handles.checkbox_width,'Value') == 1
        width = estimate_width(data, col_t, col_n, risingtime);
        set(handles.edit_width,'String', width);
    end

    % update midline
    midline = handles.midline;
    if get(handles.checkbox_midline,'Value') == 1
        midline = estimate_midline(data, col_t, col_n, risingtime);
        set(handles.edit_midline,'String', midline);
    end

    % update period
    period = handles.period;
    if get(handles.checkbox_period,'Value') == 1
        period = estimate_period(data, col_t, col_n, risingtime, midline);
        set(handles.edit_period,'String', period);
    end

    function risingtime = estimate_risingtime(data, col_t, col_n)
    % estimates the risingtime from data
    t = data(:,col_t);
    n = data(:,col_n);
    len = length(t);

    % roghly finding the middle line of the oscillatons
     midline = mean( n( floor(len/2):len ) );

     % finding the rising exponential at the beginning
     i_rising = 1;
     while n(i_rising) < midline
        i_rising = i_rising + 1;
     end

     risingtime = t(i_rising);

    function width = estimate_width(data, col_t, col_n, risingtime)
    % estimates width from risingtime and data
    t = data(:,col_t);
    n = data(:,col_n);

    i_end = length(t);
    i_rising = find_rising_index(t, risingtime);

    width = sqrt(12 * var( n(i_rising: i_end) ) );

    function midline = estimate_midline(data, col_t, col_n, risingtime)
    % estimates midline from risingtime and data
    t = data(:,col_t);
    n = data(:,col_n);

    i_end = length(t);
    i_rising = find_rising_index(t, risingtime);

    midline = mean( n(i_rising: i_end) );

    function period = estimate_period(data, col_t, col_n, risingtime, midline)
    % estimates width from risingtime and data
    t = data(:,col_t);
    n = data(:,col_n);

    len = length(t);
    i_end = len;
    i_rising = find_rising_index(t, risingtime);

    % finding the position of up and down CROSSINGS
     % crossing: the curve crosses the midline
     upedge = zeros(len,1);
     downedge = zeros(len,1);
     upedge_times = [];
     downedge_times = [];
     for i = i_rising: i_end-1
         if n(i) < midline && n(i+1) > midline
             upedge(i) = 1;
             upedge_times = [upedge_times; t(i)];
         elseif n(i) > midline && n(i+1) < midline
             downedge(i) = 1;
             downedge_times = [downedge_times; t(i)];
         end
     end

     % waiting times between up <-> down
     num_downedge = sum(downedge);
     num_upedge = sum(upedge);
     num_waittimes = min(num_downedge, num_upedge);
     if num_waittimes < 1
        period = t(i_end);
        return
     end

     waittimes = zeros(num_waittimes,1);
     for i = 1:num_waittimes
         waittimes(i) = abs(downedge_times(i) - upedge_times(i));
     end

     % roughly finding the period
     % period: the CUTOFF_p percentil of waittimes
     CUTOFF_p = 90;
     period = 2* prctile(waittimes, CUTOFF_p);
