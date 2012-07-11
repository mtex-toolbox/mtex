function bl = borderlength( p ,varargin)
% returns the borderlength of grain-polygon
%
%% Input
%  grains - @grain / @polygon
%
%% Output
%  bl   - borderlength
%
%% Options
%  COUNT - return number of border elements
%
%% See also
% polygon/perimeter

p = polygon( p );

bordersize = @(Vertices) sum(sqrt(sum(diff(Vertices).^2,2)));

nc = length(p);
bl = zeros(size(p));

pVertices = {p.Vertices};
if check_option(varargin,'count');  
  bl = cellfun('length',pVertices);
else
  hole = hashole(p);
  for k=1:nc
    Vertices = pVertices{k};
    
    bl(k) = bordersize(Vertices);
    
    if hole(k)
      bl(k) = bl(k) + sum(borderlength(p(k).Holes));
    end
  end
end
