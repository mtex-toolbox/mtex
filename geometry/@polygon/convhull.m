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
pxy = {p.xy};
v = zeros(size(p));
for k=1:length(p)
  [ind v(k)]= convhulln(pxy{k});
  ind = ind([1:end 1],1);
  p(k).xy = pxy{k}(ind,:);
end

