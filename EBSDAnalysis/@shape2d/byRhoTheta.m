function  shape = byRhoTheta(rho,theta)
% define shape2d by polar angles
%
% Syntax
%   v = shape2d.byRhoTheta(rho,theta)
%
% Input
%  rho   - radius
%  theta - angle to the x axis when projected into the x/y plane in radiant
%
% Output
%  shape - @shape2d
%
% Example
%  mtexdata forsterite silent
%  grains = calcGrains(ebsd('indexed'));
%  omega = [0:360]*degree;
%  cumpf = surfor(grains.boundary('f','f'),omega);
%  shape = shape2d.byRhoTheta(cumpf, omega)
%  plot(shape)
%
rho = reshape(rho,[],1);
theta = reshape(theta,[],1);

shape = shape2d([cos(theta) .* rho sin(theta) .* rho]);

end
