function S = replot_current_t_line(S)

    if size(S.current_t_line > 0)
        if ishandle(S.current_t_line(1))
            delete(S.current_t_line(1));
        end
    end
    if size(S.current_t_line > 1)
        if ishandle(S.current_t_line(2))
            delete(S.current_t_line(2));
        end
    end
    S.current_t_line = [];
    
    % Plot foreground and background in same subplot
    axes(S.axes(1));
    hold on;
    S.current_t_line(1) = line([S.current_t S.current_t],get(gca, 'ylim'), 'color', [1 0 0]);
    hold off;

    % set limits properly so that current t-line can be seen in plot
    xlim = get(gca, 'xlim');
    if S.current_t < xlim(1)
        set(gca,'xlim', [(S.current_t-1) xlim(2)]);
    elseif S.current_t > xlim(2)
        set(gca,'xlim', [xlim(1) (S.current_t+1)]);
    end
    
    
    axes(S.axes(2));
    hold on;
    S.current_t_line(2) = line([S.current_t S.current_t],get(gca, 'ylim'), 'color', [1 0 0]);
    hold off;
    
    % set limits properly so that current t-line can be seen in plot
    xlim = get(gca, 'xlim');
    if S.current_t < xlim(1)
        set(gca,'xlim', [(S.current_t-1) xlim(2)]);
    elseif S.current_t > xlim(2)
        set(gca,'xlim', [xlim(1) (S.current_t+1)]);
    end

    
    guidata(S.fh,S);

end