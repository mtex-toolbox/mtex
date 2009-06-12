function [grains ind] = inpolygon(grains, xy, method)
% select all grains in a given region
%% Syntax
%  grains = inpolygon(grains,[x y])
% 
%% Input
%  grains - @SO3Grid
%  [x y]  - polygon coordinates
%
%% Option
%  method - 'complete' (default), 'centroids', 'intersect'
%
%% Output
%  grains - @grains
%  ind    - indices
%

if nargin < 3
  method = 'complete';
end

if size(xy,2) ~= 2 %dimension check
  xy = xy';
end
switch lower(method)
  case 'complete'
    ind = in_it(grains,xy,@all);
  case 'centroids'  
    pxy = centroid(grains);
    ind = inpolygon(pxy(:,1),pxy(:,2),xy(:,1),xy(:,2));
  case 'intersect'
    ind = in_it(grains,xy,@any);
end
grains = grains(ind);


function ind = in_it(grains,xy,modifier)

p = polygon(grains)';
np = cellfun('length',{p.xy});
pxy = vertcat(p.xy);
    
in = inpolygon(pxy(:,1),pxy(:,2),xy(:,1),xy(:,2));

ind = cellfun(modifier,mat2cell(in, np,1));