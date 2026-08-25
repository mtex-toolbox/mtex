%% Shape Parameters - Basic Properties
%
%%
% The outline of a grain is a polygon with hundreds of vertices. A shape
% parameter compresses it into a single number that can be plotted,
% histogrammed and compared between specimens - at the price of throwing
% almost everything else away. This page covers the parameters that are
% measured on the outline itself. The three pages after it fit a simpler
% object to the grain first and measure that instead: an
% <EllipseBasedParameters.html ellipse>, a <HullBasedParameters.html convex
% hull>, or a set of <ProjectionBasedParameters.html projections>.
%
% || |numPixel| || number of pixels per grain || <grain2d.area.html |area|>  || grain area in µm² ||
% || <grain2d.boundarySize.html |boundarySize|>  || number of boundary segments || <grain2d.perimeter.html |perimeter|>  || perimeter in µm ||
% || <grain2d.subBoundarySize.html |subBoundarySize|> || number of inner boundaries || <grain2d.subBoundarySize.html |subBoundaryLength|> || length of inner boundaries in µm ||
% || <grain2d.diameter.html |diameter|>  || diameter in µm || <grain2d.caliper.html |caliper|>  || caliper or Feret diameter ||
% || <grain2d.equivalentPerimeter.html |equivalentPerimeter|>  || perimeter of a circle with the same area || <grain2d.equivalentRadius.html |equivalentRadius|>  || radius of a circle with the same area ||
% || <grain2d.shapeFactor.html |shapeFactor|>  || perimeter / equivalent perimeter || <grain2d.isBoundary.html |isBoundary|>  || is it a boundary grain ||
% || <ExIceSphericity.html |sphericity|>  || irregularity of grain boundary ||   ||  ||
% || <grain2d.hasHole.html |hasHole|>  || has inclusions  || <grain2d.isInclusion.html |isInclusion|>  || is an inclusions  ||
% || <grain2d.numNeighbors.html |numNeighbors|>  || number neighboring grains  || <triplePointList.triplePointList.html |triplePoints|>  || list of  triple points ||
% || <grainBoundary.grainBoundary.html |boundary|>  || list of  boundary segments || <grainBoundary.grainBoundary.html |innerBoundary|>  || subgrain boundaries ||
% || |x|, |y| || coordinates of the vertices || <grain2d.centroid.html |centroid|>  || x,y coordinates of the barycenter ||
%
%%
% All of them are computed on a reconstructed grain map, so we start with
% one.

% load sample EBSD data set
plottingConvention.default('y↑→x');
mtexdata forsterite silent

% restrict it to a subregion of interest
ebsd = ebsd(inpolygon(ebsd,[5 2 10 5]*10^3));

% remove all not indexed pixels
ebsd = ebsd('indexed');

% reconstruct grains
[grains, ebsd] = calcGrains(ebsd,'angle',5*degree,'minPixel',5);

% smooth them
grains = smoothBoundary(grains,5);

% plot the orientation data of the Forsterite phase
plot(ebsd('fo'),ebsd('fo').orientations)

% plot the grain boundary on top of it
hold on
plot(grains.boundary,'lineWidth',2)
hold off

%% How large is a grain
%
% Size comes in two flavours: the number of measurements a grain is made of,
% and the area it covers on the specimen.

grains(9).numPixel
grains(9).area

%%
% |numPixel| is a count and |area| is in µm². The two are proportional as
% long as the map has one step size everywhere, which is why the count is a
% useful stand-in during reconstruction - |'minPixel'| is expressed in it -
% while the area is what one reports.
%
% Over the whole map the sizes are strongly skewed.

close all
histogram(grains.area)
xlabel('grain area')
ylabel('number of grains')

%%
% Nearly every grain falls into the first bar. That is what a size
% distribution counted by grains always looks like, and it says less than it
% seems: those small grains are numerous but occupy almost none of the
% specimen. Weighting each grain by its area instead of counting it gives
% the picture that matters for the microstructure, and that is what
% <grain2d.hist.html |hist(grains)|> does - one group of bars per phase.

hist(grains); %#ok<HIST>

%%
% <grain2d.histogram.html |histogram(grains)|> draws the same numbers with
% the phases stacked on top of each other rather than side by side.

histogram(grains);

%%
% Read this way the specimen looks quite different. The area is spread over
% the whole size range, and the single largest forsterite grain, four square
% millimetres of it, holds a sixth of the map on its own. The many tiny
% grains have not gone away; they simply carry no weight.

