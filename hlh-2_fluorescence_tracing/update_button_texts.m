function S = update_button_texts(S,index)
% This function updates the button texts based on whether there is a ROI
% defined or not

    if nargin < 2
        index = 1:length(S.cells);
    end
    
    for ii = index

        if isnan(S.cells(ii).nuc_intensity(S.current_t+1))
            set(S.select_ROI_button(ii),'foregroundcolor', [0 0 1],  'string', ['Select ' S.cells(ii).name ' ROIs']);
        else
            set(S.select_ROI_button(ii),'foregroundcolor', [1 0 0],  'string', ['Delete ' S.cells(ii).name ' ROIs']);            
        end
        
    end

    if isnan(S.background.intensity(1,S.current_t+1))
        set(S.select_background_button(1),'foregroundcolor', [0 0 1],  'string', 'Select Left Background ROI');
    else
        set(S.select_background_button(1),'foregroundcolor', [1 0 0],  'string', 'Delete Left Background ROI');            
    end
    
    guidata(S.fh,S);

end