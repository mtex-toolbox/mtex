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

gB3.poly = gB3.poly(ind);
gB3.id = gB3.id(ind);
gB3.grainId = gB3.grainId(ind,:);
gB3.phaseId = gB3.phaseId(ind,:);

gB3.idV = intersect(gB3.idV,unique([gB3.poly{:}]));

% properties
gB3 = subSet@dynProp(gB3,ind);

end