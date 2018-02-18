function [V,E] = eig(sF)
% eigen value of a spherical function
%
% Syntax
%   [V,E] = eig(sF)
%
% Input
%  sF - @S2FunHarmonic
%
% Output
%  V - eigen @vector3d
%  E - eigen values
%

M = @(v) [v.x.^2 v.x.*v.y v.x.*v.z v.y.^2 v.y.*v.z v.z.^2];

sFM = S2FunHarmonic.quadrature(M,'bandwidth',2);

M = real(dot(sF,sFM));
M = reshape(M([1 2 3 2 4 5 3 5 6]),3,3);

[V,E] = eig(M,'vector');

E = flipud(E);
V = fliplr(vector3d(V)).';

end
