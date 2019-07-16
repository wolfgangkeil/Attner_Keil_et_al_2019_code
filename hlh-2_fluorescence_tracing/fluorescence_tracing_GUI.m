function S = fluorescence_tracing_GUI(CoChannel, TracingChannel, SubCellular)
% 
% DESCRIPTION: This function opens a micro-manager 1.4 data set and lets
% the user draw ROI that outline nuclei of Z1.pp, and Z4.aa and their
% progeny in order to trace intensity of hlh-2 GFP fluorescence
% Start function with S = fluorescence_tracing_GUI('DsRed', 'GFP', {'nuc'});
% and open a micro-manager data set
%
% the GUI will save a .mat file containg all the fluorescence and
% background values into the micro-manager folder and into a folder within
% the local GitHub repository 
%
%
%
%
%
% INPUT PARAMETERS:
%
%   CoChannel ... name of the channel for ckb-3 labelling ('DsRed')
%   TracingChannel ... name of the channel for hlh-2 fluorescence ('GFP')
%
%
%  SubCellular is either {'nuc'}, {'cyto'}, {'nuc', 'cyto'}
%  this is a function that using either raw or deconvolved images for the fluo channel as input
%  
%   select an uncropped worm folder to start analyzing data!
%
%
%
% 
%
% EXAMPLE: S = fluorescence_tracing_GUI('DsRed', 'GFP', {'nuc'});
%
%
%
% All code written by Wolfgang Keil, Institut Curie 2019
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    warning('off', 'images:initSize:adjustingMag');
    

    % Create the window and main layout
    S.gui_name = 'Seam/muscle cell intensity selector'; % identifier of the gui, used in some shared functions
    
    S.fh = figure('NumberTitle', 'off', ...
        'position', [200 200 900 700],...
        'Toolbar', 'none',...
        'Menubar', 'none', ...
        'resize', 'off',...
        'CloseRequestFcn', @nCloseAll);
    
    % 
    set(S.fh,'WindowKeyPressFcn',@(src,evt)key_pressed_over_window_callback(S.fh, evt,S.fh));
  
    %%% Ties S and the GUI together
    guidata(S.fh,S);
    %%% 
    
    %------------------ ACTUAL GUI DEFINITION ---------------------------     
    S.mainbox = uiextras.VBox('Parent', S.fh, 'padding',5);

    
    S.CoChannel_figure  = [];
    S.CoChannel_line_handles = []; 
    S.CoChannel_text_handles = []; 
    
    S.fluo_figure = [];
    S.fluo_line_handles = [];    
    S.fluo_text_handles = [];    
    
    S.current_t_line = [];

    S.CoChannel_axis  = [];
    S.current_t = 0;
    S.current_z = 0;
    
    
    % These should can updated in the GUI later
    S.data_min = 0;
    S.data_max = 1000;
    
    S.fluo_data_min = 100;
    S.fluo_data_max = 600;
    
        
    set(S.fh, 'Name', ['Fluo Intensity Selector v0.2 (2018)']);
 
    
    % Change this, if you want other cells to be tracked at different
    cell_names = {'Z1.pp', 'Z4.aa', 'Z1.ppa', 'Z1.ppp', 'Z4.aaa', 'Z4.aap'};
        
    S.cell_colors = [   0.9296    0.1048    0.8348; ...
                        0.1864    0.1974    0.9281; ...
                        0.9296    0.1048    0.748; ...
                        0.9296    0.2048    0.848; ...
                        0.2864    0.1974    0.9281; ...
                        0.1864    0.2974    0.9281   ];
    
                    
   %%%% This is were fluo-tracing .mat-files will be saved 
    
    S.harddrive_path = '~/Documents/GitHub/Attner_Keil_et_al_2019_code/hlh-2_fluorescence_tracing/data/fluo_tracing/';
    
    
    % Will be filled using the data path later
    S.fluo_tracing_file = [];
    
    % initialize S.cells structure
    for ii  = 1:length(cell_names)        
        S.cells(ii) = struct('name', cell_names{ii},...
            'cyto_intensity',[], ...
            'nuc_intensity', [],...
            'color', S.cell_colors(ii,:),...
            'ROI_slice',[],...
            'nuc_outline',struct('x',[], 'y',[] ),...
            'cyto_outline',struct('x',[], 'y', []));
    end
    
    
    
    %%% These are the variables for the fluorescence channels
    S.CoChannel = CoChannel;
    S.TracingChannel = TracingChannel;
    S.SubCellular = SubCellular;
    S.current_fluo_img = [];           
    S.use_decon = 'no';
    
    %
    guidata(S.fh,S);

    
    % Define the buttons 
    % 1. open folder button
    S.open_folder_button = uicontrol( 'Parent', S.mainbox,...
        'style', 'pushbutton',...
        'string', 'Open Data set',...
        'TooltipString', sprintf('This loads the first image of the data set into the figure'));
    % Set the callbacks for immo buttons
    set(S.open_folder_button, 'callback',...
            @open_folder_button_callback);
        
    
    S.axesbox = uiextras.HBox( 'Parent', S.mainbox);
     
    %%% Define the two axes
    S.axes_boxes(1) = uipanel('Parent', S.axesbox);
    S.axes_boxes(2) = uipanel('Parent', S.axesbox);
    
    S.axes(1) = axes('Parent',S.axes_boxes(1));
    S.axes(2) = axes('Parent',S.axes_boxes(2));

    
    %%%% this is where the climit controls are set
    S.climit_box =  uiextras.HBox('Parent', S.mainbox);
    
    CoChannel_min_box = uiextras.VBox('Parent',S.climit_box);
    CoChannel_max_box = uiextras.VBox('Parent',S.climit_box);
    fluo_min_box = uiextras.VBox('Parent',S.climit_box);
    fluo_max_box = uiextras.VBox('Parent',S.climit_box);
        
    % set CoChannel minimum 
    uicontrol('Parent',CoChannel_min_box, 'style', 'text','string', 'CoChannel min');
    S.CoChannel_min_edit = uicontrol('Parent',CoChannel_min_box,...
        'style', 'edit',...
        'string', num2str(S.data_min),...
        'enable', 'off',...
        'callback',@set_climits_callback);
    
    % set CoChannel maximum 
    uicontrol('Parent',CoChannel_max_box, 'style', 'text','string', 'CoChannel max');
    S.CoChannel_max_edit = uicontrol('Parent',CoChannel_max_box,...
        'style', 'edit',...
        'string', num2str(S.data_max),...
        'enable', 'off',...
        'callback',@set_climits_callback);

    
    % set fluo minimum 
    uicontrol('Parent',fluo_min_box, 'style', 'text','string', [S.TracingChannel ' min']);
    S.fluo_min_edit = uicontrol('Parent',fluo_min_box,...
        'style', 'edit',...
        'string', num2str(S.fluo_data_min),...
        'enable', 'off',...
        'callback',@set_climits_callback);

    % set fluo maximum 
    uicontrol('Parent',fluo_max_box, 'style', 'text','string', [S.TracingChannel ' max'] );
    S.fluo_max_edit = uicontrol('Parent',fluo_max_box,...
        'style', 'edit',...
        'string', num2str(S.fluo_data_max),...
        'enable', 'off',...
        'callback',@set_climits_callback);
    
    
    %%%%%%%%% This is were the z slice controls are set
    z_slices_movement_box =  uiextras.HBox('Parent', S.mainbox);
   

    % 2.  previous z-slice
    S.previous_z_slice_button = uicontrol( 'Parent', z_slices_movement_box,...
        'style', 'pushbutton',...
        'string', '<',...
        'enable', 'off',...
        'TooltipString', sprintf('This loads the previous z-slice into the figure'),...
        'callback', @previous_z_slice_button_callback);
            
    % 3. next z_slices button
    S.next_z_slice_button = uicontrol( 'Parent', z_slices_movement_box,...
        'style', 'pushbutton',...
        'string', '>',...
        'enable', 'off',...
        'TooltipString', sprintf('This loads the next z-slice into the figure'),...
        'callback', @next_z_slice_button_callback);
        
    tmp  = uiextras.VBox( 'Parent', z_slices_movement_box);
    uicontrol('Parent',tmp, 'style', 'text','string', 'Current slice:');
    
    S.goto_slice_edit = uicontrol('Parent',tmp,...
        'style', 'edit',...
        'string', '0',...
        'enable', 'off',...
        'callback',@goto_slice_callback);
    
    
    t_frames_movement_box =  uiextras.HBox('Parent', S.mainbox);
    
    
    % 4.  previous frame
    S.previous_t_frame_button = uicontrol( 'Parent', t_frames_movement_box,...
        'style', 'pushbutton',...
        'string', '<<',...
        'enable', 'off',...
        'TooltipString', sprintf('This loads the previous time frame into the figure'),...
        'callback', @previous_t_frame_button_callback);
            
    % 5. next frame
    S.next_t_frame_button = uicontrol( 'Parent', t_frames_movement_box,...
        'style', 'pushbutton',...
        'string', '>>',...
        'enable', 'off',...
        'TooltipString', sprintf('This loads the next time frame into the figure'),...
        'callback', @next_t_frame_button_callback);    
    
    tmp  = uiextras.VBox( 'Parent', t_frames_movement_box);
    uicontrol('Parent',tmp, 'style', 'text','string', 'Current frame:');
    
    S.goto_frame_edit = uicontrol('Parent',tmp,...
        'style', 'edit',...
        'string', '0',...
        'enable', 'off',...
        'callback',@goto_frame_callback);
    
    no_of_button_rows = ceil(length(S.cells)/4);

    for jj = 1:no_of_button_rows
        tmp(jj) = uiextras.HBox('Parent', S.mainbox);
    end
    
    tmp(jj+1) = uiextras.HBox('Parent', S.mainbox); % This is for the background button, always gets an extra row

    for ii = 1:2;

        % 7. Select focal plane button 
        S.select_ROI_button(ii) = uicontrol( 'Parent', tmp(1),...
            'style', 'pushbutton',...
            'string', ['Select ' S.cells(ii).name ' ROIs'],...
            'enable', 'off',...
            'TooltipString', sprintf('This enables the roipoly tool.\n Will save the selected ROI to the disk.'));
        set(S.select_ROI_button(ii),'callback', @(srv,evt)select_ROI_button_callback(S.select_ROI_button(ii), evt,S.fh, ii));
    
    end
    
    
    for ii = 3:length(S.cells)

        % 7. Select focal plane button 
        S.select_ROI_button(ii) = uicontrol( 'Parent', tmp(2),...
            'style', 'pushbutton',...
            'string', ['Select ' S.cells(ii).name ' ROIs'],...
            'enable', 'off',...
            'TooltipString', sprintf('This enables the roipoly tool.\n Will save the selected ROI to the disk.'));
        set(S.select_ROI_button(ii),'callback', @(srv,evt)select_ROI_button_callback(S.select_ROI_button(ii), evt,S.fh, ii));
            
    end

    row_index = 2;

    % 7. Select background button 
    S.select_background_button(1) = uicontrol( 'Parent', tmp(row_index+1),...
        'style', 'pushbutton',...
        'string', 'Select Background ROI (within gonad)',...
        'enable', 'off',...
        'TooltipString', sprintf('This enables the roipoly tool.\n Will save the selected ROI to the disk.'));
    set(S.select_background_button(1),'callback', @(srv,evt)select_background_button_callback(S.select_background_button(1), evt,S.fh, 1));    
    
    
    guidata(S.fh,S);
    set(S.mainbox, 'sizes', [-1 -10 -1 -1 -1 repmat(-1,[1 (no_of_button_rows+1)])]);

