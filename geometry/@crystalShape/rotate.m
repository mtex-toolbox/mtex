function cS = rotate(cS,rot)
% rotate a crystal shape by an rotation or orientation
%
% Syntax
%
%    cS = rotate(cS,rot)
%    cS = ori .* cS
%
% Input
%  cS - @crystalShape
%  rot - @rotation
%  ori - @orientation
%
% Output
%  cS - @crystalShape
%

if length(rot)>1 && size(cS.V,2)==1
  cS = rotate_outer(cS,rot);
  return
end

% rotate all the vertices
for k = 1:size(cS.V,1)
  cS.V(k,:) = rot .* cS.V(k,:);
end
