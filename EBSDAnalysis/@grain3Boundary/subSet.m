function gB = subSet(gB,ind)
% restrict 3d boundary
%
% Input
%  gB  - @grain3Boundary
%  ind - indices
%
% Output
%  gB - @grain3Boundary
%

gB.I_CF = gB.I_CF(ind,:);

notempty = any(gB.I_CF);
gB.I_CF(:,~notempty) = [];

gB.poly = gB.poly(notempty);

stillNeededVs = unique([gB.poly{:}]);
gB.V = gB.V(stillNeededVs,:);

%inefficient - still work needed
%{
for i=1:length(gB.poly)
  Ply=gB.poly{i};
  for j=1:length(Ply)
    Ply(j) = find(stillNeededVs==Ply(j));
  end
  gB.poly{i}=Ply;
end
%}

gB.poly = cellfun(@(Ply) {arrayfun(@(x) find(stillNeededVs==x),Ply)},gB.poly);
end