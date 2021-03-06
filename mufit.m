function varargout = mufit(varargin)
% MUFIT MATLAB code for mufit.fig
%      MUFIT, by itself, creates a new MUFIT or raises the existing
%      singleton*.
%
%      H = MUFIT returns the handle to a new MUFIT or the handle to
%      the existing singleton*.
%
%      MUFIT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MUFIT.M with the given input arguments.
%
%      MUFIT('Property','Value',...) creates a new MUFIT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mufit_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mufit_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mufit

% Last Modified by GUIDE v2.5 20-Jun-2014 17:53:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mufit_OpeningFcn, ...
                   'gui_OutputFcn',  @mufit_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Outputs from this function are returned to the command line.
function varargout = mufit_OutputFcn(hObject, eventdata, handles) 
    % Get default command line output from handles structure
    varargout{1} = handles.output;


% --- Executes just before mufit is made visible.
function mufit_OpeningFcn(hObject, eventdata, handles, varargin)
    handles = initialize(hObject, handles);
    guidata(hObject,handles)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Callbacks %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% "Select data" box
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pushbutton_load_Callback(hObject, eventdata, handles)

    % get user select file
    [filename,pathname,~] = uigetfile({'*.txt'}, 'Select raw data file');
    if filename == 0
        return
    end
    handles.filename = filename;
    handles.pathname = pathname;

    progressbar = waitbar(0,'Loading. Please wait...');
    
    % load raw data
    filedata = importdata([pathname,filename], '\t');
    data = filedata.data;
    
    % load header
    % check if colheaders field is present
    if size( fieldnames ( filedata ) ) >= 3
        header = filedata.colheaders;
    else
        % manually process the textdata field
        header = strsplit( filedata.textdata{1}, '\t' );
    end
    waitbar(7/10);

    % check size
    datasize = size(data);
    number_of_columns = datasize(2);
    if ~has_two_columns(number_of_columns, filename, hObject, progressbar)
        return
    end
    
    % put data into handles
    handles.data = data;
    handles.header = header;

    % initialize popup menus for selecting columns of the data
    handles = init_column_select( handles, number_of_columns );

    % display filename
    set(handles.text_filename,'String',filename);

    % set default values for 'Auto' checkboxes
    set(handles.checkbox_risingtime,'Value',1);
    set(handles.checkbox_width,'Value',1);
    set(handles.checkbox_midline,'Value',1);
    set(handles.checkbox_period,'Value',1);

    waitbar(8/10);
    
    % read ini file
    handles = read_inifile('./mufit.ini', handles);
    waitbar(9/10);

    % calculate estiamtes and filter
    handles = update_all(handles);
    enable_all(handles);
    waitbar(1);
    close(progressbar);

    guidata(hObject,handles)
function pushbutton_loadold_Callback(hObject, eventdata, handles)

    % get user select file
    [filename,pathname,~] = uigetfile( ...
        {'*.xls; *.xlsx'},...
        'Select a mufit output file ');
    if filename == 0
        return
    end
    handles.filename = filename;
    handles.pathname = pathname;

    progressbar = waitbar(0,'Loading. Please wait...');
    % checking file consistency
    if ~is_Excel_file( pathname, filename, hObject, progressbar)
        return
    end
    
    % checking if the file is really an output file of mufit
    if ~is_output_file( pathname, filename, hObject, progressbar)
        return
    end
    waitbar(1/10);

    % load raw data
    [data,header,~] = xlsread([pathname,filename],'Raw');
    
    % check size
    datasize = size(data);
    number_of_columns = datasize(2);
    if ~has_two_columns( number_of_columns, filename, hObject, progressbar )
        return
    end
    
    % put data into handles
    handles.data = data;
    handles.header = header;
    
    % initialize popup menus for selecting columns of the data
    handles = init_column_select( handles, number_of_columns );

    % display filename
    set(handles.text_filename,'String',filename);
    waitbar(1/4);

    % load parameters
    [~,varname,~]  = xlsread([pathname,filename],'Parameters', 'A:A');
    [varvalue,~,~] = xlsread([pathname,filename],'Parameters', 'B:B');
    handles = read_param( handles, varname, varvalue );
    waitbar(2/4);

    % load fitted data
    [fitdata,~,~] = xlsread([pathname,filename],'Fit');
    handles.t_fit = fitdata(:,1);
    handles.mu = fitdata(:,2);
    handles.mu_lower = fitdata(:,3);
    handles.mu_upper = fitdata(:,4);
    waitbar(3/4);

    % load misc data
    [miscdata,~,~] = xlsread([pathname,filename],'Misc');
    handles.fit_begin = miscdata(:,1);
    handles.fit_end   = miscdata(:,2);
    handles.n0 = miscdata(:,3);
    waitbar(7/8);

    % update calculated values and plot
    handles = update_all(handles);
    plot_mut(handles)

    % display the number of regions next to the 'Fit' button
    set(handles.text_fitmonitor,'String', [int2str(length(handles.t_fit)),' regions'] );

    % enable user control
    enable_all(handles);    
    waitbar(1);
    close(progressbar);

    guidata(hObject,handles)

function popupmenu1_Callback(hObject, eventdata, handles)
    handles.col_t = get(handles.popupmenu1,'Value');
    handles = update_all(handles);
    guidata(hObject,handles)
function popupmenu2_Callback(hObject, eventdata, handles)
    handles.col_n = get(handles.popupmenu2,'Value');
    handles = update_all(handles);
    guidata(hObject,handles)



% "Estimate" box
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function edit_risingtime_Callback(hObject, eventdata, handles)
    handles.risingtime = read_pos_edit_w_checkbox( hObject, handles.checkbox_risingtime );
    handles = update_all(handles);
    guidata(hObject,handles)
