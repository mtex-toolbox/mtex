function sVF = mtimes(sVF1, sVF2)
% scalar multiplication of a vector field
%
% Syntax
%
%   sVF = a * sVF1 % vector field scaled by a number
%   sVF = sVF1 * a % the same
%
% Input
%  sVF1 - @S2VectorFieldHarmonic
%  a - double
%
% Output
%  sVF - @S2VectorFieldHarmonic
%

if isnumeric(sVF1)
  sVF = sVF2;
  sVF.sF = sVF.sF.*sVF1;
elseif isnumeric(sVF2)
  sVF = sVF1;
  sVF.sF = sVF.sF.*sVF2;
end

end
