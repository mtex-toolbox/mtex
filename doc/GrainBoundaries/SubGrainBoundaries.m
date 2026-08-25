%% Subgrain Boundaries
%
%%
% A grain boundary of a few degrees is a different object from one of fifty.
% Below about 15 degrees a boundary is still an array of individual
% dislocations, and its energy and structure change with the misorientation;
% above it the dislocation cores overlap and the properties stop depending
% on the misorientation, apart from a few
% <CSLBoundaries.html special orientations> of markedly lower energy.
%
% Those low angle boundaries are the subgrain boundaries, and they sit
% inside grains rather than between them. They are how deformation is stored
% in a material, which is why one wants to see them, count them and measure
% their density.

% load some test data
mtexdata ferrite silent

%%
% A reconstruction with a single threshold has to choose: at 10 degrees the
% subgrain boundaries are invisible, at 1 degree every grain falls apart.
% Two thresholds do both at once - the second separates grains, the first
% marks boundaries within them.

[grains,ebsd] = calcGrains(ebsd,'threshold',[1*degree, 10*degree],'minPixel',5);

% lets smooth the grain boundaries a bit
grains = smoothBoundary(grains,5)

%%
% The display counts both: 15738 boundary segments between grains, and 31037
% inner boundary segments within them - twice as many. Drawing the
% second kind with a transparency that follows its misorientation angle
% keeps the strongest walls visible and lets the weakest fade out.

% plot the ebsd data
plot(ebsd('indexed'),ebsd('indexed').orientations,'faceAlpha',0.5,'figSize','large')

% init override mode
hold on

% plot grain boundaries
plot(grains.boundary,'linewidth',2)

% compute transparency from misorientation angle
alpha = grains.innerBoundary.misorientation.angle / (5*degree);

% plot the subgrain boundaries
plot(grains.innerBoundary,'linewidth',1.5,'edgeAlpha',alpha,'linecolor','b');

% stop override mode
hold off

%%
% The subgrain boundaries are not spread evenly. Some grains are cut through
% by strong walls, others are almost free of them, and the difference is a
% difference in how much those grains deformed.

%% How much subgrain boundary a grain contains
%
% <grain2d.subBoundarySize.html |subBoundarySize|> counts the inner boundary
% segments of each grain. Divided by the number of pixels of the grain it
% becomes a density that can be compared between grains of different size.

plot(grains, grains.subBoundarySize ./ grains.numPixel)
mtexColorbar

%%
% The same in physical units rather than in counts:
% <grain2d.subBoundaryLength.html |subBoundaryLength|> is the total length
% of those segments, and dividing by <grain2d.area.html |area|> gives a
% length per area, in inverse µm.

plot(grains, grains.subBoundaryLength ./ grains.area)
mtexColorbar

%%
% The two maps single out the same grains, as they should - one is a count
% of segments and the other their length, and on a regular grid the two are
% nearly proportional. The second is the one to report, since it does not
% change when the step size does.

%% The misorientations of the subgrain boundaries
%
% Being dislocation walls, subgrain boundaries rotate the lattice about the
% line directions of the dislocations that build them. So their
% misorientation axes are not arbitrary.

% extract all subgrain boundary misorientation
mori = grains.innerBoundary.misorientation;

% and visualize the distribution of the misorientation axes
plot(mori.axis,'fundamentalRegion','contourf','figSize','small')

mtexColorbar

%%
% Not here, though: over the whole fundamental sector the density stays
% between 0.8 and 1.2, which is as good as uniform. This ferrite has no
% preferred subgrain rotation axis, and that is a result rather than a
% failure - compare the forsterite of
% <TiltAndTwistBoundaries.html Tilt and Twist Boundaries>, where two axes
% stand out clearly. That page also shows the same axes in specimen
% coordinates.

%% Networks and isolated segments
%
% A wall that crosses a whole grain and a handful of segments that happen to
% exceed one degree are both subgrain boundaries by the threshold, and they
% mean very different things. |componentSize| tells them apart: it gives,
% for each segment, the size of the connected group it belongs to.
%
% Here everything in a network of more than 50 segments is drawn blue and
% everything else red.

% plot the ebsd data
plot(ebsd('indexed'),ebsd('indexed').orientations,'faceAlpha',0.5,'figSize','large')

% distinguish between large connected networks and single segments
ind = grains.innerBoundary.componentSize > 50;

% plot the boundaries
hold on
plot(grains.boundary,'linewidth',2)
plot(grains.innerBoundary(ind),'linewidth',1.5,'edgeAlpha',alpha(ind),'edgeColor','b');
plot(grains.innerBoundary(~ind),'linewidth',1.5,'edgeAlpha',alpha(~ind),'edgeColor','r');
hold off

%%
% Only 31 percent of the inner boundary segments belong to such a network.
% The blue ones are structures - continuous walls running across a grain,
% often meeting the grain boundary at both ends. The red is largely
% orientation noise crossing the one degree threshold here and there. Both
% are counted by the density maps above, and that is worth remembering
% before reading much into a small difference between two grains.
