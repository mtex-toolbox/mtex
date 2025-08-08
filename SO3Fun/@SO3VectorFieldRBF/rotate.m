function SO3VF = rotate(SO3VF, q,varargin)
% rotate a SO3 vector field by one rotation
%
% Syntax
%   SO3VF = rotate(SO3VF,rot)
%   SO3VF = rotate(SO3VF,rot,'right')
%
% Input
%  SO3VF - @SO3VectorFieldRBF
%  rot   - @rotation
%
% Output
%  SO3VF - @SO3VectorFieldRBF
%
% See also
% SO3VectorFieldHandle/rotate

if check_option(varargin,'right')
  cs = SO3VF.hiddenCS;
  if length(cs.rot)>2 && ~any(q == cs.rot(:))
    warning('Rotating an SO3VectorField with crystal symmetry will remove the crystal symmetry')
    SO3VF.hiddenCS = ID1(cs);
  end
else
  ss = SO3VF.hiddenSS;
  if length(ss.rot)>2 && ~any(q == ss.rot(:))
    warning('Rotating an SO3VectorField with specimen symmetry will remove the specimen symmetry')
    SO3VF.hiddenSS = ID1(ss);
  end
end


SO3VF.SO3F = rotate(SO3VF.SO3F, q,varargin{:});


end
