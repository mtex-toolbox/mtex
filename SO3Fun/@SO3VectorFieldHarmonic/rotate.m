function SO3VF = rotate(SO3VF, q,varargin)
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
% SO3VectorField/rotate SO3VectorFieldHandle/rotate

if check_option(varargin,'right')
  cs = SO3VF.hiddenCS;
  if length(cs.rot)>2 && ~any(q == cs.rot(:))
    warning('Rotating an SO3VectorField with crystal symmetry will remove the crystal symmetry')
    SO3VF.hiddenCS = stripSym(cs);
  end
else
  ss = SO3VF.hiddenSS;
  if length(ss.rot)>2 && ~any(q == ss.rot(:))
    warning('Rotating an SO3VectorField with specimen symmetry will remove the specimen symmetry')
    SO3VF.hiddenSS = stripSym(ss);
  end
end


% rotate the argument of the vector field
SO3VF.SO3F = rotate(SO3VF.SO3F, q,varargin{:});

% rotating the argument is not enough - the coordinates of the tangent
% vectors refer to the frame the tangent space is attached to, and that frame
% is rotated as well whenever the rotation acts from the same side as the
% intern tangent space representation. See SO3VectorField/rotate for the
% derivation.
if check_option(varargin,'right')
  if SO3VF.internTangentSpace.isRight
    SO3VF = rotateTangentCoordinates(SO3VF,inv(q));
  end
elseif SO3VF.internTangentSpace.isLeft
  SO3VF = rotateTangentCoordinates(SO3VF,q);
end

end


function SO3VF = rotateTangentCoordinates(SO3VF,q)
% replace the coordinates (x,y,z) of the tangent vectors by q * (x,y,z),
% which is a linear combination of the three component functions

M = matrix(q);
F = SO3VF.SO3F;

SO3VF.SO3F = [M(1,1)*F(1) + M(1,2)*F(2) + M(1,3)*F(3); ...
              M(2,1)*F(1) + M(2,2)*F(2) + M(2,3)*F(3); ...
              M(3,1)*F(1) + M(3,2)*F(2) + M(3,3)*F(3)];

end