end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Callbacks for the buttons
function open_folder_button_callback(varargin)

    S  = guidata(varargin{1});

    folder_name = uigetdir('/Users/wolfgang/','This opens first stitched tif-file of stack');
    if ~isequal(folder_name,0)

        %%% this a then a plain MM dataset
        S.data_path = [folder_name '/Pos0/'];
        [S.no_slices, S.no_timestamps] = get_data_set_dimensions(S.data_path);          
        
        %%% initalize fluorescence traces for the cells with NaN
        for ii = 1:length(S.cells)
            S.cells(ii).nuc_intensity = NaN*zeros(1,S.no_timestamps);
            S.cells(ii).cyto_intensity = NaN*zeros(1,S.no_timestamps);
            S.cells(ii).color = S.cell_colors(ii,:);
            S.cells(ii).ROI_slice = NaN*zeros(1,S.no_timestamps);            
        end
        
        %%% 
        S.background.intensity = NaN*zeros(2,S.no_timestamps);
        S.background.slice = NaN*zeros(2,S.no_timestamps);
        S.background.outline.x = [];
        S.background.outline.y = [];
        
        tmp = strfind(S.data_path,'/');
        strain_name = S.data_path(tmp(end-4)+1:tmp(end-3)-1);
        exp_name = S.data_path(tmp(end-3)+1:tmp(end-2)-1);

        worm_name = S.data_path(tmp(end-2)+1:tmp(end-1)-1);
        if length(strfind(worm_name,'_')) >1
            tmp2 = strfind(worm_name,'_');
            worm_name = worm_name(1:tmp2(end)-1);
        end
        tmp2 = strfind(worm_name,'_');
        worm_number = worm_name(tmp2(end)+1:end);

        % create a folder on the harddrive, if we haven't encounted that
        % strain yet
        if ~exist([S.harddrive_path '/' strain_name ], 'dir')
            mkdir([S.harddrive_path '/' strain_name ]);
        end
        
        S.fluo_tracing_file = [S.data_path 'fluo_tracing_' strain_name '_' exp_name  '_' worm_name  '.mat'];
        S.fluo_tracing_file_harddrive = [S.harddrive_path strain_name '/' strain_name '_' exp_name  '_' worm_number '.mat'];

        %%% Check whether there is a tracing file either on the external
        %%% disk or the Mac harddrive
        saved_tracing = [];
        if exist(S.fluo_tracing_file, 'file')
            disp('Loading tracing file from external disk...')
            saved_tracing = load(S.fluo_tracing_file);
            disp('...done');
        elseif exist(S.fluo_tracing_file_harddrive, 'file')
            disp('No tracing file on the external disk found.')
            disp('Loading tracing file from Mac harddrive...')
            saved_tracing = load(S.fluo_tracing_file_harddrive);
            disp('...done');
        else
            disp('No tracing file found.')
        end
        
        %%% 
        if ~isempty(saved_tracing)
            for ii = 1:length(saved_tracing.cells)
                
                ind = find(ismember({S.cells(:).name},saved_tracing.cells(ii).name));
                if ~isempty(ind)
                    if length(ind) > 1
                        error(['Somehow, two cells ' saved_tracing.cells(ii).name ' have the same name in the tracing file to be loaded...']);
                    else                
                        if isfield(saved_tracing.cells(ii),'nuc_intensity')
                            S.cells(ind).nuc_intensity = saved_tracing.cells(ii).nuc_intensity;
                        end
                        if isfield(saved_tracing.cells(ii),'cyto_intensity')
                            S.cells(ind).cyto_intensity = saved_tracing.cells(ii).cyto_intensity;
                        end
                        if isfield(saved_tracing.cells(ii),'ROI_slice')
                            S.cells(ind).ROI_slice = saved_tracing.cells(ii).ROI_slice;
                        end
                        if isfield(saved_tracing.cells(ii),'nuc_outline')
                            S.cells(ind).nuc_outline = saved_tracing.cells(ii).nuc_outline;
                        end
                        if isfield(saved_tracing.cells(ii),'cyto_outline')
                            S.cells(ind).cyto_outline = saved_tracing.cells(ii).cyto_outline;
                        end
                    end
                end
            end   
            
            % Assign the background tracings
            if isfield(saved_tracing,'background')
                S.background.intensity = saved_tracing.background.intensity;
                S.background.slice = saved_tracing.background.slice;
                S.background.outline = saved_tracing.background.outline;
            else
                S.background.intensity = NaN*zeros(2,S.no_timestamps);
                S.background.slice = NaN*zeros(2,S.no_timestamps);
            end
            
                
            % open the figures to see what we've already traced
            plot_tracing_results(S,1);
            guidata(S.fh,S);
        
        end
        
        guidata(S.fh,S);
        % this loads the first slice
        S = load_slice(S, S.current_t, S.current_z, S.TracingChannel);
        guidata(S.fh,S);
        
        %update edit fields
        set(S.goto_slice_edit, 'string', num2str(S.current_z));
        set(S.goto_frame_edit, 'string', num2str(S.current_t));
        
        
        % Enable, disable buttons and fields        
        set(S.open_folder_button, 'enable', 'off');
        
        set(S.CoChannel_min_edit, 'enable', 'on');
        set(S.CoChannel_max_edit, 'enable', 'on');
        set(S.fluo_min_edit, 'enable', 'on');
        set(S.fluo_max_edit, 'enable', 'on');
        
        if S.no_slices > 1
            set(S.next_z_slice_button, 'enable', 'on');
            set(S.goto_slice_edit, 'enable', 'on');
        end
        if S.no_timestamps> 1
            set(S.next_t_frame_button, 'enable', 'on');
            set(S.goto_frame_edit, 'enable', 'on');
        end
        
        set(S.select_ROI_button(:),'enable', 'on');
        set(S.select_background_button(:),'enable', 'on');
        
        
        % Change number of the figure
        current_title = get(S.fh, 'Name');
        set(S.fh, 'Name', [current_title ' | ' exp_name ' | ' strain_name ' | worm ' worm_number]);
 
    end
    
    
    guidata(S.fh,S);
     

