function sVF = rdivide(sVF, sF2)
% divide a spherical vector field pointwise by a function or a number
%
% Syntax
%
%   sVF = sVF ./ sF   % the field divided by the values of sF at the vertices
%   sVF = sVF ./ a    % the field divided by the number a
%
% Input
%  sVF - @S2VectorFieldTri
%  sF  - @S2FunTri on the same triangulation
%  a   - double
%
% Output
%  sVF - @S2VectorFieldTri
%

if isnumeric(sF2)
  sVF.values = sVF.values ./ sF2;
else
  sVF.values = sVF.values ./ sF2.values;
end

end
