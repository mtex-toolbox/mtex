%% Select Grain Boundaries
%
%%
% The boundaries of a map are a list of short segments, each lying between
% two neighbouring measurements that ended up in different grains. Any
% analysis starts by choosing which of them to look at: the boundaries of
% one grain, those between two particular phases, or those whose
% misorientation has some character. All of these are an index into that
% list, and the result is a boundary list again.

close all;

% import the data
plottingConvention.default('y↑→x');
mtexdata forsterite silent

% restrict it to a sub-region of interest.
ebsd = ebsd(inpolygon(ebsd,[5 2 10 5]*10^3));

% and recompute grains
[grains,ebsd] = calcGrains(ebsd,'minPixel',5,'alpha',10);

% smooth the grains a bit
grains = smoothBoundary(grains,4);

% visualize as a phase map
plot(ebsd)
hold on
plot(grains.boundary,'linewidth',2)
hold off

%% What the list contains
%
% |grains.boundary| is that list, and displaying it gives the count of
% segments for each pair of phases that meet anywhere in the map.

grains.boundary

%%
% Note the rows involving |notIndexed|. They are two different things at
% once: boundaries against a region that could not be indexed, and the outer
% rim of the map, where a grain is cut off by the edge of the scan and has
% no neighbour at all. <SelectingGrains.html Selecting Grains> shows how to
% tell the second kind apart.

%% By the phases on either side
%
% Two phase names select the segments between those two phases. The
% forsterite to forsterite boundaries, the grain boundaries proper of the
% dominant phase:

hold on
plot(grains.boundary('Fo','Fo'),'lineColor','blue','micronbar','off','lineWidth',4)
hold off

%%
% And the forsterite to enstatite boundaries, which are phase boundaries
% rather than grain boundaries - two different crystals meeting, not two
% orientations of the same one:

hold on
plot(grains.boundary('Fo','En'),'lineColor','darkgreen','micronbar','off','lineWidth',4)
hold off

%%
% The order of the two names matters, and not only for readability. A
% misorientation is a rotation *from* one crystal *to* another, so the two
% orders give misorientations inverse to each other, and any statement about
% one of them - an axis in crystal coordinates, for instance - refers to
% whichever crystal was named first.

mori = grains.boundary('Fo','En').misorientation(1)

inv(mori)

%%
% One thing to be careful about: the two selections contain the same
% segments, but not in the same order. Segment by segment the
% misorientations are exact inverses of each other, while
% |grains.boundary('En','Fo').misorientation(1)| is simply a different
% segment from the one above.

%% By grain
%
% A boundary list is also reachable from the grains it belongs to, which is
% how one asks for the boundary of a single grain or of a selection.

grains(47).boundary

hold on
plot(grains(47).boundary,'lineWidth',4,'lineColor','DarkBlue')
hold off

%% Boundaries inside a grain
%
% |grains.innerBoundary| holds the segments that separate two measurements
% *of the same grain*. They arise where a grain has an orientation gradient
% that comes back around: two pixels that are neighbours in space are far
% apart along the gradient, so the criterion separates them, but a path
% through the grain still connects them and they stay one grain.

hold on
plot(grains.innerBoundary,'linecolor','red','linewidth',4)
hold off

%%
% Eleven segments here, in a rock that is barely deformed. In deformed
% material there are many, and they are the subject of
% <SubGrainBoundaries.html Subgrain Boundaries>.

%% By misorientation
%
% Every segment carries its misorientation, so any condition on it selects
% segments - a threshold on the angle, a distance from a twin relationship,
% a coincidence site lattice. Those selections have pages of their own:
% <TiltAndTwistBoundaries.html Twist and Tilt>,
% <TwinningBoundaries.html Twinning> and <CSLBoundaries.html CSL>.