end


%%% Callback for settings climits
function set_climits_callback(varargin)

    hObject = varargin{1};
    S  = guidata(hObject);
    

    if hObject == S.CoChannel_min_edit
        new_lim = checkstring(hObject,[0, S.data_max]); % Check if larger than zero and smaller than S.data_max
        S.data_min = new_lim;
        
        % Update the figure
        set(0, 'CurrentFigure',S.CoChannel_figure);
        tmp_ax = findobj(gcf,'type','axes');
        clim = get(tmp_ax,'clim');        
        set(tmp_ax, 'clim', [S.data_min clim(2)]);
        
    elseif hObject == S.CoChannel_max_edit
        new_lim = checkstring(hObject,[S.data_min, inf]); % Check if larger than zero
        S.data_max = new_lim;
        
        % Update the figure
        set(0, 'CurrentFigure',S.CoChannel_figure);
        tmp_ax = findobj(gcf,'type','axes');
        clim = get(tmp_ax,'clim');        
        set(tmp_ax, 'clim', [clim(1) S.data_max]);
    elseif hObject == S.fluo_min_edit
        new_lim = checkstring(hObject,[0, S.fluo_data_max]); % Check if larger than zero and smaller than S.data_max
        S.fluo_data_min = new_lim;

        % Update the figure
        set(0, 'CurrentFigure',S.fluo_figure);
        tmp_ax = findobj(gcf,'type','axes');
        clim = get(tmp_ax,'clim');        
        set(tmp_ax, 'clim', [S.fluo_data_min clim(2)]);
    elseif hObject == S.fluo_max_edit
        new_lim = checkstring(hObject,[S.fluo_data_min, inf]); % Check if larger than zero and larger than S.data_min
        S.fluo_data_max = new_lim;

        % Update the figure
        set(0, 'CurrentFigure',S.fluo_figure);
        tmp_ax = findobj(gcf,'type','axes');   
        clim = get(tmp_ax,'clim');
        set(tmp_ax, 'clim', [clim(1) S.fluo_data_max]);
    end
    % Update S 
    guidata(S.fh,S);
end

%%%
%%% Callbacks for the buttons
function next_z_slice_button_callback(varargin)
    S  = guidata(varargin{1});
    
    if S.current_z + 1  < S.no_slices
        S.current_z = S.current_z + 1;
        guidata(S.fh,S);
        S = load_slice(S,S.current_t,S.current_z,S.TracingChannel);

        if (S.current_z+1) == S.no_slices
            % Disable next z-slice button
            set(S.next_z_slice_button,'enable','off');
        end

        % re-activate previous slice buttons
        if strcmpi(get(S.previous_z_slice_button,'enable'),'off')
            set(S.previous_z_slice_button,'enable','on')
        end

        set(S.goto_slice_edit, 'string',num2str(S.current_z));

        guidata(S.fh,S);
        
        
        % Refocus on tracing window        
        set(0,'CurrentFigure', S.fluo_figure);
        
        
        
        
    end
