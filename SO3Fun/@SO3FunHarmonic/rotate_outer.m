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
  elseif numSym(SO3F.CS.Laue)>2 && ~all(any(rot(:).' == SO3F.CS.rot(:)))
    warning('Rotating an ODF with crystal symmetry will remove the crystal symmetry')
    SO3F.CS = crystalSymmetry;
  end
  
else
  if isa(rot,'orientation') 
    assert(rot.CS == SO3F.SS,'symmetry missmatch');
    SO3F.SS = rot.SS;
  elseif numSym(SO3F.SS.Laue)>2 && ~all(any(rot(:).' == SO3F.SS.rot(:)))
    warning('Rotating an ODF with specimen symmetry will remove the specimen symmetry')
    SO3F.SS = specimenSymmetry;
  end
end

L = SO3F.bandwidth;
D = conj(WignerD(inv(rot),'bandwidth',L));
D = reshape(D,[],length(rot));
G = conv(SO3F,sqrt(2*(0:L)+1).');

if check_option(varargin,'right')  
  SO3F.fhat = convSO3(G.fhat,D);  
else
  SO3F.fhat = convSO3(D,G.fhat);
end

end
