



cs = crystalSymmetry('1','mineral','test');


id = [...
  0 0 0 0 0 0; ...
  0 1 1 1 1 0; ...
  0 1 1 1 1 0; ...
  0 1 0 0 1 0; ...
  0 1 0 0 1 0; ...
  0 1 1 1 0 0; ...
  0 0 0 0 0 0]==1;

rot = rotation.id(size(id));

rot(id) = rotation.rand;


ebsd = EBSDsquare(rot,2*ones(size(rot)),1:2,{'not indexed',cs},[1 1]);

%%

plot(ebsd,ebsd.orientations)

%%

grains = calcGrains(ebsd,'removeQuadruplePoints')

%%

gB = grains.boundary
grains = merge(grains,gB(end),'calcMeanOrientation')

%%

grains = smooth(grains,1,'moveTriplePoints')

%%

plot(grains.boundary)

%%

id = 2;
gB = grains(id).boundary;

plot(gB,gB.curvature(10),'linewidth',6)

mtexColorMap blue2red
setColorRange(0.5*[-1,1])