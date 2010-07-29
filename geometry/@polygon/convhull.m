function [p v]= convhull(p,varargin)
% calculate the convex hull of polygons
%
%% Input
%  p - @grain / @polygon

%% Options
%  p - @polygon
%
%

p = polygon(p);
pVertices = {p.Vertices};
v = zeros(size(p));
for k=1:length(p)
  [ind v(k)]= convhulln(pVertices{k});
  ind = ind([1:end 1],1);
  p(k).Vertices = pVertices{k}(ind,:);
end

