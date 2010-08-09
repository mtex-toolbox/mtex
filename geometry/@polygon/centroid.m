function cxy = centroid( p ,varargin)
% calculates the barycenter of the grain-polygon, without respect to holes
%
%% Input
%  p - @grain / @polygon
%
%% Output
%  cxy   - center [x y];
%
%% Options
%  HULL
%

p = polygon( p );

nc = length(p);
cxy = zeros(nc,2);

%without respect to holes
pxy = {p.xy};

for k=1:nc
  xy = pxy{k};  
  
  sel = ':';
  if check_option(varargin,'hull')
     sel = convhull(xy(:,1),xy(:,2));
  end  
  x = xy(sel,1);
  y = xy(sel,2);

  cr = x(1:end-1).*y(2:end)-x(2:end).*y(1:end-1);

  A = 1/2 * sum(cr);

  cx = sum((x(1:end-1)+x(2:end)).* cr) / (6*A);
  cy = sum((y(1:end-1)+y(2:end)).* cr) / (6*A);
  
  cxy(k,:) =[cx cy];
end