function edit_width_Callback(hObject, eventdata, handles)
    handles.width = read_pos_edit_w_checkbox( hObject, handles.checkbox_width );
    handles = update_all(handles);
    guidata(hObject,handles)
function edit_midline_Callback(hObject, eventdata, handles)
    handles.midline = read_pos_edit_w_checkbox( hObject, handles.checkbox_midline );
    handles = update_all(handles);
    guidata(hObject,handles)
function edit_period_Callback(hObject, eventdata, handles)
    handles.period = read_pos_edit_w_checkbox( hObject, handles.checkbox_period );
    handles = update_all(handles);
    guidata(hObject,handles)

function checkbox_risingtime_Callback(hObject, eventdata, handles)
    handles = update_all(handles);
    guidata(hObject,handles)
function checkbox_width_Callback(hObject, eventdata, handles)
    handles = update_all(handles);
    guidata(hObject,handles)
function checkbox_midline_Callback(hObject, eventdata, handles)
    handles = update_all(handles);
    guidata(hObject,handles)
function checkbox_period_Callback(hObject, eventdata, handles)
    handles = update_all(handles);
    guidata(hObject,handles)

function checkbox_show_Callback(hObject, eventdata, handles)
    handles = update_all(handles);
    guidata(hObject,handles)



% "Filter" box
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function edit_twindow_Callback(hObject, eventdata, handles)
    handles.twindow_numeric = read_pos_edit( hObject );
    handles = update_all(handles);
    guidata(hObject,handles)
function edit_nwindow_Callback(hObject, eventdata, handles)
    handles.nwindow_numeric = read_pos_edit( hObject );
    handles = update_all(handles);
    guidata(hObject,handles)
function edit_minlength_Callback(hObject, eventdata, handles)
    handles.minlength_numeric = read_pos_edit( hObject );
    handles = update_all(handles);
    guidata(hObject,handles)

function popupmenu_twindow_Callback(hObject, eventdata, handles)
    % changes the displayed numeric value but leaves twindow unchanged
     handles.twindow_numeric = change_unit( ...
        handles.popupmenu_twindow, ...
        handles.edit_twindow, ...
        handles.twindow, ...
        handles.period );
    guidata(hObject,handles)
function popupmenu_nwindow_Callback(hObject, eventdata, handles)
    % changes the displayed numeric value but leaves nwindow unchanged
     handles.nwindow_numeric = change_unit( ...
        handles.popupmenu_nwindow, ...
        handles.edit_nwindow, ...
        handles.nwindow, ...
        handles.width );
    guidata(hObject,handles)
function popupmenu_minlength_Callback(hObject, eventdata, handles)
    % changes the displayed numeric value but leaves minlength unchanged
     handles.minlength_numeric = change_unit( ...
        handles.popupmenu_minlength, ...
        handles.edit_minlength, ...
        handles.minlength, ...
        handles.period );
    guidata(hObject,handles)

function checkbox_jumps_Callback(hObject, eventdata, handles)
    handles = update_all(handles);
    guidata(hObject,handles)
function checkbox_smoothregions_Callback(hObject, eventdata, handles)
    handles = update_all(handles);
    guidata(hObject,handles)



% "Fit" box
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function edit_chi_Callback(hObject, eventdata, handles)
    handles.chi =  read_pos_edit( hObject ) / 100;
    guidata(hObject,handles)
function pushbutton_oscfit_Callback(hObject, eventdata, handles)
    handles = parallel_linear_fit(handles);
    guidata(hObject,handles)
function checkbox_showoscfit_Callback(hObject, eventdata, handles)
    plot_nt(handles);
function popupmenu_model_Callback(hObject, eventdata, handles)


% Secondary plot's controls
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function popupmenu_muplot_Callback(hObject, eventdata, handles)
    plot_mut(handles)
function checkbox_confint_Callback(hObject, eventdata, handles)
    plot_mut(handles)
function edit_conflevel_Callback(hObject, eventdata, handles)
    input = read_pos_edit( hObject );    
    if input >= 1
        errordlg('You must enter a numerical value between 0 and 1','Invalid Input','modal')
        uicontrol(hObject)
        return
    else
        handles.conflevel = input;
    end
    plot_mut(handles)
    guidata(hObject,handles)



% "Save" button
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pushbutton_savedata_Callback(hObject, eventdata, handles)
    warning off MATLAB:xlswrite:AddSheet

    % checking for existing fit data
    if length(handles.t_fit) < 1 || isempty(handles.t_fit)
        errordlg('No fit data','Data missing','modal')
        uicontrol(hObject)
        return
    end

    % get user select file
    [~,name,~] = fileparts(char(handles.filename));
    defaultfilename =[char(handles.pathname), ...
                name, '_', char(handles.header(handles.col_n)), '_fit','.xls'];
    [filename,pathname,~] = uiputfile( {'*.xls; *.xlsx'}, 'Save Data', ...
        defaultfilename );
    if filename == 0
        return
    end

    progressbar = waitbar(0,'Saving. Please wait...');

    % raw data
    save_rawdata( handles, pathname, filename )
    waitbar(1/4);

    % running parameters
    save_runparam( handles, pathname, filename )
    waitbar(2/4);

    % misc data
    save_misc( handles, pathname, filename )
    waitbar(3/4);

    % fitted parameters
    save_fitdata( handles, pathname, filename )
    waitbar(4/4);

    close(progressbar);




 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% CreateFcn %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function popupmenu1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popupmenu2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_risingtime_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_width_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_midline_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_period_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_twindow_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popupmenu_twindow_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_nwindow_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popupmenu_nwindow_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_minlength_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popupmenu_minlength_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_conflevel_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popupmenu_muplot_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_chi_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popupmenu_model_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