end

%%%
%%% Callbacks for the buttons
function previous_z_slice_button_callback(varargin)
    S  = guidata(varargin{1});
    
    if S.current_z - 1 >= 0
        S.current_z = S.current_z - 1;
        guidata(S.fh,S);
        S = load_slice(S,S.current_t,S.current_z, S.TracingChannel);

        if (S.current_z) == 0
            % Disable previous z-slice button
            set(S.previous_z_slice_button,'enable','off');
        end


        % re-activate next slice buttons if disabled
        if strcmpi(get(S.next_z_slice_button,'enable'),'off')
            set(S.next_z_slice_button,'enable','on')
        end

        set(S.goto_slice_edit, 'string',num2str(S.current_z));


        guidata(S.fh,S);
    end

end

function goto_slice_callback(varargin)

    S  = guidata(varargin{1});
    new_slice = checkstring(varargin{1},[0 S.no_slices-1],1);
    
    if new_slice >=0 && new_slice < S.no_slices
        S.current_z = new_slice;  
        guidata(S.fh,S);

        S = load_slice(S,S.current_t,new_slice, S.TracingChannel);

        if (S.current_z) == 0
            % Disable previous z-slice button
            set(S.previous_z_slice_button  ,'enable','off');
        else
            set(S.previous_z_slice_button  ,'enable','on');

        end

        if (S.current_z+1) == S.no_slices
            % Disable next z-slice button
            set(S.next_z_slice_button,'enable','off');
        else
            set(S.next_z_slice_button,'enable','on');

        end

        plot_tracing_results(S,1) ;


        guidata(S.fh,S);
    end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function goto_frame_callback(varargin)
    S  = guidata(varargin{1});
    new_t = checkstring(varargin{1},[0 S.no_timestamps-1],1);
    S.current_t = new_t;    
    % Update S structure
    guidata(S.fh,S);
       
    S = load_slice(S,new_t,S.current_z, S.TracingChannel);
    
    if (S.current_t) == 0
        % Disable previous z-slice button
        set(S.previous_t_frame_button  ,'enable','off');
    else
        set(S.previous_t_frame_button  ,'enable','on');
    end
    
    if (S.current_t+1) == S.no_timestamps
        % Disable next z-slice button
        set(S.next_t_frame_button ,'enable','off');
    else
        set(S.next_t_frame_button  ,'enable','on');        
    end
   
    plot_tracing_results(S,1);


    guidata(S.fh,S);
end


%%% Callbacks for the buttons
function next_t_frame_button_callback(varargin)
    S  = guidata(varargin{1});
    
    S.current_t = S.current_t + 1;
    guidata(S.fh,S);
    S = load_slice(S,S.current_t,S.current_z, S.TracingChannel);

    if (S.current_t+1) == S.no_timestamps
        % Disable next z-slice button
        set(S.next_t_frame_button,'enable','off');
    end
   
    % re-activate previous slice buttons
    if strcmpi(get(S.previous_t_frame_button,'enable'),'off')
        set(S.previous_t_frame_button,'enable','on')
    end
    set(S.goto_frame_edit, 'string',num2str(S.current_t));
    

    % Refocus on tracing window        
    set(0,'CurrentFigure', S.fluo_figure);
        
    guidata(S.fh,S);
    
    
end
%%% Callback for the previous_t_frame buttons
function previous_t_frame_button_callback(varargin)
    S  = guidata(varargin{1});
    
    S.current_t = S.current_t - 1;
    guidata(S.fh,S);
    load_slice(S,S.current_t,S.current_z, S.TracingChannel);
    
    if (S.current_t) == 0
        % Disable previous z-slice button
        set(S.previous_t_frame_button,'enable','off');
    end
    
    % re-activate next slice buttons if disabled
    if strcmpi(get(S.next_t_frame_button,'enable'),'off')
        set(S.next_t_frame_button,'enable','on')
    end
   
    set(S.goto_frame_edit, 'string',num2str(S.current_t));
    
    % Refocus on tracing window        
    set(0,'CurrentFigure', S.fluo_figure);
        
    guidata(S.fh,S);
end

