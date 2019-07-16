function statistics_hlh2_expression()
%
% DESCRIPTION: 
% This function plots onset statistics of hlh-2 expression vs. cell-cycle
% timing and relative birth order (Figure 3, Attner & Keil et al., 2019)
%
%
%
%
% by Wolfgang Keil, wolfgang.keil@curie.fr 2019
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % 
    close all;
    fs = 16;
    
    t_factor = 60; % set to 60 for plots in minutes 


    %%%%%%%%%%%%%%%%%%%%%% THIS READS SCORING FILE WITH PARENT BIRTH INCLUDED
    %%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%
    %%%% This checks if hlh-2 onset is always at roughly the same phase of cc
    %%%% of Z1.pp and Z4.aa
    filename = '~/Documents/GitHub/Attner_Keil_et_al_2019_code/hlh-2_fluorescence_tracing/data/GS9062_hlh2_cell_cycle_timing.xlsx';

    lower_ind = 59;
    upper_ind = 92;
    
    if exist(filename,'file')
        [~ ,sheets] = xlsfinfo(filename);
        % Read the data
        date = xlsread(filename, sheets{1}, ['A' num2str(lower_ind) ':A' num2str(upper_ind)]);
        dates_string = {};
        for ii = 1:length(date)
            dates_string{ii} = datestr(date(ii)+datenum('30-Dec-1899'));
        end   
        
        div_time_Z1p = xlsread(filename, sheets{1}, ['C' num2str(lower_ind) ':C' num2str(upper_ind)], 'basic');
        div_time_Z4a = xlsread(filename, sheets{1}, ['D' num2str(lower_ind) ':D' num2str(upper_ind)], 'basic');

        hlh2_onset_Z1pp = xlsread(filename, sheets{1}, ['E' num2str(lower_ind) ':E' num2str(upper_ind)], 'basic');
        hlh2_onset_Z4aa = xlsread(filename, sheets{1}, ['F' num2str(lower_ind) ':F' num2str(upper_ind)], 'basic');

        div_time_Z1pp = xlsread(filename, sheets{1}, ['G' num2str(lower_ind) ':G' num2str(upper_ind)], 'basic');
        div_time_Z4aa = xlsread(filename, sheets{1}, ['H' num2str(lower_ind) ':H' num2str(upper_ind)], 'basic');

        birth_timing = xlsread(filename, sheets{1}, ['J' num2str(lower_ind) ':J' num2str(upper_ind)]); % this reads the absolute time difference
       
        [~,first_born_cell]= xlsread(filename, sheets{1}, ['I' num2str(lower_ind) ':I' num2str(upper_ind)], 'basic');
        [~,first_born_fate] = xlsread(filename, sheets{1}, ['K' num2str(lower_ind) ':K' num2str(upper_ind)],'basic'); 

        %%% Calculate the other arrays
        
        first_born_cc_length = zeros(size(div_time_Z1pp));
        first_born_hlh2_onset = zeros(size(div_time_Z1pp));
        
        second_born_cc_length = zeros(size(div_time_Z1pp));
        second_born_hlh2_onset = zeros(size(div_time_Z1pp));        
        
        first_born_parent_hlh2_onset  = zeros(size(div_time_Z1pp)); % these arrays are there to check whether it makes a difference for a PARENT to be first-born
        second_born_parent_hlh2_onset = zeros(size(div_time_Z4aa)); % as to when it turns on hlh-2::GFP
        
        for ii = 1:length(first_born_fate)
            
            if ~isempty(strfind(first_born_cell{ii}, 'Z4.aaa'))
                first_born_cc_length(ii) = etime(datevec(div_time_Z4aa(ii)),datevec(div_time_Z4a(ii)))/t_factor; 
                first_born_hlh2_onset(ii) = etime(datevec(hlh2_onset_Z4aa(ii)),datevec(div_time_Z4a(ii)))/t_factor; 

                second_born_cc_length(ii) = etime(datevec(div_time_Z1pp(ii)),datevec(div_time_Z1p(ii)))/t_factor; 
                second_born_hlh2_onset(ii) = etime(datevec(hlh2_onset_Z1pp(ii)),datevec(div_time_Z1p(ii)))/t_factor;
            else
                first_born_cc_length(ii) = etime(datevec(div_time_Z1pp(ii)),datevec(div_time_Z1p(ii)))/t_factor; 
                first_born_hlh2_onset(ii) = etime(datevec(hlh2_onset_Z1pp(ii)),datevec(div_time_Z1p(ii)))/t_factor;

                second_born_cc_length(ii) = etime(datevec(div_time_Z4aa(ii)),datevec(div_time_Z4a(ii)))/t_factor; 
                second_born_hlh2_onset(ii) = etime(datevec(hlh2_onset_Z4aa(ii)),datevec(div_time_Z4a(ii)))/t_factor; 
            end
            
            if div_time_Z4a(ii) > div_time_Z1p(ii) %Z1.pp parent first-born
                first_born_parent_hlh2_onset(ii) = etime(datevec(hlh2_onset_Z1pp(ii)),datevec(div_time_Z1p(ii)))/t_factor;
                second_born_parent_hlh2_onset(ii) = etime(datevec(hlh2_onset_Z4aa(ii)),datevec(div_time_Z4a(ii)))/t_factor; 
            else
                first_born_parent_hlh2_onset(ii) = etime(datevec(hlh2_onset_Z4aa(ii)),datevec(div_time_Z4a(ii)))/t_factor; 
                second_born_parent_hlh2_onset(ii) = etime(datevec(hlh2_onset_Z1pp(ii)),datevec(div_time_Z1p(ii)))/t_factor;
                
            end
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % exclude all animals where we don't have birth of parents
        ind = ~isnan(div_time_Z1p) & ~isnan(div_time_Z4a); 

        first_born_cc_length = first_born_cc_length(ind);
        second_born_cc_length = second_born_cc_length(ind);
        
        first_born_fate = first_born_fate(ind);
        
        first_born_hlh2_onset = first_born_hlh2_onset(ind);
        second_born_hlh2_onset = second_born_hlh2_onset(ind);
        
        birth_timing = birth_timing(ind);
        
        %%%%%%%%%%%%%%%% THIS NOW PLOTS ALL BARS ON TOP OF EACH OTHER 
        sorting_array = (first_born_cc_length + second_born_cc_length)/2; % mean
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        figure(3);
        set(gcf, 'units', 'normalized', 'position', [0.1 0.1 0.35 0.9]);
        clf;
        
        plot_bars_w_timing(sorting_array,birth_timing,first_born_fate,first_born_cc_length,...
                second_born_cc_length, first_born_hlh2_onset,second_born_hlh2_onset);
    
        hold on;
        plot([0.5 length(first_born_fate)+1], [0 0], '--', 'Color', [0.5 0.5 0.5], 'Linewidth', 1);
        hold off;
        box off;
        set(gca, 'fontsize', 1.2*fs, 'tickdir', 'out', 'linewidth', 1.5);
        xlabel('Animal', 'Fontsize', 1.2*fs);
        %set(gca, 'xcolor',[1 1 1]);
        if t_factor == 60
            ylabel('Time [min]', 'Fontsize', 1.2*fs);
        else
            ylabel('Time [h]', 'Fontsize', 1.2*fs);
        end
        
        set(gca, 'ylim', [-0.5 6]*t_factor);
        set(gca, 'xlim', [0.5 length(birth_timing)+1]);
        set(gca, 'xtick', 0:5:length(first_born_fate));
        
        view([90 -90]);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        figure(4);
        clf;
        set(gcf, 'units', 'normalized', 'position', [0.1 0.1 0.25 0.9]);
        
        plot_bars_aligned(sorting_array,birth_timing, first_born_fate,first_born_cc_length,...
                second_born_cc_length, first_born_hlh2_onset,second_born_hlh2_onset);
    
        hold on;
        plot([0.5 length(first_born_fate)+1], [0 0], '--', 'Color', [0.5 0.5 0.5], 'Linewidth', 1);
        hold off;
        box off;
        set(gca, 'fontsize', 0.8*fs, 'tickdir', 'out');
        %xlabel('animal index');
        %set(gca, 'xcolor',[1 1 1]);
        if t_factor == 60
            ylabel('Time [min]', 'Fontsize', fs);
        else
            ylabel('Time [h]', 'Fontsize', fs);
        end
        
        xlabel('Animal', 'Fontsize', fs);
        set(gca, 'ylim', [0 4.85]*t_factor);
        set(gca, 'xtick', 0:5:length(first_born_fate));
        set(gca, 'xlim', [0.5 length(birth_timing)+1]);
        set(gca, 'linewidth', 1.5);
                
        view([90 -90]);

     end
