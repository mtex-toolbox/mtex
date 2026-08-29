%% Grain Size and Basic Shape Parameters
%
%%
% The outline of a grain is a polygon with hundreds of vertices. A shape
% parameter compresses that outline into a number that can be plotted,
% histogrammed, and compared between specimens. The price is that almost
% all other information about the outline is lost.
%
% This page covers direct measurements of a grain in a two-dimensional
% section. It assumes that the grains have been
% <GrainReconstruction.html reconstructed> and explains why their boundaries
% are <GrainSmoothing.html smoothed>. Use
% <SelectingGrains.html Selecting Grains> first if selecting complete grains
% away from the map edge is unfamiliar.
%
% A measured section is not a three-dimensional grain. Large grains are
% more likely to be cut, and most cuts miss the widest part of a grain.
% Quantities such as |area| and |equivalentRadius| therefore describe the
% observed section unless a stereological model or a standard says how to
% infer a three-dimensional size from them.
%
% The most useful scalar properties are listed below. Lengths are returned
% in the map's measurement unit and areas in its square.
%
% || |numPixel| || number of measurements in the grain || <grain2d.area.html |area|> || area of the section ||
% || <grain2d.boundarySize.html |boundarySize|> || number of outline segments || <grain2d.perimeter.html |perimeter|> || length of the outline ||
% || <grain2d.subBoundarySize.html |subBoundarySize|> || number of subgrain boundary segments || <grain2d.subBoundaryLength.html |subBoundaryLength|> || length of subgrain boundaries ||
% || <grain2d.diameter.html |diameter|> || largest vertex-to-vertex distance || <grain2d.caliper.html |caliper|> || caliper or Feret diameter ||
% || <grain2d.equivalentPerimeter.html |equivalentPerimeter|> || perimeter of the equal-area circle || <grain2d.equivalentRadius.html |equivalentRadius|> || radius of the equal-area circle ||
% || <grain2d.shapeFactor.html |shapeFactor|> || perimeter divided by equivalent perimeter || <grain2d.paris.html |paris|> || indentation relative to the convex hull ||
% || <ExIceSphericity.html |sphericity|> || boundary irregularity in the ice-grain example || <grain2d.isBoundary.html |isBoundary|> || does the grain touch the map edge? ||
% || <grain2d.hasHole.html |hasHole|> || does the grain enclose another grain? || <grain2d.isInclusion.html |isInclusion|> || is the grain enclosed by another grain? ||
% || <grain2d.numNeighbors.html |numNeighbors|> || number of neighbouring grains || <triplePointList.triplePointList.html |triplePoints|> || list of triple points ||
% || <grainBoundary.grainBoundary.html |boundary|> || list of grain boundary segments || <grainBoundary.grainBoundary.html |innerBoundary|> || list of subgrain boundary segments ||
% || |x|, |y| || coordinates of the outline vertices || <grain2d.centroid.html |centroid|> || area centroid ||
%
% A hole and an inclusion are the same enclosure viewed from opposite sides.
% The containing grain has a hole, and the contained grain is an inclusion.

% load sample EBSD data in its specimen plotting frame
plottingConvention.default('y↑→x');
mtexdata forsterite silent

% restrict the map to a region of interest and indexed measurements
ebsd = ebsd(inpolygon(ebsd,[5 2 10 5]*10^3));
ebsd = ebsd('indexed');

% reconstruct and smooth the grains
[grains,ebsd] = calcGrains(ebsd,'angle',5*degree,'minPixel',5);
grains = smoothBoundary(grains,5);
mapGrains = grains;

% plot forsterite orientations and the reconstructed boundary network
plot(ebsd('Fo'),ebsd('Fo').orientations,'ipfDirection',zvector)
hold on
plot(grains.boundary,'lineWidth',2)
hold off

%%
% The black network separates the reconstructed grains. Smoothing has
% removed the square-grid staircase while retaining the larger-scale turns
% of the boundaries. It is a measurement choice, not recovered sub-pixel
% detail.
%
% A grain touching the map edge continues beyond the measured field. Its
% visible area and outline are truncated, so we exclude such grains from
% the per-grain comparisons below. A standardised average grain-size method
% may prescribe a different edge-counting rule.

grains = grains(~grains.isBoundary);

%% Pixel count and area
%
% Size comes in two forms: the number of measurements assigned to a grain
% and the area occupied by its observed section.

grains(9).numPixel
grains(9).area

%%
% |numPixel| is a count, while |area| is in the square of the map unit. They
% are proportional only when one step size is used throughout the map. The
% count is useful during reconstruction because |'minPixel'| is expressed
% in it. Physical area is usually the quantity to report.
%
% The number-weighted area distribution is strongly skewed.

close all
histogram(grains.area)
xlabel('grain area')
ylabel('number of grains')

%%
% Nearly every grain falls into the first bar. The plot answers how many
% grains have each area, so numerous small grains dominate even when they
% occupy little of the section.
%
% Weighting each grain by its area asks a different question: what fraction
% of the observed section belongs to grains in each size class?
% <grain2d.hist.html |hist(grains)|> draws grouped bars, one colour per
% indexed phase.

