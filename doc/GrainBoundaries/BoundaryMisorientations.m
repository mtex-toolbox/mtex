%% Misorientations at grain boundaries
%
%%
% The misorientation across a boundary is a rotation, so it has an angle and
% an axis, and the two are read very differently. The angle is a single
% number that can be drawn along the boundary directly. The axis is a
% direction, and which frame it is given in - the crystal or the specimen -
% decides what it can tell you. This page follows one boundary network
% through both, and ends with a trap that catches the axis near large
% misorientation angles.

% take some MTEX data set
plottingConvention.default('y↑→x');
mtexdata forsterite silent

% define a sub region
xmin = 25000;
xmax = 35000;
ymin = 4500;
ymax = 9000;

region = [xmin ymin xmax-xmin ymax-ymin];

% visualize the whole data set
plot(ebsd)
% and mark the sub region
rectangle('position',region,'edgecolor','r','linewidth',2)

% select EBSD data within region
condition = inpolygon(ebsd,region); % select indices by polygon
ebsd = ebsd(condition);

%%
% A few grains are enough here, since the axes will be drawn as arrows and a
% full map of them is unreadable.

% segmentation angle typically 10 to 15 degrees that separates two grains
seg_angle = 10;

% minimum indexed points per grain between 5 and 10
min_points = 10;

% restrict to indexed only points
[grains,ebsd] = calcGrains(ebsd,'angle',seg_angle*degree,'minPixel',min_points);

% smooth grains - ebsdId is read per segment further down, so keep every
% segment between the pair of pixels it was measured from
grains = smoothBoundary(grains,4,'noSimplify','noRefine');

% plot the data
% Note, only the forsterite grains are colored. Grains with different
% phase remain white
plot(grains('fo'),grains('fo').meanOrientation,'micronbar','off','figSize','large')
hold on
plot(grains.boundary)
hold off

%% The misorientation angle along a boundary
%
% One number per segment, so a colorbar does the job. Drawing a thicker
% black line underneath keeps the colours legible where boundaries run close
% together.

% define the linewidth
lw = 6;

% consider on Fo-Fo boundaries
gB = grains.boundary('Fo','Fo');

% visualize the misorientation angle
% draw the boundary in black very thick
hold on
plot(gB,'linewidth',lw+2);

% and on top of it the boundary colorized according to the misorientation
% angle
plot(gB,gB.misorientation.angle./degree,'linewidth',lw);
hold off
mtexColorMap jet
mtexColorbar('title','misorientation angle in degrees')

%%
% The colour is constant along each boundary and differs between boundaries,
% which is what one expects of grains that are internally uniform: the
% misorientation is a property of the pair of grains, not of the place along
% their interface.

%% The misorientation axis in specimen coordinates
%
% The misorientation stored on a segment is a crystal to crystal rotation
% and knows nothing about the specimen, so an axis in specimen coordinates
% has to be built from the two orientations either side. |ebsdId| leads back
% to them.
%
% Boundary segments are stored in walk order - consecutive segments are
% connected, and each run between two triple junctions is one chain - so
% taking every third segment thins the arrows out evenly along the
% boundaries rather than emptying whole parts of the map.

% do only consider every third boundary segment
Sampling_N=3;
gB = gB(1:Sampling_N:end);

% the following command gives an Nx2 matrix of orientations which contains
% for each boundary segment the orientation on both sides of the boundary.
ori = ebsd('id',gB.ebsdId).orientations;

% the misorientation axis in specimen coordinates
gB_axes = axis(ori(:,1),ori(:,2),'antipodal');

% axes can be plotted using the command quiver
hold on
quiver(gB,gB_axes,'linewidth',2,'color','k','autoScaleFactor',0.3)
hold off

%%
% What is drawn is the projection of each axis into the plane of the
% section, so a short arrow is an axis pointing steeply out of it. Along
% most boundaries the arrows keep one direction, as the constant colour of
% the previous figure already promised.

%% When the axis jumps
%
% Not everywhere, though. Along a few boundaries the arrows change direction
% abruptly from one segment to the next, although the two grains either side
% are as uniform as anywhere else. The explanation is not in the data but in
% how a misorientation is chosen.
%
% A misorientation between two crystals is only defined up to the symmetry
% of both, so there are many equivalent rotations and MTEX reports the one
% with the smallest angle - the disorientation. Where two of them are nearly
% equal in angle, a difference of a tenth of a degree in the measurement is
% enough to make the other one the smaller, and its axis is somewhere else
% entirely.
%
% For forsterite this happens near 120 degrees, the largest misorientation
% angle two orthorhombic crystals can have, and the effect is measurable.
% Between neighbouring segments of one boundary the axis normally moves by
% half a degree. Where the misorientation angle exceeds 105 degrees, one
% step in sixteen turns the axis by more than 30 degrees; below 105 degrees
% that essentially never happens.
%
% So an axis is trustworthy where the misorientation angle is well away from
% the maximum, and needs care near it. The angle itself is not affected -
% it is the same however the equivalent rotation is chosen.
