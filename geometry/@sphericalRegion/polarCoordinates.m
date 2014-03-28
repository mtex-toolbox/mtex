function [r,rho] = polarCoordinates(sR,v,center,varargin)
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

center = center.normalize;
vxcenter = normalize(cross(v,center));

if all(isnull(dot(sR.N,center)))
  r = angle(center,v) ./ pi;
else
  r = zeros(length(v),length(sR.N));
  for i = 1:length(sR.N)
  
    % boundary points
    bc = normalize(cross(vxcenter,sR.N(i)));
    
    % compute distances
    r(:,i) = angle(-v(:),bc(:))./angle(-center,bc(:));
  end
  r(isnan(r)) = 1;
  r = min(r,[],2);
  r(imag(r) ~=0 ) = 0;
end


% the angle
% --------------------------------------------------------------------

% a reference direction for rho = 0
if center == zvector
  rx = xvector - center; 
else
  rx = zvector - center;
end

% make rx orthogonal to center
rx = normalize(rx - dot(rx,center) .* center);

% choose a perpendicular direction
ry = normalize(cross(center,rx)); 

% compute azimuth angle
dv = normalize(v(:) - center); 
rho = mod(atan2(dot(ry,dv),dot(rx,dv)),2*pi);
rho(isnan(rho)) = 0;

ind = isnull(angle(center,sR.vertices));
if any(ind)
  
  alpha = sR.innerAngle;
  rho = mod(rho,alpha(ind)) * 2*pi ./ alpha(ind);
  
end


% some testing code
% 
% sR = fundamentalSector(symmetry('-3m'))
% v = plotS2Grid(sR)
% [r,rho] = polarCoordinates(sR,v,sR.center);
% pcolor(v,r)
% pcolor(v,rho)
