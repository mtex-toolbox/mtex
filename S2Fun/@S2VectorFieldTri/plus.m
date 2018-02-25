function sVF1 = plus(sVF1, sVF2)
%
% Syntax
%   sVF = sVF1 + sVF2
%   sVF = sVF + v
%
% Input
%  sVF1 - @S2VectorFieldTri
%  sVF2 - @S2VectorField
%  v    - @vector3d
%
% Output
%  sF - @S2FunTri
%

% first should be S2VectorFieldTri
if ~isa(sVF1,'S2VectorFieldTri'), [sVF1,sVF2] = deal(sVF2,sVF1); end

if isa(sVF2,'vector3d')
  sVF1.values = sVF1.values +  a;
elseif isa(sVF2,'S2VectorFieldTri')
  sVF1.values = sVF1.values + sVF2.values;
else
  sVF1.values = sVF1.values + sVF2.eval(SVF.vertices);
end

end