%
%
function select_ROI_button_callback(varargin)
%
%
%
    S = guidata(varargin{3});
    index = varargin{4}; % index of the button that was pressed
    
    % Re-enable GUI
    S = enable_disable_GUI_buttons(S, 'off');
    
    
    % Check what we want to trace
    if sum(ismember(S.SubCellular,'nuc')) > 0
        select_nuc = 1;
    else
        select_nuc = 0;
    end

    if sum(ismember(S.SubCellular,'cyto')) > 0
        select_cyto = 1;
    else
        select_cyto = 0;
    end     
   
    
    
    if ((isnan(S.cells(index).nuc_intensity(S.current_t+1)) && select_nuc) || (isnan(S.cells(index).cyto_intensity(S.current_t+1)) && select_cyto))
        % this is true, if no ROIs have been selected previously

        % Replot the ROI outlines, without the one we want to draw
        tmp=  1:length(S.cells);    
        S = plot_ROI_outlines(S, tmp(tmp~=index));
        guidata(S.fh,S);

        [Y, X] = meshgrid(1:size(S.current_fluo_img,2), 1:size(S.current_fluo_img,1));
                
        if ~isempty(S.fluo_figure)
            
            % Make the ROI either on the fluo or the CoChannel channel
            set(0, 'CurrentFigure',S.fluo_figure);        
                
            
            if select_nuc
                title('Select outline of nucleus');
                hFH_nucleus = imfreehand();

                if ~isempty(hFH_nucleus) % in which case the user actually selected a ROI

                    BW = hFH_nucleus.createMask();
                    delete(hFH_nucleus);
                    % immediately delete the handle to the freehand drawing
                    % to not mess up the figure
                    % Get bondaries of free hand region
                    structBoundaries_nucleus = bwboundaries(BW);

                    if ~isempty(structBoundaries_nucleus) % this is empty, if the user actually only clicked once and didn't draw a region

                        xy=structBoundaries_nucleus{1}; % Get n by 2 array of x,y coordinates.
                        x_nucleus = xy(:, 2); % Columns.
                        y_nucleus = xy(:, 1); % Rows.    

                        %[x_nucleus, y_nucleus] = poly2cw(x_nucleus, y_nucleus);
                        
                        S.cells(index).nuc_outline.x{S.current_t+1} = x_nucleus;                   
                        S.cells(index).nuc_outline.y{S.current_t+1} = y_nucleus;                   
                        
                        in_nucleus = inpolygon(X(:),Y(:),y_nucleus,x_nucleus);
                        S.cells(index).nuc_intensity(S.current_t+1) = mean(S.current_fluo_img(in_nucleus));
                        disp(['The mean intensity inside the nucleus is ' num2str(S.cells(index).nuc_intensity(S.current_t+1))]);
                        
                        S.cells(index).ROI_slice(S.current_t+1) = S.current_z;
                        
                    end
                else
                    
                    S.cells(index).nuc_outline.x{S.current_t+1} = [];                   
                    S.cells(index).nuc_outline.y{S.current_t+1} = [];                   
                    S.cells(index).nuc_intensity(S.current_t+1) = NaN;
                    
                    % Re-enable GUI
                    S = enable_disable_GUI_buttons(S, 'on');
                    title('');
                    guidata(S.fh, S);
                    return;
                    
                end
            else
                S.cells(index).nuc_outline.x{S.current_t+1} = [];                   
                S.cells(index).nuc_outline.y{S.current_t+1} = [];                   
                S.cells(index).nuc_intensity(S.current_t+1) = NaN;
            end
            
            
            
            if select_cyto
                title('Select outline of cytoplasm');
                hFH_cyto = imfreehand();

                if ~isempty(hFH_cyto) % in which case the user actually selected a ROI

                    BW = hFH_cyto.createMask();
                    % immediately delete the handle to the freehand drawing
                    % to not mess up the figure
                    delete(hFH_cyto);
                    % Get bondaries of free hand region
                    structBoundaries_cyto = bwboundaries(BW);

                    if ~isempty(structBoundaries_cyto) % this is empty, if the user actually only clicked once and didn't draw a region
                        xy=structBoundaries_cyto{1}; % Get n by 2 array of x,y coordinates.
                        x_cyto = xy(:, 2); % Columns.
                        y_cyto = xy(:, 1); % Rows.    
                        
                        %[x_cyto, y_cyto] = poly2cw(x_cyto, y_cyto);
                        S.cells(index).cyto_outline.x{S.current_t+1} = x_cyto;                   
                        S.cells(index).cyto_outline.y{S.current_t+1} = y_cyto;                   
 
                        S.cells(index).ROI_slice(S.current_t+1) = S.current_z;

                        in_cyto = inpolygon(X(:),Y(:),y_cyto,x_cyto);

                        % this determines all pixels that are in the convex hull
                        if ~isempty(find(contains(C,'nuc'), 1)) % means we also selected the nucleus outline
    
                            tmp = zeros(size(S.current_fluo_img));
                            tmp1 = zeros(size(S.current_fluo_img));
                            tmp(in_cyto) = 1;
                            tmp1(in_nucleus) = 1;

                            in_cyto = ((tmp + tmp1) == 1); % overwrite in cyto by subtracting the nucleus
                        end


                        % Get mean fluorescence inside the region selected      
                        S.cells(index).cyto_intensity(S.current_t+1) = mean(S.current_fluo_img(in_cyto));

                        disp(['The mean intensity inside the cytoplasm is ' num2str(S.cells(index).cyto_intensity(S.current_t+1))]);
                        
                    else
                        % if we also select nucleus, then we need to delete
                        % it here
                        if select_nuc
                            S.cells(index).nuc_outline.x{S.current_t+1} = [];                   
                            S.cells(index).nuc_outline.y{S.current_t+1} = [];                   
                            S.cells(index).nuc_intensity(S.current_t+1) = NaN;
                            
                            S.cells(index).ROI_slice(S.current_t+1) = NaN;
                            
                            S = enable_disable_GUI_buttons(S, 'on');
                            title('');
                            guidata(S.fh, S);
                            return;
                            
                            
                        end
                                                
                        % Re-enable GUI
                        S = enable_disable_GUI_buttons(S, 'on');
                        title('');
                        guidata(S.fh, S);
                        return;
                    end
                else
                    % if we also selected the nucleus, then we need to delete
                    % it here
                    if select_nuc
                        S.cells(index).nuc_outline.x{S.current_t+1} = [];                   
                        S.cells(index).nuc_outline.y{S.current_t+1} = [];                   
                        S.cells(index).nuc_intensity(S.current_t+1) = NaN;
                        
                        S.cells(index).cyto_outline.x{S.current_t+1} = [];                   
                        S.cells(index).cyto_outline.y{S.current_t+1} = [];                   
                        S.cells(index).cyto_intensity(S.current_t+1) = NaN;

                        S.cells(index).ROI_slice(S.current_t+1) = NaN;

                    end
                    % Re-enable GUI
                    S = enable_disable_GUI_buttons(S, 'on');
                    title('');
                    guidata(S.fh, S);
                    return;
                end
            else
                S.cells(index).cyto_outline.x{S.current_t+1} = [];                   
                S.cells(index).cyto_outline.y{S.current_t+1} = [];                   
                S.cells(index).cyto_intensity(S.current_t+1) = NaN;
                            
            end

            % Save updated cells structure
            cells = S.cells;        
            background = S.background;        
            save(S.fluo_tracing_file, 'cells', 'background');
            save(S.fluo_tracing_file_harddrive, 'cells', 'background');

            % Plot the tracing results 
            S = plot_ROI_outlines(S,index);

            % update the plot in the results
            guidata(S.fh,S); % update S after plotting
            plot_tracing_results(S, 1);      
                            
        end        
        
    %%% There already is a ROI defined and we want to delete it   
    else
        % Delete everything that is known about this ROI       
        S.cells(index).nuc_intensity(S.current_t+1) = NaN;

        S.cells(index).ROI_slice(S.current_t+1) = NaN;

        S.cells(index).nuc_outline.x{S.current_t+1} = [];
        S.cells(index).nuc_outline.y{S.current_t+1} = [];

        S.cells(index).cyto_outline.x{S.current_t+1} = [];
        S.cells(index).cyto_outline.y{S.current_t+1} = [];
        
        guidata(S.fh,S);
        
        % Save updated cells structure
        cells = S.cells;        
        background = S.background;        
        save(S.fluo_tracing_file, 'cells', 'background');
        save(S.fluo_tracing_file_harddrive, 'cells', 'background');
        
        plot_tracing_results(S,1)
        
    end
    guidata(S.fh,S);
    % Replot the ROI outlines
    S = plot_ROI_outlines(S,1:length(S.cells));
    % update button text
    S = update_button_texts(S,index);
    guidata(S.fh,S);

    % Give control to the next button                    
    if index <length(S.select_ROI_button)
        set(gcf,'Visible','on');
        drawnow;
        % Give control to the next nucleus button
        uicontrol(S.select_ROI_button(index + 1));
    end

    title('');

    % Re-enable GUI
    S = enable_disable_GUI_buttons(S, 'on');
    title('');
    guidata(S.fh, S);
    return;
    
end



function select_background_button_callback(varargin)

