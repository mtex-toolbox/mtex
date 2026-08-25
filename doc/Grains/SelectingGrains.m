%% Selecting Grains
%
%%
% The grains of a map are one long list, so picking out the ones you care
% about is indexing that list. This page collects the ways of writing such an
% index: by clicking, by position, by phase, by any property, by a condition
% combining several of them, and by orientation. All of them return grains
% again, so they may be applied one after the other.

% load sample EBSD data set
plottingConvention.default('y↑→x');
mtexdata forsterite silent

% restrict it to a subregion of interest
ebsd = ebsd(inpolygon(ebsd,[5 2 10 5]*10^3));

% reconstruct grains
[grains, ebsd] = calcGrains(ebsd,'angle',5*degree,'minPixel',5,'alpha',6);

% smooth them
grains = smoothBoundary(grains,5);

% plot the orientation data of the Forsterite phase
plot(ebsd('fo'),ebsd('fo').orientations)

% and the other two phases in grey
hold on
plot(ebsd('En'),'FaceColor','lightgray')
plot(ebsd('Di'),'FaceColor','darkgray')
plot(grains.boundary,'lineWidth',2)
hold off

%% By mouse
%
% <grain2d.selectInteractive.html |selectInteractive|> lets you click grains
% in the figure. The ids of the grains you clicked are collected in the
% global variable |indSelected|.

selectInteractive(grains,'lineColor','gold')

clear global indSelected
global indSelected

%%
% Nobody is clicking while this page is published, so we set |indSelected|
% by hand to the id of the grain at a position we know, and highlight it.

indSelected = grains(9000,3500).id;

grains(indSelected)

hold on
plot(grains(indSelected).boundary,'lineWidth',4,'lineColor','gold')
hold off

%% By position
%
% That last line was already the second way of selecting: |grains(x,y)|
% returns the grain containing the point |(x,y)|, in the coordinates of the
% map. It needs no figure and no clicking.

x = 12000; y = 4000;

hold on
plot(grains(x,y).boundary,'linewidth',4,'linecolor','blue')

plot(x,y,'marker','s','markerfacecolor','k',...
  'markersize',10,'markeredgecolor','w','DisplayName','A')
hold off

%% By phase
%
% A grain knows its phase, so the mineral name selects all grains of that
% phase.

grains('forsterite')

%%
% This is the readable form of a condition on the |phase| property, which
% holds a number per grain.

grains(1:5).phase

%% By a property
%
% Any property of the grains is a list of the same length as the grains
% themselves - one number per grain - and MATLAB's own tools for such lists
% then do the work. The area, for instance:

grainArea = grains.area;

plot(grains,grainArea)

%%
% |max| gives both the largest value and where it sits in the list, and that
% position is the index of the grain.

[maxArea,maxId] = max(grainArea)

hold on
plot(grains(maxId).boundary,'linecolor','red','linewidth',4)
hold off

%%
% Sorting generalises this from one grain to the largest few.

[sortedArea,sortedId] = sort(grainArea,'descend');

% the second to fifth largest
hold on
plot(grains(sortedId(2:5)).boundary,'linecolor','Orange','linewidth',4)
hold off

%% By a condition
%
% Instead of positions in the list one may index with a logical condition,
% which is often closer to the question being asked. All grains at least a
% quarter the size of the largest one:

condition = grainArea > maxArea/4;

hold on
plot(grains(condition).boundary,'linecolor','Yellow','linewidth',4)
hold off

%%
% Conditions combine, which is where this becomes powerful. Here are the
% grains that are both long in the perimeter and well covered by
% measurements - large grains, and only those large enough for their shape
% to mean something.

condition = grains.perimeter>6000 & grains.numPixel >= 600;

selectedGrains = grains(condition)

plot(selectedGrains)

%% By orientation
%
% <grain2d.findByOrientation.html |findByOrientation|> selects the grains
% whose mean orientation is within a given angle of a reference orientation.
% Crystal symmetry is taken into account, so this asks about the lattice and
% not about the numbers describing it.
%
% Taking the gold grain from above as the reference and 20 degrees as the
% threshold:

similarGrains = grains.findByOrientation(grains(indSelected).meanOrientation,20*degree)

plot(ebsd('fo'),ebsd('fo').orientations)
hold on
plot(grains.boundary,'lineWidth',2)
plot(similarGrains.boundary,'linewidth',4,'linecolor','gold')
hold off

%%
% Three grains come out, and two of them share a boundary. Neighbours with
% orientations this close are worth a second look: either the reconstruction
% cut one grain in two, or they were one grain before something separated
% them - see <GrainMerge.html Merging Grains>.

%% From grains back to measurements
%
% Every selection can be turned into the measurements it contains, provided
% the map carries the |grainId| that <EBSD.calcGrains.html |calcGrains|>
% returned as its second output.

plot(grains)
largeGrains = grains(grains.numPixel > 50);
text(largeGrains,largeGrains.id)

%%
% Pick one of the labelled grains and ask for its measurements:

id = largeGrains.id(1)

ebsd(grains(id))

%%
% which is the same as asking the map directly.

ebsd(ebsd.grainId == id)

%%
% Applied to the largest grain, this is how one looks at the orientations
% inside a single grain.

plot(ebsd(grains(maxId)),ebsd(grains(maxId)).orientations)
hold on
plot(grains(maxId).boundary,'lineWidth',2)
hold off

%% Grains at the edge of the map
%
% A grain touching the edge of the map continues outside it, so its size and
% shape are those of the piece that was measured and not of the grain. Any
% statistic over sizes or shapes should therefore drop them, which
% <grain2d.isBoundary.html |isBoundary|> does.

plot(grains(~grains.isBoundary))

%%
% What that command tests is visible in the boundary itself. Every boundary
% segment stores the ids of the two grains it separates, and a segment at
% the edge of the map has no grain on one side, so that id is zero.

% the segments with a zero on one side
outerBoundaryId = any(grains.boundary.grainId==0,2);

plot(grains)
hold on
plot(grains.boundary(outerBoundaryId),'linecolor','red','linewidth',2)
hold off

%%
% The grains those segments belong to are exactly the ones just removed.

grainId = grains.boundary(outerBoundaryId).grainId;
grainId(grainId==0) = [];

plot(grains(grainId))

%#ok<*GVMIS>
