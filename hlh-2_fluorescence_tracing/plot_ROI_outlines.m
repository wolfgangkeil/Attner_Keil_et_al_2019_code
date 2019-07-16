function S = plot_ROI_outlines(S, cell_indices)
% This function is called by focal_plane_selector.m
%
% it overlays
    no_cells = length(S.cells);
    
    
    if nargin < 2
        cell_indices = 1:no_cells;
    end
    
    if ~isempty(S.CoChannel_line_handles)
        delete(S.CoChannel_line_handles);
        delete(S.CoChannel_text_handles);
        S.CoChannel_line_handles = [];
        S.CoChannel_text_handles = [];
    end
    if ~isempty(S.fluo_line_handles)
        delete(S.fluo_line_handles);
        delete(S.fluo_text_handles);
        S.fluo_line_handles = [];
        S.fluo_text_handles = [];
    end
    
    ind_t= S.current_t + 1;
    
    
    for ii = cell_indices    
        if ~isempty(S.cells(ii).nuc_intensity)
            if ~isnan(S.cells(ii).nuc_intensity(ind_t))

                % We are displaying the actual slice where the ROI was selected
                if S.cells(ii).ROI_slice(S.current_t+1) == S.current_z
                    hold on;
                    set(0, 'CurrentFigure',S.CoChannel_figure);

                    S.CoChannel_line_handles = [S.CoChannel_line_handles, ...
                        line(S.cells(ii).nuc_outline.x{S.current_t+1}, S.cells(ii).nuc_outline.y{S.current_t+1}, 'linewidth',2,'color', [1 1 1]),...
                        line(S.cells(ii).cyto_outline.x{S.current_t+1}, S.cells(ii).cyto_outline.y{S.current_t+1},'linestyle', '--', 'linewidth',2,'color', [1 1 1]),...
                        ];
                    hold off;

                    % get max x position, and max y position
                    x_max = max(max(S.cells(ii).nuc_outline.x{S.current_t+1}), max(S.cells(ii).nuc_outline.x{S.current_t+1}));
                    y_max = max(max(S.cells(ii).nuc_outline.y{S.current_t+1}), max(S.cells(ii).nuc_outline.y{S.current_t+1}));

                    S.CoChannel_text_handles = [S.CoChannel_text_handles text(x_max, y_max,S.cells(ii).name, 'color', [1 1 1],'fontsize',12)];

                    % 
                    set(0, 'CurrentFigure',S.fluo_figure);
                    hold on;
                    S.fluo_line_handles = [S.fluo_line_handles, ...
                        line(S.cells(ii).nuc_outline.x{S.current_t+1}, S.cells(ii).nuc_outline.y{S.current_t+1}, 'linewidth',2),...
                        line(S.cells(ii).cyto_outline.x{S.current_t+1}, S.cells(ii).cyto_outline.y{S.current_t+1}, 'linewidth',2),...
                        ];
                    hold off;
                    
                    S.fluo_text_handles = [S.fluo_text_handles text(x_max, y_max,S.cells(ii).name, 'color', [1,0,0],'fontsize',12)];


                elseif abs(S.cells(ii).ROI_slice(S.current_t+1) - S.current_z) < 3
                    % We are NOT displaying the actual slice where the ROI was selected, but plus minus 2 slices up or down
                    hold on;
                    set(0, 'CurrentFigure',S.CoChannel_figure);

                    S.CoChannel_line_handles = [S.CoChannel_line_handles, ...
                    line(S.cells(ii).nuc_outline.x{S.current_t+1}, S.cells(ii).nuc_outline.y{S.current_t+1},'linestyle', '-','linewidth',1,'color', [0.8 0.8 0.8]),...
                    line(S.cells(ii).cyto_outline.x{S.current_t+1}, S.cells(ii).cyto_outline.y{S.current_t+1},'linestyle', '--','linewidth',1,'color', [0.8 0.8 0.8])];
                    hold off;

                    % get max x position, and max y position
                    x_max = max(max(S.cells(ii).nuc_outline.x{S.current_t+1}), max(S.cells(ii).nuc_outline.x{S.current_t+1}));
                    y_max = max(max(S.cells(ii).nuc_outline.y{S.current_t+1}), max(S.cells(ii).nuc_outline.y{S.current_t+1}));

                    S.CoChannel_text_handles = [S.CoChannel_text_handles text(x_max, y_max,S.cells(ii).name, 'color', [0.8 0.8 0.8],'fontsize',12)];


                    set(0, 'CurrentFigure',S.fluo_figure);
                    hold on;
                    S.fluo_line_handles = [S.fluo_line_handles, ...
                        line(S.cells(ii).nuc_outline.x{S.current_t+1}, S.cells(ii).nuc_outline.y{S.current_t+1}, 'linewidth',1,'color',[0.5 0.5 0.5]),...
                        line(S.cells(ii).cyto_outline.x{S.current_t+1}, S.cells(ii).cyto_outline.y{S.current_t+1}, 'linewidth',1,'color',[0.5 0.5 0.5])];
                    hold off;

                    S.fluo_text_handles = [S.fluo_text_handles text(x_max, y_max,S.cells(ii).name, 'color', [0.5,0.5,0.5],'fontsize',12)];

                end
            end
        end
    end
    
    
    % Display the left background ROI
    if ~isnan(S.background.intensity(1,S.current_t+1))    
        line(S.background.outline.x{1, S.current_t+1} , S.background.outline.y{1, S.current_t+1}, 'linewidth',3,'color',[0.5 0.5 0.5]),...
    end
    % Display the let background ROI
    if ~isnan(S.background.intensity(2,S.current_t+1))
        line(S.background.outline.x{2, S.current_t+1} , S.background.outline.y{2, S.current_t+1}, 'linewidth',3,'color',[0.5 0.5 0.5]),...
    end
    
    

    guidata(S.fh);
end

