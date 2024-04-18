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
%   SO3VF - @SO3VectorFieldHarmonic
%

if isa(SO3VF2, 'vector3d') && isscalar(SO3VF2)
  ensureCompatibleTangentSpaces(SO3VF1,SO3VF2);
  xyz = repmat(SO3VF2.xyz,size(SO3VF1.SO3F.fhat,1),1);
  SO3VF = SO3VF1;
  SO3VF.SO3F.fhat = cross(SO3VF1.SO3F.fhat,xyz,2);
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
f = SO3VectorFieldHandle(@(rot) cross(SO3VF1.eval(rot),SO3VF2.eval(rot)),SO3VF1.CS,SO3VF1.SS,SO3VF1.tangentSpace);
SO3VF = SO3VectorFieldHarmonic(f, varargin{:});

end