end
     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h = plot_bars_w_timing(sorting_array,birth_timing, first_born_fate,first_born_cc_length,...
                second_born_cc_length, first_born_hlh2_onset,second_born_hlh2_onset)

% sorting array is the one that the animals will be sorted against, it will
% not be plotted

    % plotting parameters
    barwidth = 0.275;
    barspacing = 0;

    % do the sorting according to the sorting array
    [~,ind] = sort(sorting_array);
    %ind = 1:length(sorting_array);
    
    birth_timing = birth_timing(ind);
    
    first_born_fate = first_born_fate(ind);
    
    first_born_cc_length = first_born_cc_length(ind);
    second_born_cc_length = second_born_cc_length(ind);

    first_born_hlh2_onset = first_born_hlh2_onset(ind);
    second_born_hlh2_onset = second_born_hlh2_onset(ind);
    
    for ii = 1:length(sorting_array)
     
        % plot gray asterisk going against bias
        if strcmpi(first_born_fate(ii), 'AC')
            x = ii-0.8;
            y = first_born_cc_length(ii) + birth_timing(ii) + 10;
            text(x,y,'*', 'FontSize', 40, 'Color', [.3 .3 .3], 'FontWeight', 'bold');
        end
                
        % Plot cell cycle bar for first-born cell
        x = ((ii-barwidth)+barspacing + barwidth) + [0 barwidth barwidth 0];
        y = [0 0 first_born_cc_length(ii) first_born_cc_length(ii)];        
        
        h = patch(x,y,'r');
        h.FaceColor = [1 1 1];
        h.EdgeColor = [0 0 0];
        h.LineWidth = 1;
        
        % Plot hlh-2 "ON" for first-born cell
        x = ((ii-barwidth)+barspacing + barwidth) + [0 barwidth barwidth 0];
        y = [first_born_hlh2_onset(ii), first_born_hlh2_onset(ii), first_born_cc_length(ii),first_born_cc_length(ii)];        
        
        h = patch(x,y,'r');
        h.FaceColor = [0 1 0];
        h.EdgeColor = [0 0 0];
        h.LineWidth = 1;

        
        % Plot cell cycle bar for second-born cell
        x = (ii-barwidth)  + [0 barwidth barwidth 0];
        y = first_born_cc_length(ii) + birth_timing(ii) - [second_born_cc_length(ii) second_born_cc_length(ii) 0 0];        
        h = patch(x,y,'r');
        h.FaceColor = [1 1 1];
        h.EdgeColor = [0 0 0];
        h.LineWidth = 1;

        % Plot hlh-2 "ON" for second-born cell
        x = (ii-barwidth) + [0 barwidth barwidth 0];
        y = first_born_cc_length(ii) + birth_timing(ii) - second_born_cc_length(ii) + ...
            [second_born_hlh2_onset(ii) second_born_hlh2_onset(ii) second_born_cc_length(ii) second_born_cc_length(ii)];        
        
        h = patch(x,y,'r');
        if birth_timing(ii) == 0
            h.FaceColor = [0 1 0];
        else
            h.FaceColor = [0.8 0.8 0];
        end
        h.EdgeColor = [0 0 0];
        h.LineWidth = 1;
        
    end

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h = plot_bars_aligned(sorting_array,birth_timing,first_born_fate,first_born_cc_length,...
                second_born_cc_length, first_born_hlh2_onset,second_born_hlh2_onset)

