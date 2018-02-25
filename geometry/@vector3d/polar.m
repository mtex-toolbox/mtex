function [theta,rho,r] = polar(v)
% cartesian to spherical coordinates
% Input
%  v - @vector3d
% Output
%  theta  - polar angle
%  rho    - azimuthal angle 
%  r      - radius

r = sqrt(v.x.^2 + v.y.^2 + v.z.^2);
if isfield(v.opt,'theta')
  theta = v.opt.theta;
  rho = v.opt.rho;  
else
  %rho = mod(atan2(v.y,v.x),2*pi);
  % the next two lines do exactly the same but are a bit faster
  rho = atan2(v.y,v.x);
  rho = rho + (rho<0)*2*pi;
  
  theta = acos(v.z./r);
end

if nargout == 0
  rho =  mod(rho(:).'./degree,360);
  theta = theta(:).'./degree;
  cprintf([theta;rho],'-n',' %3.1f','-Lr',{'polar angle ','azimuthal angle '},'-dt',mtexdegchar,'-T',mtexdegchar);
  clear rho, clear theta
end
