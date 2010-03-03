function [x,y,z] = sph2vec(theta,rho,r)
% spheriacl to cartesian coordiantes
%
% transforms spherical into cartesian coordiantes
%
%% Syntax
% v = sph2vec(theta,rho)
% v = sph2vec(theta,rho,r)
% [x,y,z] = sph2vec(theta,rho,r)
%
%% Input
%  theta, rho - spherical coordinates in radians
%  r          - radius
%
%% Output
%  v     - @vector3d 
%  x,y,z - double

if nargin ==2, r = 1;end

if nargout == 3
  x = r.*sin(theta).*cos(rho);
  y = r.*sin(theta).*sin(rho);
  z = r.*cos(theta);
else
  x = vector3d(r.*cos(rho).*sin(theta),r.*sin(rho).*sin(theta),r.*cos(theta));
end

