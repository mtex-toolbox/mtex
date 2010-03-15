function [x,y] = stereographicProj(theta,rho)
% stereographic projection
%% Input
%  theta, rho - double
%  v          - @vector3d
%% Output
%  x, y 

if nargin == 1, [theta,rho] = polar(theta);end

ind = find(theta > pi/2+10^(-10));
theta(ind)  = pi - theta(ind);
rho(ind) = pi + rho(ind);

x = cos(rho) .* 2 .* tan(theta/2);
y = sin(rho) .* 2 .* tan(theta/2);
