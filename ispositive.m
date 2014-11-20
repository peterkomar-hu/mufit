function logical = ispositive(input)
% checks if the input is a positive number

    if isnan(input)
        logical = 0;
    elseif input <= 0
        logical = 0;
    else 
        logical = 1;
    end
