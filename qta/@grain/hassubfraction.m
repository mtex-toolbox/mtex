function b = hassubfraction(grains)
% checks whether given grains has subfractions
%
%% Input
%  grains - @grain
%
%% Output
%  b   - boolean
%

subs = [grains.subfractions];
b = ~cellfun('isempty',{subs.xx});

