function gB3 = subSet(gB3,ind)
% restrict 3d boundary
%
% Input
%  gB  - @grain3Boundary
%  ind - indices
%
% Output
%  gB - @grain3Boundary
%

gB3.F = gB3.F(ind,:);
gB3.id = gB3.id(ind);
gB3.grainId = gB3.grainId(ind,:);
gB3.phaseId = gB3.phaseId(ind,:);
gB3.misrotation = gB3.misrotation(ind);
if ~isempty(gB3.ebsdId)
  gB3.ebsdId = gB3.ebsdId(ind,:);
end

% properties
gB3 = subSet@dynProp(gB3,ind);

end