function plot_nt(handles)
% draws the main plot showing
% n, smooth regions (bold curves), fits (red curves) VS t

    % plot col_t and col_n columns of data on axh with axes labels from header
    t = handles.data(:,handles.col_t);
    n = handles.data(:,handles.col_n);

    % grab handle for main plot field
    axes(handles.axes1);
    cla;
    % label axes
    xlabel(handles.header(handles.col_t));
    ylabel(handles.header(handles.col_n));

    hold on
    % raw data
    plot(t,n,'-k');

    % estimate lines
    if get(handles.checkbox_show,'Value') == 1
        % rising time's vertical line
        rt = handles.risingtime;
        t_end = t(length(t));
        m = handles.midline;
        w = handles.width;
        line([rt, rt],[n(1), m + 1*w],'Color','red');
        
        % dashed line below and above (indicating period, width and midline
        x = rt;
        dx = handles.period;
        while x < t_end
            line([x,x + dx/2],[m + w/2, m + w/2],'Color','red'); 
            line([x + dx/2,x + dx],[m - w/2, m - w/2],'Color','red'); 
            x = x + dx;
        end
    end

    % jumps
    if get(handles.checkbox_jumps,'Value') == 1
        rt = handles.risingtime;
        t_end = t(length(t));
        m = handles.midline;
        w = handles.width;
        
        % down jumps
        for k = ( 1 : length(handles.downedge) )
            x = t(handles.downedge(k));
            line([x,x], [m-w, m-w/2], 'Color','blue');
        end

        % up jumps
        for k = ( 1 : length(handles.upedge) )
            x = t(handles.upedge(k));
            line([x,x], [m-w, m-w/2], 'Color','red');
        end
    end

    % smooth regions
    if get(handles.checkbox_smoothregions,'Value') == 1
       for k =  1 : length(handles.smooth_begin) 
          plot( t( handles.smooth_begin(k) : handles.smooth_end(k) ),...
                n( handles.smooth_begin(k) : handles.smooth_end(k) ),...
                '-k', 'LineWidth', 2);
       end
    end

    % fitted oscillating regions
    if get(handles.checkbox_showoscfit,'Value') == 1 && length(handles.t_fit) > 0

        for k = 1 : length(handles.t_fit)
            t1 = t(handles.fit_begin(k)) - handles.period/8;
            t2 = t(handles.fit_end(k)) + handles.period/8;
            x = linspace( t1, t2, 20);
            y = handles.n0(k) * exp( handles.mu(k) * (x - handles.t_fit(k))  );
            plot(x,y,'-r');
        end

    end

    hold off


    % grab handle for filters plot field
    axes(handles.axes_filter);
    cla;
    xlabel( [ 'period = ', num2str(handles.period) ] );
    ylabel( [ 'width = ', num2str(handles.width) ] );

    hold on;

    % schematic sawtooth
    x = linspace(0,1,21);
    y = zeros(1,21);
    for i = 1:21;
        if x(i) <= 0.9
            y(i) = x(i) + ( x(i) / 0.9 )^2 * 0.1;
        else
            y(i) = 9 * ( 1 - x(i) );
        end
    end
    plot(x,y,'-k','LineWidth', 1.5);
    
    % set plot range
    set(handles.axes_filter,'XLim',[0,1]);
    set(handles.axes_filter,'YLim',[0,1]);

    % filter window
    dx = handles.twindow/handles.period;
    dy = handles.nwindow/handles.width;
    x1 = 0.5 - dx/2;
    x2 = 0.5 + dx/2;
    y1 = x1 + ( x1 / 0.9 )^2 * 0.1;
    y2 = x2 + ( x2 / 0.9 )^2 * 0.1;

    line([x1,x1],[0,1],'Color','black');
    line([x2,x2],[0,1],'Color','black');
    line([x1,x2],[y1 - dy/2, y2 - dy/2], 'Color', 'red');
    line([x1,x2],[y1 + dy/2, y2 + dy/2], 'Color', 'red');

    hold off;
