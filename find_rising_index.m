function i_rising = find_rising_index(t, risingtime)
% find the index corresponding to risingtime in the array t
    
    % total length
    i_end = length(t);
    % starting point
    i_rising = min(ceil( i_end * risingtime / t(i_end) )+1, i_end);
    
    % if started below
    while t(i_rising) < risingtime && i_rising < i_end
       i_rising = i_rising + 1; 
    end
    
    % if started above
    while t(i_rising) > risingtime && i_rising > 1
        i_rising = i_rising - 1;
    end
    
    if i_rising < 1;
        i_rising  = i_rising + 1;
    end
