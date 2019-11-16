function cS = rotate_outer(cS,rot)
% rotate a crystal shape by an rotation or orientation
%
% Syntax
%
%    cS = rotate_outer(cS,rot)
%    cS = ori * cS
%
% Input
%  cS - @crystalShape
%  rot - @rotation
%  ori - @orientation
%
% Output
%  cS - @crystalShape

if size(cS.V,2) > 1, error('Not yet supported'); end

% duplicate the faces
shift = length(cS.V) * repmat((0:length(rot)-1),size(cS.F,1),1);
shift = repmat(shift(:),1,size(cS.F,2));

% shift faces indices
cS.F = repmat(cS.F,length(rot),1) + shift;
  
cS.V = (rotation(rot) * cS.V).';

end