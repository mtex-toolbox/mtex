%% Convex Hull Based Shape Parameters
%
%%
% In this section we discuss geometric properties of grains that are
% related to the convex hull of the grains. The table below summarizes all
% these propeties
%
% || <grain2d.convHull.html |grains.convHull|>  || convex hull || 
% || <grain2d.areaHull.html |grains.areaHull|>  || area of the convex hull in square |grains.scanUnit|  || 
% || <grain2d.perimeterHull.html |grains.perimeterHull|>  || perimeter of the convex hull in square |grains.scanUnit| || 
% || <grain2d.paris.html |grains.paris|>  || 2 * quotient excess perimeter of convex hull / perimeter || 
%
% In order to demonstrate these properties we start by reconstructing the
% grain structure from a sample EBSD data set.

% load sample EBSD data set
mtexdata forsterite

% restrict it to a subregion of interest.
ebsd = ebsd(inpolygon(ebsd,[5 2 10 5]*10^3));

% remove all not indexed pixels
ebsd = ebsd('indexed');

% reconstruct grains
[grains, ebsd.grainId] = calcGrains(ebsd,'angle',5*degree);

% smooth them
grains = smooth(grains,5);

% plot the orientation data of the Forsterite phase
plot(grains,'lineWidth',4)

%% Computing the Convex Hull
% The convex hull of a list of grains can be computed by the command
% <grain2d.hull.html |hull|>. The result is a list of convex grains which
% can be analyzed almost analogously like the original list of grains.

chGrains = grains.hull

hold on
plot(chGrains.boundary,'lineWidth',2,'lineColor','w')
hold off

%%
% One majore difference is that the grains may now overlap. Accordingly, a
% boundary of the convex hull is not a boundary between two adjecent grains
% anymore. Therefore, the second phase in all boundary segments is set to
% not indexed.

chGrains.boundary

%% Deviation from fully convex shapes

% There are various measures to describe the deviation from fully convex
% shapes, i.e. the lobateness of grains. Many of these are based on the
% differences between the convex hull of the grain and the grain itself.
% Depending on the type of deviation from the fully convex shape, some
% measures might be more appropriate over others.

mtexdata testgrains

% We will select a few interesting grains.
id = [4 5 20 22 26 27 29 34 42 44 49 51 50]

% Smoothing of grains is necessary since otherwise many grain
% segments are either vertical or horizontal (for a square grid) 
% and perimeters rather measure the "cityblock" distance.
% See also https://t.co/1vQ3SR8noy?amp=1 for examples.
% Note, that for very small grains, the error between the smoothed grains
% and their convex hull may lead to unsatisfactory results.
sgrains = smooth(grains('id',id),3)

% Next we get the area and the perimeter of the convex hull of grains
[harea, hperim]=convexhullProps(sgrains)

% One measure is the relative difference between the grain perimeter and
% the perimeter of the convex hull. It most strongly discriminizes grains
% with thin, narrow indenting parts, e.g. fracture which not entirely
% dissect a grain.
deltP = (sgrains.perimeter-hperim')./sgrains.perimeter*100;
plot(sgrains,deltP)
mtexTitle('deltP')

% The relative difference between the grain area and the area within the
% convex hull is more indicative for a broad lobateness of grains
deltA = (harea' - sgrains.area)./sgrains.area*100;
nextAxis
plot(sgrains,deltA)
mtexTitle('deltA')

% The total deviation from the fully convex shape can be expressed by
radiusD = sqrt(deltP.^2+deltA.^2);
nextAxis
plot(sgrains,radiusD)
mtexTitle('radiusD')

% A similar measure is the <grain2d.paris.html paris> which stands
% for Percentile Average Relative Indented Surface and gives the
% difference between the actual perimeter and the perimeter of the convex
% hull, relative to the convex hull.
nextAxis
plot(sgrains,sgrains.paris)
mtexTitle('paris factor')
mtexColorbar