%try 
    S = guidata(varargin{3});
    index = varargin{4};
    
    if isnan(S.background.intensity(index, S.current_t+1))
        set(S.select_background_button(index),'enable', 'off');

        if ~isempty(S.fluo_figure)
            
            % Make the ROI either on the fluo or the CoChannel channel
            set(0, 'CurrentFigure',S.fluo_figure);        
                
            title('Select outline of nucleus');
            hFH_background = imfreehand();

            if ~isempty(hFH_background) % in which case the user actually selected a ROI

                BW = hFH_background.createMask();
                delete(hFH_background);
                % immediately delete the handle to the freehand drawing
                % to not mess up the figure
                % Get bondaries of free hand region
                structBoundaries = bwboundaries(BW);
                
                if ~isempty(structBoundaries) % this is empty, if the user actually only clicked once and didn't draw a region
                    xy = structBoundaries{1}; % Get n by 2 array of x,y coordinates.
                    x = xy(:, 2); % Columns.
                    y = xy(:, 1); % Rows.    

                    [Y, X] = meshgrid(1:size(S.current_fluo_img,2), 1:size(S.current_fluo_img,1));

                    % this determines all pixels that are in the convex hull
                    in_bg = inpolygon(X(:),Y(:),y,x);
                    % Get mean fluorescence inside the region selected      
                    S.background.intensity(index, S.current_t+1) = mean(S.current_fluo_img(in_bg));
                    S.background.slices(index, S.current_t+1) = S.current_z;
                    S.background.outline.x{index, S.current_t+1} = x;                   
                    S.background.outline.y{index, S.current_t+1} = y;                   

                    disp(['The mean background inside the selected region is ' num2str(S.background.intensity(index, S.current_t+1))]);


                    % Save updated cells structure
                    cells = S.cells;        
                    background = S.background;        
                    save(S.fluo_tracing_file, 'cells', 'background');
                    save(S.fluo_tracing_file_harddrive, 'cells', 'background');

                    % Plot the tracing results 
                    S = plot_ROI_outlines(S,1:length(S.cells));

                    % update the plot in the results
                    guidata(S.fh,S); % update S after plotting
                    plot_tracing_results(S, 1);      
                else
                    set(S.select_background_button(index),'enable', 'on');    
                    title('');
                    return;
                end
            else
                set(S.select_background_button(index),'enable', 'on');    
                title('');
                return;
            end
        end

        set(S.select_background_button(index),'enable', 'on');    
        
        
    %%% There already is a background ROI defined and we want to delete it   
    else
        % Delete everything that is known about this background ROI       
        S.background.intensity(index, S.current_t+1) = NaN;
        S.background.slice(index, S.current_t+1) = NaN;
        S.background.outline.x{index, S.current_t+1} = [];
        S.background.outline.y{index, S.current_t+1} = [];
        
        guidata(S.fh,S);
        
        % Save updated cells structure
        cells = S.cells;        
        background = S.background;        
        save(S.fluo_tracing_file, 'cells', 'background');
        save(S.fluo_tracing_file_harddrive, 'cells', 'background');
        
        plot_tracing_results(S,1)
        
    end
    guidata(S.fh,S);
    % Replot the ROI outlines
    S = plot_ROI_outlines(S,1:length(S.cells));
    % update button text
    S = update_button_texts(S,index);
    guidata(S.fh,S);

    % Give control to the next button                    
    if index < length(S.select_ROI_button)
        set(gcf,'Visible','on');
        drawnow;
        % Give control to the next nucleus button
        uicontrol(S.select_ROI_button(index + 1));
    end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function close_data_display_window_callback(varargin)

    S = guidata(varargin{3});

    if ishandle(S.CoChannel_figure)
        delete(S.CoChannel_figure);
        S.CoChannel_figure = [];
        S.CoChannel_axis = [];
    end
    if ishandle(S.fluo_figure)
        delete(S.fluo_figure);
        S.fluo_figure = [];
        S.fluo_axis = [];
    end
    
    S.current_t = 0;
    S.current_z = 0;
    S.data_path = [];
    axes(S.axes(1)); cla;
    axes(S.axes(2)); cla;
    S.current_t_line = [];
    
    % re-initialize S.cells structure with empty fields
    for ii  = 1:length(S.cells)        
        
        tmp(ii) = struct('name', S.cells(ii).name,...
            'foreground',[], ...
            'background', [],...
            'ROI_slice',[],...
            'EMs', [],...
            'ROIs',struct('x',[], 'y',[] ),...
            'conv_hulls',struct('x',[], 'y', []));
    end
    S.cells = tmp;
    
    % Re-enable open data set button
    set(S.open_folder_button, 'enable', 'on');


    set(S.CoChannel_min_edit, 'enable', 'off');
    set(S.CoChannel_max_edit, 'enable', 'off');
    set(S.fluo_min_edit, 'enable', 'off');
    set(S.fluo_max_edit, 'enable', 'off');
    
    set(S.previous_t_frame_button, 'enable', 'off');
    set(S.next_t_frame_button, 'enable', 'off');
    set(S.previous_z_slice_button, 'enable', 'off');
    set(S.next_z_slice_button, 'enable', 'off');
    set(S.goto_slice_edit, 'enable', 'off');
    set(S.goto_frame_edit, 'enable', 'off');

    
    %set(S.select_focal_plane_button, 'enable', 'off');
    set(S.select_ROI_button(:), 'enable', 'off');
    set(S.select_background_button(:), 'enable', 'off');
    guidata(S.fh, S);

end


