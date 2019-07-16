function [birth_order_1st_round,birth_order_2nd_round,birth_order_3rd_round,...
    cc_lengths_2nd,cc_lengths_3rd, fates] = get_all_Z1_Z4_fates_and_birth_orders(dirname, list_file,sex)
%
% DESCRIPTION 
% This function reads early somatic cell divisions and Z1.ppp and Z4.aaa cell fates 
% function is called by statistical_analyses_Z1Z4lineages.m
%
%
%
% INPUT PARAMETERES: 
% 
% this function gets all Z1_fates, Z4_fates for worms of sex "sex" in the worm_list, given by
% 'list_file' in the folder 'dirname'
% sex can be either 'male' or 'hermaphrodite'
%
% 
%
% OUTPUT PARAMETERS:
% birth_order_1st_round ... difference in timing between Z1 and Z4 division
% birth_order_2nd_round ... difference in timing between Z1.a/p and Z4.a/p
%                           divisions
% birth_order_3rd_round ... difference in timing between Z1.pa/p and Z4.aa/p
%                           divisions
% cc_lengths_2nd ... time interval between Z1/Z4  and Z1/Z4.a/p divisions
% cc_lengths_3rd ... time interval between Z1/Z4.aa/ap/ap and Z4.aa/ap/ap divisions
% fates ... cell fates of Z1.ppp and Z4.aaa
%
% NOTE: birth_order is div_times.Z1pp - div_times.Z4aa, i.e. positive if Z1.ppp is
% born first and negative if Z1.ppp is born second
%
% see also statistical_analyses_Z1Z4lineages.m
%
% by Wolfgang Keil, wolfgang.keil@curie.fr 2019
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if nargin < 3
        sex = 'hermaphrodite';
    end
    
    verbose  = 0;

    fid = fopen([dirname list_file]);
    C1 = textscan(fid, '%s');

    birth_order_1st_round = [];    
    birth_order_2nd_round = [];    
    birth_order_3rd_round = [];    
    
    cc_lengths_2nd = [];
    
    cc_lengths_2nd.Z1a = [];
    cc_lengths_2nd.Z1p = [];
    cc_lengths_2nd.Z4a = [];
    cc_lengths_2nd.Z4p = [];
    
    cc_lengths_3rd = [];
    cc_lengths_3rd.Z1pa = [];
    cc_lengths_3rd.Z1pp = [];
    cc_lengths_3rd.Z4aa = [];
    cc_lengths_3rd.Z4ap = [];

    fates = [];
    
    % Go over all the worms! 
    for ii  = 1:length(C1{1,1})

        if verbose
            disp(C1{1,1}{ii});
        end
        % read the lineaging data
        worm = read_single_worm_lineage_data(C1{1,1}{ii});

        div_times_1st = get_1st_division_times(worm);
        [div_times_2nd, cc_len_2nd] = get_2nd_division_times(worm);
        [div_times_3rd, cc_len_3rd] = get_3rd_division_times(worm);
        
        if strcmpi('hermaphrodite', sex)
            % Only read hermaphrodites here
            if strcmpi(worm.sex, sex)
                fates = [fates ; get_fates(worm)];   
                birth_order_1st_round = [birth_order_1st_round, div_times_1st.Z1 - div_times_1st.Z4];
                birth_order_2nd_round = [birth_order_2nd_round, div_times_2nd.Z1p - div_times_2nd.Z4a];
                birth_order_3rd_round = [birth_order_3rd_round, div_times_3rd.Z1pp - div_times_3rd.Z4aa];
                
                cc_lengths_2nd.Z1a = [cc_lengths_2nd.Z1a cc_len_2nd.Z1a];
                cc_lengths_2nd.Z1p = [cc_lengths_2nd.Z1p cc_len_2nd.Z1p];
                cc_lengths_2nd.Z4a = [cc_lengths_2nd.Z4a cc_len_2nd.Z4a];
                cc_lengths_2nd.Z4p = [cc_lengths_2nd.Z4p cc_len_2nd.Z4p];
                
                cc_lengths_3rd.Z1pa = [cc_lengths_3rd.Z1pa, cc_len_3rd.Z1pa];
                cc_lengths_3rd.Z1pp = [cc_lengths_3rd.Z1pp, cc_len_3rd.Z1pp];
                cc_lengths_3rd.Z4aa = [cc_lengths_3rd.Z4aa, cc_len_3rd.Z4aa];
                cc_lengths_3rd.Z4ap = [cc_lengths_3rd.Z4ap, cc_len_3rd.Z4ap];
   
            else
                disp('No Sex specified?');
                
            end
        else
            % Only read males here, take Z1.pa as precursor of Z1.paa (LC
            % or VD)
            if strcmpi(worm.sex, sex) % make sure it's actually a male
                get_fates(worm)
                fates = [fates ; get_fates(worm)];   
                birth_order_1st_round = [birth_order_1st_round, div_times_1st.Z1 - div_times_1st.Z4];
                birth_order_2nd_round = [birth_order_2nd_round, div_times_2nd.Z1p - div_times_2nd.Z4a];
                birth_order_3rd_round = [birth_order_3rd_round, div_times_3rd.Z1pa - div_times_3rd.Z4aa];
            end
        end
    end


end