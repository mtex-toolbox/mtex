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

stillNeededVs = unique([gB3.poly{:}]);
gB3.V = gB3.V(stillNeededVs,:);

gB3.poly = cellfun(@(Ply) {arrayfun(@(x) find(stillNeededVs==x),Ply)},gB3.poly);

% properties
gB3 = subSet@dynProp(gB3,ind);

end