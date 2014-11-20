function handles = parallel_linear_fit(handles)
% calls the fitting functions accroding to the parameters stored in handels

     % read from handle
     col_t = handles.col_t;
     col_n = handles.col_n;
     data = handles.data;
     t = data(:,col_t);
     n = data(:,col_n);
     width = handles.width;
     period = handles.period;
     midline = handles.midline;
    
     % set bounds of fitting to be equal to bounds of smooth regions
     handles.fit_begin = handles.smooth_begin;
     handles.fit_end = handles.smooth_end;

     % rename data point:  (x,y) = (t, log(n))
     x = t;
     y = log(n);

     % Choose model for fitting
     if get(handles.popupmenu_model,'value') == 1
     % 1: Brownian motion
         % calculate diffusion constant from estimated values and chi
         D  = (handles.chi)^2 / log(2) *  ( width/( period * midline) )^3;
        
         % fit
         [  x_avg, a, a_lower, a_upper,  b, b_lower, b_upper ] = ...
         fit_slope_of_segments_changing_with_Brownian_motion( ...
            x, y, handles.smooth_begin, handles.smooth_end, ...
            D, handles.eps, handles.itermax );
     
     elseif get(handles.popupmenu_model,'value') == 2
     % 2: integrated Brownian motion
         % calculate diffusion constant from estimated values and chi
         D  = 3/4*(handles.chi)^2 / (log(2))^3 *  ( width/( period * midline) )^5;
         
         % fit
         [  x_avg, a, a_lower, a_upper,  b, b_lower, b_upper ] = ...
         fit_slope_of_segments_changing_with_integrated_Brownian_motion( ...
            x, y, handles.smooth_begin, handles.smooth_end, ...
            D, handles.eps, handles.itermax );
         
     end
         

     % transform back to original variables
     handles.t_fit = x_avg;
     handles.mu = a;
     handles.mu_lower = a_lower;
     handles.mu_upper = a_upper;
     handles.n0 = exp(b);
     handles.n0_lower = exp(b_lower);
     handles.n0_upper = exp(b_upper);

     % display the number of fitted regions
     kmax = length(handles.smooth_begin);
     set(handles.text_fitmonitor,'String', [int2str(kmax),' regions'] );

     % plot data + fit
     plot_nt(handles);

     % plot fitted mu on second plot
     plot_mut(handles);

