function sVF1 = rdivide(sVF1, sVF2)
% divide a spherical vector field pointwise by a function or a number
%
% Syntax
%
%   sVF = sVF ./ a    % the field divided by the number a
%   sVF = sVF ./ sF   % the field divided pointwise by the spherical function sF
%
% Input
%  sVF - @S2VectorFieldHarmonic
%  sF  - @S2Fun
%  a   - double
%
% Output
%  sVF - @S2VectorFieldHarmonic
%

if isnumeric(sVF2)
  sVF1.sF = sVF1.sF .* (1./sVF2);
elseif isa(sVF2,'S2Fun')
  sVF1.sF = sVF1.sF ./ sVF2;
end

end
