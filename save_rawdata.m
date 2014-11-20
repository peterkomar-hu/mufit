function save_rawdata(handles, pathname, filename)
% exports raw data to pahtname/filename Excel file, sheet 'Raw'

    header = {  char(handles.header(handles.col_t)), ...
                char(handles.header(handles.col_n))  };
    data = [ handles.data(:, handles.col_t), ...
             handles.data(:, handles.col_n)  ];
    xlswrite([pathname,filename], header, 'Raw', 'A1');
    xlswrite([pathname,filename], data, 'Raw', 'A2');
