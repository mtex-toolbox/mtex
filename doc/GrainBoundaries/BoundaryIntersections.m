%% Line intersections
%
%%
% Counting how often a straight line drawn across a map crosses a grain
% boundary is one of the oldest measurements in microscopy. It needs no
% grain shapes and no segmentation of the image, only the boundaries and a
% ruler, and it gives a mean intercept length - the standard measure of
% grain size, and a directional one, since a line drawn along the
% elongation of the grains crosses fewer boundaries than one drawn across
% it.
%
% <grainBoundary.intersect.html |intersect|> is the command.

% load some example data
plottingConvention.default('y↑→x');
mtexdata twins silent

% detect grains
[grains,ebsd] = calcGrains(ebsd);

% smooth them
grains = grains.smoothBoundary;

% visualize the grains
plot(grains,grains.meanOrientation)

% extract all grain boundaries
gB = grains.boundary;

hold on
plot(gB,'LineWidth',2)
hold off

%%
% A line is given by its two end points.

xy1 = [10,10];   % staring point
xy2 = [41,41]; % end point

line([xy1(1);xy2(1)],[xy1(2);xy2(2)],'linestyle',':','linewidth',4,'color','white')

%%
% |intersect| returns one point per boundary segment, and |NaN| for the
% segments the line misses - so the intersections are the entries that are
% not |NaN|.

[x,y] = grains.boundary.intersect(xy1,xy2);
hold on
scatter(x,y,'blue','linewidth',2)
hold off
% find the number of intersection points
sum(~isnan(x))

%%
% The mean intercept length along this line is its length divided by the
% number of crossings.

norm(xy2-xy1) ./ sum(~isnan(x))

%%
% 2.4 µm, from 18 crossings over a line of 44. One line is a thin estimate
% and this one runs diagonally across a map full of twin lamellae, every one
% of which it counts. In practice one averages over many
% parallel lines, and repeats the whole thing in several directions when the
% microstructure is elongated. What a single line does give you is a check
% on a reconstruction: if the number of crossings on a map disagrees badly
% with what <ShapeParameters.html the grain sizes> imply, the reconstruction
% is finding boundaries that are not there, or missing ones that are.