%% How long is its boundary
%
% |boundarySize| and |perimeter| are the same pair one dimension lower: a
% count of boundary segments and a length in µm.

grains(9).boundarySize
grains(9).perimeter

%%
% Both are shortcuts for asking the boundary itself, which is a list of
% segments with a length each.

length(grains(9).boundary)
sum(grains(9).boundary.segLength)

%% Diameter and the equivalent circle
%
% The <grain2d.diameter.html |diameter|> is the longest distance between any
% two points of the outline. It is one of a family of measures taken along a
% direction, the caliper or Feret diameters, which
% <ProjectionBasedParameters.html Projection Parameters> covers.

grains(9).diameter

%%
% The other way of putting a length to a grain is to ask for the circle of
% the same area and take its radius, the
% <grain2d.equivalentRadius.html |equivalentRadius|>. Being the roundest
% shape of that area, this circle is smaller across than the grain and
% shorter around it than the grain's perimeter.

2*grains(9).equivalentRadius

grains(9).equivalentPerimeter

%% How far from a circle
%
% Because the equivalent circle is the shortest way round a given area, the
% ratio of the two perimeters is at least 1 and grows with how ragged or how
% elongated a grain is. That ratio is the
% <grain2d.shapeFactor.html |shapeFactor|>.

plot(grains,grains.shapeFactor)
mtexColorbar('title','shape factor')

%%
% On this map the shape factor runs from 1.06 to 1.74 with a median of 1.25.
% The yellow grains are the lobed ones in the upper left, the dark blue ones
% are small and compact. Note that the measure does not say which of the two
% causes it is reacting to - a smooth ellipse and a round grain with a
% frayed boundary can reach the same value.
%
% The same information scaled differently, as the relative difference
% between the <grain2d.perimeter.html |perimeter|> and the
% <grain2d.equivalentPerimeter.html |equivalentPerimeter|>:

plot(grains,(grains.perimeter - grains.equivalentPerimeter)./grains.perimeter)
setColorRange([0,0.5])
mtexColorbar

%%
% Round shapes are near zero here, and the range is bounded above by 1
% rather than unbounded.
%
% A third measure separates raggedness from elongation, by comparing the
% perimeter not to a circle but to the grain's own convex hull:
% <grain2d.paris.html |paris|>, the Percentile Average Relative Indented
% Surface, in percent. An elongated but smoothly bounded grain has a paris
% near zero, since its hull follows it closely; a grain with bays and inlets
% does not. It is discussed in
% <HullBasedParameters.html Convex Hull Parameters>.

plot(grains,grains.paris)
mtexColorbar('title','paris')

%%
% The median here is 3.7 percent and the most indented grain reaches 43. The
% two measures agree only in part - they correlate at 0.5 over this map, and
% they pick different grains as the most extreme - because the shape factor
% counts elongation as a departure from a circle and paris does not.

%% Fractal dimension
%
% How long a boundary is depends on how closely you look at it - the
% coastline problem. The fractal dimension puts a number to that dependence,
% and has been used to characterise the conditions of dynamic
% recrystallisation.
%
% One way to estimate it is to compare grains of different size within the
% same map: plot the perimeter against the
% <grain2d.equivalentRadius.html |equivalentRadius|> in a log log plot and
% fit a straight line. A shape that keeps its proportions while growing gives
% a slope of 1, and every excursion of the boundary that survives at larger
% scales pushes the slope above it.

% consider the entire data set
mtexdata forsterite silent

% reconstruct grains
grains = calcGrains(ebsd);

% smooth them
grains = smoothBoundary(grains,5);

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
% The slope of that line is the fractal dimension.

fractalDimension = ab(1)

%%
% Treat the number with care: it depends on how much the boundaries were
% smoothed beforehand, since smoothing is exactly the operation that removes
% the small excursions the measure is counting.

for iter = [0 5 25]
  g = smoothBoundary(calcGrains(ebsd),iter);
  ab = polyfit(log(g.equivalentRadius),log(g.perimeter),1);
  fprintf('%2d smoothing iterations: fractal dimension %.3f\n',iter,ab(1));
end

%%
% The unsmoothed staircase gives the largest value, and that excess is an
% artefact of the measurement grid rather than a property of the rock. Heavy
% smoothing overshoots the other way, to below 1, which no self-similar
% shape can produce - by then the small grains have been rounded into
% polygons. A fractal dimension is comparable between specimens only if the
% same smoothing was applied to both.
%
%#ok<*NOPTS>