hist(grains); %#ok<HIST>

%%
% The small-grain bar is much less dominant after area weighting. Each bar
% height is now a percentage of the analysed section rather than a grain
% count. <grain2d.histogram.html |histogram(grains)|> draws the same values
% as overlaid phase histograms instead of side-by-side bars.

histogram(grains);

%%
% The phase distributions overlap; they are not stacked and their heights
% should not be added by eye. The many tiny grains remain in the list, but
% they contribute little area. The largest forsterite grain and its fraction
% of the analysed interior-grain area are printed below.

forsteriteArea = grains('Fo').area;
largestForsteriteArea = max(forsteriteArea)
largestForsteriteFraction = largestForsteriteArea ./ sum(grains.area)

%%
% The largest forsterite section covers 2.805 mm² and accounts for 15.31
% percent of the analysed interior-grain area. The many small grains have
% not gone away; area weighting has changed how much each one counts.

%% Boundary segments and perimeter
%
% |boundarySize| and |perimeter| are the same pair one dimension lower: a
% count of outline segments and their total length.

grains(9).boundarySize
grains(9).perimeter

%%
% Both are shortcuts for asking the grain boundary itself, which is a list
% of segments with one <grainBoundary.segLength.html |segLength|> each.

length(grains(9).boundary)
sum(grains(9).boundary.segLength)

%%
% The two pairs react differently to processing. |numPixel| remains tied to
% the measurements, whereas smoothing resamples the outline and can change
% both |boundarySize| and |perimeter|. By default, |perimeter| measures only
% the outer loop. The option |'withInclusion'| adds the loops around grains
% enclosed inside it.

%% Diameter and the equivalent circle
%
% The <grain2d.diameter.html |diameter|> is the longest distance between any
% two vertices of the outline. It is one of the directional caliper or
% Feret measures developed in
% <ProjectionBasedParameters.html Projection Parameters>.

grains(9).diameter

%%
% Another characteristic length comes from the circle with the same area.
% Its <grain2d.equivalentRadius.html |equivalentRadius|> gives the diameter
% below. No shape of that area has a shorter perimeter than the circle, and
% no grain of that area has a smaller maximum diameter.

2*grains(9).equivalentRadius

grains(9).equivalentPerimeter

%% Departure from a circle
%
% The <grain2d.shapeFactor.html |shapeFactor|> is
% $F=P/P_{\mathrm{eq}}$, where $P$ is the perimeter and
% $P_{\mathrm{eq}}$ is the equivalent perimeter. It is at least 1 and grows
% when a grain is elongated, indented, or ragged.
%
% Other literature sometimes calls $4\pi A/P^2=1/F^2$ the circularity or
% even the shape factor. State the formula when comparing values between
% software or publications.

shapeFactorSummary = [min(grains.shapeFactor),...
  median(grains.shapeFactor),max(grains.shapeFactor)]

plot(grains,grains.shapeFactor)
mtexColorbar('title','shape factor')

%%
% The minimum, median, and maximum are 1.058, 1.221, and 1.662. In the map,
% the high-value yellow grains are visibly lobed or elongated, while compact
% grains are dark blue. The measure cannot tell those causes apart: a smooth
% ellipse and a round grain with a frayed boundary can have the same value.
%
% The same information can be scaled as the relative difference between
% the <grain2d.perimeter.html |perimeter|> and the
% <grain2d.equivalentPerimeter.html |equivalentPerimeter|>.

relativePerimeter = (grains.perimeter - grains.equivalentPerimeter) ...
  ./ grains.perimeter;
plot(grains,relativePerimeter)
setColorRange([0,0.5])
mtexColorbar('title','relative perimeter difference')

%%
% Round shapes are near zero in this map. The quantity equals $1-1/F$ and
% is bounded above by 1 rather than being unbounded.
%
% A third measure compares the perimeter with the grain's own convex hull.
% <grain2d.paris.html |paris|>, the Percentile Average Relative Indented
% Surface, is reported in percent. An elongated but smoothly bounded grain
% has a small |paris| because its hull follows it closely. Bays and inlets
% increase it. Inclusion loops are excluded from both |paris| and the
% default perimeter. <HullBasedParameters.html Convex Hull Parameters>
% develops this comparison.

parisSummary = [median(grains.paris),max(grains.paris)]
C = corrcoef(grains.shapeFactor,grains.paris);
shapeParisCorrelation = C(1,2)

[~,shapeFactorExtreme] = max(grains.shapeFactor);
[~,parisExtreme] = max(grains.paris);
sameExtremeGrain = shapeFactorExtreme == parisExtreme

[~,mapShapeFactorExtreme] = max(mapGrains.shapeFactor);
[~,mapParisExtreme] = max(mapGrains.paris);
sameExtremeWithEdgeGrains = mapShapeFactorExtreme == mapParisExtreme

plot(grains,grains.paris)
mtexColorbar('title','paris')

%%
% The median |paris| is 2.77 percent, its maximum is 43.30, and its
% correlation with |shapeFactor| is 0.472. Among the complete grains, both
% measures select the same extreme grain. In the full plotted map, including
% truncated edge grains, they select different extremes. Their partial
% agreement is the point: |shapeFactor| counts elongation as a departure
% from a circle, whereas |paris| does not. The changed selection also shows
% why the edge-grain rule belongs in a reported method.

