function grains = smooth(grains,iter)
% routine smoothes grains
%

if nargin < 2
  iter = 1;
end

hasHole = hasSubBoundary(grains);
subBndry = get(grains(hasHole),'subfractions');
subBndryP = [subBndry.P];
subBndrySZ = numel(grains) + [0 cumsum(cellfun('prodofsize',{subBndry.P}))];

allBndry = smooth([polytope(grains),subBndryP],iter);
allBndry = polytope(allBndry);

for k=1:numel(grains)
  grains(k).polytope = allBndry(k);
  if hasHole(k)
    i = sum(hasHole(1:k));
    grains(k).subfractions.P =  allBndry(subBndrySZ(i)+1:subBndrySZ(i+1));
  end
end
