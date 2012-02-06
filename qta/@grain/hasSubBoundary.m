function b = hasSubBoundary(grains)
% checks whether given grains has sub grain boundaries
%
%% Input
%  grains - @grain
%
%% Output
%  b   - boolean
%

b = ~cellfun('isempty', {grains.subfractions});

