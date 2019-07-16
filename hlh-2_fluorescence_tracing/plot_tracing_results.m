
function plot_tracing_results(S,replot)

    % Default is to replot everything
    if nargin < 3
        replot = 1;
    end
    
    
    no_cells =  length(S.cells);
    
    
    
    if replot
        axes(S.axes(1));cla;
        axes(S.axes(2));cla;    
    end

    
    rand('seed',1234);
    
    % These variables are for determining the axes properties
    max_value = -Inf;
    max_ratio_value = -Inf;
    
    min_t = Inf;
    max_t = 0;
    
    bg_index  =1;
    
    for ii = 1:no_cells
        if sum(~isnan(S.cells(ii).nuc_intensity)) > 0 || sum(~isnan(S.cells(ii).cyto_intensity)) > 0 % checks if something has been traced
             
            % first plot the nuclear and cyto intensities in the same plot
            time_inds = find(~isnan(S.cells(ii).nuc_intensity));
            
            if ~isempty(time_inds)
                nuc_intensity = S.cells(ii).nuc_intensity(time_inds);
                cyto_intensity = S.cells(ii).cyto_intensity(time_inds);
                
                bg_intensity = S.background.intensity(bg_index,time_inds);
                bg_intensity(isnan(bg_intensity)) = 0; % If no defined background, set to zero
                
                % Substract the background
                nuc_intensity = nuc_intensity - bg_intensity;
                cyto_intensity = cyto_intensity - bg_intensity;
                
                % These assignments is just for plotting reasons...
                if max(max(nuc_intensity), max(cyto_intensity)) > max_value
                    max_value = max(nuc_intensity);
                end
                
                % These assignments is just for plotting reasons...
                if max(time_inds) > max_t
                    max_t = max(time_inds);
                end
                % This is just for plotting reasons...
                if min(time_inds) < min_t
                    min_t = min(time_inds);
                end



                if isfield(S.cells(ii),'color')
                    plot_color = S.cells(ii).color;
                else
                    plot_color = rand(1,3)*0.6;
                end

                % Plot foreground and background in same subplot
                axes(S.axes(1));
                hold on;
                if strfind(S.cells(ii).name, 'L.')
                    plot(time_inds-1,nuc_intensity,'-','Marker','o','Color', plot_color);
                elseif strfind(S.cells(ii).name, 'R.')
                   plot(time_inds-1,nuc_intensity,'--','Marker','x','Color', plot_color);
                else % means we are plotting muscle
                    plot(time_inds-1,nuc_intensity,'-.','Marker','d','Color', plot_color);
                end
                hold off;
                
                axes(S.axes(2));
                hold on;                
                if strfind(S.cells(ii).name, 'L.')
                    plot(time_inds-1,cyto_intensity,'-','Marker','o','Color', plot_color);
                elseif strfind(S.cells(ii).name, 'R.')
                    plot(time_inds-1,cyto_intensity,'--','Marker','x','Color', plot_color);
                else
                    plot(time_inds-1,nuc_intensity,'-.','Marker','d','Color', plot_color);                    
                end
                hold off;
    
            end                        
        end
    end
    
    %legend({S.cells(:).name})
    
    if ~isinf(min_t)
        if min_t < max_t
            set(S.axes(1), 'xlim', [min_t-2 max_t]);
            set(S.axes(2), 'xlim', [min_t-2 max_t]);
        else
            set(S.axes(1), 'xlim', [-1 max_t]);
            set(S.axes(2), 'xlim', [-1 max_t]);
        end
        set(S.axes(1),'ylim', [-100 1.1*max_value]);
        set(S.axes(2),'ylim', [-100 1.1*max_value]);
    else
        set(S.axes(1), 'xlim', [-1 1]);                
        set(S.axes(2), 'xlim', [-1 1]);                
        set(S.axes(1),'ylim', [0 1]);
        set(S.axes(2),'ylim', [0 1]);
    end
    
    S.axes(1).XLabel.String = 'frame';
    S.axes(2).XLabel.String = 'frame';

    S.axes(1).YLabel.String = 'nuclear intensity';
    S.axes(2).YLabel.String = 'cyto intensity';
    
%             
    
    guidata(S.fh,S);
    S = replot_current_t_line(S);
    
    
end

