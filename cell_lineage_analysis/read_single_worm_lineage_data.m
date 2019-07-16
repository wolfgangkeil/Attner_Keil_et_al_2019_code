function worm = read_single_worm_lineage_data(wormfile)
%
% function worm = read_single_worm_lineage_data(wormfile)
%
% DESCRIPTION
% This function reads a worm lineage textfile and returns a structure
% called worm, with lineage trees and durations for the individual cells
% in the worm structure, NA means 'not applicable', i.e. any dates make no
% sense in the automated imaging setup
% NC means 'not captured', the duration trees have zero entries when this
% happened
%
% INPUT PARAMETERS
% filename of a .txt file with all the lineages scored
%
% OUTPUT PARAMETERS
%  
% worm ... structure, containing all the worm info
%
% a typical worm structure might look like this
%
% worm = 
% 
%                   wormfile: '09_Jun_2015_2.txt'
%                   sex: 'hermaphrodite'
%                   genotype: 'N2'
%             imaging_method: 'automated'
%                temperature: '2015-06-09'
%                 synch_date: '2015-06-09'
%                 synch_time: '15:15:00'
%           growth_condition: 'liquid'
%                 mount_date: '2015-06-10'
%                 mount_time: '16:40:00'
%     end_of_experiment_date: '2015-06-11'
%     end_of_experiment_time: '12:00:00'
%          l1_lethargus_date: 'NA'
%          l1_lethargus_time: 'NC'
%               l1_molt_date: 'NA'
%               l1_molt_time: '00:00:00'
%          l2_lethargus_date: 'NA'
%          l2_lethargus_time: 'NC'
%               l2_molt_date: 'NA'
%               l2_molt_time: '01:20:00'
%          l3_lethargus_time: 'NC'
%               l3_molt_date: 'NA'
%               l3_molt_time: 'NC'
%               l4_molt_date: 'NA'
%               l4_molt_time: 'NC'
%                Z1_lineage: [1x1 tree]
%                Z4_lineage: [1x1 tree]
%
%
% see also get_1st_division_times.m, get_2nd_division_times.m, get_3rd_division_times.m
%
%
% by Wolfgang Keil, wolfgang.keil@curie.fr 2019
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fid = fopen(wormfile);
    % Skip the header 
    try
        tmp = textscan(fid, '%s %*[^\n]',1);
    catch 
        disp(['Couldn''t read file: ' wormfile]);
        worm = {};
        return;
    end
    
    
    while ~strcmp(tmp{1}, '##')
        tmp = textscan(fid, '%s %*[^\n]',1);
    end

    worm.wormfile = wormfile;
    %%%%%%%%%  THIS READS EXPERIMENT INFORMATIONS        
    tmp  = {''};
    while ~strcmp(tmp{1}, '##');            
        tmp = textscan(fid, '%s',1);
        if strcmpi(tmp{1}, 'genotype')
            t  = textscan(fid, '%s %*[^\n]',1);
            worm.genotype =char(t{1});
        elseif strcmpi(tmp{1}, 'sex')
            t = textscan(fid, '%s %*[^\n]',1);
            worm.sex = char(t{1});
        elseif strcmpi(tmp{1}, 'temperature')
            t = textscan(fid, '%s %*[^\n]',1);
            worm.temperature = char(t{1});
        elseif strcmpi(tmp{1}, 'synch_date')
            t = textscan(fid, '%s %*[^\n]',1);
            worm.synch_date = char(t{1});
            worm.temperature = char(t{1});
        elseif strcmpi(tmp{1}, 'synch_time')
            t = textscan(fid, '%s %*[^\n]',1);
            worm.synch_time =char(t{1});
        elseif strcmpi(tmp{1}, 'imaging_method')
            t = textscan(fid, '%s %*[^\n]',1);
            worm.imaging_method = char(t{1});        
        elseif strcmpi(tmp{1}, 'growth_condition')
            t = textscan(fid, '%s %*[^\n]',1);
            worm.growth_condition = char(t{1});            
        elseif strcmpi(tmp{1}, 'mount_date')
            t = textscan(fid, '%s %*[^\n]',1);
            worm.mount_date =char(t{1});
        elseif strcmpi(tmp{1}, 'mount_time')
            t = textscan(fid, '%s %*[^\n]',1);
            worm.mount_time = char(t{1});
        elseif strcmpi(tmp{1}, 'end_of_experiment_date')
            t = textscan(fid, '%s %*[^\n]',1);
            worm.end_of_experiment_date = char(t{1});
        elseif strcmpi(tmp{1}, 'end_of_experiment_time')
            t = textscan(fid, '%s %*[^\n]',1);
            worm.end_of_experiment_time = char(t{1});
        end

    end
    
    % assign 'default' sex of the worm as hermaphrodite
    if ~isfield(worm,'sex')
        worm.sex = 'hermaphrodite';
    end

    %%%%%%%%%  THIS READS LETHARGUS INFORMATIONS
    tmp  = {''};        
    while ~strcmp(tmp{1}, '##');            
        tmp = textscan(fid, '%s',1);

        %%% L1/L2 molts        
        if strcmpi(tmp{1}, 'l1_lethargus_date')
            t = textscan(fid, '%s %*[^\n]',1);
            worm.l1_lethargus_date = char(t{1});
        elseif strcmpi(tmp{1}, 'l1_lethargus_time')
            t = textscan(fid, '%s %*[^\n]',1);
            worm.l1_lethargus_time = char(t{1});
        elseif strcmpi(tmp{1}, 'l1_molt_date')
            t = textscan(fid, '%s %*[^\n]',1);
            worm.l1_molt_date = char(t{1});
        elseif strcmpi(tmp{1}, 'l1_molt_time')
            t = textscan(fid, '%s %*[^\n]',1);
            worm.l1_molt_time = char(t{1});
            
        %%% L2/L3 molts
        elseif strcmpi(tmp{1}, 'l2_lethargus_date')
            t = textscan(fid, '%s %*[^\n]',1);
            worm.l2_lethargus_date = char(t{1});
        elseif strcmpi(tmp{1}, 'l2_lethargus_time')
            t = textscan(fid, '%s %*[^\n]',1);
            worm.l2_lethargus_time = char(t{1});
        elseif strcmpi(tmp{1}, 'l2_molt_date')
            t = textscan(fid, '%s %*[^\n]',1);
            worm.l2_molt_date = char(t{1});
        elseif strcmpi(tmp{1}, 'l2_molt_time')
            t = textscan(fid, '%s %*[^\n]',1);
            worm.l2_molt_time = char(t{1});
            
            %%% L3/L4 molts
        elseif strcmpi(tmp{1}, 'l3_lethargus_date')
            t = textscan(fid, '%s %*[^\n]',1);
            worm.l3_lethargus_date = char(t{1});
        elseif strcmpi(tmp{1}, 'l3_lethargus_time')
            t = textscan(fid, '%s %*[^\n]',1);
            worm.l3_lethargus_time = char(t{1});
        elseif strcmpi(tmp{1}, 'l3_molt_date')
            t = textscan(fid, '%s %*[^\n]',1);
            worm.l3_molt_date = char(t{1});
        elseif strcmpi(tmp{1}, 'l3_molt_time')
            t = textscan(fid, '%s %*[^\n]',1);
            worm.l3_molt_time = char(t{1});
            
            %%% L4/adult molts
        elseif strcmpi(tmp{1}, 'l4_lethargus_date')
            t = textscan(fid, '%s %*[^\n]',1);
            worm.l4_lethargus_date = char(t{1});
        elseif strcmpi(tmp{1}, 'l4_lethargus_time')
            t = textscan(fid, '%s %*[^\n]',1);
            worm.l4_lethargus_time = char(t{1});
        elseif strcmpi(tmp{1}, 'l4_molt_date')
            t = textscan(fid, '%s %*[^\n]',1);
            worm.l4_molt_date = char(t{1});
        elseif strcmpi(tmp{1}, 'l4_molt_time')
            t = textscan(fid, '%s %*[^\n]',1);
            worm.l4_molt_time = char(t{1});            
            
           %%%% Time of first egg-laying
        elseif strcmpi(tmp{1}, 'first_egg_date')
            t = textscan(fid, '%s %*[^\n]',1);
            worm.first_egg_date = char(t{1});
        elseif strcmpi(tmp{1}, 'first_egg_time')
            t = textscan(fid, '%s %*[^\n]',1);
            worm.first_egg_time = char(t{1});            
        end

    end

    %%%%%%%%%  THIS READS DIVISION INFORMATIONS
    %%%%%%%%%  Initialize trees   
    worm.Z1_lineage = tree('Z1');
    worm.Z4_lineage = tree('Z4');
    
    tmp2 = {''};
    heading = textscan(fid, '%s %*[^\n]',1); %% Read the line
    
    
    % First round reads the tree of the 
    if strcmpi(heading{1}, 'DIVISIONS')
    
        while ~strcmpi(tmp2{1}, 'EndOfDivisionInformation');
            tmp2 = textscan(fid, '%s %s %*[^\n]',1);
            tmp  = ''; 
            if length(tmp2)>1                
                mother_cell_string = char(tmp2{2});
            end
            while ~strcmp(tmp, '##');         
                %%%%%%%%%%%%% First round of division
                tmp = textscan(fid, '%s',1);
                tmp  = char(tmp{1});
                d = strfind(tmp, '_');

                if ~isempty(d)
                
                    
                    cell_string = tmp(1:d(1)-1);
                    %%%%% This saves the division times in separate
                    %%%%% variables
                    if strcmpi(tmp, strcat(cell_string ,'_div_date'))
                        
                        t = textscan(fid, '%s %*[^\n]',1);
                        eval(sprintf('worm.%s_div_date = char(t{1});', cell_string));

                    elseif strcmpi(tmp, strcat(cell_string, '_div_time'))
                        t = textscan(fid, '%s %*[^\n]',1);
                        
                        % Read the time when the cell has divided
                        eval(sprintf('worm.%s_div_time = char(t{1});', cell_string));
                        %%%% This builds up trees for the VPCs                        
                        if length(cell_string) == 2
                            %%% Means first division

                            %%% add two daughters to lineage tree
                            eval(sprintf('[worm.%s_lineage, %sa ] = worm.%s_lineage.addnode(1, [cell_string ''a'']);',cell_string,cell_string,cell_string));
                            eval(sprintf('[worm.%s_lineage, %sp ] = worm.%s_lineage.addnode(1, [cell_string ''p'']);',cell_string,cell_string,cell_string));
                                
                        else
                            eval(sprintf('[worm.%s_lineage, %sa ] = worm.%s_lineage.addnode(%s, [cell_string ''a'']);',...
                                mother_cell_string,cell_string,mother_cell_string,cell_string));
                            eval(sprintf('[worm.%s_lineage, %sp ] = worm.%s_lineage.addnode(%s, [cell_string ''p'']);',...
                                mother_cell_string,cell_string,mother_cell_string,cell_string));
                        end
                    end
                end
            end
            
        end

    end
    
    %%%% READ THE FATES
    tmp2 = {''};
    heading = textscan(fid, '%s %*[^\n]',1); %% Read the line
    
    if strcmpi(heading{1}, 'FATES')
    
        while ~strcmpi(tmp2{1}, 'EndOfFile');
            %%%%%%%%%%%%% First round of division
            tmp2 = textscan(fid, '%s',1);
            mother_cell_string = char(tmp2{1});
            d = strfind(mother_cell_string, '_');

            if ~isempty(d)

                mother_cell_string = mother_cell_string(1:d(1)-1);
                t = textscan(fid, '%s %*[^\n]',1);
                eval(sprintf('worm.%s_fate = char(t{1});', mother_cell_string));
            end
        end
    end
    
    if ~(strcmpi(worm.Z4aaa_fate, 'VD') || strcmpi(worm.Z4aaa_fate, 'LC'))
        worm.Z4aaa_fate;
    end
        
   fclose(fid);
   
   
   
   
   
   

    %%%%%%% make a synched trees for the durations
    %%% create a SYNCHRONIZED trees for the duration
    worm.Z1_duration = tree(worm.Z1_lineage,0);
    %%% create a SYNCHRONIZED trees for the duration
    worm.Z4_duration = tree(worm.Z4_lineage,0);
    
    
    % Loop over both Z-cells
    for mother_cell = [1,4]

        mother_cell_string = ['Z' num2str(mother_cell)];
        
        % get the iterator for the tree
        eval(sprintf('indices = worm.%s_duration.nodeorderiterator();',mother_cell_string ));

        % get depth of tree 
        eval(sprintf('tree_depth = worm.%s_lineage.depth();', mother_cell_string));

        % Go over all nodes
        for ii = indices
            
            cell_string = eval(sprintf('worm.%s_lineage.get(ii)', mother_cell_string));
            

            % this means date format is actually day and
            % time
            if strcmpi(worm.imaging_method, 'manual')

                % this means date format is from start of
                % experiment, generate duration tree

                if ii == 1 %%% parent node!         
                    if eval(sprintf('isempty(worm.%s_lineage.getchildren(ii))', mother_cell_string)) % VPC didn't divide
                        eval(sprintf('worm.%s_duration = worm.%s_duration.set(ii,etime(datevec([worm.end_of_experiment_date '' '' worm.end_of_experiment_time]),datevec([worm.synch_date '' '' worm.synch_time]))/3600);',...
                            mother_cell_string, mother_cell_string));  

                    else
                        eval(sprintf('worm.%s_duration = worm.%s_duration.set(ii,etime(datevec([worm.%s_div_date '' '' worm.%s_div_time]),datevec([worm.synch_date '' '' worm.synch_time]))/3600);',...
                            mother_cell_string, mother_cell_string,mother_cell_string,mother_cell_string));  
                        
                    end
                else
                    
                    if eval(sprintf('isempty(worm.%s_lineage.getchildren(ii))', mother_cell_string))
                    % cell didn't divide further, duration until the end of
                    % experiment
                    
                        eval(sprintf('worm.%s_duration = worm.%s_duration.set(ii, etime(datevec([worm.end_of_experiment_date '' '' worm.end_of_experiment_time]),datevec([worm.%s_div_date '' '' worm.%s_div_time]))/3600);',...
                        mother_cell_string,mother_cell_string,cell_string(1:end-1),cell_string(1:end-1)));

                    else
                        cell_string = eval(sprintf('worm.%s_lineage.get(ii)', mother_cell_string));
                        eval(sprintf('worm.%s_duration = worm.%s_duration.set(ii, etime(datevec([worm.%s_div_date '' '' worm.%s_div_time]), datevec([worm.%s_div_date '' '' worm.%s_div_time]))/3600);',...
                            mother_cell_string,mother_cell_string, cell_string, cell_string, cell_string(1:end-1), cell_string(1:end-1)));
                    end
                    
                    
                end


            elseif strcmpi(worm.imaging_method, 'automated')

                % this means date format is from start of
                % experiment, Hours from synch time to start of
                % experiment
                %
                % Are the divisions captured, so that
                % the durations can be calculated?
                
                if ii == 1 % parent node1!                    
                    if eval(sprintf('isempty(worm.%s_lineage.getchildren(ii))', mother_cell_string)) % VPC didn't divide
                        
                       eval(sprintf('worm.%s_duration = worm.%s_duration.set(ii,etime(datevec([worm.end_of_experiment_date '' '' worm.end_of_experiment_time]),datevec([worm.synch_date '' '' worm.synch_time]))/3600);',...
                                        mother_cell_string,mother_cell_string));
                        
                    else % cell did divide
                        
                        
                        captured_div1 = eval(sprintf('~strcmpi(worm.%s_div_time,''NC'')',mother_cell_string));
                        if strcmpi(worm.synch_date, 'NC') ||  strcmpi(worm.synch_time, 'NC')
                            captured_synch_date = 0;
                        else
                            captured_synch_date = 1;
                        end

                        if captured_div1 && captured_synch_date
                            tmp = etime(datevec([worm.mount_date ' ' worm.mount_time]),datevec([worm.synch_date ' ' worm.synch_time]))/3600;

                            eval(sprintf('tmp  = tmp + to_seconds(worm.%s_div_time)/3600;',mother_cell_string))                                
                            %%% generate duration tree for the VPC
                            eval(sprintf('worm.%s_duration = worm.%s_duration.set(1, tmp);', mother_cell_string, mother_cell_string));

                        else
                            %%% generate duration tree for the VPC
                            %%% with zero duration, indicating that we
                            %%% couldn't score the "duration" of the first cc
                            eval(sprintf('worm.%s_duration = worm.%s_duration.set(1,0);', mother_cell_string, mother_cell_string));
                        end
                    end
                    
                else %%% Z1/4 daughter node
                    if eval(sprintf('isempty(worm.%s_lineage.getchildren(ii))', mother_cell_string))
                    % cell didn't divide further, duration until the end of
                    % experiment
                    
                        % Is divisions of parent cell captured? 
                        captured_div1 = eval(sprintf('~strcmpi(worm.%s_div_time,''NC'')',cell_string(1:end-1)));
                        
                        if captured_div1
                            
                           eval(sprintf('worm.%s_duration = worm.%s_duration.set(ii,etime(datevec([worm.end_of_experiment_date '' '' worm.end_of_experiment_time]),datevec([worm.mount_date '' '' worm.mount_time]))/3600 - to_seconds(worm.%s_div_time)/3600);',...
                                            mother_cell_string,mother_cell_string,cell_string(1:end-1)));

                            % if not the duration is zero, as per default
                            % in the initialized duration tree
                        end
                        
                    else
                        % Is division of parent cell and division of the cell? 
                        captured_div1 = eval(sprintf('~strcmpi(worm.%s_div_time,''NC'')',cell_string));
                        captured_div2 = eval(sprintf('~strcmpi(worm.%s_div_time,''NC'')',cell_string(1:end-1)));
                        

                        % if yes, calculate and add to the
                        % division tree
                        if captured_div1 && captured_div2                                            
                            eval(sprintf('worm.%s_duration = worm.%s_duration.set(ii, (to_seconds(worm.%s_div_time)-to_seconds(worm.%s_div_time))/3600);',...
                                mother_cell_string,mother_cell_string, cell_string, cell_string(1:end-1)));
                            % if not the duration is zero, as per default
                            % in the initialized duration tree
                        end
                    end
                end
            end
        end
    end
    
    
