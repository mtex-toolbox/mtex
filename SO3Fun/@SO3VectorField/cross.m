function SO3VF = cross(SO3VF1, SO3VF2, varargin)
% pointwise cross product
%
% Syntax
%   SO3VF = cross(SO3VF1, SO3VF2)
%   SO3VF = cross(v, SO3VF2)
%   SO3VF = cross(SO3VF1, v)
%
% Input
%   SO3VF1, SO3VF2 - @SO3VectorField
%   v - @vector3d
%
% Output
%   SO3VF - @SO3VectorField
%

if isa(SO3VF2, 'vector3d') && isscalar(SO3VF2)
  ensureCompatibleTangentSpaces(SO3VF1,SO3VF2);
  SO3VF = SO3VectorFieldHandle(@(rot) cross(SO3VF1.eval(rot),SO3VF2),SO3VF1.CS,SO3VF1.SS,SO3VF1.tangentSpace);
  if SO3VF2.antipodal
    SO3VF = abs(SO3VF);
  end
  return
end

if isa(SO3VF1, 'vector3d')
  SO3VF = -cross(SO3VF2,SO3VF1);
  return
end

ensureCompatibleSymmetries(SO3VF1,SO3VF2)
SO3VF = SO3VectorFieldHandle(@(rot) cross(SO3VF1.eval(rot),SO3VF2.eval(rot)),SO3VF1.CS,SO3VF1.SS,SO3VF1.tangentSpace);

end