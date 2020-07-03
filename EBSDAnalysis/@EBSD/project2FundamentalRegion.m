function ebsd = project2FundamentalRegion(ebsd,grains)
%

rot = ebsd.rotations;
grainId = ebsd.grainId;

CS = ebsd.CSList;

for i = 1:length(grains)
  
  id = grainId == grains.id(i);
  
  rot(id) = project2FundamentalRegion(rot(id),CS{grains.phaseId(i)},grains.meanRotation(i));
  
end
  
ebsd.rotations = rot; 
