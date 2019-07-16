function plot_Z1Z4_traces(experiment_date,worm_index)
%
% DESCRIPTION
% this function plots a fluorescence traces for Z1.pp and Z4.aa and
% daughters as in Figure 2A, Figure S2E in Attner & Keil et al. (2019)
% experiment needs to be stored in a folder {strain_name}/{Micro-Manager folder}
% 
% EXAMPLES: 
% plot_Z1Z4_traces('27-Sep-2018', 2);
% plot_Z1Z4_traces('10-Oct-2018', 2);
% plot_Z1Z4_traces('10-Oct-2018', 4);
% plot_Z1Z4_traces('10-Oct-2018', 9);
%   
% by Wolfgang Keil, wolfgang.keil@curie.fr 2019
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    
    strain_name = 'GS9062';

    do_interpolation = 1;
    do_filtering = 1;
    
    addpath('../cell_lineage_analysis/');
    tracing_foldername = ['data/fluo_tracing/' ...
                    strain_name '/']; % folder with .mat files 
    
    
    % Filter settings
    filter_shape = 'Gaussian';
    filter_type = 'lowpass';
    lp_cutoff = 0.15; % 9min Gaussian low-pass
    
    %  experiments are imaged every 16min, except 10-Oct-2018
    plot_alphacells_only = 1;
    if strfind(experiment_date, '10-Oct-2018')
        imaging_interval = 8;        
    else
        imaging_interval = 16;
    end
    
    % Cases 1,2,3 in Figure 2 of Attner & Keil et al., 2019
    if (strfind(experiment_date, '10-Oct-2018') & (worm_index ==  2 || worm_index ==  9)) | ...
            (strfind(experiment_date, '04-Oct-2018') & worm_index ==  7)
        plot_alphacells_only = 1;
    end
    
    
    
    % Generate the worm_file name to get birth-timings (need to rename months to numbers)
    worm_file_folder = ['../cell_lineage_analysis/lineaging_data/25degrees/' strain_name '/'];
    if strfind(experiment_date, 'Nov-2018')
        worm_filename = [strain_name '_2018-11-' experiment_date(1:2) '_Worm' num2str(worm_index) '.txt'];
    elseif strfind(experiment_date, 'Oct-2018')
        worm_filename = [strain_name '_2018-10-' experiment_date(1:2) '_Worm' num2str(worm_index) '.txt'];
    elseif strfind(experiment_date, 'Sep-2018')
        worm_filename = [strain_name '_2018-09-' experiment_date(1:2) '_Worm' num2str(worm_index) '.txt'];
    elseif strfind(experiment_date, 'Apr-2018')
        worm_filename = [strain_name '_2018-04-' experiment_date(1:2) '_Worm' num2str(worm_index) '.txt'];
    elseif strfind(experiment_date, 'May-2018')
        worm_filename = [strain_name '_2018-05-' experiment_date(1:2) '_Worm' num2str(worm_index) '.txt'];
    elseif strfind(experiment_date, 'May-2019')
        worm_filename = [strain_name '_2019-05-' experiment_date(1:2) '_Worm' num2str(worm_index) '.txt'];
    elseif strfind(experiment_date, 'Apr-2019')
        worm_filename = [strain_name '_2019-04-' experiment_date(1:2) '_Worm' num2str(worm_index) '.txt'];
    end
    
    
    tracing_filename = [strain_name '_' experiment_date '_'  num2str(worm_index) '.mat'];
    
    %
    disp('Loading lineage file...');
    worm = read_single_worm_lineage_data([worm_file_folder worm_filename]);
    
    div_times = get_3rd_division_times(worm);
    
    
    % Plotting parameters
    fs  = 26; % fontsize
    lw  = 2; % linewidth
    ms = 12; % marker size
    
                
    cell_colors = [[0 1 0];... % first_born_parent_color 
                    [0.8 0.8 0];...%second_born_parent_color
                    [0 0.5 0]; ... %first_born_beta_color
                    [0 0.7 0]; ... %first_born_alpha_color
                    [0.7 0.7 0];... %second_born_alpha_color
                    [0.5 0.5 0];];%second_born_beta_color
                
    if exist([tracing_foldername tracing_filename], 'file')
            disp('Fluorescence tracing file on external drive not found. Loading file from Dropbox folder.');
            load([tracing_foldername tracing_filename]); % loads variables background, cells
    else
        disp('Cannot locate tracing files. Did you choose the right experiment_name and worm_index?');
        disp('Try: ''plot_Z1Z4_traces(''27-Sep-2018'', 2);''');
        return;
        
    end
    
    
    % Deal with NaNs in background
    bg_intensity = background.intensity(1,:);
    bg_intensity(isnan(bg_intensity)) = 0; % If no defined background, set to zero

    fig_position = [0.2 0.2 0.35 0.5];
    fig = figure(14);
    set(fig, 'units', 'normalized', 'position', fig_position);
    clf;
        
    % Check first what's the maximum fluorescence intensity-> plot 
    % 
    max_intense = 0;
    for ii  = 1:length(cells)            
        tmp = cells(ii).nuc_intensity - bg_intensity;   
        if max(tmp(:))> max_intense
            max_intense = max(tmp(:));
        end
    end
    
    hold on;
    
    if ~isempty(div_times)
        % Change color scheme according to who's first-born
        if div_times.Z1pp > div_times.Z4aa % Z4.aaa first_born
            % 
            cell_colors = cell_colors([2,1,6,5,4,3],:);
        end
        % Plot the divisions of Z1.pp and Z4.aa
        plot([div_times.Z1pp, div_times.Z1pp], [0 1.2*max_intense], '--', 'Color', cell_colors(1,:), 'linewidth', 1.5*lw);
        plot([div_times.Z4aa, div_times.Z4aa], [0 1.2*max_intense], '--', 'Color', cell_colors(2,:), 'linewidth', 1.5*lw);
        
    end
    no_plotted_cells = 0;
    
    % This is to calculate the plot range below
    min_t_fluo = 9999;

    % Go through all the cells and plot
    for ii  = 1:length(cells)
        
        if ~(plot_alphacells_only && ((strcmpi(cells(ii).name, 'Z4.aap') || strcmpi(cells(ii).name, 'Z1.ppa'))))
        
            no_plotted_cells = no_plotted_cells + 1;
            
            if ii > 2 % means we are dealing with the alpha and beta cells
                marker = 'o-';
            else
                marker = 'd-';
            end

            nuc_intensity = cells(ii).nuc_intensity - bg_intensity;
            % extract the interval, in which values are scored
            t_fluo = (0:length(nuc_intensity))*imaging_interval/60;% in hours
            ind_min = find(~isnan(nuc_intensity)==1,1);
            ind_max = find(~isnan(nuc_intensity)==1,1,'last');
            %
            nuc_intensity = nuc_intensity(ind_min:ind_max);
            t_fluo = t_fluo(ind_min:ind_max);
            
            % 
            if(min_t_fluo) > min(t_fluo)
                min_t_fluo =  min(t_fluo);
            end

            if do_interpolation || do_filtering % in case of filtering, we have to interpolate anyways

                if imaging_interval == 16
                    t_fluo_interp = t_fluo(1):imaging_interval/60/2:t_fluo(end);%
                else
                    t_fluo_interp = t_fluo;%
                end

                t_OK = t_fluo(~isnan(nuc_intensity));
                nuc_intensity_OK = nuc_intensity(~isnan(nuc_intensity));
                nuc_intensity = interp1(t_OK,nuc_intensity_OK, t_fluo_interp, 'linear');
            end

            if do_filtering
                % extend the signal on both ends to avoid bounday effects
                tmp = [nuc_intensity(end:-1:1),nuc_intensity, nuc_intensity(end:-1:1)];
                %%% Gaussian Filter the signal
                [nuc_intensity_filt, ~] = filter_signal(tmp, 60/imaging_interval,filter_shape,filter_type, lp_cutoff);    
                % chop the extended ends off again
                nuc_intensity = nuc_intensity_filt(length(nuc_intensity)+1:2*length(nuc_intensity));        
            end

            if ~do_filtering && ~do_interpolation
                iind = find(~isnan(nuc_intensity));
                h(no_plotted_cells) = plot(t_fluo(iind),nuc_intensity(iind),marker, 'Color', 'k',...
                                            'MarkerFaceColor', cell_colors(ii,:), 'linewidth', lw, 'MarkerSize', ms);
            else
                h(no_plotted_cells) = plot(t_fluo_interp,nuc_intensity,marker, 'Color', 'k',...
                                            'MarkerFaceColor', cell_colors(ii,:), 'linewidth', lw, 'MarkerSize', ms);
            end
        end
    end
    
    
    xlabel('Time [h]');
    ylabel('Fluorescence [u.a.]');
    
    set(gca, 'fontsize', fs, 'linewidth', lw, 'tickdir', 'out');
    hold off;
    
    %%% Set plotting limits
    t_plot_span = 10; % plot 10h (starting from 10h prior to hlh-2 onset
    set(gca,'xlim', [min_t_fluo-2,min_t_fluo-2 + t_plot_span]);
    set(gca,'ylim', [-20 1.2*max_intense]);
    
    
    
    if plot_alphacells_only
        hl = legend(h([1,2,3,4]), 'Z1.pp', 'Z4.aa','Z1.ppp', 'Z4.aaa');
    else
        hl = legend(h([1,3,4,2,5,6]), 'Z1.pp','Z1.ppa', 'Z1.ppp', 'Z4.aa', 'Z4.aaa', 'Z4.aap');
    end

    if ~isempty(strfind(experiment_date, '10-Oct-2018_4')) && worm_index == 2
        set(hl, 'box', 'off', 'fontsize', 0.7*fs, 'position',[0.55 0.65  0.1 0.2] );
    elseif (~isempty(strfind(experiment_date, '10-Oct-2018_4')) && worm_index == 4)
        set(hl, 'box', 'off', 'fontsize', 0.7*fs, 'position',[0.65 0.65  0.1 0.2] );
    elseif (~isempty(strfind(experiment_date, '27-Sep-2018')) && worm_index == 9)
        set(hl, 'box', 'off', 'fontsize', 0.7*fs, 'position',[0.65 0.35  0.1 0.2] );
    elseif (~isempty(strfind(experiment_date, '27-Sep-2018')) && worm_index == 2)
        set(hl, 'box', 'off', 'fontsize', 0.7*fs, 'position',[0.65 0.65  0.1 0.2] );
    elseif (~isempty(strfind(experiment_date, '04-Oct-2018')) && worm_index == 1)
        set(hl, 'box', 'off', 'fontsize', 0.7*fs, 'position',[0.65 0.65  0.1 0.2] );
    elseif (~isempty(strfind(experiment_date, '30-May-2019')) && worm_index == 7)
        set(hl, 'box', 'off', 'fontsize', 0.7*fs, 'position',[0.65 0.65  0.1 0.2] );
    else
        set(hl, 'box', 'off', 'fontsize', 0.7*fs, 'position',[0.25 0.65  0.1 0.2] );
    end
    set(gcf,'color', 'w');
    ylim = get(gca,'ylim'); set(gca, 'ylim',[-5 ylim(2)]);
    
    if max(get(gca, 'ylim')) < 400
        set(gca,'ytick', [0 100 200 300]);
    else
        set(gca,'ytick', [0 200 400 600 800 1000]);
    end
    
end