%  
%     
%                                 % this means date format is actually day and
%                             % time
%                             if strcmpi(worm.imaging_method, 'manual')
%                             
%                                 if length(cell_string) == 4
%                                     eval(sprintf('[worm.%s_duration, %s_dur ] = worm.%s_duration.addnode(1, etime(datevec([worm.%s_div_date '' '' worm.%s_div_time]), datevec([worm.%s_div_date '' '' worm.%s_div_time]))/3600);',...
%                                         mother_cell_string,cell_string,mother_cell_string, cell_string, cell_string, cell_string(1:end-1), cell_string(1:end-1)));
%                                 else
%                                     eval(sprintf('[worm.%s_duration, %s_dur ] = worm.%s_duration.addnode(%s_dur, etime(datevec([worm.%s_div_date '' '' worm.%s_div_time]), datevec([worm.%s_div_date '' '' worm.%s_div_time]))/3600);',...
%                                         mother_cell_string,cell_string,mother_cell_string, cell_string(1:end-1), cell_string, cell_string, cell_string(1:end-1), cell_string(1:end-1)));
%                                 end
%                             elseif strcmpi(worm.imaging_method, 'automated')                                
%                                 
%                                 if length(cell_string) == 4 % this means it's a Pnp daughter and we have to add to node 1
%                                     
%                                     
%                                     % Are the divisions captured, so that
%                                     % the durations can be calculated?
%                                     captured_div1 = eval(sprintf('~strcmpi(worm.%s_div_time,''NC'')',cell_string));
%                                     captured_div2 = eval(sprintf('~strcmpi(worm.%s_div_time,''NC'')',cell_string(1:end-1)));
%                                     
%                                     
%                                     % if yes, calculate and add to the
%                                     % division tree
%                                     if captured_div1 && captured_div2                                            
%                                         eval(sprintf('[worm.%s_duration, %s_dur ] = worm.%s_duration.addnode(1, (to_seconds(worm.%s_div_time)-to_seconds(worm.%s_div_time))/3600);',...
%                                             mother_cell_string,cell_string,mother_cell_string, cell_string, cell_string(1:end-1)));
%                                     %
%                                     else
%                                             eval(sprintf('[worm.%s_duration, %s_dur ] = worm.%s_duration.addnode(1, 0);',...
%                                                 mother_cell_string,cell_string,mother_cell_string));
%                                         
%                                     end
%                                     
% 
%                                 else
%                                     
%                                     % Are the divisions captured, so that
%                                     % the durations can be calculated?
%                                     captured_div1 = eval(sprintf('~strcmpi(worm.%s_div_time,''NC'')',cell_string));
%                                     captured_div2 = eval(sprintf('~strcmpi(worm.%s_div_time,''NC'')',cell_string(1:end-1)));
%                                     
%                                     
%                                     % if yes, calculate and add to the
%                                     % division tree
%                                     if captured_div1 && captured_div2                                            
%                                             eval(sprintf('[worm.%s_duration, %s_dur ] = worm.%s_duration.addnode(%s_dur, (to_seconds(worm.%s_div_time)-to_seconds(worm.%s_div_time))/3600);',...
%                                                 mother_cell_string,cell_string,mother_cell_string, cell_string(1:end-1), cell_string, cell_string(1:end-1)));
%                                     %
%                                     else
%                                             eval(sprintf('[worm.%s_duration, %s_dur ] = worm.%s_duration.addnode(%s_dur, 0);',...
%                                                 mother_cell_string,cell_string,mother_cell_string, cell_string(1:end-1)));
%                                         
%                                     end
%                                 end
%                                 
%                             end
%                             
%                             
%                             eval(sprintf('[worm.%s_lineage, %sa ] = worm.%s_lineage.addnode(%s, [cell_string ''a'']);',...
%                                 mother_cell_string,cell_string,mother_cell_string,cell_string));
%                             eval(sprintf('[worm.%s_lineage, %sp ] = worm.%s_lineage.addnode(%s, [cell_string ''p'']);',...
%                                 mother_cell_string,cell_string,mother_cell_string,cell_string));
%                         end
   


%    worm.Z1_lineage.tostring()
%    worm.Z4_lineage.tostring()
   
end
