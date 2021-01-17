%% Shape Parameters - Basic Properties
%
%%
% In this section we discuss basic geometric properties of grains. Due to
% the huge amount of shape parameters we split them into different
% categories: basic properties (this page), <EllipseBasedProperties.html
% properties based on fitted ellipses>, <HullBasedParameters.html convex
% hull bases properties>, <ProjectionBasesParameters.html projection bases
% properties>. The table below summarizes the shape parameters discussed on
% this page.
%
% || |grainSize| || number of pixels per grain || <grain2d.area.html |area|>  || grain area in $\mu m^2$ || 
% || <grain2d.boundarySize.html |boundarySize|>  || number of boundary segments || <grain2d.perimeter.html |perimeter|>  || perimeter in $\mu m$ || 
% || <grain2d.subBoundarySize.html |subBoundarySize|> || number of inner boundaries || <grain2d.subBoundarySize.html |subBoundaryLength|> || length of inner boundaries in $\mu m$ || 
% || <grain2d.diameter.html |diameter|>  || diameter in $\mu m$ || <grain2d.calliper.html |caliper|>  || caliper or Feret diameter ||
% || <grain2d.equivalentPerimeter.html |equivalentPerimeter|>  || perimeter of a circle with the same area || <grain2d.equivalentRadius.html |equivalentRadius|>  || radius of a circle with the same area || 
% || <grain2d.shapeFactor.html |shapeFactor|>  || perimeter / equivalent perimeter || <grain2d.isBoundary.html |isBoundary|>  || is it a boundary grain ||
% || <grain2d.hasHole.html |hasHole|>  || has inclusions  || <grain2d.isInclusion.html |isInclusion|>  || is an inclusions  ||
% || <grain2d.numNeighbors.html |numNeighbors|>  || number neighboring grains  || <triplePointList.triplePointList.html |triplePoints|>  || list of  triple points || 
% || <grainBoundary.grainBoundary.html |boundary|>  || list of  boundary segments || <grainBoundary.grainBoundary.html |innerBoundary|>  || subgrain boundaries || 
% || |x|, |y| || coordinates of the vertices || <grain2d.centroid.html |centroid|>  || x,y coordinates of the barycenter || 
%
%%
% We start our discussion by reconstructing the grain structure from a
% sample EBSD data set.

% load sample EBSD data set
mtexdata forsterite silent

% restrict it to a subregion of interest.
ebsd = ebsd(inpolygon(ebsd,[5 2 10 5]*10^3));

% remove all not indexed pixels
ebsd = ebsd('indexed');

% reconstruct grains
[grains, ebsd.grainId] = calcGrains(ebsd,'angle',5*degree);

% smooth them
grains = smooth(grains,5);

% plot the orientation data of the Forsterite phase
plot(ebsd('fo'),ebsd('fo').orientations)

% plot the grain boundary on top of it
hold on
plot(grains.boundary,'lineWidth',2)
hold off


%% Grain size vs. grain area and boundary size vs. perimeter
%
% The most basic properties are grainSize and grain area. Those can be
% computed by

grains(9).grainSize
grains(9).area

%%
% Hereby |grainSize| referes to the number of pixels that belong to a
% certain grain while |area| represents the actual area measured in
% |(µm)^2|. We may analyze the distribution of grains by grain area using a
% histogram.

close all
histogram(grains.area)
xlabel('grain area')
ylabel('number of grains')

%%
% Note the large amount of very small grains. A more realistic histogram we
% obtain if we do not plot the number of grains at the y-axis but its total
% area. This can be achieved with the command <grain2d.histogram.html
% |histogram(grains)|>

histogram(grains)
xlabel('grain area')

%
% Simarly as |grainSize| and |area|, the one-dimensional meassures
% |boundarySize| and |perimeter| give the length of the grain boundary as
% number of segments and in |µm|, respectively.

grains(9).boundarySize
grains(9).perimeter

%%
% We may compute these quantities also explicitely from the grain boundary
% segents. In the following code the first command returns simply the
% number of boundary segments while the second one gives the total length
% of the boundary by summing up the length of each individual boundary
% segment

length(grains(9).boundary)
sum(grains(9).boundary.segLength)


%% Radius, diameter, equivalent radius, equivalent perimeter and shape factor
%
% Another, one dimensional measure is the |diameter| which refers to the
% longest distance between any two boundary points and is given im |µm| as
% well

grains(9).diameter

%%
% The diameter is a special case of the caliper or Feret diameter of a
% grain that is explained in detail in the section
% <ProjectionBasedParameters.html Projection based parameters>.
%
% In contrast the <grain2d.equivalentRadius.html equivalent radius> is the
% radius of a circle with the same area as the grain. Naturally, the
% equivalent radius is always smaller than the actual radius of the grains.
% Similarly, the <grain2d.equivalentPerimeter equivalent perimeter> is
% defined as the perimeter of the circle the same area and is always
% smaller then the actual perimeter.

2*grains(9).equivalentRadius

grains(9).equivalentPerimeter

%%
% As a consequence, the ratio between between actual grain perimeter and
% the equivalent perimeter, the so called shape factor, is always larger
% then 1. The <grain2d.shapeFactor.html |shapeFactor|> amd measures how
% different a certain shape is from a circle.

plot(grains,grains.shapeFactor)
mtexColorbar('title','shape factor')

%% 
% A second measure for the discrepancy between the actual shape and a
% circle is the relative difference between the <grain2d.perimeter.html
% |perimeter|> and the <grain2d.equivalentPerimeter.html
% |equivalentPerimeter|>

plot(grains,(grains.perimeter - grains.equivalentPerimeter)./grains.perimeter)
setColorRange([0,0.5])
mtexColorbar

%%
% In this plot round shapes will have values close to zero while concave
% shapes will get values up to $0.5$. 
%
% A third measure is the <grain2d.paris.html |paris|> which stands for
% Percentile Average Relative Indented Surface and gives the relative
% difference between the actual perimeter and the perimeter of the convex
% hull. It is explained in more detail in the section
% <HullBasedParameters.html convex hull parameters.>

plot(grains,grains.paris)
mtexColorbar('title','paris')

%% Fractal Dimension
%
% The fractal dimension of grain boundaries has been used to characterize
% the conditions of dynamical recrystallization. One way to define the
% fractal dimension of grain boundaries is to look at the slope of the
% perimeter as a function of the <grain2d.equivalentRadius.html equivalent
% radius> of the grains. More precisely, we consider this relationship in a
% log log plot and fit a linear model. 

% consider the entire data set
mtexdata forsterite silent

% reconstruct grains
grains = calcGrains(ebsd('indexed'));

% smooth them
grains = smooth(grains,5);

close all
scatter(grains.equivalentRadius,grains.perimeter)
xlabel('equivalent radius')
ylabel('perimeter')

% set axes to logarithmic
logAxis(gca, [10,10^4],[10^2,10^5])

% fit a linear function in log space
ab = polyfit(log(grains.equivalentRadius),log(grains.perimeter),1);

% plot it 
hold on
plot([10,10^4],exp(ab(2) + ab(1) * log([10,10^4])),'LineWidth',3)
hold off

%%
% The slope of the linear function is the fractal dimension.

fractalDimension = ab(1)

%%
% It is important to understand that the fractal dimension computed this
% way heavily depends on the smoothing applied to the grain boundaries.
