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


%%
% We may now investigate the difference between original grains and their
% convex hull. An example is the relative difference in area 

plot(grains,(chGrains.area-grains.area)./grains.area)
setColorRange([0,0.5])


%%
% A similar measure is the <grain2d.paris.html paris> which stands
% for Percentile Average Relative Indented Surface and gives the relative
% difference between the actual perimeter and the perimeter of the convex
% hull.

plot(grains,grains.paris)
mtexColorbar('title','paris')

