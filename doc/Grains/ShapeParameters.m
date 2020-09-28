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
% || <grain2d.subBoundarySize.html |subBoundarySize|> || number of subgrain boundaries || <grain2d.subBoundarySize.html |subBoundaryLength|> || length subgrain boundaries in $\mu m$ || 
% || <grain2d.diameter.html |diameter|>  || diameter in $\mu m$ || <grain2d.isBoundary.html |isBoundary|>  || is it a boundary grain ||
% || <grain2d.hasHole.html |hasHole|>  || has inclusions  || <grain2d.isInclusion.html |isInclusion|>  || is an inclusions  ||
% || <grain2d.numNeighbors.html |numNeighbors|>  || number neighboring grains  || <triplePointList.triplePointList.html |triplePoints|>  || list of  triple points || 
% || <grainBoundary.grainBoundary.html |boundary|>  || list of  boundary segments || <grainBoundary.grainBoundary.html |innerBoundary|>  || subgrain boundaries || 
% || |x|, |y| || coordinates of the vertices || <grain2d.centroid.html |centroid|>  || x,y coordinates of the barycenter || 
%
%%
% We start our discussion by reconstructing the grain structure from a
% sample EBSD data set.

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
plot(ebsd('fo'),ebsd('fo').orientations)

% plot the grain boundary on top of it
hold on
plot(grains.boundary,'lineWidth',2)
hold off


%% Grain size vs. grain area
%
% The most basic properties are grainSize and grain area. Those can be
% computed by

grains(9).grainSize
grains(9).area

%%
% Hereby |grainSize| referes to the number of pixels that belong to a
% certain grain while |area| represents the actual area measured in |(µm)^2|.
% Simarly the one-dimensional meassures |boundarySize| and |perimeter| give
% the length of the grain boundary in number of segments and in in |µm|,
% respectively.

grains(9).boundarySize
grains(9).perimeter

%%
% Another, one dimensional measure is the |diameter| which refers to the
% longest distance between any two boundary points and is given im |µm| as
% well

grains(9).diameter

%%
% The diameter is a special case of the caliper or Feret diameter of a
% grain. By definition the caliper is the length of a grain when projected
% onto a line. Hence, the length of the longest projection is coincides
% with the diameter, while the quotient between longest and shortest
% projection gives an indication about the shape of the grain.

grains(9).calliper('longest')
grains(9).calliper('shortest')


%%
% Another way to investigate the perimeter is using the grain boundary. The
% first command returns simply the number of boundary segments while the
% second one gives the total length of the boundary by summing up the
% length of each individual boundary segment

length(grains(9).boundary)
sum(grains(9).boundary.segLength)

%% Histograms
%  

close all
histogram(grains.area)
xlabel('grain area')
ylabel('number of grains')

%%
% Note the large amount of very small grains. 
% A more realistic histogram we obtain if we do not plot the number of
% grains at the y-axis but its total area. This can be achieved with the
% command <grain2d.hist.html hist>

hist(grains,grains.area)
xlabel('grain area')

%% Scatter plot
% Scatter plots provide an efficient way to check whether two or more
% properties are correlated. As an example lets look at the paris and the
% shape factor

close all
scatter(grains.paris,grains.shapeFactor)
xlabel('paris')
ylabel('shape factor')

%%
% Obviously, there is a strong correlation between those two quantities.
