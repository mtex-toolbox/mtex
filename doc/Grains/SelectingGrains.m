%% Selecting Grains
%
%%
% A @grain2d variable is a list of grains. Selecting grains means indexing
% that list by position, phase, property, spatial coordinates, or mean
% orientation. Every selection is another grain list, so selections can be
% applied one after another.
%
% This page assumes that you have reconstructed grains as described in
% <GrainReconstruction.html Grain Reconstruction>. It also assumes that you
% can draw them as in <GrainSpatialPlots.html Plotting Grains>.

close all;

% load sample EBSD data set
plottingConvention.default('y↑→x');
mtexdata forsterite silent

% restrict it to a subregion of interest
ebsd = ebsd(inpolygon(ebsd,[5 2 10 5]*10^3));

% reconstruct grains and store their ids with the measurements
[grains,ebsd] = calcGrains(ebsd,'angle',5*degree,'minPixel',5,'alpha',6);

% smooth the boundaries
grains = smoothBoundary(grains,5);

% plot forsterite by orientation
plot(ebsd('Fo'),ebsd('Fo').orientations,'ipfDirection',zvector)

% plot the other two phases in grey
hold on
plot(ebsd('En'),'FaceColor','lightgray')
plot(ebsd('Di'),'FaceColor','darkgray')
plot(grains.boundary,'lineWidth',2)
hold off

%%
% The black network outlines every reconstructed grain. The forsterite
% measurements retain their orientation colours, while the two minor phases
% are grey so that later highlights remain easy to see.

%% By mouse
%
% <grain2d.selectInteractive.html |selectInteractive|> installs a mouse
% callback on the current figure. A click selects one grain, and additional
% clicks extend the selection. The global variable |indSelected| stores the
% selected positions in the current grain list.

selectInteractive(grains,'lineColor','gold')

clear global indSelected
global indSelected

%%
% Nobody clicks while this page is published. We therefore set
% |indSelected| to the list position of the grain at a known coordinate.

indSelected = grains.id2ind(grains(9000,3500).id);

mouseGrains = grains(indSelected)

hold on
plot(mouseGrains.boundary,'lineWidth',4,'lineColor','gold')
hold off

%%
% The gold outline marks the selected grain. If several grains had been
% clicked, every selected outline would be gold and |mouseGrains| would
% contain all of them.

%% By position
%
% The expression |grains(x,y)| returns the grain containing the point
% |(x,y)| in map coordinates. It needs neither a figure nor a mouse click.

x = 12000;
y = 4000;

hold on
plot(grains(x,y).boundary,'lineWidth',4,'lineColor','blue')
plot(x,y,'Marker','s','MarkerFaceColor','k','MarkerSize',10,...
  'MarkerEdgeColor','w','DisplayName','A')
hold off

%%
% Marker A lies inside the thick blue outline. The coordinate is used for
% the lookup; its location in the current axes does not affect the result.

%% By phase
%
% A grain is phase-homogeneous. A mineral name therefore selects every
% grain of that phase, and the displayed summary reports what came back.

forsteriteGrains = grains('forsterite')

%%
% The mineral name is the readable form of a condition on |phase|. This
% property stores one imported phase number per grain.

firstFivePhase = grains(1:5).phase

%% By a property
%
% A grain property has one value per grain. MATLAB operations on numeric
% arrays can therefore build indices from any such property. We begin with
% <grain2d.area.html |area|>.

grainArea = grains.area;

plot(grains,grainArea)

%%
% Large grains are bright and small grains are dark. This map shows where
% the extremes lie before any threshold is imposed.
%
% <matlab:doc('max') |max|> returns the largest value and its position in
% the list. That position is an index, not a persistent grain ID.

[maxArea,maxIndex] = max(grainArea)

hold on
plot(grains(maxIndex).boundary,'lineColor','red','lineWidth',4)
hold off

%%
% The red outline encloses the brightest grain in the area map. Sorting
% generalises this selection from one grain to the largest few.

[sortedArea,sortedIndex] = sort(grainArea,'descend');

% select the second to fifth largest grains
hold on
plot(grains(sortedIndex(2:5)).boundary,'lineColor','orange','lineWidth',4)
hold off

%%
% The orange outlines mark ranks two through five. The largest grain remains
% identifiable by its red outline from the preceding selection.

%% By a condition
%
% A logical array with one value per grain can index the list directly.
% Here it selects every grain at least one quarter the size of the largest.

condition = grainArea > maxArea/4;

hold on
plot(grains(condition).boundary,'lineColor','yellow','lineWidth',4)
hold off

%%
% The yellow outlines include more grains than the fixed rank selection.
% Their membership follows an area threshold rather than a chosen count.
%
% Conditions may be combined. The next selection requires a perimeter above
% 6000 map units and at least 600 measurements. The pixel-count condition
% excludes grains too small for their outline to support a useful shape
% interpretation.

condition = grains.perimeter > 6000 & grains.numPixel >= 600;

selectedGrains = grains(condition)

plot(selectedGrains)

%%
% Only the grains satisfying both conditions remain in the plot. Empty
% spaces belong to grains excluded by at least one condition.

%% By orientation
%
% <grain2d.findByOrientation.html |findByOrientation|> selects grains whose
% mean orientation lies within a specified angle of a reference orientation.
% It accounts for crystal symmetry, so equivalent descriptions of the same
% lattice orientation are treated as the same orientation.
%
% We use the first gold grain from above as the reference and a threshold of
% 20 degrees.

referenceGrain = mouseGrains(1);
similarGrains = grains.findByOrientation(referenceGrain.meanOrientation,20*degree)

