%% Grain Boundary Tutorial
%
%%
% A grain boundary is where two crystals meet, and what makes it interesting
% is the relation between the two lattices rather than the line on the map.
% This tutorial gets from a measurement to that relation in a dozen lines.

% load some example data
plottingConvention.default('y↑→x');
mtexdata twins

% detect grains
[grains,ebsd] = calcGrains(ebsd)

% smooth them
grains = grains.smoothBoundary

% visualize the grains
plot(grains,grains.meanOrientation)

%%
% 121 grains of magnesium, and the lamellae crossing the larger ones are
% twins - the thing this specimen is here to show.
%
% The boundaries are an object of their own, reached from the grains:

gB = grains.boundary

%%
% 3359 segments, and they are not all of one kind. 2751 lie between two
% magnesium grains; the remaining 608 are against |notIndexed|, which here
% means the edge of the scan, where a grain is cut off and has no neighbour.
% Only the first kind has a misorientation, so that is what one selects:

gB_MgMg = gB('Magnesium','Magnesium')

%% What a boundary segment knows
%
% Each segment carries the misorientation across it, the direction it runs
% in and its length - see <BoundaryProperties.html Boundary Properties> for
% the full list. Any of them can be used as a colour.

plot(gB_MgMg,gB_MgMg.misorientation.angle./degree,'linewidth',2)
mtexColorbar

%%
% The map is dominated by one value. The median misorientation angle is 85
% degrees and nearly six segments in ten are above 80, which is no accident:
% 86.3 degrees is the twin relationship of magnesium, so most of what is
% drawn here is twin boundary.
%
% <TwinningBoundaries.html Twinning> identifies that relationship from the
% data rather than assuming it, and <GrainMerge.html Merging Grains> puts
% the twins back into the grains they grew in.