% Closes the entire GUI, delete data set window etc.
function nCloseAll(varargin)


    S  = guidata(varargin{1});

    if ishandle(S.CoChannel_figure)
        delete(S.CoChannel_figure);
        delete(S.fluo_figure);
    end

    % Finally close the figure
    if isfield(S,'fh')
        delete(S.fh);
    else
        delete(gcf);
    end    
    
    
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%% HELPER FUNCTIONS %%%%%%%%%%
function S = load_slice(S,t,z,TracingChannel)
    
    S = guidata(S.fh);
    
    if ~isempty(S.data_path)
        
        
        
        timestamp_string = num2str(t);
        timestamp_string = [repmat('0', [1 9-length(timestamp_string)]) timestamp_string];
        
        z_slice_string = num2str(z);
        z_slice_string = [repmat('0', [1 3-length(z_slice_string)]) z_slice_string];
        
        S.current_CoChannel_file = [S.data_path '/img_' timestamp_string '_' S.CoChannel '_' z_slice_string '.tif'];
        S.current_fluo_file = [S.data_path '/img_' timestamp_string '_' TracingChannel '_' z_slice_string '.tif'];

        % Try to read the tif file in the data set, display it via
        % imshow
        if exist(S.current_CoChannel_file, 'file')
            
            S.current_img = imread(S.current_CoChannel_file);
            
            % this is true, when we first open the data set
            if isempty(S.CoChannel_figure) || ~ishandle(S.CoChannel_figure)
                S.CoChannel_figure = figure( 'Name', sprintf('%s: Slice: %f; Frame: %f',S.CoChannel, z,t),...
                    'CloseRequestFcn', @(src,evt)close_data_display_window_callback(S.CoChannel_figure,evt, S.fh));
                imshow(S.current_img,[S.data_min,S.data_max]);
                S.CoChannel_axis = gca;
                 %%% set callback for scrollwheel (change slice)
                set(S.CoChannel_figure,'WindowScrollWheelFcn',@(src,evt)scroll_over_window_callback(S.CoChannel_figure, evt,S.fh))
                %%% set callback for key pressed (+ and - key is zoom out and zoom in)
                set(S.CoChannel_figure,'KeyPressFcn',@(src,evt)key_pressed_over_window_callback(S.CoChannel_figure, evt,S.fh))
            else
                
                % make figure current, and show image
                % get axis limits
                set(0, 'CurrentFigure',S.CoChannel_figure);
                xlim = get(gca,'xlim');
                ylim = get(gca,'ylim');
                set(S.CoChannel_figure, 'Name',sprintf('%s: Slice: %f; Frame: %f', S.CoChannel, z,t));
                imshow(S.current_img,[S.data_min,S.data_max]);
                zoom reset;
                set(gca, 'xlim', xlim);
                set(gca, 'ylim', ylim);
            end
                
        else
            disp(['Cannot load CoChannel file: ' S.current_CoChannel_file '!']);
        
        end
        
        if exist(S.current_fluo_file, 'file')
            
            S.current_fluo_img  =  imread(S.current_fluo_file);
            %S.current_fluo_img  =  medfilt2(imread(S.current_fluo_file),[2 2]);
            % this is true, when we first open the data set
            if isempty(S.fluo_figure) || ~ishandle(S.fluo_figure)
                S.fluo_figure = figure( 'Name', sprintf('%s: Slice: %f; Frame: %f',S.TracingChannel, z,t),...
                    'CloseRequestFcn', @(src,evt)close_data_display_window_callback(S.fluo_figure,evt, S.fh));
                imshow(S.current_fluo_img,[S.fluo_data_min,S.fluo_data_max]);
                S.fluo_axis = gca;
                % this makes both axes have the same x-y zoom
                linkaxes([S.fluo_axis, S.CoChannel_axis]);
                %%% set callback for scrollwheel (change slice)
                set(S.fluo_figure,'WindowScrollWheelFcn',@(src,evt)scroll_over_window_callback(S.fluo_figure, evt,S.fh))
                %%% set callback for key pressed (+ and - key is zoom out and zoom in)
                set(S.fluo_figure,'KeyPressFcn',@(src,evt)key_pressed_over_window_callback(S.fluo_figure, evt,S.fh))
            else
                % make figure current, and show image
                % get axis limits
                set(0, 'CurrentFigure',S.fluo_figure);
                xlim = get(gca,'xlim');
                ylim = get(gca,'ylim');
                set(S.fluo_figure, 'Name',sprintf('%s: Slice: %f; Frame: %f',S.TracingChannel, z,t));
%                imshow(S.current_fluo_img,[2*min(S.current_fluo_img(:)),max(S.current_fluo_img(:))]);
                imshow(S.current_fluo_img,[S.fluo_data_min,S.fluo_data_max]);
                zoom reset;
                set(gca, 'xlim', xlim);
                set(gca, 'ylim', ylim);
            end
            
                
        else
            disp(['Cannot load ' TracingChannel '-file!']);
        end
        
    end
    
    S = plot_ROI_outlines(S,1:length(S.cells));
    S = update_button_texts(S,1:length(S.cells));
    guidata(S.fh,S);
    plot_tracing_results(S,1);
    S = replot_current_t_line(S);

    guidata(S.fh,S);


end

% Gets the dimensions of the data set based on the file names in the folder
function [no_slices, no_timestamps] = get_data_set_dimensions(data_path)

    no_timestamps = [];
    no_slices = [];
    
    list_of_tiff_files = dir(data_path);
    
    z_string_range = [-6:-4]; %% this counts from the end
    t_string_range = 5:13;

    % Find out how many slices were taken   
    % Find out how many timeframes the actually are
    for ii = length(list_of_tiff_files):-1:1

        if strfind(list_of_tiff_files(ii).name,'tif')        

            no_timestamps = str2double(list_of_tiff_files(ii).name(t_string_range))+1;
            no_slices = str2double(list_of_tiff_files(ii).name(end+z_string_range))+1;
            break;            
        end
    end
    
        
    if isempty(no_slices) || isempty(no_timestamps)
        disp('Cannot determine size of data set! Is this a proper worm folder?');
    else
        %%% Output for sanity check 
        disp(['    No timestamps: ' num2str(no_timestamps)]);
        disp(['    No slices: ' num2str(no_slices)]);      
    end
end



function [level, em] = graythresh_single_vector(I)
    %GRAYTHRESH_SINGLE_VECTOR image threshold using Otsu's method.
    %   LEVEL = GRAYTHRESH_SINGLE_VECTOR(I) computes a threshold (LEVEL). 
    %   GRAYTHRESH_SINGLE_VECTOR uses Otsu's method, which chooses the threshold to minimize
    %   the intraclass variance of the thresholded black and white pixels.
    %
    %   [LEVEL, EM] = GRAYTHRESH_SINGLE_VECTOR(I) returns effectiveness metric, EM, as the
    %   second output argument. It indicates the effectiveness of thresholding
    %   of the input image and it is in the range [0, 1]. The lower bound is
    %   attainable only by images having a single gray level, and the upper
    %   bound is attainable only by two-valued images.
    %
    %   NOTE: This is modified from the code in the built in matlab
    %   function
    %   the main difference is that it takes uint vectors, normalizes them
    %   to one and then computes the Otsu threshold
    %   level is then returned so that I(I>level) will actually work
    %
    %
    % Reference:
    % N. Otsu, "A Threshold Selection Method from Gray-Level Histograms,"
    % IEEE Transactions on Systems, Man, and Cybernetics, vol. 9, no. 1,
    % pp. 62-66, 1979.

    % One input argument required.
    narginchk(1,1);
    validateattributes(I,{'uint8','uint16','double','single','int16'},{'nonsparse'}, ...
                  mfilename,'I',1);

    if ~isempty(I)
      % Convert all N-D arrays into a single column.  Convert to uint8 for
      % fastest histogram computation.
      num_bins = 256;
      
      %
      %%% the following lines are just to be able to work with the matlab
      %%% routines
      
      % Scale I, so that it fits the entire range
      range = getrangefromclass(I);
      max_I = max(I(:));
      scaling_factor = double(range(2))/double(max(I(:)));
      % scale I
      I = uint16(double(I)*scaling_factor);
      
      counts = imhist(I,num_bins);

      % Variables names are chosen to be similar to the formulas in
      % the Otsu paper.
      p = counts' / sum(counts);
      omega = cumsum(p);
      mu = cumsum(p .* (1:num_bins));
      mu_t = mu(end);

      sigma_b_squared = (mu_t * omega - mu).^2 ./ (omega .* (1 - omega));

      % Find the location of the maximum value of sigma_b_squared.
      % The maximum may extend over several bins, so average together the
      % locations.  If maxval is NaN, meaning that sigma_b_squared is all NaN,
      % then return 0.
      maxval = max(sigma_b_squared);
      isfinite_maxval = isfinite(maxval);
      if isfinite_maxval
        idx = mean(find(sigma_b_squared == maxval));
        % Normalize the threshold to the range [0, 1].
        level = (idx - 1) / (num_bins - 1);
      else
        level = 0.0;
      end
    else
      level = 0.0;
      isfinite_maxval = false;
    end

    % compute the effectiveness metric
    if nargout > 1
      if isfinite_maxval
        em = maxval/(sum(p.*((1:num_bins).^2)) - mu_t^2);
      else
        em = 0;
      end
    end
    
    level = level*max_I;
    
    disp(['Threshold level is ' num2str(level)]);
    
    
