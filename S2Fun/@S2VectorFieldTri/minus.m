function sVF1 = minus(sVF1, sVF2)
% difference of a vector field and a vector field or a direction
%
% Syntax
%
%   sVF = sVF1 - sVF2 % difference of two vector fields
%   sVF = sVF1 - v    % subtract a fixed vector
%
% Input
%  sVF1 - @S2VectorFieldTri
%  sVF2 - @S2VectorField
%  v    - @vector3d
%
% Output
%  sVF - @S2VectorFieldTri
%

sVF1 = sVF1 + (-sVF2);
