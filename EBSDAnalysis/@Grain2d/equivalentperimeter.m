function p = equivalentperimeter(grains)
% returns the equivalent perimeter of grain-polygon
%
% defined as
%
% $$ p = 2 \pi ER $$,
%
% where $ER$ is the [[Grain2d.equivalentradius.html,equivalent radius]] of
% a grain
%
%% Input
%  grains - @Grain2d
%
%% Output
%  p   - perimeter
%
%% See also
% Grain2d/deltaarea Grain2d/paris Grain2d/equivalentradius

p = 2*pi*equivalentradius(grains);