function [div_times, cc_lengths]= get_3rd_division_times(worm)
%
%
% function [div_times,cc_lengths] = get_3rd_division_times(worm)
%
% DESCRIPTION:
%
% this function gets the time of the third divisions Z1 (division of Z1.pa and Z1.pp) and Z4 (Z4.aa and Z4.ap) in hours after the
% mount into the device
%
% INPUT PARAMETERS: 
% worm ... structure obtained from read_single_worm_lineage_data.m
%
% OUTPUT PARAMETERS:
% div_times is structure with four fields (Z1pa,Z1pp, Z4aa, Z4ap) 0, if the division was there but not
% captured and NaN if the cell didn't divide
% the zero is assigned by read_single_worm_lineage_data.m
% NaNs are assigned in thise function 
%
% the function also returns the cc lengths for the four divisions
%
%
% 
% see also read_single_worm_lineage_data.m, get_1st_division_times.m, get_2nd_division_times.m
%
%
% by Wolfgang Keil, wolfgang.keil@curie.fr 2019
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    cc_lengths = [];
    
    % Initialize the structure for the individual division times
    div_times = [];
    
    cc_lengths.all = [];
    cc_lengths.Z1_all = []; % this will store the division times of all Z1 descendants (3rd round, i.e. usually two divisions)
    cc_lengths.Z4_all = []; % this will store the division times of all Z4 descendants (3rd round, i.e. usually two divisions)
    
    
    
    if isfield(worm, 'Z1_lineage')        
        depth_tree = worm.Z1_lineage.depthtree;
        index = find(depth_tree == 2); % this finds Z1 lineage descendents that arose from two divisions

        for ii = index % go over all of those cells and ask whether there are children (--> 3rd round of divisions)
            if ~isempty(worm.Z1_duration.getchildren(ii))
                cc_lengths.all = [cc_lengths.all worm.Z1_duration.get(ii)];
                cc_lengths.Z1_all = [cc_lengths.Z1_all worm.Z1_duration.get(ii)];
                
                % If the field is not created yet, create one
                if eval(sprintf('~isfield(cc_lengths, ''%s_cc_lengths'');',worm.Z1_lineage.get(ii)))
                    eval(sprintf('cc_lengths.%s = [];',worm.Z1_lineage.get(ii)));
                end
                eval(sprintf('cc_lengths.%s = [cc_lengths.%s  worm.Z1_duration.get(ii)];',...
                        worm.Z1_lineage.get(ii),worm.Z1_lineage.get(ii)));
                    
                    
                  % If the field corresponding to the daughter cell is not
                % created yet, create it
                if eval(sprintf('~isfield(div_times, ''%s'');',worm.Z1_lineage.get(ii)))
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
        index = find(depth_tree == 2); % this finds Z4 lineage descendents that arose from two divisions

        for ii = index % go over all of those cells and ask whether there are children (--> 3rd round of divisions)
            if ~isempty(worm.Z4_duration.getchildren(ii))
                cc_lengths.all = [cc_lengths.all worm.Z4_duration.get(ii)];
                cc_lengths.Z4_all = [cc_lengths.Z4_all worm.Z4_duration.get(ii)];
                
                % If the field is not created yet, create one
                if eval(sprintf('~isfield(cc_lengths, ''%s_cc_lengths'');',worm.Z4_lineage.get(ii)))
                    eval(sprintf('cc_lengths.%s = [];',worm.Z4_lineage.get(ii)));
                end
                eval(sprintf('cc_lengths.%s = [cc_lengths.%s  worm.Z4_duration.get(ii)];',...
                        worm.Z4_lineage.get(ii),worm.Z4_lineage.get(ii)));
                    
                    
                % If the field corresponding to the daughter cell is not
                % created yet, create it
                if eval(sprintf('~isfield(div_times, ''%s'');',worm.Z4_lineage.get(ii)))
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