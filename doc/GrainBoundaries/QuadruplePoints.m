%% Quadruple Points
%%
%
% On a square grid four pixels meet in every interior vertex. If the two
% pixels on one diagonal belong to one grain and the two pixels on the
% other diagonal belong to a different grain, that vertex is a *quadruple
% point*: four boundary segments emanate from it and the boundary network
% is ambiguous there. Depending on which of the two grains is considered
% connected across the vertex one obtains a different number of grains.
% Since real grain boundary networks practically never contain quadruple
% points, MTEX offers the option |'removeQuadruplePoints'| to
% <EBSD.calcGrains.html |calcGrains|>, which splits every such vertex into
% two triple points.
%
%% A minimal example
%
% Let us construct a small artificial map. The pixels marked by |1| form a
% ring which touches itself diagonally in its lower left corner.

cs = crystalSymmetry('1','mineral','test');

id = [...
  0 0 0 0 0 0; ...
  0 1 1 1 1 0; ...
  0 1 1 1 1 0; ...
  0 1 0 0 1 0; ...
  0 1 0 0 1 0; ...
  0 1 1 1 0 0; ...
  0 0 0 0 0 0]==1;

%%
% All pixels of the ring get one common orientation, all remaining pixels
% get the identity

rot = rotation.id(size(id));
rot(id) = rotation.byEuler(130*degree,120*degree,110*degree);

ebsd = EBSDsquare([],rot,2*ones(size(rot)),1:2,{'not indexed',cs},'dxy',[1 1])

%%

plot(ebsd,ebsd.orientations)

%% Grain reconstruction with quadruple points
%
% Reconstructing grains in the usual way the interior of the ring is cut
% off from the exterior at the diagonal contact, and we end up with three
% grains instead of two

grains = calcGrains(ebsd)

%%

plot(grains,grains.meanOrientation)
hold on
plot(grains.boundary,'lineWidth',2)
hold off

%% Removing the quadruple points
%
% The option |'removeQuadruplePoints'| splits the ambiguous vertex into two
% triple points and keeps the two like oriented pixels connected. Now we
% obtain the expected two grains

grains = calcGrains(ebsd,'removeQuadruplePoints')

%%

plot(grains,grains.meanOrientation)
hold on
plot(grains.boundary,'lineWidth',2)
hold off

%%
% Note that the total boundary length is unchanged - only the connectivity
% at the critical vertex is different.

%% Smoothing at the critical vertex
%
% The two triple points that replace the quadruple point sit on top of each
% other. Smoothing the boundary with the option |'moveTriplePoints'| pulls
% them apart

grains = smoothBoundary(grains,taubinFilter,'moveTriplePoints');

plot(grains,grains.meanOrientation, 'lineWidth',2)

%%
% and the <grainBoundary.curvature.html curvature> of the smoothed boundary
% shows the pinch as a pair of opposite extrema

gB = grains(1).boundary;

plot(gB,gB.curvature(10),'linewidth',6)
mtexColorMap blue2red
setColorRange(0.5*[-1,1])
mtexColorbar
