function cxy = centroid(grains,varargin)
% calculates the barycenter of the grain-polygon, without respect to holes
%
%% Input
%  grains - @grain
%
%% Output
%  cxy   - center [x y];
%
%% Options
%  HULL
%

nc = length(grains);
cxy = zeros(nc,2);

%without respect to holes
p = polygon(grains);
for k=1:nc
  xy = p(k).xy;  
  
  sel = ':';
  if check_option(varargin,'hull')
     K = convhulln(xy);
     sel = [K(:,1); K(1,1)];
  end  
  x = xy(sel,1);
  y = xy(sel,2);

  l = length(x);

  cr = x(1:l-1).*y(2:l)-x(2:l).*y(1:l-1);

  A = 1/2 * sum(cr);

  cx = sum((x(1:l-1)+x(2:l)).* cr) / (6*A);
  cy = sum((y(1:l-1)+y(2:l)).* cr) / (6*A);
  
  cxy(k,:) =[cx cy];
end
