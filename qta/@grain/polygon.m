function p = polygon(grains)
% returns the polygon of grains as struct
%
%% Input
%  grains - @grain
%
%% Output
%  p.xy    - border 
%  p.hxy   - struct of holes
%

p = [grains.polygon];