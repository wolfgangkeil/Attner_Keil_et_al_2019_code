function plot_fates_vs_birth_delay(dirname, list_file)
%
% function plot_fates_vs_birth_delay(dirname, list_file)
%
% this function plots various cell-cycle and birth order statistics for the
% Z1 and Z4 lineages
%
%
%----------- code written by Wolfgang Keil, 2017 The Rockefeller University

    do_printing = 0;
    specification_string = 'WT_25degrees_';

    close all;
    scrsz = get(0, 'screensize');
    

    %Design of the figures is set here
    AC_FC = [1 0 1]; % magenta
    AC_EC = [.5 0 .5]; % magenta

    
    Against_bias_FC = [0.9 .3 .4];
    Against_bias_EC = [1 0 0];
    
%     AC_against_bias_FC = [1 0.6 1]; % magenta
%     AC_against_bias_EC = [.78 0.6 .78]; % magenta

    AC_with_bias_FC = [0.45 0.4 0.95]; % light blue 
    AC_with_bias_EC = [0.03 0.2 .9]; % Darker blue
    
    
    VU_FC = [0 1 0]; % green
    VU_EC = [0 .5 0]; % magenta

    
%     VU_against_bias_FC = [0.74 1 0.74]; % green
%     VU_against_bias_EC = [0.6 .8 0.6]; % magenta
    VU_with_bias_FC = AC_with_bias_FC;
    VU_with_bias_EC = AC_with_bias_EC;

    % Marker and line properties
    ms = 15;
    fs = 26;
    lw = 2;
    tl  = [0.025 0.025];
    
    axis_lim_rel_divs = [0 3 -3 3];
    axis_lim_birth_orders = [0 4 0 4];

    % Which sex do we plot
    sex  = 'hermaphrodite';
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if do_printing
        addpath('./export_fig');
    end
    
    
    %%% First, read all the worm with hermaphrodite sex
    [birth_order_1st_round,birth_order_2nd_round,birth_order_3rd_round,...
        cc_lengths_2nd, cc_lengths_3rd, fates] ...
        = get_all_Z1_Z4_fates_and_birth_orders(dirname, list_file, sex);

    %%%% Find all worms, in which Z1.ppp adopted the AC or VU fate
    Z1aaa_AC = find(strcmpi(fates(:,1),'AC'));
    Z1aaa_VU = find(strcmpi(fates(:,1),'VU'));

    %%%%%%%%%%%%%%%%%%%%%%%%%%% NOW THE ACTUAL PLOTTING
    %%%% 


    hf1 = figure(1);
    clf;
    % Have to add NaNs here, otherwise color specifications have no effect 
    catIdx = repmat({'AC'}, [length(Z1aaa_AC),1]);
    [handles, data] = plotSpread([NaN;NaN;birth_order_1st_round(Z1aaa_AC)'], ...
        'categoryIdx',{'AC', 'VU', catIdx{:}},'xValues', 1, 'categoryMarkers',...
        {'o', 'o'},'categoryColors',[AC_FC;VU_FC]);
    
    hold on;
    % Have to add NaNs here, otherwise color specifications have no effect 
    catIdx = repmat({'VU'}, [length(Z1aaa_VU),1]);
    plotSpread([NaN;NaN;birth_order_1st_round(Z1aaa_VU)'], ...
         'categoryIdx',{'AC', 'VU', catIdx{:}},'xValues', 2, 'categoryMarkers',...
         {'o', 'o'},'categoryColors',[AC_FC;VU_FC]);
     
    hold off;
    set(gca, 'tickdir','out', 'linewidth', lw, 'fontsize', fs, 'ticklength', tl, 'box', 'off');

    xlabel('Z1.ppp fate');
    ylabel('Z1 - Z4 div. [h]');
    set(gca,'xtick',[1,2], 'xticklabel', {'AC', 'VU'});
    set(gca,'ytick',[-3 -2 -1 0 1 2 3]);

    hold on;
    plot([0 3], [0 0], '--', 'Color', [0.7 0.7 0.7], 'linewidth', lw);
    hold off;
    axis(axis_lim_rel_divs);

    % replace markers with right colors etc.
    replace_AC_marker_colors(hf1,AC_FC, AC_EC, AC_FC,lw,ms);
    replace_VU_marker_colors(hf1,VU_FC, VU_EC, VU_FC,lw,ms);


    if do_printing
        set(gcf,'color','none');
        set(gca,'color','none');
        % Sets background color to white
        export_fig(gcf, ['../../pics/' specification_string sex '_Z1Z4_BO_fate_1st_div.pdf']);        
        set(gcf,'color','w');
        set(gca,'color','w');
    end
 

    %%%% 
    hf2 = figure(2);
    clf;
    % Have to add NaNs here, otherwise color specifications have no effect 
    catIdx = repmat({'AC'}, [length(Z1aaa_AC),1]);
    plotSpread([NaN;NaN;birth_order_2nd_round(Z1aaa_AC)'], ...
        'categoryIdx',{'AC', 'VU', catIdx{:}},'xValues', 1, ...
               'categoryMarkers', {'o', 'o'},'categoryColors',[AC_FC;VU_FC]);
    hold on;
    % Have to add NaNs here, otherwise color specifications have no effect 
    catIdx = repmat({'VU'}, [length(Z1aaa_VU),1]);
    plotSpread([NaN;NaN;birth_order_2nd_round(Z1aaa_VU)'], ...
         'categoryIdx',{'AC', 'VU', catIdx{:}},'xValues', 2, ...
            'categoryMarkers', {'o', 'o'},'categoryColors',[AC_FC;VU_FC]);
    hold off;
    set(gca, 'tickdir','out', 'linewidth', lw, 'fontsize', fs, 'ticklength', tl, 'box', 'off');

    xlabel('Z1.ppp fate');
    ylabel('Z1.p - Z4.a div. [h]');
    set(gca,'xtick',[1,2], 'xticklabel', {'AC', 'VU'});
    set(gca,'ytick',[-4 -3 -2 -1 0 1 2 3 4]);

    hold on;
    plot([0 3], [0 0], '--', 'Color', [0.7 0.7 0.7], 'linewidth', lw);
    hold off;
    axis(axis_lim_rel_divs);

    % replace markers with right colors etc.
    replace_AC_marker_colors(hf2,AC_FC, AC_EC, AC_FC,lw,ms);
    replace_VU_marker_colors(hf2,VU_FC, VU_EC, VU_FC,lw,ms);


    if do_printing
        % Sets background color to white
        set(gcf,'color','w');
        export_fig(gcf, ['../../pics/' specification_string sex '_Z1Z4_BO_fate_2nd_div.pdf']);        
    end
 

    %%%%%%%%%%%%%%%%
    hf3 = figure(3);
    clf;
    % Have to add NaNs here, otherwise color specifications have no effect 
    catIdx = repmat({'AC'}, [length(Z1aaa_AC),1]);
    plotSpread([NaN;NaN;birth_order_3rd_round(Z1aaa_AC)'],...
         'categoryIdx',{'AC', 'VU', catIdx{:}},'xValues', 1, ...
            'categoryMarkers', {'o', 'o'},'categoryColors',[AC_FC;VU_FC]);
    hold on;
    % Have to add NaNs here, otherwise color specifications have no effect 
    catIdx = repmat({'VU'}, [length(Z1aaa_VU),1]);
    plotSpread([NaN;NaN;birth_order_3rd_round(Z1aaa_VU)'], ...
         'categoryIdx',{'AC', 'VU', catIdx{:}},'xValues', 2,...
                'categoryMarkers', {'o', 'o'},'categoryColors',[AC_FC;VU_FC]);
    hold off;
    set(gca, 'tickdir','out', 'linewidth', lw, 'fontsize', fs, 'ticklength', tl, 'box', 'off');

    xlabel('Z1.ppp fate');
    ylabel('Z1.pp - Z4.aa div. [h]');
    set(gca,'xtick',[1,2], 'xticklabel', {'AC', 'VU'});
    set(gca,'ytick',[-4 -3 -2 -1 0 1 2 3 4]);

    hold on;
    plot([0 3], [0 0], '--', 'Color', [0.7 0.7 0.7], 'linewidth', lw);
    hold off;
    axis(axis_lim_rel_divs);

    % replace markers with right colors etc.
    replace_AC_marker_colors(hf3,AC_FC, AC_EC, AC_FC,lw,ms);
    replace_VU_marker_colors(hf3,VU_FC, VU_EC, VU_FC,lw,ms);



    if do_printing
        % Sets background color to white
        set(gcf,'color','none');
        set(gca,'color','none');
        export_fig(gcf, ['../../pics/' specification_string sex '_Z1Z4_BO_fate_3rd_div.pdf']);        
        set(gcf,'color','w');
        set(gca,'color','w');
    end
    
    
    %%%%%%%%%%%%% DETERMINE CATETORIES FOR PLOTTING
    AC_1st = birth_order_1st_round(Z1aaa_AC);
    AC_2nd = birth_order_2nd_round(Z1aaa_AC);
    AC_3rd = birth_order_3rd_round(Z1aaa_AC);

    AC_1st_2plot = AC_1st(~isnan(AC_1st) & ~isnan(AC_2nd) & ~isnan(AC_3rd));
    AC_2nd_2plot = AC_2nd(~isnan(AC_1st) & ~isnan(AC_2nd) & ~isnan(AC_3rd));
    AC_3rd_2plot = AC_3rd(~isnan(AC_1st) & ~isnan(AC_2nd) & ~isnan(AC_3rd));



    %%%%%
    VU_1st = birth_order_1st_round(Z1aaa_VU);
    VU_2nd = birth_order_2nd_round(Z1aaa_VU);
    VU_3rd = birth_order_3rd_round(Z1aaa_VU);

    VU_1st_2plot = VU_1st(~isnan(VU_1st) & ~isnan(VU_2nd) & ~isnan(VU_3rd));
    VU_2nd_2plot = VU_2nd(~isnan(VU_1st) & ~isnan(VU_2nd) & ~isnan(VU_3rd));
    VU_3rd_2plot = VU_3rd(~isnan(VU_1st) & ~isnan(VU_2nd) & ~isnan(VU_3rd));

    data_1st = [NaN;NaN;AC_1st_2plot';VU_1st_2plot'];
    data_2nd = [NaN;NaN;AC_2nd_2plot';VU_2nd_2plot'];
    data_3rd = [NaN;NaN;AC_3rd_2plot';VU_3rd_2plot'];

    %%% Categories
    catIdxAC = repmat({'AC'}, [length(AC_1st_2plot),1]);
    catIdxVU = repmat({'VU'}, [length(VU_1st_2plot),1]);


    hf4 = figure(4);
    set(hf4, 'Position',[1 1 2*scrsz(3)/3 scrsz(4)/2]);

    % plot first just to get the data
    clf; 
    [~, data_1st] = plotSpread(data_1st,'categoryIdx',{'AC', 'VU', catIdxAC{:},catIdxVU{:}}', 'xvalues', 1);
    [~, data_2nd] = plotSpread(data_2nd,'categoryIdx',{'AC', 'VU', catIdxAC{:},catIdxVU{:}}', 'xvalues', 2);
    [~, data_3rd] = plotSpread(data_3rd,'categoryIdx',{'AC', 'VU', catIdxAC{:},catIdxVU{:}}', 'xvalues', 3);

    clf; % clear the figure again


    plot([data_1st(:,1),data_2nd(:,1),data_3rd(:,1)]', [data_1st(:,2),data_2nd(:,2),data_3rd(:,2)]', '--', 'linewidth', 1, 'Color', [0.8 0.8 0.8]);
    hold on;
    plotSpread([NaN; NaN; data_1st(:,2)],'categoryIdx',{'AC', 'VU', catIdxAC{:},catIdxVU{:}}', 'xvalues', 1,'categoryMarkers', {'o', 'o'},'categoryColors',[AC_FC;VU_FC]);
    plotSpread([NaN; NaN; data_2nd(:,2)],'categoryIdx',{'AC', 'VU', catIdxAC{:},catIdxVU{:}}', 'xvalues', 2,'categoryMarkers', {'o', 'o'},'categoryColors',[AC_FC;VU_FC]);
    plotSpread([NaN; NaN; data_3rd(:,2)],'categoryIdx',{'AC', 'VU', catIdxAC{:},catIdxVU{:}}', 'xvalues', 3,'categoryMarkers', {'o', 'o'},'categoryColors',[AC_FC;VU_FC]);
    hold off; 

    set(gca, 'tickdir','out', 'linewidth', lw,'fontsize', fs, 'ticklength', 0.5*tl, 'box', 'off');
    xlabel('Division rounds');
    ylabel('Z1-Z4 precursor div. [h]');
    set(gca,'xtick',[1,2,3]);
    set(gca,'ytick',[-4 -3 -2 -1 0 1 2 3 4]);

    hold on;
    plot([0 4], [0 0], '--', 'Color', [0.7 0.7 0.7], 'linewidth', lw);
    hold off;
    axis([0 4 -3 4]);

    % replace markers with right colors etc.
    replace_AC_marker_colors(hf4,AC_FC, AC_EC, AC_FC,lw,ms);
    replace_VU_marker_colors(hf4,VU_FC, VU_EC, VU_FC,lw,ms);

    if do_printing
        % Sets background color to white
        set(gcf,'color','none');
        set(gca,'color','none');
        export_fig(gcf, ['../../pics/' specification_string sex '_Z1Z4_BO_fate_all_div.pdf']);        
        set(gcf,'color','w');
        set(gca,'color','w');
    end
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%% PLOT CC Lengths VS Fates (last divisions)
    hf5 = figure(5);
    set(hf5, 'Position',[1 1 2*scrsz(3)/3 scrsz(4)/2]);
    %%%% 
    clf;
    
    cc_2plot = cc_lengths_3rd.Z1pa(Z1aaa_AC);
    cc_2plot = cc_2plot(cc_2plot > 0);
    
    %%% Plot Z1.pa
    % Have to add NaNs here, otherwise color specifications have no effect 
    catIdx = repmat({'AC'}, [length(cc_2plot),1]);
    plotSpread([NaN;NaN;cc_2plot'], ...
        'categoryIdx',{'AC', 'VU', catIdx{:}},'xValues', 1, ...
               'categoryMarkers', {'o', 'o'},'categoryColors',[AC_FC;VU_FC]);
    hold on;
    
    cc_2plot = cc_lengths_3rd.Z1pa(Z1aaa_VU);
    cc_2plot = cc_2plot(cc_2plot > 0);

    % Have to add NaNs here, otherwise color specifications have no effect 
    catIdx = repmat({'VU'}, [length(cc_2plot),1]);
    plotSpread([NaN;NaN;cc_2plot'], ...
         'categoryIdx',{'AC', 'VU', catIdx{:}},'xValues', 1.5, ...
            'categoryMarkers', {'o', 'o'},'categoryColors',[AC_FC;VU_FC]);
    hold off;
    

    %%% Plot Z1.pp
    %cc_2plot = cc_lengths_3rd.Z1pp;
    cc_2plot = cc_lengths_3rd.Z1pp(Z1aaa_AC);
    cc_2plot = cc_2plot(cc_2plot > 0);
    
    % Have to add NaNs here, otherwise color specifications have no effect 
    catIdx = repmat({'AC'}, [length(cc_2plot),1]);
    plotSpread([NaN;NaN;cc_2plot'], ...
        'categoryIdx',{'AC', 'VU', catIdx{:}},'xValues', 2.5, ...
               'categoryMarkers', {'o', 'o'},'categoryColors',[AC_FC;VU_FC]);
    hold on;

    cc_2plot = cc_lengths_3rd.Z1pp(Z1aaa_VU);
    cc_2plot = cc_2plot(cc_2plot > 0);
    % Have to add NaNs here, otherwise color specifications have no effect 
    catIdx = repmat({'VU'}, [length(cc_2plot),1]);
    plotSpread([NaN;NaN;cc_2plot'], ...
        'categoryIdx',{'AC', 'VU', catIdx{:}},'xValues', 3, ...
               'categoryMarkers', {'o', 'o'},'categoryColors',[AC_FC;VU_FC]);
    hold off;
    

    %%% Plot Z4.aa
    cc_2plot = cc_lengths_3rd.Z4aa(Z1aaa_AC);
    cc_2plot = cc_2plot(cc_2plot > 0);
    % Have to add NaNs here, otherwise color specifications have no effect 
    catIdx = repmat({'AC'}, [length(cc_2plot),1]);
    plotSpread([NaN;NaN;cc_2plot'], ...
        'categoryIdx',{'AC', 'VU', catIdx{:}},'xValues', 4, ...
               'categoryMarkers', {'o', 'o'},'categoryColors',[AC_FC;VU_FC]);
    hold on;
    cc_2plot = cc_lengths_3rd.Z4aa(Z1aaa_VU);
    cc_2plot = cc_2plot(cc_2plot > 0);
    % Have to add NaNs here, otherwise color specifications have no effect 
    catIdx = repmat({'VU'}, [length(cc_2plot),1]);
    plotSpread([NaN;NaN;cc_2plot'], ...
        'categoryIdx',{'AC', 'VU', catIdx{:}},'xValues', 4.5, ...
               'categoryMarkers', {'o', 'o'},'categoryColors',[AC_FC;VU_FC]);
    hold off;

    %%% Plot Z4.ap
    cc_2plot = cc_lengths_3rd.Z4ap(Z1aaa_AC);
    cc_2plot = cc_2plot(cc_2plot > 0);
    % Have to add NaNs here, otherwise color specifications have no effect 
    catIdx = repmat({'AC'}, [length(cc_2plot),1]);
    plotSpread([NaN;NaN;cc_2plot'], ...
        'categoryIdx',{'AC', 'VU', catIdx{:}},'xValues', 5.5, ...
               'categoryMarkers', {'o', 'o'},'categoryColors',[AC_FC;VU_FC]);
    hold on;
    cc_2plot = cc_lengths_3rd.Z4ap(Z1aaa_VU);
    cc_2plot = cc_2plot(cc_2plot > 0);
    % Have to add NaNs here, otherwise color specifications have no effect 
    catIdx = repmat({'VU'}, [length(cc_2plot),1]);
    plotSpread([NaN;NaN;cc_2plot'], ...
        'categoryIdx',{'AC', 'VU', catIdx{:}},'xValues', 6, ...
               'categoryMarkers', {'o', 'o'},'categoryColors',[AC_FC;VU_FC]);
    hold off;    

    
    %%%%% Design the figure
    set(gca, 'tickdir','out', 'linewidth', lw, 'fontsize', fs, 'ticklength', tl, 'box', 'off');
    ylabel('cc lengths [h]');
    set(gca,'xtick',[1.25, 2.75 4.25 5.75], 'xticklabel', {'Z1.pa', 'Z1.pp', 'Z4.aa', 'Z4.ap'});
    set(gca,'ytick',[0 2 4 6 8 10]);
    axis([0 7 0 6]);
    
    % replace markers with right colors etc.
    replace_AC_marker_colors(hf5,AC_FC, AC_EC, AC_FC,lw,ms);
    replace_VU_marker_colors(hf5,VU_FC, VU_EC, VU_FC,lw,ms);

    if do_printing
        set(gcf,'color','none');
        set(gca,'color','none');
        % Sets background color to white
        export_fig(gcf, ['../../pics/' specification_string sex '_Z1Z4_cc_lengths_fate_3rd_div.pdf']);        
        set(gcf,'color','w');
        set(gca,'color','w');
    end
        

    %%%%%%%%%%%%%%%%%%%%%%%%%% PLOT CC Lengths VS Fates (2nd divisions)
    hf6 = figure(6);
    clf;
    set(hf6, 'Position',[1 1 2*scrsz(3)/3 scrsz(4)/2]);
    %%%% 
    %%% Plot Z1.a
    cc_2plot = cc_lengths_2nd.Z1a(Z1aaa_AC);
    cc_2plot = cc_2plot(cc_2plot > 0);
    
    % Have to add NaNs here, otherwise color specifications have no effect 
    catIdx = repmat({'AC'}, [length(cc_2plot),1]);
    plotSpread([NaN;NaN;cc_2plot'], ...
        'categoryIdx',{'AC', 'VU', catIdx{:}},'xValues', 1, ...
               'categoryMarkers', {'o', 'o'},'categoryColors',[AC_FC;VU_FC]);
    hold on;
    
    cc_2plot = cc_lengths_2nd.Z1a(Z1aaa_VU);
    cc_2plot = cc_2plot(cc_2plot > 0);
    % Have to add NaNs here, otherwise color specifications have no effect 
    catIdx = repmat({'VU'}, [length(cc_2plot),1]);
    plotSpread([NaN;NaN;cc_2plot'], ...
        'categoryIdx',{'AC', 'VU', catIdx{:}},'xValues', 1.5, ...
               'categoryMarkers', {'o', 'o'},'categoryColors',[AC_FC;VU_FC]);
    hold off;
    

    %%% Plot Z1.p
    cc_2plot = cc_lengths_2nd.Z1p(Z1aaa_AC);
    cc_2plot = cc_2plot(cc_2plot > 0);
    % Have to add NaNs here, otherwise color specifications have no effect 
    catIdx = repmat({'AC'}, [length(cc_2plot),1]);
    plotSpread([NaN;NaN;cc_2plot'], ...
        'categoryIdx',{'AC', 'VU', catIdx{:}},'xValues', 2.5, ...
               'categoryMarkers', {'o', 'o'},'categoryColors',[AC_FC;VU_FC]);
    hold on;
    cc_2plot = cc_lengths_2nd.Z1p(Z1aaa_VU);
    cc_2plot = cc_2plot(cc_2plot > 0);
    % Have to add NaNs here, otherwise color specifications have no effect 
    catIdx = repmat({'VU'}, [length(cc_2plot),1]);
    plotSpread([NaN;NaN;cc_2plot'], ...
        'categoryIdx',{'AC', 'VU', catIdx{:}},'xValues', 3, ...
               'categoryMarkers', {'o', 'o'},'categoryColors',[AC_FC;VU_FC]);
    hold off;
    

    %%% Plot Z4.a
    cc_2plot = cc_lengths_2nd.Z4a(Z1aaa_AC);
    cc_2plot = cc_2plot(cc_2plot > 0);
    % Have to add NaNs here, otherwise color specifications have no effect 
    catIdx = repmat({'AC'}, [length(cc_2plot),1]);
    plotSpread([NaN;NaN;cc_2plot'], ...
        'categoryIdx',{'AC', 'VU', catIdx{:}},'xValues', 4, ...
               'categoryMarkers', {'o', 'o'},'categoryColors',[AC_FC;VU_FC]);
    hold on;

    cc_2plot = cc_lengths_2nd.Z4a(Z1aaa_VU);
    cc_2plot = cc_2plot(cc_2plot > 0);
    % Have to add NaNs here, otherwise color specifications have no effect 
    catIdx = repmat({'VU'}, [length(cc_2plot),1]);
    plotSpread([NaN;NaN;cc_2plot'], ...
        'categoryIdx',{'AC', 'VU', catIdx{:}},'xValues', 4.5, ...
               'categoryMarkers', {'o', 'o'},'categoryColors',[AC_FC;VU_FC]);
    hold off;

    %%% Plot Z4.p
    cc_2plot = cc_lengths_2nd.Z4p(Z1aaa_AC);
    cc_2plot = cc_2plot(cc_2plot > 0);
    % Have to add NaNs here, otherwise color specifications have no effect 
    catIdx = repmat({'AC'}, [length(cc_2plot),1]);
    plotSpread([NaN;NaN;cc_2plot'], ...
        'categoryIdx',{'AC', 'VU', catIdx{:}},'xValues', 5.5, ...
               'categoryMarkers', {'o', 'o'},'categoryColors',[AC_FC;VU_FC]);
    hold on;
    cc_2plot = cc_lengths_2nd.Z4p(Z1aaa_VU);
    cc_2plot = cc_2plot(cc_2plot > 0);
    % Have to add NaNs here, otherwise color specifications have no effect 
    catIdx = repmat({'VU'}, [length(cc_2plot),1]);
    plotSpread([NaN;NaN;cc_2plot'], ...
        'categoryIdx',{'AC', 'VU', catIdx{:}},'xValues', 6, ...
               'categoryMarkers', {'o', 'o'},'categoryColors',[AC_FC;VU_FC]);
    hold off;    
    
    
    
    %%%%%% Design the figure
    set(gca, 'tickdir','out', 'linewidth', lw, 'fontsize', fs, 'ticklength', tl, 'box', 'off');
    ylabel('cc lengths [h]');
    set(gca,'xtick',[1.25, 2.75 4.25 5.75], 'xticklabel', {'Z1.a', 'Z1.p', 'Z4.a', 'Z4.p'});
    set(gca,'ytick',[0 2 4 6 8 10]);
    axis([0 7 0 6]);
    
    % replace markers with right colors etc.
    replace_AC_marker_colors(hf6,AC_FC, AC_EC, AC_FC,lw,ms);
    replace_VU_marker_colors(hf6,VU_FC, VU_EC, VU_FC,lw,ms);

    if do_printing
        % Sets background color to white
        set(gcf,'color','none');
        set(gca,'color','none');
        export_fig(gcf, ['../../pics/' specification_string sex '_Z1Z4_cc_lengths_fate_2nd_div.pdf']);        
        set(gcf,'color','w');
        set(gca,'color','w');
    end
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%% Plots for highlighting timing differences
    AC_1st = birth_order_1st_round(Z1aaa_AC);
    AC_2nd = birth_order_2nd_round(Z1aaa_AC);
    AC_3rd = birth_order_3rd_round(Z1aaa_AC);

    %%% determine Categories
    catIdxAC_1st = {};
    for ii = 1:length(AC_1st)
        if AC_1st(ii) >= 0
            catIdxAC_1st = {catIdxAC_1st{:},'AC_against_bias' };
        else
            catIdxAC_1st = {catIdxAC_1st{:},'AC'};
        end
    end
        
    %%% determine Categories
    catIdxAC_2nd = {};
    for ii = 1:length(AC_2nd)
        if AC_2nd(ii) >= 0
            catIdxAC_2nd = {catIdxAC_2nd{:},'AC_against_bias' };
        else
            catIdxAC_2nd = {catIdxAC_2nd{:},'AC'};
        end
    end
    %%% determine Categories
    catIdxAC_3rd = {};
    for ii = 1:length(AC_3rd)
        if AC_3rd(ii) >= 0
            catIdxAC_3rd = {catIdxAC_3rd{:},'AC_against_bias' };
        else
            catIdxAC_3rd = {catIdxAC_3rd{:},'AC'};
        end
    end
    
    
    
    VU_1st = birth_order_1st_round(Z1aaa_VU);
    VU_2nd = birth_order_2nd_round(Z1aaa_VU);
    VU_3rd = birth_order_3rd_round(Z1aaa_VU);

    %%% determine Categories
    catIdxVU_1st = {};
    for ii = 1:length(VU_1st)
        if VU_1st(ii) <= 0
            catIdxVU_1st = {catIdxVU_1st{:},'VU_against_bias' };
        else
            catIdxVU_1st = {catIdxVU_1st{:},'VU'};
        end
    end
        
    %%% determine Categories
    catIdxVU_2nd = {};
    for ii = 1:length(VU_2nd)
        if VU_2nd(ii) <= 0
            catIdxVU_2nd = {catIdxVU_2nd{:},'VU_against_bias' };
        else
            catIdxVU_2nd = {catIdxVU_2nd{:},'VU'};
        end
    end
    %%% determine Categories
    catIdxVU_3rd = {};
    for ii = 1:length(VU_3rd)
        if VU_3rd(ii) <= 0
            catIdxVU_3rd = {catIdxVU_3rd{:},'VU_against_bias' };
        else
            catIdxVU_3rd = {catIdxVU_3rd{:},'VU'};
        end
    end    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    hf7 = figure(7);

    clf;
    plotSpread([NaN;NaN;NaN;NaN;AC_1st'], ...
         'categoryIdx',{'AC', 'VU','AC_against_bias', 'VU_against_bias' catIdxAC_1st{:}},'xValues', 1, 'categoryMarkers',...
         {'o', 'o','o','o'},'categoryColors',[AC_FC;VU_FC;AC_with_bias_FC;VU_with_bias_FC]);
    hold on;
    plotSpread([NaN;NaN;NaN;NaN;VU_1st'], ...
         'categoryIdx',{'AC', 'VU','AC_against_bias', 'VU_against_bias' catIdxVU_1st{:}},'xValues', 2, 'categoryMarkers',...
         {'o', 'o','o','o'},'categoryColors',[AC_FC;VU_FC;AC_with_bias_FC;VU_with_bias_FC]);
    
    hold off;
    set(gca, 'tickdir','out', 'linewidth', lw, 'fontsize', fs, 'ticklength', tl, 'box', 'off');

    xlabel('Z1.ppp fate');
    ylabel('Z1 - Z4 div. [h]');
    set(gca,'xtick',[1,2], 'xticklabel', {'AC', 'VU'});
    set(gca,'ytick',[-2 -1 0 1 2]);

    hold on;
    plot([0 3], [0 0], '--', 'Color', [0.7 0.7 0.7], 'linewidth', lw);
    hold off;
    axis(axis_lim_rel_divs);
    
     
    % replace markers with right colors etc.
    replace_marker_color(hf7,AC_FC, AC_EC, AC_FC,lw,ms);
    replace_marker_color(hf7,VU_FC, VU_EC, VU_FC,lw,ms);
    replace_marker_color(hf7,AC_with_bias_FC, AC_with_bias_EC, AC_with_bias_FC,lw,ms);
    replace_marker_color(hf7,VU_with_bias_FC, VU_with_bias_EC, VU_with_bias_FC,lw,ms);
    
   

    if do_printing
        % Sets background color to white
        set(gcf,'color','none');
        set(gca,'color','none');
        export_fig(gcf, ['../../pics/' specification_string sex '_Z1Z4_BO_fate_1st_div_bias_highlighted.pdf']);        
        set(gcf,'color','w');
        set(gca,'color','w');
    end
    
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    hf8 = figure(8);

    clf;
    plotSpread([NaN;NaN;NaN;NaN;AC_2nd'], ...
         'categoryIdx',{'AC', 'VU','AC_against_bias', 'VU_against_bias' catIdxAC_2nd{:}},'xValues', 1, 'categoryMarkers',...
         {'o', 'o','o','o'},'categoryColors',[AC_FC;VU_FC;AC_with_bias_FC;VU_with_bias_FC]);
    hold on;
    plotSpread([NaN;NaN;NaN;NaN;VU_2nd'], ...
         'categoryIdx',{'AC', 'VU','AC_against_bias', 'VU_against_bias' catIdxVU_2nd{:}},'xValues', 2, 'categoryMarkers',...
         {'o', 'o','o','o'},'categoryColors',[AC_FC;VU_FC;AC_with_bias_FC;VU_with_bias_FC]);
        
    hold off;
    set(gca, 'tickdir','out', 'linewidth', lw, 'fontsize', fs, 'ticklength', tl, 'box', 'off');

    xlabel('Z1.ppp fate');
    ylabel('Z1.p - Z4.a div. [h]');
    set(gca,'xtick',[1,2], 'xticklabel', {'AC', 'VU'});
    set(gca,'ytick',[-2 -1 0 1 2]);

    hold on;
    plot([0 3], [0 0], '--', 'Color', [0.7 0.7 0.7], 'linewidth', lw);
    hold off;
    axis(axis_lim_rel_divs);

    % replace markers with right colors etc.
    replace_marker_color(hf8,AC_FC, AC_EC, AC_FC,lw,ms);
    replace_marker_color(hf8,VU_FC, VU_EC, VU_FC,lw,ms);
    replace_marker_color(hf8,AC_with_bias_FC, AC_with_bias_EC, AC_with_bias_FC,lw,ms);
    replace_marker_color(hf8,VU_with_bias_FC, VU_with_bias_EC, VU_with_bias_FC,lw,ms);
    

    if do_printing
        % Sets background color to white
        set(gcf,'color','none');
        set(gca,'color','none');
        export_fig(gcf, ['../../pics/' specification_string sex '_Z1Z4_BO_fate_2nd_div_bias_highlighted.pdf']);        
        set(gcf,'color','w');
        set(gca,'color','w');
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    hf9 = figure(9);

    clf;
    plotSpread([NaN;NaN;NaN;NaN;AC_3rd'], ...
         'categoryIdx',{'AC', 'VU','AC_against_bias', 'VU_against_bias' catIdxAC_3rd{:}},'xValues', 1, 'categoryMarkers',...
         {'o', 'o','o','o'},'categoryColors',[AC_FC;VU_FC;AC_with_bias_FC;VU_with_bias_FC]);
    hold on;
    plotSpread([NaN;NaN;NaN;NaN;VU_3rd'], ...
         'categoryIdx',{'AC', 'VU','AC_against_bias', 'VU_against_bias' catIdxVU_3rd{:}},'xValues', 2, 'categoryMarkers',...
         {'o', 'o','o','o'},'categoryColors',[AC_FC;VU_FC;AC_with_bias_FC;VU_with_bias_FC]);
    

    hold off;
    set(gca, 'tickdir','out', 'linewidth', lw, 'fontsize', fs, 'ticklength', tl, 'box', 'off');

    xlabel('Z1.ppp fate');
    ylabel('Z1.pp - Z4.aa div. [h]');
    set(gca,'xtick',[1,2], 'xticklabel', {'AC', 'VU'});
    set(gca,'ytick',[-2 -1 0 1 2]);

    hold on;
    plot([0 3], [0 0], '--', 'Color', [0.7 0.7 0.7], 'linewidth', lw);
    hold off;
    axis([0 3 -3 3]);   

     % replace markers with right colors etc.
    replace_marker_color(hf9,AC_FC, AC_EC, AC_FC,lw,ms);
    replace_marker_color(hf9,VU_FC, VU_EC, VU_FC,lw,ms);
    replace_marker_color(hf9,AC_with_bias_FC, AC_with_bias_EC, AC_with_bias_FC,lw,ms);
    replace_marker_color(hf9,VU_with_bias_FC, VU_with_bias_EC, VU_with_bias_FC,lw,ms);

    if do_printing
        % Sets background color to white
        set(gcf,'color','none');
        set(gca,'color','none');
        export_fig(gcf, ['../../pics/' specification_string sex '_Z1Z4_BO_fate_3rd_div_bias_highlighted.pdf']);        
        set(gcf,'color','w');
        set(gca,'color','w');
    end
    
    


    %%%%%%%%%%%%%%% PLOT EVERYTHING IN ONE FIGURE, BIAS OF  %%%%%%%%%%%%%%%%%%%%%
    AC_1st = birth_order_1st_round(Z1aaa_AC);
    AC_2nd = birth_order_2nd_round(Z1aaa_AC);
    AC_3rd = birth_order_3rd_round(Z1aaa_AC);

    AC_1st_2plot = AC_1st(~isnan(AC_1st) & ~isnan(AC_2nd) & ~isnan(AC_3rd));
    AC_2nd_2plot = AC_2nd(~isnan(AC_1st) & ~isnan(AC_2nd) & ~isnan(AC_3rd));
    AC_3rd_2plot = AC_3rd(~isnan(AC_1st) & ~isnan(AC_2nd) & ~isnan(AC_3rd));

    %%% determine Categories
    catIdxAC = {};
    for ii = 1:length(AC_1st_2plot)
        if AC_3rd_2plot(ii) >= 0
            catIdxAC = {catIdxAC{:},'AC_against_bias' };
        else
            catIdxAC = {catIdxAC{:},'AC'};
        end
    end

    %%%%%
    VU_1st = birth_order_1st_round(Z1aaa_VU);
    VU_2nd = birth_order_2nd_round(Z1aaa_VU);
    VU_3rd = birth_order_3rd_round(Z1aaa_VU);

    VU_1st_2plot = VU_1st(~isnan(VU_1st) & ~isnan(VU_2nd) & ~isnan(VU_3rd));
    VU_2nd_2plot = VU_2nd(~isnan(VU_1st) & ~isnan(VU_2nd) & ~isnan(VU_3rd));
    VU_3rd_2plot = VU_3rd(~isnan(VU_1st) & ~isnan(VU_2nd) & ~isnan(VU_3rd));

    %%% determine Categories
    catIdxVU = {};
    for ii = 1:length(VU_1st_2plot)
        if VU_3rd_2plot(ii) <= 0
            catIdxVU = {catIdxVU{:},'VU_against_bias' };
        else
            catIdxVU = {catIdxVU{:},'VU'};
        end
    end
    
    
    
    data_1st = [NaN;NaN;NaN;NaN;AC_1st_2plot';VU_1st_2plot'];
    data_2nd = [NaN;NaN;NaN;NaN;AC_2nd_2plot';VU_2nd_2plot'];
    data_3rd = [NaN;NaN;NaN;NaN;AC_3rd_2plot';VU_3rd_2plot'];

    
    hf10 = figure(10);
    set(hf10, 'Position',[1 1 2*scrsz(3)/3 scrsz(4)/2]);

    % plot first just to get the data
    clf; 
    [~, data_1st] = plotSpread(data_1st,'categoryIdx',{'AC', 'VU','AC_against_bias', 'VU_against_bias', catIdxAC{:},catIdxVU{:}}', 'xvalues', 1);
    [~, data_2nd] = plotSpread(data_2nd,'categoryIdx',{'AC', 'VU','AC_against_bias', 'VU_against_bias', catIdxAC{:},catIdxVU{:}}', 'xvalues', 2);
    [~, data_3rd] = plotSpread(data_3rd,'categoryIdx',{'AC', 'VU','AC_against_bias', 'VU_against_bias', catIdxAC{:},catIdxVU{:}}', 'xvalues', 3);

    clf; % clear the figure again


    plot([data_1st(:,1),data_2nd(:,1),data_3rd(:,1)]', [data_1st(:,2),data_2nd(:,2),data_3rd(:,2)]', '--', 'linewidth', 1, 'Color', [0.8 0.8 0.8]);
    hold on;
    plotSpread([NaN; NaN; NaN; NaN; data_1st(:,2)],'categoryIdx',{'AC', 'VU','AC_against_bias', 'VU_against_bias', catIdxAC{:},catIdxVU{:}}',...
        'xvalues', 1,'categoryMarkers', {'o', 'o','o', 'o'},'categoryColors',[AC_FC;VU_FC;AC_with_bias_FC;VU_with_bias_FC]);
    plotSpread([NaN; NaN; NaN; NaN; data_2nd(:,2)],'categoryIdx',{'AC', 'VU','AC_against_bias', 'VU_against_bias', catIdxAC{:},catIdxVU{:}}',...
        'xvalues', 2,'categoryMarkers', {'o', 'o','o', 'o'},'categoryColors',[AC_FC;VU_FC;AC_with_bias_FC;VU_with_bias_FC]);
    plotSpread([NaN; NaN; NaN; NaN; data_3rd(:,2)],'categoryIdx',{'AC', 'VU','AC_against_bias', 'VU_against_bias', catIdxAC{:},catIdxVU{:}}',...
        'xvalues', 3,'categoryMarkers', {'o', 'o','o', 'o'},'categoryColors',[AC_FC;VU_FC;AC_with_bias_FC;VU_with_bias_FC]);
    
    hold off; 

    set(gca, 'tickdir','out', 'linewidth', lw, 'fontsize', fs, 'ticklength', 0.5*tl, 'box', 'off');
    xlabel('Division rounds');
    ylabel('Z1-Z4 precursor div. [h]');
    set(gca,'xtick',[1,2,3]);
    set(gca,'ytick',[-4 -3 -2 -1 0 1 2 3 4]);

    hold on;
    plot([0 4], [0 0], '--', 'Color', [0.7 0.7 0.7], 'linewidth', lw);
    hold off;
    axis([0 4 -3 4]);

    
     
     % replace markers with right colors etc.
    replace_marker_color(hf10,AC_FC, AC_EC, AC_FC,lw,ms);
    replace_marker_color(hf10,VU_FC, VU_EC, VU_FC,lw,ms);
    replace_marker_color(hf10,AC_with_bias_FC, AC_with_bias_EC, AC_with_bias_FC,lw,ms);
    replace_marker_color(hf10,VU_with_bias_FC, VU_with_bias_EC, VU_with_bias_FC,lw,ms);
    
    
    
    if do_printing
        % Sets background color to white
        set(gcf,'color','none');
        set(gca,'color','none');
        export_fig(gcf, ['../../pics/' specification_string sex '_Z1Z4_BO_fate_all_div_bias_highlighted.pdf']);        
        set(gcf,'color','w');
        set(gca,'color','w');
    end
    
    
    
    %----------------------- 
    hf11 = figure(11);
    AC_3rd = birth_order_3rd_round(Z1aaa_AC);
    AC_3rd_2plot = AC_3rd(~isnan(AC_1st) & ~isnan(AC_2nd) & ~isnan(AC_3rd));

    %
    VU_3rd = birth_order_3rd_round(Z1aaa_VU);    
    VU_3rd_2plot = VU_3rd(~isnan(VU_1st) & ~isnan(VU_2nd) & ~isnan(VU_3rd));

    data = [AC_3rd_2plot';VU_3rd_2plot'];

    % Determine categories
    %%% determine Categories
    %catIdxAC = {'Against_bias','With_Bias'};
    catIdx = {};
    for ii = 1:length(AC_3rd_2plot)
        if AC_3rd_2plot(ii) < 0
            catIdx = {catIdx{:},'Against_bias'};
        else
            catIdx = {catIdx{:},'With_bias'};
        end
    end
    for ii = 1:length(VU_3rd_2plot)
        if VU_3rd_2plot(ii) > 0
            catIdx = {catIdx{:},'Against_bias'};
        else
            catIdx = {catIdx{:},'With_bias'};
        end
    end

    h = plotSpread(abs([NaN; NaN; data]),'categoryIdx',{'Against_bias', 'With_bias', catIdx{:}}',...
        'xvalues', 1,'categoryMarkers', {'^', 's'},'categoryColors',[Against_bias_FC;AC_with_bias_FC]);

    h.NodeChildren.LineWidth = 0.25;
    set(gca, 'tickdir','out', 'linewidth', lw, 'fontsize', fs, 'ticklength', 0.5*tl, 'box', 'off');
    ylabel('Div. timing differences [h]');
    set(gca,'xtick',0, 'xticklabel', {});
    set(gca,'ytick',[-2 -1 0 1 2]);
    axis([0.25 1.75 0 4]);

    
    % replace markers with right colors etc.
    replace_marker_color(hf11,AC_with_bias_FC, AC_with_bias_EC, AC_with_bias_FC,lw,1.3*ms);
    replace_marker_color(hf11,Against_bias_FC, Against_bias_EC, Against_bias_FC,lw,1.3*ms);
    

    
%    if do_printing
        % Sets background color to white
        set(gcf,'color','none');
        set(gca,'color','none');
        export_fig(gcf, ['../../pics/' specification_string sex '_Z1Z4_ABS_BO_vs_fate_against_bias_highlighted.pdf']);        
        set(gcf,'color','w');
        set(gca,'color','w');
%    end


    
    

end




%%%%%%%%%%%%%%%%%%% USED FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function replace_marker_color(fig_handle, orig_color,  Edgecolor, Facecolor,lw,ms)
    set(findobj(fig_handle,'color',orig_color),'Color',Edgecolor ,'MarkerFaceColor',Facecolor,'Linewidth', lw,'Markersize', ms);
end
function replace_AC_marker_colors(fig_handle, AC_color,  AC_Edgecolor, AC_Facecolor,lw,ms)
    set(findobj(fig_handle,'color',AC_color),'Color',AC_Edgecolor ,'MarkerFaceColor',AC_Facecolor,'Linewidth', lw,'Markersize', ms);
end

function replace_VU_marker_colors(fig_handle, VU_color,  VU_Edgecolor, VU_Facecolor,lw,ms)
    set(findobj(fig_handle,'color',VU_color),'Color',VU_Edgecolor ,'MarkerFaceColor',VU_Facecolor,'Linewidth', lw,'Markersize', ms);
end