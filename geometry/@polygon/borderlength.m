function bl = borderlength( p ,varargin)
% returns the borderlength of grain-polygon
%
%% Input
%  grains - @grain
%
%% Output
%  bl   - borderlength
%% Options
%  COUNT - return number of border elements

p = polygon( p );

bordersize = @(xy) sum(sqrt(sum(diff(xy).^2,2)));

nc = length(p);
bl = zeros(size(p));

pxy = {p.xy};
if check_option(varargin,'count');  
  bl = cellfun('length',pxy);
else
  hole = hashole(p);
  for k=1:nc
    xy = pxy{k};
    
    bl(k) = bordersize(xy);
    
    if hole(k)
      bl(k) = bl(k) + sum(borderlength(p(k).holes));
    end
  end
end
