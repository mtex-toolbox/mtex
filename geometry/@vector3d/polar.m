function [theta,rho,r] = polar(v)
% cartesian to spherical coordinates
%% Input
%  v - @vector3d
%% Output
%  theta  - polar angle
%  rho    - azimuthal angle 
%  r      - radius

if nargout == 0
  hr = sqrt(v.x.^2 + v.y.^2 + v.z.^2);
  hrho =  reshape(atan2(v.y,v.x),1,[])/degree;
  htheta = reshape(acos(v.z./hr),1,[])/degree;
  cprintf([htheta;hrho],'-n',' %3.1f','-Lr',{'polar angle ','azimuthal angle '},'-dt',mtexdegchar,'-T',mtexdegchar);
else
  r = sqrt(v.x.^2 + v.y.^2 + v.z.^2);
  rho = atan2(v.y,v.x);
  theta = acos(v.z./r);
end
