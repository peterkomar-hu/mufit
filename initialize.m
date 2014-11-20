function handles = initialize(hObject, handles)
% initializes the user interface components and handle variables

    % Choose default command line output for mufit
    handles.output = hObject;

    % set axes1 properties
    set(handles.axes1,'NextPlot', 'replacechildren');

    % set popupmenus
    set(handles.popupmenu1,'String',' ');
    set(handles.popupmenu2,'String',' ');

    % set checkboxes
    set(handles.checkbox_risingtime,'Value',1);
    set(handles.checkbox_width,'Value',1);
    set(handles.checkbox_midline,'Value',1);
    set(handles.checkbox_period,'Value',1);
    set(handles.checkbox_show,'Value',0);
    set(handles.checkbox_jumps,'Value',0);
    set(handles.checkbox_smoothregions,'Value',1);
    set(handles.checkbox_confint,'Value',1);
    set(handles.checkbox_showoscfit,'Value',1);

    % set edittexts
    set(handles.edit_risingtime,'String','');
    set(handles.edit_width,'String','');
    set(handles.edit_midline,'String','');
    set(handles.edit_period,'String','');
    set(handles.edit_twindow,'String','0.1');
    set(handles.edit_nwindow,'String','0.2');
    set(handles.edit_minlength,'String','0.1');
    set(handles.edit_conflevel,'String','0.95');
    set(handles.edit_chi,'String','5');

    disable_all(handles);

    % variables for handling
    handles.data = [];
    handles.filename = [];
    handles.pathname = [];
    handles.col_t = [];
    handles.col_n = [];

    handles.risingtime = 0;
    handles.width = 0;
    handles.midline = 0;
    handles.period = 0;

    handles.twindow_numeric = 0.1;
    handles.nwindow_numeric = 0.2;
    handles.minlength_numeric = 0.1;
    handles.twindow = 0;
    handles.nwindow = 0;
    handles.minlength = 0;

    handles.downedge = [];
    handles.upedge = [];
    handles.edge = [];
    handles.smooth_begin = [];
    handles.smooth_end = [];
    handles.fit_begin = [];
    handles.fit_end = [];

    handles.conflevel = 0.95;
    handles.chi = 0.05;

    handles.eps = 1.0e-4;
    handles.itermax = 100;

    handles.t_fit = [];
    handles.n0 = [];
    handles.n0_lower = [];
    handles.n0_upper = [];
    handles.mu = [];
    handles.mu_upper = [];
    handles.mu_lower = [];

    % read default values from ini file
    handles = read_inifile('./mufit.ini', handles);
