function SO3VF = rotate(SO3VF, rot,varargin)
% rotate a SO3 vector field by one rotation
%
% Syntax
%   SO3VF = rotate(SO3VF,rot)
%   SO3VF = rotate(SO3VF,rot,'right')
%
% Input
%  SO3VF - @SO3VectorFieldHarmonic
%  rot   - @rotation
%
% Output
%  SO3VF - @SO3VectorFieldHarmonic
%
% See also
% SO3VectorFieldHandle/rotate

if check_option(varargin,'right')
  cs = SO3VF.CS.rot;
  if length(cs)>2 && ~any(rot == cs(:))
    warning('Rotating an SO3VectorField with crystal symmetry will remove the crystal symmetry')
    SO3VF.CS = crystalSymmetry;
  end
else
  ss = SO3VF.SS.rot;
  if length(ss)>2 && ~any(rot == ss(:))
    warning('Rotating an SO3VectorField with specimen symmetry will remove the specimen symmetry')
    SO3VF.SS = specimenSymmetry;
  end
end


SO3VF.SO3F = rotate(SO3VF.SO3F, rot,varargin{:});


end
