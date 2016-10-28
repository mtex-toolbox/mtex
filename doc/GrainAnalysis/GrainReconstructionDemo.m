%% First Steps and Function Overview
% Get in touch with grains.
%
%% Grain reconstruction from EBSD data
%
% So far grains can be exclusively computed from EBSD data using the command
% <EBSD_calcGrains.html calcGrains>. In order to demonstrate grain
% reconstruction we import some EBSD data

mtexdata forsterite
plotx2east

% plot the Forsterite phase colorized according to orientation
plot(ebsd('fo'),ebsd('fo').orientations)


%%
% When reconstructing grain there are two basic ways how to deal with not
% indexed measurements. The simplest way is to keep the not indexed pixels
% separately, i.e., do not assign them to any indexed grain.

[grains, ebsd.grainId] = calcGrains(ebsd,'angle',5*degree)

%%
% We observe that there are not only grains of specific phases but also not
% indexed grains. Let's add the grain boundaries to the previous plot.

hold on
plot(grains.boundary)
hold off

%%
% The resulting grains contain a lot of holes and one-pixel grains. The
% second way is to assign not indexed pixels to surrounding grains. In MTEX
% this is done if the not indexed data are removed from the measurements,
% i.e.

ebsd = ebsd('indexed') % this removes all not indexed data
[grains, ebsd.grainId] = calcGrains(ebsd,'angle',5*degree)


%%
% Now, there are no not indexed grains computed. Let's visualize the result

% plot the orientation data of the Forsterite phase
plot(ebsd('fo'),ebsd('fo').orientations)

% plot the grain boundary on top of it
hold on
plot(grains.boundary)
hold off

%%
% A more detailed discussion on grain reconstruction in MTEX can be found
% <GrainReconstruction.html here>


%% Smoothing grain boundaries
%
% Due to the measurement grid, the grain boundaries often show a typical
% staircase effect. This effect can be reduced by smoothing the grain
% boundaries. Using the command <grain2d.smooth.html smooth>.

% smooth the grains
grains = smooth(grains);

% plot the orientation data of the Forsterite phase
plot(ebsd('fo'),ebsd('fo').orientations)

% plot the grain boundary on top of it
hold on
plot(grains.boundary)
hold off

%% Grain properties
%
% Grains are stored as a long list of several properties. Please find
% below a table of most of the properties that are stored or can be
% computed for grains
%
% || <grain2d.area.html *grains.area*>  || grain area in square <grain2d.index.html grains.scanUnit>  || 
% || <grain2d.aspectRatio.html *grains.aspectRatio*>  || grain length / grain width ||
% || <grainBoundary.html *grains.boundary*>  || list of boundary segments|| 
% || <grain2d.boundarySize.html *grains.boundarySize*>  || number of boundary segments || 
% || <grain2d.calcParis.html *grains.calcParis*>  || area difference between grain and its convex hull|| 
% || <grain2d.centroid.html *grains.centroid*>  || x,y coordinates of the barycenter of the grain || 
% || *grains.CS* || crystal symmetry (single phase only)|| 
% || <grain2d.diameter.html *grains.diameter*>  || diameter in <grain2d.index.html grains.scanUnit>  || 
% || <grain2d.equivalentPerimeter.html *grains.equivalentPerimeter*>  || the perimeter of the fitted ellipse  || 
% || <grain2d.equivalentRadius.html *grains.equivalentRadius*>  || the radius of the fitted ellipse  || 
% || *grains.GOS* || grain orientation spread|| 
% || *grains.grainSize* || number of measurements per grain|| 
% || <grain2d.hasHole.html *grains.hasHole*>  || check for inclusions  ||
% || *grains.id* || grain id|| 
% || <grainBoundary.html *grains.innBoundary*>  || list of inner boundary segments|| 
% || *grains.meanOrientation* || meanOrientation (single phase only)|| 
% || *grains.mineral* || mineral name (single phase only)|| 
% || <grain2d.neigbours.html *grains.neighbours*>  || number and ids of neighboring grains  || 
% || *grains.phase* || phase identifier|| 
% || <grain2d.perimeter.html *grains.perimeter*>  || perimeter in <grain2d.index.html grains.scanUnit>  || 
% || <grain2d.principalComponents.html *grains.principalComponents*>  || length and width of the fitted ellipse || 
% || <grain2d.shapeFactor.html *grains.shapeFactor*>  || quotient perimeter / perimeter of the fitted ellipse|| 
% || <triplePoints.html *grains.triplePoints*>  || list of  triple points|| 
% || *grains.x* || x coordinates of the vertices|| 
% || *grains.y* || y coordinates of the vertices|| 

%%
% Those grain properties can be used for colorization. E.g. we may colorize
% grains according to their area.

plot(grains,grains.area)

%%
% or a little bit more advanced according to the log quotient between
% grain size and boundary size.

plot(grains,log(grains.grainSize ./ grains.boundarySize))
mtexColorbar

%%
% Note that some properties are available for single phase lists of grains,
% e.g.

% colorize the Forsterite Phase according to its mean orientation
plot(grains('Fo'),grains('Fo').meanOrientation)


%% Changing lists of grains
%
% As with any list in MTEX, one can single out specific grains by conditions
% using the syntax

% this gives all grains with more the 1000 pixels
largeGrains = grains(grains.grainSize > 1000)

hold on
% mark only large Forsterite grains
plot(largeGrains('Fo').boundary,'linewidth',2,'linecolor','k')
hold off

