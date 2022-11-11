function SO3VF = times(SO3VF1,SO3VF2)
%
% Syntax
%   sVF = sVF1 .* sVF2
%   sVF = a .* sVF1
%   sVF = sVF1 .* a
%

if isnumeric(SO3VF1) || isa(SO3VF1,'SO3Fun')
  SO3VF = SO3VF2;
  SO3VF.SO3F = SO3VF.SO3F.*SO3VF1;
  return
end
if isnumeric(SO3VF2) || isa(SO3VF2,'SO3Fun')
  SO3VF = SO3VF2.*SO3VF1;
  return
end

SO3VF = times@SO3VectorField(SO3VF1,SO3VF2);
SO3VF = SO3VectorFieldHarmonic(SO3VF,'bandwidth', min(getMTEXpref('maxSO3Bandwidth'),SO3VF1.bandwidth + SO3VF2.bandwidth));

end
