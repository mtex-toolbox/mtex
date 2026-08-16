function SO3F = rotate_outer(SO3F,rot,varargin)
% rotate function on SO(3) by multiple rotations
%
% Syntax
%   SO3F = rotate(SO3F,rot)
%   SO3F = rotate(SO3F,rot,'right')
%
% Input
%  SO3F - @SO3FunHarmonic
%  rot  - @rotation
%
% Output
%  SO3F - @SO3FunHarmonic
%
% See also
% SO3FunHandle/rotate_outer

if check_option(varargin,'right')
  
  if isa(rot,'orientation') 
    assert(rot.SS == SO3F.CS,'symmetry missmatch');
    SO3F.CS = rot.CS;
  else
  SO3F.CS = dropSymmetry(SO3F.CS,rot,'crystal','ODF');
  end
  
else
  if isa(rot,'orientation') 
    assert(rot.CS == SO3F.SS,'symmetry missmatch');
    SO3F.SS = rot.SS;
  else
  SO3F.SS = dropSymmetry(SO3F.SS,rot,'specimen','ODF');
  end
end

L = SO3F.bandwidth;
D = conj(WignerD(rot,'bandwidth',L,'normalize'));
D = reshape(D,[],length(rot));

if check_option(varargin,'right')  
  SO3F.fhat = convSO3(SO3F.fhat,D);  
else
  SO3F.fhat = convSO3(D,SO3F.fhat);
end

end
