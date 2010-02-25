function h = hashole(p)
% returns whether a polygon has holes or not
%
%% Input
%  p - @grain / @polygon
%
%% Output
%  h  - logical indexing
%

p = polygon(p);
h = ~cellfun('isempty',{p.holes});