plot(ebsd('Fo'),ebsd('Fo').orientations,'ipfDirection',zvector)
hold on
plot(grains.boundary,'lineWidth',2)
plot(similarGrains.boundary,'lineWidth',4,'lineColor','gold')
hold off

%%
% Three grains are selected, and two share a boundary. Neighbours with mean
% orientations this close deserve a second look. The reconstruction may have
% split one grain, or the grains may have belonged together before another
% process separated them. <GrainMerge.html Merging Grains> develops this
% question.

%% List position and grain ID
%
% A list position answers "which entry of this variable?" A grain ID answers
% "which reconstructed grain?" They are initially often equal, but a subset
% keeps the original IDs while its positions start again at one.

plot(grains)
largeGrains = grains(grains.numPixel > 50);
text(largeGrains,largeGrains.id)

%%
% The labels are persistent grain IDs. They are not the positions of the
% labelled grains in |largeGrains|.

listPosition = 1;
grainId = largeGrains.id(listPosition);
fprintf('list position %d has grain ID %d\n',listPosition,grainId);

grainByPosition = largeGrains(listPosition);
grainById = largeGrains('id',grainId);
sameGrain = grainByPosition.id == grainById.id

%%
% |largeGrains(1)| selects by position. The form
% |largeGrains('id',grainId)| searches the stored IDs. The printed logical
% value confirms that both expressions identify the same grain here.

%% From grains back to measurements
%
% Every grain selection can be converted to the measurements it contains.
% This requires the |grainId| property that
% <EBSD.calcGrains.html |calcGrains|> returned with the map.

measurementsByGrain = ebsd(grainById)

measurementsById = ebsd(ebsd.grainId == grainId);
sameMeasurements = isequal(measurementsByGrain.id,measurementsById.id)

%%
% The first command displays the selected measurements. The printed logical
% value confirms that selecting by the grain object and matching the stored
% |ebsd.grainId| return the same subset.
%
% Applied to the largest grain, this relationship reveals the orientations
% measured inside one reconstructed grain.

largestGrain = grains(maxIndex);
largestGrainEbsd = ebsd(largestGrain);

plot(largestGrainEbsd,largestGrainEbsd.orientations,...
  'ipfDirection',zvector)
hold on
plot(largestGrain.boundary,'lineWidth',2)
hold off

%%
% The colours inside the black outline come from the individual
% measurements, not from one grain mean. On this grain the spread is small,
% under two and a half degrees, so the fill reads as a single shade and the
% unindexed white pixels are what stands out.
%
% A spread this size has to be measured rather than looked for. The mean and
% spread of the distribution are the subject of
% <GrainOrientationParameters.html Grain Orientation Parameters>.

%% Grains at the edge of the map
%
% A grain touching the map edge continues outside the measured region. Its
% observed area and shape describe only the measured piece. Remove such
% grains before calculating per-grain size or shape statistics with
% <grain2d.isBoundary.html |isBoundary|>.

interiorGrains = grains(~grains.isBoundary);
plot(interiorGrains)

%%
% The white band around the plot is occupied by the omitted edge grains.
% This exclusion is appropriate for comparing complete observed shapes.
% A standardised average grain-size measurement may prescribe a different
% boundary-counting rule, so follow the selected standard when reporting one.
%
% The boundary network shows what |isBoundary| tests. Each grain boundary
% segment stores the IDs of the two grains it separates. A segment at the
% map edge has no grain on one side, so the corresponding ID is zero.

% find segments with zero on one side
isOuterBoundary = any(grains.boundary.grainId == 0,2);

plot(grains)
hold on
plot(grains.boundary(isOuterBoundary),'lineColor','red','lineWidth',2)
hold off

%%
% The red segments form the outer rim of the measured region. Their nonzero
% IDs identify exactly the grains removed above.

boundaryGrainId = grains.boundary(isOuterBoundary).grainId;
boundaryGrainId(boundaryGrainId == 0) = [];
boundaryGrainId = unique(boundaryGrainId);

plot(grains('id',boundaryGrainId))

%%
% Only the edge grains remain. The explicit |'id'| lookup is required because
% the values came from |grainBoundary.grainId| rather than from list positions.

%% Next
%
% <ShapeParameters.html Shape Parameters> defines the area, perimeter, and
% other geometric properties used to build selections. The ellipse, convex
% hull, and projection pages that follow it provide further shape measures.
% <GrainOrientationParameters.html Grain Orientation Parameters> develops
% selections based on the orientation distribution inside each grain.
%
% Grain selections also lead back to the boundary network.
% <BoundarySelect.html Selecting Grain Boundaries> selects its segments, and
% <GrainMerge.html Merging Grains> uses selected boundaries to join grains.

%% Further reading
%
% * F. Bachmann, R. Hielscher, and H. Schaeben, "Grain detection from 2d
% and 3d EBSD data - Specification of the MTEX algorithm",
% _Ultramicroscopy_ 111 (2011), 1720-1733,
% <https://doi.org/10.1016/j.ultramic.2011.08.002
% doi:10.1016/j.ultramic.2011.08.002>. This paper derives the Voronoi-cell
% grain model whose IDs connect the grain list to the EBSD measurements.
%
% * <https://doi.org/10.1520/E2627-13R19 ASTM E2627-13(2019)>, _Standard
% Practice for Determining Average Grain Size Using Electron Backscatter
% Diffraction (EBSD) in Fully Recrystallized Polycrystalline Materials_.
%
% * <https://www.iso.org/standard/74309.html ISO 13067:2020>, _Microbeam
% analysis - Electron backscatter diffraction - Measurement of average
% grain size_. It distinguishes measurements on a two-dimensional section
% from inferences about three-dimensional grain size.

%#ok<*GVMIS>
