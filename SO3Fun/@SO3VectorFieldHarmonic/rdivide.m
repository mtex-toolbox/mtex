function SO3VF1 = rdivide(SO3VF1, SO3VF2)
%
% Syntax
%
%   SO3VF = SO3VF ./ a
%   SO3VF = SO3VF ./ sF
%
% Input
%  SO3VF - @SO3VectorFieldHarmonic
%  sF  - @SO3Fun
%  a   - double
%
% Output
%  SO3VF - @S2VectorFieldHarmonic
%

if isnumeric(SO3VF2)
  SO3VF1.SO3F = SO3VF1.SO3F .* (1./SO3VF2);
elseif isa(SO3VF2,'SO3Fun')
  SO3VF1.SO3F = SO3VF1.SO3F ./ SO3VF2;
end

end
