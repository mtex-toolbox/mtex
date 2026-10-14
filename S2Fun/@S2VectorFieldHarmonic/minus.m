function sVF = minus(sVF1, sVF2)
% subtract spherical vector fields
%
% Syntax
%
%   sVF = sVF1 - sVF2   % the difference of two vector fields
%   sVF = a - sVF1      % a constant minus the field
%   sVF = sVF1 - a      % the field minus a constant
%
% Input
%  sVF1, sVF2 - @S2VectorFieldHarmonic
%  a          - @vector3d, a constant field
%
% Output
%  sVF - @S2VectorFieldHarmonic
%

sVF = plus(sVF1, -sVF2);

end
