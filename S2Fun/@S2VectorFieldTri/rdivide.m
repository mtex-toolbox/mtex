function sVF = rdivide(sVF, sF2)
%
% Syntax
%   sVF = sVF ./ sF
%   sVF = sVF ./ a
%
% Input
%  sVF - @S2VectorFieldTri
%  sF  - @S2Fun
%  a   - double
%
% Output
%  sF - @S2VectorFieldTri
%

if isnumeric(sF2)
  sVF.values = sVF.values ./ sF2;
else
  sVF.values = sVF.values ./ sF2.values;
end

end
