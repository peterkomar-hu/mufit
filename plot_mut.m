function plot_mut(handles)
% draws the auxiliary plot, showing
% mu OR doubling_time VS t_fit

    % if there's nothing to plot
    if length(handles.t_fit) < 1
        return
    end
    
    % grab the handle to the plot field
    axes(handles.axes_mu);
    cla;
    % set x-axis label
    xlabel(handles.header(handles.col_t));
    
    % determines the sigma multiplier from confidence level
    sigma_multiplier = sqrt(2)*erfinv(handles.conflevel);
    
    % x values
    x = handles.t_fit;
    x_max = x(length(x));
    
    % choose between plotting mu or doubling time
    if get(handles.popupmenu_muplot, 'Value') == 1
        y = handles.mu;
        y_lower = (handles.mu_lower - handles.mu) * sigma_multiplier + handles.mu;
        y_upper = (handles.mu_upper - handles.mu) * sigma_multiplier + handles.mu;
        ylabel('mu (1 / time units)');
    else
        y = log(2)./handles.mu;
        y_lower = log(2)./( (handles.mu_lower - handles.mu) * sigma_multiplier + handles.mu );
        y_upper = log(2)./( (handles.mu_upper - handles.mu) * sigma_multiplier + handles.mu );
        ylabel('doubling time (time units)');
    end
    
    % set y-axis range
    axis([0, x_max, 0, 1.4*max(y_upper)]);

    hold on;
    % plot upper and lower bounds
    if get(handles.checkbox_confint,'Value') == 1
        color = 0.60 * [1,1,1];
        plot(x, y_lower, '-','Color', color, 'LineWidth',1);
        plot(x, y_upper, '-','Color', color, 'LineWidth',1);
    end
    % plot main curve
    plot(x, y, '-k','LineWidth',1);
    hold off;
