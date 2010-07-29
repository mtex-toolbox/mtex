function h = hashole(p)
% returns whether a polygon has Holes or not
%
%% Input
%  p - @grain / @polygon
%
%% Output
%  h  - logical indexing
%

p = polygon(p);
h = ~cellfun('isempty',{p.Holes});