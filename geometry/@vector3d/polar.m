function [theta,rho,r] = polar(v)
% Cartesian to spherical coordinates
%
% Syntax
%
%   [theta,rho,r] = polar(v)
%
% Input
%  v - @vector3d
%
% Output
%  theta  - polar angle
%  rho    - azimuthal angle 
%  r      - radius

if v.isNormalized
  r = 1;
else
  r = sqrt(v.x.^2 + v.y.^2 + v.z.^2);
end

if isfield(v.opt,'theta')
  theta = v.opt.theta;
  rho = v.opt.rho;
else
  %rho = mod(atan2(v.y,v.x),2*pi);
  % the next two lines do exactly the same but are a bit faster
  rho = atan2(v.y,v.x);
  rho = rho + (rho<0)*2*pi;

  % the cosine has to be clamped: rotating a normalized vector, or dividing
  % by a norm computed from the very same coordinates, may land a hair
  % outside [-1,1] - acos then returns a complex angle with an imaginary
  % part of about 1e-8, which is small enough to survive unnoticed through
  % any arithmetic downstream and only surfaces much later, e.g. as
  % "Complex values are not supported" out of image() when an interpolated
  % ipf color is handed to a map plot
  if v.isNormalized
    theta = acos(max(-1,min(1,v.z)));
  else
    theta = acos(max(-1,min(1,v.z./r)));
  end
end

if nargout == 0
  rho =  mod(rho(:).'./degree,360);
  theta = theta(:).'./degree;
  cprintf([theta;rho],'-n',' %3.1f','-Lr',{'polar angle ','azimuthal angle '},'-dt',mtexdegchar,'-T',mtexdegchar);
  clear rho, clear theta
end