%% Perimeter-area fractal dimension
%
% Boundary length depends on the scale at which it is measured. This is the
% coastline problem. A perimeter-area fractal dimension describes how
% rapidly perimeter grows with grain size across a population and has been
% related to dynamic-recrystallisation conditions.
%
% This is a population estimator, not a box-counting dimension of one grain.
% It assumes that the grains are statistically self-similar over the fitted
% size range. If $P\propto r^D$, a straight line fitted to
% $\log(P)$ against $\log(r)$ has slope $D$. A family of geometrically
% similar smooth grains has $D=1$; increasingly convoluted boundaries can
% give a slope between 1 and 2.

% reconstruct all indexed grains in the full data set once
mtexdata forsterite silent
rawGrains = calcGrains(ebsd('indexed'));
rawGrains = rawGrains(~rawGrains.isBoundary);

% use five smoothing iterations for the main estimate
grains = smoothBoundary(rawGrains,5);

close all
scatter(grains.equivalentRadius,grains.perimeter)
xlabel('equivalent radius')
ylabel('perimeter')

% set both axes to logarithmic scales
logAxis(gca,[10,10^4],[10^2,10^5])

% fit and draw a straight line in log space
ab = polyfit(log(grains.equivalentRadius),log(grains.perimeter),1);
fitRadius = [10,10^4];
hold on
plot(fitRadius,exp(ab(2) + ab(1) * log(fitRadius)),'LineWidth',3)
hold off

%%
% The points scatter around the fitted line because individual grains are
% not scaled copies of one shape. The fitted slope, 1.011, is the estimated
% perimeter-area fractal dimension.

fractalDimension = ab(1)

%%
% Treat the estimate with care. Pixel spacing sets the smallest visible
% feature, small grains provide very few boundary samples, and smoothing
% removes exactly the excursions that the measure is intended to count.
% The next comparison reuses one reconstruction so that only the boundary
% processing changes. The zero-iteration case is the actual pixel
% staircase; calling |smoothBoundary(rawGrains,0)| would still simplify and
% resample it.

for iter = [0 5 25]
  if iter == 0
    g = rawGrains;
  else
    g = smoothBoundary(rawGrains,iter);
  end
  ab = polyfit(log(g.equivalentRadius),log(g.perimeter),1);
  fprintf('%2d smoothing iterations: fractal dimension %.3f\n',iter,ab(1));
end

%%
% The pixel staircase gives 1.128 because grid corners add artificial
% length. Five iterations give 1.011, while 25 iterations push the estimate
% to 0.965, below the range of a self-similar plane curve. That is a
% diagnostic that the estimator's assumptions have failed, not a physical
% property of the rock. Compare specimens only after matching the pixel
% resolution, grain-size cutoff, segmentation, and smoothing procedure.

%% Further reading
%
% * <https://www.iso.org/standard/74309.html ISO 13067:2020>, _Microbeam
% analysis - Electron backscatter diffraction - Measurement of average
% grain size_. It distinguishes measurements on a two-dimensional section
% from inferences about three-dimensional grain size.
%
% * R. Heilbronner and S. Barrett,
% <https://doi.org/10.1007/978-3-642-10343-8 Image Analysis in Earth
% Sciences: Microstructures and Textures of Earth Materials>, Springer,
% 2014. The textbook develops two- and three-dimensional grain-size
% distributions together with particle and surface fabrics.
%
% * B. B. Mandelbrot,
% <https://doi.org/10.1126/science.156.3775.636 How Long Is the Coast of
% Britain? Statistical Self-Similarity and Fractional Dimension>, _Science_
% 156 (1967), 636-638. This paper explains why measured length depends on
% scale.
%
% * M. Takahashi and H. Nagahama,
% <https://doi.org/10.1016/S0169-4332(01)00417-2 The Sections' Fractal
% Dimension of Grain Boundary>, _Applied Surface Science_ 182 (2001),
% 297-301. It gives the perimeter-diameter construction used above for
% dynamically recrystallised quartz.
%
% * S. E. Johnson et al.,
% <https://doi.org/10.1029/2024JB030866 EBSD-Based Calibration of
% Differential Stress From Experimentally Deformed Black Hills Quartzite
% Using the Perimeter-Area Fractal Dimension>, _Journal of Geophysical
% Research: Solid Earth_ 130 (2025), e2024JB030866. The study tests pixel
% spacing, minimum grain size, and MTEX smoothing before calibration.

%% Next
%
% <EllipseBasedParameters.html Ellipse Based Shape Parameters> replaces each
% grain by a moment-equivalent ellipse and introduces shape preferred
% orientation. <HullBasedParameters.html Convex Hull Parameters> isolates
% indentations, while <ProjectionBasedParameters.html Projection Parameters>
% measures directional widths. Continue to
% <GrainBoundaries.html Grain Boundaries> when the segments and junctions,
% rather than whole-grain outlines, are the subject.
%
%#ok<*NOPTS>
