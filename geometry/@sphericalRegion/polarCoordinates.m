function [r,rho] = polarCoordinates(sR,v,center,ref,varargin)
% compute polar coordinates of with respect to a spherical region
%
% Input
%  sR - @sphericalRegion
%  v  - @vector3d 
%  center - @vector3d
%
% Output
%  r - relative distance to the center
%  rho - angle with respect to the center

% the radius
% -------------------------------------------------------------------  

v = normalize(vector3d(v));
center = center.normalize;
vxcenter = normalize(cross(v,center));

if all(isnull(dot(sR.N,center)))
  r = angle(center,v) ./ pi;
else
  r = inf(length(v),1);
  for i = 1:length(sR.N)
  
    % boundary points
    bc = normalize(cross(vxcenter,sR.N(i)));
    
    % compute distances
    d = angle(-v,bc)./angle(-center,bc);
    d(isnan(d)) = 1;
    d(imag(d) ~=0 ) = 0;
    r = min(r,d(:));
  end
end

% a reference direction for rho = 0
if center == zvector
  rx = ref - center; 
else
  rx = zvector - center;
end
rho = calcAngle(center,rx,v);

ind = isnull(angle(center,sR.vertices));
if any(ind) % if center is in a vertice
  
  alpha = sR.innerAngle;
  rho = mod(rho,alpha(ind)) * 2*pi ./ alpha(ind);
  
elseif any(isnull(dot(sR.N,center))) % if center is at the boundary
  rho = mod(rho,pi) * 2;

elseif ~isempty(sR.vertices) && get_option(varargin,'maxAngle',inf) == inf
  [irho,omega] = correctAngle(sR,rx);

  rho = interp1(irho,omega,rho);
end
% some testing code
% 
% sR = fundamentalSector(crystalSymmetry('-3m'))
% v = plotS2Grid(sR)
% [r,rho] = polarCoordinates(sR,v,sR.center);
% pcolor(v,r)
% pcolor(v,rho)

end

function [rho,omega] = correctAngle(sR,rx)

rho = linspace(0,2*pi,1000);

v = sR.vertices;
%v = v([1 3 2]);

%n1 = rx - sR.center;
%n1 = normalize(n1 - dot(n1,sR.center) * sR.center);

n1 = normalize(cross(rx,sR.center));

r = rotation.byAxisAngle(sR.center,rho(1:end-1));

n = r * n1;

% compute the distance between the center and any boundary point
omega = min(angle(cross_outer(sR.N,n),sR.center));

% ensure vertices are at 0, 120 and 240 degree
% midpoints
%mp = v + v([2,3,1]);
%mp = mp.normalize;


if length(v) == 3
  
  rho_v = round(1000*sort(calcAngle(sR.center,rx,v))/2/pi);
  if rho_v(1) < 10, rho_v(1) = [];end
  
  ind = 1:rho_v(1)-1;
  omega(ind) = omega(ind) ./ sum(omega(ind)) / 3;
  ind = rho_v(1):rho_v(2)-1;
  omega(ind) = omega(ind) ./ sum(omega(ind)) / 3;
  ind = rho_v(2):length(omega);
  omega(ind) = omega(ind) ./ sum(omega(ind)) / 3;
  
end


omega = 2*pi*cumsum([0,omega./ sum(omega)]);




end
%plot(omega)

function rho = calcAngle(center,rx,v)
% the angle
% --------------------------------------------------------------------

% make rx orthogonal to center
rx = normalize(rx - dot(rx,center) .* center);

% choose a perpendicular direction
ry = normalize(cross(center,rx)); 

% compute azimuth angle
dv = normalize(v(:) - center); 
rho = mod(atan2(dot(ry,dv),dot(rx,dv)),2*pi);
rho(isnan(rho)) = 0;

end
