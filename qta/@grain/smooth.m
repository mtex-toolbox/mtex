function grains = smooth(grains,iter,mpower)
% routine smoothes grains
%

if nargin < 2
  iter = 1;
end

if nargin < 3
  mpower = 0;
end



geom = polytope(grains);

hasSub = hasSubBoundary(grains);
if any(hasSub)
  subBndry = get(grains(hasSub),'subfractions');
  subBndryP = [subBndry.P];
  subBndrySZ = numel(grains) + [0 cumsum(cellfun('prodofsize',{subBndry.P}))];
  geom = [geom subBndryP];
end

allBndry = smooth(geom,iter,mpower);
allBndry = polytope(allBndry);

for k=1:numel(grains)
  grains(k).polytope = allBndry(k);
  if hasSub(k)
    i = sum(hasSub(1:k));
    grains(k).subfractions.P =  allBndry(subBndrySZ(i)+1:subBndrySZ(i+1));
  end
end
