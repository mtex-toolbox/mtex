function [x,y] = edistProj(theta,rho)
% equal distance projection
%
%% Input
%  theta, rho - double
%  v          - @vector3d
%
%% Output
%  x, y       - double

if nargin == 1, [theta,rho] = polar(theta);end

ind = find(theta > pi/2+10^(-10));
theta(ind)  = pi - theta(ind);
rho(ind) = pi + rho(ind);

x = cos(rho) .* theta;
y = sin(rho) .* theta;
