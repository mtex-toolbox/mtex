function SO3VF = times(SO3VF1,SO3VF2)
% overloads |SO3VF1 .* SO3VF2|
%
% Syntax
%   SO3VF = SO3VF1 .* SO3VF2
%   SO3VF = a .* SO3VF1
%   SO3VF = SO3VF1 .* a
%   SO3VF = SO3F .* SO3VF1
%   SO3VF = SO3VF1 .* SO3F
%   
% Input
%  SO3VF1, SO3VF2 - @SO3VectorField
%  a - double, @vector3d
%  SO3F - @SO3Fun
%
% Output
%  SO3VF - @SO3VectorField
%

if isa(SO3VF2,'vector3d')
  SO3VF2 = SO3VF2.xyz.';
end

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
