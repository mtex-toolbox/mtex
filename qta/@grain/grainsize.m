function s = grainsize(grains,varargin)
% returns the size of a grain
%
%% Input
%  grains - @grain
%
%% Output
%  s   - size
%
%% See also
% polygon/area polygon/hullarea

s = cellfun('prodofsize',{grains.cells});