% sorting array is the one that the animals will be sorted against, it will
% not be plotted

    % plotting parameters
    barwidth = 0.275;
    barspacing = 0;

    % do the sorting according to the sorting array
    [~,ind] = sort(sorting_array);
    %ind = 1:length(sorting_array);
    
    
    birth_timing = birth_timing(ind);
    
    first_born_fate = first_born_fate(ind);
    
    first_born_cc_length = first_born_cc_length(ind);
    second_born_cc_length = second_born_cc_length(ind);

    first_born_hlh2_onset = first_born_hlh2_onset(ind);
    second_born_hlh2_onset = second_born_hlh2_onset(ind);
    
    for ii = 1:length(sorting_array)
     
        % plot red bar going against bias
        if strcmpi(first_born_fate(ii), 'AC')
            x = ii-0.8;
            y = first_born_cc_length(ii) + birth_timing(ii) + 10;
            text(x,y,'*', 'FontSize', 40, 'Color', [.3 .3 .3], 'FontWeight', 'bold');
        end
        
        % Plot cell cycle bar for first-born cell
        x = ((ii-barwidth)+barspacing + barwidth) + [0 barwidth barwidth 0];
        y = [0 0 first_born_cc_length(ii) first_born_cc_length(ii)];        
        
        h = patch(x,y,'r');
        h.FaceColor = [1 1 1];
        h.EdgeColor = [0 0 0];
        h.LineWidth = 1;
        
        % Plot cell cycle bar for second-born cell
        x = (ii-barwidth) + [0 barwidth barwidth 0];
        y = [0 0 second_born_cc_length(ii) second_born_cc_length(ii)];        
        h = patch(x,y,'r');
        h.FaceColor = [1 1 1];
        h.EdgeColor = [0 0 0];
        h.LineWidth = 1;
        
        
        % Plot hlh-2 "ON" for first-born cell
        x = ((ii-barwidth)+barspacing + barwidth) + [0 barwidth barwidth 0];
        y = [first_born_hlh2_onset(ii), first_born_hlh2_onset(ii), first_born_cc_length(ii),first_born_cc_length(ii)];        
        
        h = patch(x,y,'r');
        h.FaceColor = [0 1 0];
        h.EdgeColor = [0 0 0];
        h.LineWidth = 1;

        % Plot hlh-2 "ON" for second-born cell
        x = (ii-barwidth) + [0 barwidth barwidth 0];
        y = [second_born_hlh2_onset(ii), second_born_hlh2_onset(ii), second_born_cc_length(ii),second_born_cc_length(ii)];        
        
        h = patch(x,y,'r');
        if birth_timing(ii) == 0
            h.FaceColor = [0 1 0];
        else
            h.FaceColor = [0.8 0.8 0];
        end
        h.EdgeColor = [0 0 0];
        h.LineWidth = 1;
        
    end

end