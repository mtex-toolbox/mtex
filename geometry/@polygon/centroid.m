function cVertices = centroid( p ,varargin)
% calculates the barycenter of the grain-polygon, without respect to Holes
%
%% Input
%  p - @grain / @polygon
%
%% Output
%  cVertices   - center [x y];
%
%% Options
%  HULL
%

p = polygon( p );

nc = length(p);
cVertices = zeros(nc,2);

%without respect to Holes
pVertices = {p.Vertices};

for k=1:nc
  Vertices = pVertices{k};  
  
  sel = ':';
  if check_option(varargin,'hull')
     sel = convhull(Vertices(:,1),Vertices(:,2));
  end  
  x = Vertices(sel,1);
  y = Vertices(sel,2);

  cr = x(1:end-1).*y(2:end)-x(2:end).*y(1:end-1);

  A = 1/2 * sum(cr);

  cx = sum((x(1:end-1)+x(2:end)).* cr) / (6*A);
  cy = sum((y(1:end-1)+y(2:end)).* cr) / (6*A);
  
  cVertices(k,:) =[cx cy];
end
