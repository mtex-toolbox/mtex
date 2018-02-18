function sVF1 = rdivide(sVF1, sVF2)
%
% Syntax
%
%   sVF = sVF ./ a
%   sVF = sVF ./ sF
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
