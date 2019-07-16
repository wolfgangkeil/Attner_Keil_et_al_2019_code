function statistical_analyses_Z1Z4lineages()
%
% function plot_fates_vs_birth_delay(dirname, list_file)
%
% this function computes/plots various cell-cycle and birth order statistics for the
% Z1 and Z4 lineages
%
% % see also get_all_Z1_Z4_fates_and_birth_orders.m,
% read_single_worm_lineage_data.m , statistical_analyses_Z1Z4lineages.m
%
% by Wolfgang Keil, wolfgang.keil@curie.fr 2019
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    dirname = '~/Documents/GitHub/Attner_Keil_et_al_2019_code/cell_lineage_analysis/lineaging_data/';
    list_file = 'WT_25degrees_list.txt'; % includes only animals, were fate could be scored

    fs = 20;
    ms = 14;
    t_factor = 60;

    % Which sex do we plot
    sex  = 'hermaphrodite';
        
    %%% First, read all the worm with hermaphrodite sex
    [~,~,birth_order_3rd_round,...
        cc_lengths_2nd, cc_lengths_3rd, fates] ...
        = get_all_Z1_Z4_fates_and_birth_orders(dirname, list_file, sex);

    %%%%%%%%%%%%%%%%%%%% PLOTTING Z1.p vs. Z4.a cc-lengths
    figure(1)
    set(gcf, 'units','normalized', 'position', [0.2 0.2 0.35 0.4]);
    % against bias
    ind = (cc_lengths_2nd.Z1p > 0) & (cc_lengths_2nd.Z4a > 0) & ...
        ((strcmpi(fates(:,1),'AC')' & birth_order_3rd_round < 0 ) | (strcmpi(fates(:,2),'AC')' & birth_order_3rd_round > 0)) ;
    plot(cc_lengths_2nd.Z1p(ind)*t_factor, cc_lengths_2nd.Z4a(ind)*t_factor, '^', 'MarkerFaceColor', [1 0 0], 'MarkerEdgeColor', [1 1 1], 'MarkerSize', ms);
    hold on;
    % with bias
    ind = (cc_lengths_2nd.Z1p > 0) & (cc_lengths_2nd.Z4a > 0) & ...
        ((strcmpi(fates(:,1),'AC')' & birth_order_3rd_round > 0 ) | (strcmpi(fates(:,2),'AC')' & birth_order_3rd_round < 0)) ;
    plot(cc_lengths_2nd.Z1p(ind)*t_factor, cc_lengths_2nd.Z4a(ind)*t_factor, 's', 'MarkerFaceColor', [0 0 1], 'MarkerEdgeColor', [1 1 1], 'MarkerSize', ms);
    hold off
    box off;
    
    xlabel('Z1.p cc-length [min]');    ylabel('Z4.a cc-length [min]');
    axis equal;
    set(gca,'tickdir', 'out', 'linewidth', 3.5, 'ticklength', [0.03 0.03], 'fontsize', fs, 'fontweight', 'bold');
    
    disp('###########################')
    disp('Correlation between Z1.a and Z4.p:');
    [r,p] = corrcoef(cc_lengths_2nd.Z1p(ind), cc_lengths_2nd.Z4a(ind));
    disp(['r = ' num2str(r(1,2)) ' ; p < ' num2str(p(1,2)) ' ; ']);
    disp('    ');
    axis([1.5 5 1.5 5]*t_factor);
        
  
    disp('###########################')
    disp('Correlation between Z1.pa and Z4.ap:');
    [r,p] = corrcoef(cc_lengths_3rd.Z1pa(ind), cc_lengths_3rd.Z4ap(ind));
    disp(['r = ' num2str(r(1,2)) ' ; p < ' num2str(p(1,2)) ' ; ']);
    disp('    ');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    figure(2)
    set(gcf, 'units','normalized', 'position', [0.2 0.2 0.35 0.4]);
    % against bias
    ind = (cc_lengths_3rd.Z1pp > 0) & (cc_lengths_3rd.Z4aa > 0) & ...
        ((strcmpi(fates(:,1),'AC')' & birth_order_3rd_round < 0 ) | (strcmpi(fates(:,2),'AC')' & birth_order_3rd_round > 0)) ;
    plot(cc_lengths_3rd.Z1pp(ind)*t_factor, cc_lengths_3rd.Z4aa(ind)*t_factor, '^', 'MarkerFaceColor', [1 0 0], 'MarkerEdgeColor', [1 1 1], 'MarkerSize', ms);
    hold on;
    % with bias
    ind = (cc_lengths_3rd.Z1pp > 0) & (cc_lengths_3rd.Z4aa > 0) & ...
        ((strcmpi(fates(:,1),'AC')' & birth_order_3rd_round > 0 ) | (strcmpi(fates(:,2),'AC')' & birth_order_3rd_round < 0)) ;
    plot(cc_lengths_3rd.Z1pp(ind)*t_factor, cc_lengths_3rd.Z4aa(ind)*t_factor, 's', 'MarkerFaceColor', [0 0 1], 'MarkerEdgeColor', [1 1 1], 'MarkerSize', ms);
    hold off
    box off;
    
    xlabel('Z1.pp cc-length [min]');    ylabel('Z4.aa cc-length [min]');
    axis equal;
    set(gca,'tickdir', 'out', 'linewidth', 3.5, 'ticklength', [0.03 0.03], 'fontsize', fs, 'fontweight', 'bold');
    axis([1.5 5 1.5 5]*t_factor);  
    

    %%%%%%%%%%%%%%%%%%%%%%%%%%% Mean cc-duration differences
    
    ind = (cc_lengths_2nd.Z1a > 0) & (cc_lengths_2nd.Z4p > 0);
    tmp = mean(abs(cc_lengths_2nd.Z1a(ind) - cc_lengths_2nd.Z4p(ind)));
    disp('###########################')
    disp(['Mean cc-duration difference between Z1.a and Z4.p: ' num2str(tmp) 'h']);
    
    ind = (cc_lengths_2nd.Z1p > 0) & (cc_lengths_2nd.Z4a > 0);
    tmp = mean(abs(cc_lengths_2nd.Z1p(ind) - cc_lengths_2nd.Z4a(ind)));
    disp('###########################')
    disp(['Mean cc-duration difference between Z1.p and Z4.a: ' num2str(tmp) 'h']);
    
        
    
end