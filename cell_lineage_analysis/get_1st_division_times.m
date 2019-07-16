function div_times = get_1st_division_times(worm)
% function div_times = get_1st_division_times(worm)
%
%
% DESCRIPTION
% this function gets the time of the first divisions Z1 and Z4 in hours after the
% mount 
% INPUT PARAMETERS: 
% worm ... structure obtained from read_single_worm_lineage_data.m
%
% OUTPUT PARAMETERS
% div_times is structure with two fields, Z1 and Z4, 
% NaNs are assigned in this function, if a division is not captured
%
%
% see also read_single_worm_lineage_data.m, get_2nd_division_times.m, get_3rd_division_times.m
%
%
% by Wolfgang Keil, wolfgang.keil@curie.fr 2019
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Initialize the structure for the division times
    div_times = [];
    

    if isfield(worm, 'Z1_lineage')     
        depth_tree = worm.Z1_lineage.depthtree;
        index = find(depth_tree == 0); % this finds Z1 lineage descendents that arose from one division

        for ii = index % go over all of those cells and ask whether there are children (--> 2nd divisions)
            if ~isempty(worm.Z1_duration.getchildren(ii))
                % If the field corresponding to the daughter cell is not
                % created yet, create it
                if eval(sprintf('~isfield(div_times, ''%s_div_times'');',worm.Z1_lineage.get(ii)))
                    eval(sprintf('div_times.%s = [];',worm.Z1_lineage.get(ii)));
                end
                
                
                %%% Assign the actual division time
                if ~eval(sprintf('strcmpi(worm.%s_div_time, ''NC'')', worm.Z1_lineage.get(ii)));
                    eval(sprintf('div_times.%s = [div_times.%s  to_seconds(worm.%s_div_time)/3600];',...
                            worm.Z1_lineage.get(ii),worm.Z1_lineage.get(ii),worm.Z1_lineage.get(ii)));
                else
                    % Or assign NaN, if division could not be scored
                    eval(sprintf('div_times.%s = NaN;', worm.Z1_lineage.get(ii)));
                end
            end
        end
        
    end
    
    if isfield(worm, 'Z4_lineage')     
        depth_tree = worm.Z4_lineage.depthtree;
        index = find(depth_tree == 0); % this finds Z4 lineage descendents that arose from one division

        for ii = index % go over all of those cells and ask whether there are children (--> 2nd divisions)
            if ~isempty(worm.Z4_duration.getchildren(ii))
                % If the field corresponding to the daughter cell is not
                % created yet, create it
                if eval(sprintf('~isfield(div_times, ''%s_div_times'');',worm.Z4_lineage.get(ii)))
                    eval(sprintf('div_times.%s = [];',worm.Z4_lineage.get(ii)));
                end
                
                
                %%% Assign the actual division time
                if ~eval(sprintf('strcmpi(worm.%s_div_time, ''NC'')', worm.Z4_lineage.get(ii)));
                    eval(sprintf('div_times.%s = [div_times.%s  to_seconds(worm.%s_div_time)/3600];',...
                            worm.Z4_lineage.get(ii),worm.Z4_lineage.get(ii),worm.Z4_lineage.get(ii)));
                else
                    % Or assign NaN, if division could not be scored
                    eval(sprintf('div_times.%s = NaN;', worm.Z4_lineage.get(ii)));
                end
            end
        end
        
    end

end