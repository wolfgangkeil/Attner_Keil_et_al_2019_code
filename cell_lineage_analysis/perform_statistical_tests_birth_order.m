function perform_statistical_tests_birth_order()
%
% function perform_statistical_tests_birth_order(dirname, list_file)
%
% DESCRIPTION
% this function tests various statistical properties on AC/VU birth-order vs.
% fate assignment, (Figure S1, Attner & Keil et al. 2019)
%
%
%
% see also get_all_Z1_Z4_fates_and_birth_orders.m,
% read_single_worm_lineage_data.m, statistical_analyses_Z1Z4lineages.m
%
%
% by Wolfgang Keil, wolfgang.keil@curie.fr 2019
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    dirname = 'lineaging_data/';
    list_file = 'WT_25degrees_list.txt'; % includes only animals, were fate could be scored

    % Which sex do we plot
    sex  = 'hermaphrodite';

    %%% First, read all the worm with hermaphrodite sex
    disp('Reading all worm files ...');
    [birth_order_1st_round,birth_order_2nd_round,birth_order_3rd_round,...
        cc_lengths_2nd, cc_lengths_3rd, fates] ...
        = get_all_Z1_Z4_fates_and_birth_orders(dirname, list_file, sex);

    %%%% Find all worms, in which Z1.ppp adopted the AC or VU fate
    Z1ppp_AC = find(strcmpi(fates(:,1),'AC'));
    Z1ppp_VU = find(strcmpi(fates(:,1),'VU'));
    
    %%%% Find all worms, in which Z4.aaa adopted the AC or VU fate
    Z4aaa_AC = find(strcmpi(fates(:,2),'AC'));
    Z4ppp_VU = find(strcmpi(fates(:,2),'VU'));   
    
    % Recall that birth_order is div_times.Z1pp - div_times.Z4aa, i.e.
    % negative if Z1.ppp is born first and positive if Z1.ppp is born second
    r.estimator = sum(birth_order_3rd_round > 0)/length(birth_order_3rd_round);
    
  
    % test whether this is any bias in who's born first in general
    Z_value = 1.9599; % for 95% confidence level, check https://en.wikipedia.org/wiki/Checking_whether_a_coin_is_fair for other Z_values
    
    disp('Using 95% confidence level...');
    
    E = Z_value/2/sqrt(length(birth_order_3rd_round));
    r.CI = [r.estimator-E, r.estimator+E];
    
    disp(['Birth order:  ' num2str(r.CI(1))  ' < ' num2str(r.estimator) ' < ' num2str(r.CI(2)) ]);
    
    for time_threshold  = 0.1:0.1:1
        
        disp('--------------------------');
        disp(['time threshold delta t < ' num2str(time_threshold) 'h']);
        disp('--------------------------');
        subset_worms = ((abs(birth_order_3rd_round) < time_threshold)');
        
        % Take out all the worms that have timing differences larger than
        % this 
        fates_subset_Z1ppp = fates(subset_worms,1);
        fates_subset_Z4aaa = fates(subset_worms,2);
        birth_order_3rd_round_subset = birth_order_3rd_round(subset_worms);
        
        
        % ask whether, of a cell is first-born what's the probability of it
        % becoming the AC
        tt1 = sum(strcmpi(fates_subset_Z1ppp(:,1),'AC') & birth_order_3rd_round_subset' < 0)...
                        + sum(strcmpi(fates_subset_Z4aaa(:,1),'AC') & birth_order_3rd_round_subset' > 0);        
        tt2 = sum(strcmpi(fates_subset_Z1ppp(:,1),'VU') & birth_order_3rd_round_subset' < 0)....
                           + sum(strcmpi(fates_subset_Z4aaa(:,1),'VU') & birth_order_3rd_round_subset' > 0);        

        r.estimator  = tt1/(tt1 + tt2);
        E = Z_value/2/sqrt(tt1 + tt2);
        r.CI = [r.estimator-E, r.estimator+E];

        disp(['N = ' num2str(tt1 + tt2)]);
        disp(['p(first-born cell = AC | dt < ' num2str(time_threshold)  ' h):  ' num2str(r.CI(1))  ' < ' num2str(r.estimator) ' < ' num2str(r.CI(2)) ]);

        
        
        % Ask what whether, if a cell becomes AC, what's the probability it
        % naving been the first-born cell
        tt1 = sum(strcmpi(fates_subset_Z1ppp(:,1),'AC') & birth_order_3rd_round_subset' < 0) ...
                        + sum(strcmpi(fates_subset_Z4aaa(:,1),'AC') & birth_order_3rd_round_subset' > 0);    
        tt2 = sum(strcmpi(fates_subset_Z1ppp(:,1),'AC') & birth_order_3rd_round_subset' > 0)...
                        + sum(strcmpi(fates_subset_Z4aaa(:,1),'AC') & birth_order_3rd_round_subset' < 0);
        
        r.estimator  = tt1/(tt1 + tt2);
        E = Z_value/2/sqrt(tt1 + tt2);
        r.CI = [r.estimator-E, r.estimator+E];

        disp(['N = ' num2str(tt1 + tt2)]);
        disp(['p(cell=first-born | cell-fate=AC, dt < ' num2str(time_threshold)  ' h):  ' num2str(r.CI(1))  ' < ' num2str(r.estimator) ' < ' num2str(r.CI(2)) ]);

       
        
%         % 
%         % ask what whether, if Z1.ppp is first-born, the probability of (Z1.ppp = AC) is equal to the probability of (Z1.ppp = VU).
%         tt1 = sum(strcmpi(fates_subset_Z1ppp(:,1),'AC') & birth_order_3rd_round_subset' < 0);        
%         tt2 = sum(strcmpi(fates_subset_Z1ppp(:,1),'VU') & birth_order_3rd_round_subset' < 0);
%         
%         r.estimator  = tt1/(tt1 + tt2);
%         E = Z_value/2/sqrt(tt1 + tt2);
%         r.CI = [r.estimator-E, r.estimator+E];
% 
%         disp(['N = ' num2str(tt1 + tt2)]);
%         disp(['p(Z1.ppp=AC | Z1.ppp first-born, dt < ' num2str(time_threshold)  ' h):  ' num2str(r.CI(1))  ' < ' num2str(r.estimator) ' < ' num2str(r.CI(2)) ]);
%         
% 
%         % Ask what whether, if Z1.ppp=AC, the probability of (Z1.ppp first-born) is equal to the probability of (Z1.ppp second-born).
%         tt1 = sum(strcmpi(fates_subset_Z1ppp(:,1),'AC') & birth_order_3rd_round_subset' < 0);        
%         tt2 = sum(strcmpi(fates_subset_Z1ppp(:,1),'AC') & birth_order_3rd_round_subset' > 0);
%         
%         r.estimator  = tt1/(tt1 + tt2);
%         E = Z_value/2/sqrt(tt1 + tt2);
%         r.CI = [r.estimator-E, r.estimator+E];
% 
%         disp(['N = ' num2str(tt1 + tt2)]);
%         disp(['p(Z1.ppp first-born | Z1.ppp=AC, dt < ' num2str(time_threshold)  ' h):  ' num2str(r.CI(1))  ' < ' num2str(r.estimator) ' < ' num2str(r.CI(2)) ]);
        
    end
    
    
    disp('####################################################');
    disp('####################################################');
    % Now play the same game, only with all worms with time difference
    % ABOVE a certain limit
    for time_threshold  = 0.1:0.1:1
        
        disp('--------------------------');
        disp(['time threshold delta t < ' num2str(time_threshold) 'h']);
        disp('--------------------------');
        subset_worms = ((abs(birth_order_3rd_round) > time_threshold)');
        
        % Take out all the worms that have timing differences larger than
        % this 
        fates_subset_Z1ppp = fates(subset_worms,1);
        fates_subset_Z4aaa = fates(subset_worms,2);
        birth_order_3rd_round_subset = birth_order_3rd_round(subset_worms);
        
        
        % ask whether, of a cell is first-born what's the probability of it
        % becoming the AC
        tt1 = sum(strcmpi(fates_subset_Z1ppp(:,1),'AC') & birth_order_3rd_round_subset' < 0)...
                        + sum(strcmpi(fates_subset_Z4aaa(:,1),'AC') & birth_order_3rd_round_subset' > 0);        
        tt2 = sum(strcmpi(fates_subset_Z1ppp(:,1),'VU') & birth_order_3rd_round_subset' < 0)....
                           + sum(strcmpi(fates_subset_Z4aaa(:,1),'VU') & birth_order_3rd_round_subset' > 0);        

        r.estimator  = tt1/(tt1 + tt2);
        E = Z_value/2/sqrt(tt1 + tt2);
        r.CI = [r.estimator-E, r.estimator+E];

        disp(['N = ' num2str(tt1 + tt2)]);
        disp(['p(first-born cell = AC | dt > ' num2str(time_threshold)  ' h):  ' num2str(r.CI(1))  ' < ' num2str(r.estimator) ' < ' num2str(r.CI(2)) ]);

        
        
        % Ask what whether, if a cell becomes AC, what's the probability it
        % naving been the first-born cell
        tt1 = sum(strcmpi(fates_subset_Z1ppp(:,1),'AC') & birth_order_3rd_round_subset' < 0) ...
                        + sum(strcmpi(fates_subset_Z4aaa(:,1),'AC') & birth_order_3rd_round_subset' > 0);    
        tt2 = sum(strcmpi(fates_subset_Z1ppp(:,1),'AC') & birth_order_3rd_round_subset' > 0)...
                        + sum(strcmpi(fates_subset_Z4aaa(:,1),'AC') & birth_order_3rd_round_subset' < 0);
        
        r.estimator  = tt1/(tt1 + tt2);
        E = Z_value/2/sqrt(tt1 + tt2);
        r.CI = [r.estimator-E, r.estimator+E];

        disp(['N = ' num2str(tt1 + tt2)]);
        disp(['p(cell=first-born | cell-fate=AC, dt > ' num2str(time_threshold)  ' h):  ' num2str(r.CI(1))  ' < ' num2str(r.estimator) ' < ' num2str(r.CI(2)) ]);


    end

end