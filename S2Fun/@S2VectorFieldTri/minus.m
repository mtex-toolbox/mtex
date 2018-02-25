function sVF1 = minus(sVF1, sVF2)
%
% Syntax
%   sVF = sVF1 - sVF2
%   sVF = sVF - v
%
% Input
%  sVF1 - @S2VectorFieldTri
%  sVF2 - @S2VectorField
%  v    - @vector3d
%
% Output
%  sF - @S2FunTri
%

sVF1 = sVF1 + (-sVF2);
