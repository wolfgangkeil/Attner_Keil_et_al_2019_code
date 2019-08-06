function fates = get_fates(worm)
% 
% DESCRIPTION: this functions reads the Z1.ppp and Z4.aaa fate from a worm structure 
%
% by Wolfgang Keil, wolfgang.keil@curie.fr 2019
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


   if isfield(worm, 'Z1ppp_fate')        
        fates{1} = worm.Z1ppp_fate;
    else
        fates{1} = NaN;          
    end

    if isfield(worm, 'Z4aaa_fate')        
        fates{2} = worm.Z4aaa_fate;
    else
        fates{2} = NaN;          
    end
end