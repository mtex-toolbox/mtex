%% Grain Neighbors
%
%%
% Once a map has been divided into grains, it is also a network: each grain
% touches a few others, and which grain touches which carries information
% that a list of grains on its own does not. Twins come in touching pairs,
% recrystallised grains are surrounded by their parent, a second phase sits
% at the corners between three grains of the first.
%
% The same relationships are visible in the
% <BoundaryMisorientations.html grain boundaries>, measurement by
% measurement. Working with the mean orientations of whole grains instead
% is coarser but much cheaper, and for a large map that matters.

% load sample EBSD data set
plottingConvention.default('y↑→x');
mtexdata twins silent
CS = ebsd.CS;

% reconstruct grains
[grains, ebsd] = calcGrains(ebsd,'angle',5*degree);

grains = smoothBoundary(grains,5);

% plot the grains
plot(grains,grains.meanOrientation)

%% Which grain touches which
%
% <grain2d.neighbors.html |grains.neighbors|> returns the network as a list
% of pairs of grain ids, one row per pair of grains that share a boundary.
% Row 188 of that list, for instance:

pairs = grains('indexed').neighbors;

hold on
plot(grains(pairs(188,:)).boundary,'LineWidth',4,'linecolor','b')
hold off

%%
% Two grains that share a boundary have a misorientation, and for a pair of
% mean orientations it is one number rather than one per boundary segment.

mori = inv(grains(pairs(188,1)).meanOrientation) * grains(pairs(188,2)).meanOrientation

%%
% Since the pairs are a list, the same line computes all of them at once.

mori = inv(grains(pairs(:,1)).meanOrientation) .* grains(pairs(:,2)).meanOrientation

close all
histogram(mori.angle./degree)
xlabel('misorientation angle')

%%
% The histogram is not the smooth curve a random misorientation distribution
% would give. It has a sharp peak just below 90 degrees, which in magnesium
% is the signature of twinning.

%% Finding the twins
%
% A twin relationship is a specific orientation relationship, defined here
% by two pairs of crystal directions that it maps onto each other.

twinning = orientation.map(Miller(0,1,-1,-2,CS),Miller(0,-1,1,-2,CS),...
  Miller(2,-1,-1,0,CS),Miller(2,-1,-1,0,CS))

%%
% Its angle is 86.3 degrees, which is where the peak sits. Counting the
% pairs that are within 3 degrees of it says how much of the network is
% twin boundaries.

% which of the pairs are twinning
isTwinning = angle(mori,twinning) < 3*degree;

% percentage of twinning pairs
100 * sum(isTwinning) / length(isTwinning)

%%
% 37 percent of the 251 neighbouring pairs in this map are twins, and 93 of
% them fall in the 85 to 90 degree bin of the histogram - the peak is the
% twins and little else. <TwinningBoundaries.html Twinning> pursues them
% along the boundaries themselves.

%% Pairs, and what counts as one
%
% |neighbors| only returns a pair when *both* grains are in the list it was
% called on. That is what makes |grains('phaseName').neighbors| return the
% relationships within one phase and nothing else.
%
% Sometimes the other rule is wanted: every pair in which at least one grain
% is in the list, which is how one asks for the neighbours of a given grain.
% The option |'full'| switches to it.

% get all pairs containing grain 92
pairs = grains(92).neighbors('full');

% remove the centre grain from this list, leaving its neighbours
pairs(pairs == 92) = [];

plot(grains,grains.meanOrientation,'micronbar','off')
hold on
plot(grains(pairs),'FaceColor','black','FaceAlpha',0.5)
plot(grains(92).boundary,'lineColor','white','lineWidth',3)
hold off

%%
% The grain outlined in white is grain 92 and the darkened ones are the
% grains it touches. Without |'full'| this list would have been empty, since
% no pair has both of its grains inside a list of one.

%#ok<*NASGU>
%#ok<*NOPTS>
%#ok<*MINV>
