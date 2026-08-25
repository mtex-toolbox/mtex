%% Tilt and Twist Boundaries
%
%%
% A subgrain boundary is a wall of dislocations. Which dislocations they are
% is visible in the misorientation across it, because the two extreme cases
% differ in where the misorientation axis points:
%
% * a wall of *edge* dislocations rotates the lattice about an axis lying
% *in* the boundary plane - a *tilt boundary*
% * a wall of *screw* dislocations rotates it about the boundary *normal* -
% a *twist boundary*
%
% Real boundaries lie between the two. This page computes the misorientation
% axes of the subgrain boundaries of a map and asks what they say, and it
% ends with what a two dimensional section can and cannot decide.
%
% The subgrain boundaries themselves come from a reconstruction with two
% thresholds, as described in <SubGrainBoundaries.html Subgrain Boundaries>.

% load some test data
plottingConvention.default('y↑→x');
mtexdata forsterite silent

% compute subgrain boundaries with 1 degree threshold angle
[grains,ebsd] = calcGrains(ebsd,'threshold',[1*degree, 15*degree],'minPixel',5);

% lets smooth the grain boundaries a bit - ebsdId is read per segment further
% down, so keep every segment between the pair of pixels it was measured from
grains = smoothBoundary(grains,5,'noSimplify','noRefine');

% set up the ipf coloring
cKey = ipfColorKey(ebsd('fo').CS.properGroup);
cKey.ipfDirection = yvector;
color = cKey.orientation2color(ebsd('fo').orientations);

% plot the forsterite phase
plot(ebsd('fo'),color,'faceAlpha',0.8,'figSize','large')

% init override mode
hold on

% plot grain boundaries
plot(grains.boundary,'linewidth',2)

% compute transparency from misorientation angle
alpha = grains('fo').innerBoundary.misorientation.angle / (5*degree);

% plot the subgrain boundaries
plot(grains('fo').innerBoundary,'linewidth',1.5,'edgeAlpha',alpha,'edgeColor','blue');

% stop override mode
hold off

%%
% The blue lines are the subgrain boundaries, drawn the more opaque the
% larger their misorientation. They are not scattered at random: they run in
% families across the interiors of the larger grains, which is what
% dislocation walls look like.

%% Misorientation axes in crystal coordinates
%
% The axis of a subgrain boundary misorientation, expressed in the crystal
% frame, is a statement about the lattice - it is the direction the
% dislocations run along, for a tilt wall. It comes straight from the
% misorientation.

% extract the Forsterite subgrain boundaries
subGB = grains('fo').innerBoundary;

% plot the misorientation axes in the fundamental sector
plot(subGB.misorientation.axis,'fundamentalRegion','figSize','small')

%%
% Thousands of dots say little. A <DensityEstimation.html density estimate>
% of the same axes, and its <S2FunOperations.html#4 local maxima>, say more.

% compute the density distribution of misorientation axes
density = calcDensity(subGB.misorientation.axis,'halfwidth',3*degree);

% plot them
plot(density,'figSize','small')
mtexColorbar

% find the two preferred misorientation axes
[~,hkl] = max(density,'numLocal',2); round(hkl)

%%
% Two directions stand out, (001) and (071) - rotations about the c axis,
% and about an axis close to b. That the axes cluster at all is the result:
% a few kinds of dislocation wall account for most of the subgrain
% boundaries in this rock.
%
% Attributing an axis to a particular slip system is a step further, and it
% is a question about the material rather than about the data. The axis of a
% tilt wall is the line direction of the edge dislocations that build it, so
% naming the system means knowing which systems can be active in olivine at
% the conditions this rock saw.

%% Misorientation axes in specimen coordinates
%
% The same axes in the frame of the specimen say something else: how the
% walls are oriented in space, which relates to the geometry of the flow
% rather than to the lattice. This cannot be read from the misorientation
% alone, since a misorientation is a crystal to crystal rotation. The two
% orientations either side of each segment are needed, and |ebsdId| leads to
% them.

oriGB = ebsd('id',subGB.ebsdId).orientations

%%
% One row per segment, two columns for the two sides. Their misorientation
% axis in specimen coordinates:

axS = axis(oriGB(:,1),oriGB(:,2),'antipodal')

% plot the misorientation axes
plot(axS,'MarkerAlpha',0.2,'MarkerSize',2,'figSize','small')

%%
% The flag |'antipodal'| is needed because the two sides of a boundary come
% in no particular order: swapping them inverts the misorientation and
% reverses the axis, and both answers must count as the same axis.
%
% Again the density says more than the dots.

density = calcDensity(axS,'halfwidth',5*degree);
plot(density,'figSize','small')
mtexColorbar

[~,pos] = max(density)
annotate(pos)

%% What a section can decide
%
% In two dimensions the boundary plane is not observed - only its trace on
% the polished surface. Since the plane is unknown, tilt and twist cannot be
% told apart in general. One half of the question can still be answered.
%
% A twist boundary has its misorientation axis along the boundary normal,
% which is perpendicular to every direction in the plane and in particular
% to the trace. So an axis *parallel to the trace* rules a twist boundary
% out and makes a tilt boundary likely. An axis perpendicular to the trace
% leaves both open, since the trace is only one direction of the plane.
%
% Colouring the subgrain boundaries by the angle between their trace and
% their misorientation axis therefore separates the likely tilt boundaries,
% in blue, from the undecided ones in red.

plot(ebsd('fo'),color,'faceAlpha',0.5,'figSize','large')

% init override mode
hold on

% plot grain boundaries
plot(grains.boundary,'linewidth',2)

% colorize the subgrain boundaries according the angle between boundary
% trace and misorientation axis
plot(subGB,angle(subGB.direction,axS)./degree,'linewidth',2)
mtexColorMap blue2red
mtexColorbar

hold off

%%
% Both colours are present, and where a subgrain boundary is long and
% straight it holds one of them along its whole length - those are walls
% whose character can be read off. The speckle in between is something else:
% isolated one and two segment features, changing colour from one to the
% next. Statistically the difference is modest, an angle scatter of 19
% degrees within the components of 20 segments or more against 22 degrees
% over the map, so it is the long boundaries that are worth reading and not
% the average.
%
% Deciding the red ones needs the boundary plane, which means either three
% dimensional data or an argument from many boundaries at once - see
% <BoundaryNormalDistribution.html Grain Boundary Normal Distribution>.
