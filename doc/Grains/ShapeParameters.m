%% Shape Parameters
%
%%
% In this section we discuss various geometric properties of grains. We
% start our discussion by reconstructing the grain structure from a sample
% EBSD data set.

% load sample EBSD data set
mtexdata forsterite

% restrict it to a subregion of interest.
ebsd = ebsd(inpolygon(ebsd,[5 2 10 5]*10^3));

% remove all not indexed pixels
ebsd = ebsd('indexed')

% reconstruct grains
[grains, ebsd.grainId] = calcGrains(ebsd,'angle',5*degree)

% smooth them
grains = smooth(grains,5);

% plot the orientation data of the Forsterite phase
plot(ebsd('fo'),ebsd('fo').orientations)

% plot the grain boundary on top of it
hold on
plot(grains.boundary,'lineWidth',2)
hold off


%% Grain size, area, diameter, perimeter and calliper
%
% Once grains have been reconstructed, several shape parameters can be
% computed. Those can be visualized either as histograms, or used to
% colorize an grain map.
%
% The most basic properties are grainSize and grain area. Those can be
% computed by

grains(9).grainSize
grains(9).area

%%
% Hereby *grainSize* referes to the number of pixels the belong to a
% certain grain while *area* represents the actual area measured in (um)^2.
% Simarly the two one-dimensional meassures *boundarySize* and *perimeter*
% gives the length of the grain boundary in number of segments and in in
% um, respectively.

grains(9).boundarySize
grains(9).perimeter

%%
% Another, one dimensional measure is the *diameter* which refers to the
% longest distance between any two boundary points and is given im um as
% well

grains(9).diameter

%%
% The diameter is a special case of the caliper or Feret diameter of a
% grain. By definition the caliper is the length of a grain when projected
% onto a line. Hence, the length of the longest projection is coincides
% with the diameter, while the quotient between longest and shortest
% projection gives an indication about the shape of the grain

grains(9).calliper('longest')
grains(9).calliper('shortest')


%%
% Another way to investigate the perimeter is using the grain boundary. The
% first command returns simply the number of boundary segments while the
% second one gives the total length of the boundary by summing up the
% length of each individual boundary segment

length(grains(9).boundary)
sum(grains(9).boundary.segLength)


%% Fitted ellipses
%
% Many shape parameters refers to ellipses fit to the grains 

[omega,a,b] = grains.fitEllipse;
plot(grains,'linewidth',4)
plotEllipse(grains.centroid,a,b,omega,'lineColor','w','linewidth',2)

%%
% in the above lines the midpoint of the ellipse is given by
% <grain2d.centroid.html *grains.centroid*>. The variable *omega* is the
% angle describing the rotation of the ellipses and *a* and *b* are the
% length of the longest and shortest half axis of the ellipses,
% respectively. Note, that the ellipses are scalled such that their areas
% coincide with the actual grain areas.
%
%%
% The quotient a/b between the longest and the shortest axis is called
% aspect ration and can be computed via

grains(9).aspectRatio

%%
% The radius and perimeter of the fitted ellipse can be computed by

grains(9).equivalentRadius
grains(9).equivalentPerimeter

%%
% Let have a look at the difference between perimeter of the ellipse and
% perimeter of the grain:

plot(grains,(grains.perimeter - grains.equivalentPerimeter)./grains.perimeter)
setColorRange([0,0.5])
mtexColorbar

%%
% In this plot round shapes will have values close to zero while concave
% shapes will get large values. A similar measure is the shape factor which
% is defined as the ratio between the grain perimeter and the equivalent
% perimeter

plot(grains,grains.shapeFactor)
setColorRange([1,2])
mtexColorbar('title','shape factor')


%%
% Another simular measures is the <grain2d.paris.html paris> which stands
% for Percentile Average Relative Indented Surface and gives the relative
% difference between the actual perimeter and the perimeter of the convex
% hull.

plot(grains,grains.paris)
mtexColorbar('title','paris')

%%
% A bit strange quantity

plot(grains,log10(2.*grains.equivalentRadius))
cb = mtexColorbar;
labels = num2str(round(10.^(cb.Ticks))');
cb.TickLabels=labels;
drawNow(gcm)


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


%% List of all geometric grain properties
%
% Grains are stored as a long list of several properties. Please find
% below a table of most of the properties that are stored or can be
% computed for grains
%
% || <grain2d.area.html *grains.area*>  || grain area in square |grains.scanUnit|  || 
% || <grain2d.aspectRatio.html *grains.aspectRatio*>  || grain length / grain width ||
% || <grainBoundary.grainBoundary.html *grains.boundary*>  || list of boundary segments || 
% || <grainBoundary.grainBoundary.html *grains.innerBoundary*>  || list of inner boundary segments || 
% || <grain2d.boundarySize.html *grains.boundarySize*>  || number of boundary segments || 
% || <grain2d.paris.html *grains.paris*>  || 2* quotient excess perimeter of convex hull / perimeter || 
% || <grain2d.centroid.html *grains.centroid*>  || x,y coordinates of the barycenter of the grain || 
% || <grain2d.diameter.html *grains.diameter*>  || diameter in |grains.scanUnit|  || 
% || <grain2d.equivalentPerimeter.html *grains.equivalentPerimeter*>  || area-equivalent perimeter  || 
% || <grain2d.equivalentRadius.html *grains.equivalentRadius*>  || area-equivalent radius  || 
% || *grains.grainSize* || number of measurements per grain || 
% || <grain2d.hasHole.html *grains.hasHole*>  || check for inclusions  ||
% || <grain2d.neighbors.html *grains.neighbors*>  || number and ids of neighboring grains  || 
% || <grain2d.perimeter.html *grains.perimeter*>  || perimeter in |grains.scanUnit| || 
% || <grain2d.principalComponents.html *grains.principalComponents*>  || angle, length and width of the fitted ellipse || 
% || <grain2d.shapeFactor.html *grains.shapeFactor*>  || quotient perimeter / area-equivalent perimeter || 
% || <triplePointList.triplePointList.html *grains.triplePoints*>  || list of  triple points || 
% || *grains.x* || x coordinates of the vertices || 
% || *grains.y* || y coordinates of the vertices || 

