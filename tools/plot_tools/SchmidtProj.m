function [x,y] = SchmidtProj(theta,rho)
% Schmidt projection
%% Input
%  theta, rho - double
%  v          - @vector3d
%% Output
%  x, y 

if nargin == 1, [theta,rho] = vec2sph(theta);end

ind = find(theta > pi/2+10^(-10));
theta(ind)  = pi - theta(ind);
rho(ind) = pi + rho(ind);

x = cos(rho) .* sqrt(2*(1-cos(theta)));
y = sin(rho) .* sqrt(2*(1-cos(theta)));
