function ebsd = project2FundamentalRegion(ebsd,grains)
%

rot = ebsd.rotations;
grainId = ebsd.grainId;

CS = ebsd.CSList;
isIndexed = grains.isIndexed;

for i = 1:length(grains)
  
  id = grainId == grains.id(i);
  
  if nnz(id) < 2 || ~isIndexed(i), continue; end
  
  rot(id) = project2FundamentalRegion(rot(id),CS{grains.phaseId(i)},grains.meanRotation(i));
  
end
  
ebsd.rotations = rot; 
