function v = mean(sVF)
% mean of a spherical vector field
%
% Syntax
%
%   v = mean(sVF)
%
% Input
%  sVF - @S2VectorFieldHarmonic
%
% Output
%  v - @vector3d, the zeroth harmonic coefficient of the components x, y, z

v = vector3d(sVF.sF.fhat(1, :));

end