end

function input = checkstring(hObject,range,integer)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
% str2double(get(hObject,'String')) returns contents as a double
    input = str2double(get(hObject,'string'));

    % Get default 
    if nargin < 2
        range = [-inf, inf];
        integer = 0; % doesn't have to be integer
    end

    if nargin < 3
        integer = 0; % doesn't have to be integer
    end


    if isnan(input)
      errordlg('You must enter a numeric value','Invalid Input','modal')
      uicontrol(hObject)
      return;
    else
        if input < range(1)
          errordlg(['You must enter a value larger than ' num2str(range(1))],'Invalid Input','modal')
          uicontrol(hObject)
          return;
        end
        if input > range(2)
          errordlg(['You must enter a value smaller than ' num2str(range(2))],'Invalid Input','modal')
          uicontrol(hObject)
          return;
        end
        if integer
            if input ~=round(input)
              errordlg('You must enter an integer value','Invalid Input','modal')
              uicontrol(hObject)
              return;
            end
        end

    end
end

function scroll_over_window_callback(varargin)

    callbackdata = varargin{2};
    S  = guidata(varargin{3});

    
    % Check whether there is something to do, i.e. whether we are not
    % scrolling beyond the boundary anyway
    do_something = 1;
    if (S.current_z == 0 && callbackdata.VerticalScrollCount < 0) || ...
        (S.current_z == S.no_slices-1 && callbackdata.VerticalScrollCount > 0)
        do_something = 0;
    end
    
    if do_something == 1
        % Determine new slice
        new_slice = S.current_z + callbackdata.VerticalScrollCount;
        
        % Ensure that new_slice is within the limits
        if new_slice >= S.no_slices
            new_slice = S.no_slices-1;%% last slice
        elseif new_slice < 0
            new_slice = 0;
        end


        if new_slice >=0 && new_slice < S.no_slices
            S.current_z = new_slice;  
            guidata(S.fh,S);

            S = load_slice(S,S.current_t,new_slice, S.TracingChannel);

            if (S.current_z) == 0
                % Disable previous z-slice button
                set(S.previous_z_slice_button  ,'enable','off');
            else
                set(S.previous_z_slice_button  ,'enable','on');

            end

            if (S.current_z+1) == S.no_slices
                % Disable next z-slice button
                set(S.next_z_slice_button,'enable','off');
            else
                set(S.next_z_slice_button,'enable','on');

            end

            plot_tracing_results(S,1) ;
            guidata(S.fh,S);
        end
    end

end

function key_pressed_over_window_callback(varargin)

    hObject = varargin{1}; %%% Figure over which callback was pressed
    callbackdata = varargin{2};
    
    S  = guidata(varargin{3});
    
    C = get (gca, 'CurrentPoint');
    
    if ~isempty(callbackdata.Character)
        switch double(callbackdata.Character)
            case 45 % '-' % zoom out
                if ~(gcf == S.fh)
                    zoomcenter(C(1,1),C(1,2), 1/2);
                    %zoom(1/2);
                end
            case 61 % '=' % zoom in
                if ~(gcf == S.fh)
                    zoomcenter(C(1,1),C(1,2), 2);
                end
            case 30 % 'uparrow' % next slice
                next_z_slice_button_callback(S.fh);
            case 31 % 'downarrow' % previous slice
                previous_z_slice_button_callback(S.fh);
            case 29 % 'rightarrow' % next frame
                next_t_frame_button_callback(S.fh);
            case 28 % 'leftarrow' % previous frame
                previous_t_frame_button_callback(S.fh);
        end
    end
    
    % get the focus back on the figure
    set(0, 'CurrentFigure', hObject);
    % get the focus back on the figure
    set(0, 'CurrentFigure', hObject);
    
    
end


function zoomcenter(varargin)
%ZOOMCENTER Zoom in and out of a specifeid point on a 2-D plot.
% ZOOMCENTER(X,Y) zooms the current axis on the point (X,Y) by a factor of 2.5.
% ZOOMCENTER(X,Y,FACTOR) zooms the current axis on the point (X,Y) by FACTOR.
%
% ZOOMCENTER(AX,...) zooms on the specified axis
%
% Example:
% line
% zoomcenter(.5, .5, 10)
%
% line
% zoomcenter(.7, .3, .5)

    nin = nargin;
    if nin==0
         error('ZOOMCENTER requires at least 2 inputs');
    end
    if ishandle(varargin{1})
        ax = varargin{1};
        varargin = varargin(2:end);
        nin = nin-1;
    else
         ax = gca;
    end
    if nin<2
        error('ZOOMCENTER requires specifying both X and Y');
    else
        x = varargin{1};
        y = varargin{2};
    end
    if nin==3
        factor = varargin{3};
    else
        factor = 2;
    end

    cax = axis(ax);
    daxX = (cax(2)-cax(1))/factor(1)/2;
    daxY = (cax(4)-cax(3))/factor(end)/2;
    axis(ax,[x+[-1 1]*daxX y+[-1 1]*daxY]);

    %axis fill;

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function S = enable_disable_GUI_buttons(S, state)
%
% 
%
% this leaves the OPEN DATA button untouched

    S = guidata(S.fh);    
    
    %%%%%%%%%%%%%%%%%%%%%%%
    if S.no_slices > 1 && (S.current_z+1) ~= S.no_slices
        set(S.next_z_slice_button, 'enable', state);
    end
    if S.current_z ~= 0
        set(S.previous_z_slice_button, 'enable', state);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%
    if (S.current_t+1) ~= S.no_timestamps && S.no_timestamps > 1
        set(S.next_t_frame_button,'enable',state);
    end
    if S.current_t ~= 0
        set(S.previous_t_frame_button,'enable',state);
    end
    
    set(S.select_ROI_button(:),'enable', state);
    set(S.select_background_button(:),'enable', state);

    guidata(S.fh, S);

end

