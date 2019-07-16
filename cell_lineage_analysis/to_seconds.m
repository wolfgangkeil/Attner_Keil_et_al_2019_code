% This function converts a time string given in the lineaging files used for automated lineaging into
% seconds, usually from the beginning of the experiment
function seconds = to_seconds(time_string)

    tt = strfind(time_string, ':');
    
    if length(tt) < 2
        error('Cannot convert string to time! Check format obeys hh:mm:ss');
    end
    
    hours = str2double(time_string(1:tt(1)-1));
    minutes = str2double(time_string(tt(1)+1:tt(2)-1));
    seconds = str2double(time_string(tt(2)+1:end));
    
    seconds = seconds + minutes*60 + hours*3600;
 
end