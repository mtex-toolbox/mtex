%% Grain Tutorial
%
%%
% This tutorial starts with an EBSD map and turns its measurements into
% grains. It then compares pixel and grain orientations, selects grains by
% their properties, and previews the boundaries between two phases.
%
% Read <EBSDTutorial.html the EBSD tutorial> first if phase maps,
% orientation maps, or MTEX selections are new to you.
% <GeneralConcepts.html General Concepts> explains how one MTEX object holds
% a vectorized list of measurements or grains.
%
% The specimen is the mylonite used by Bachmann, Hielscher and Schaeben in
% <https://doi.org/10.1016/j.ultramic.2011.08.002 Grain detection from 2d
% and 3d EBSD data>. The data are courtesy of Daniel Rutte and Bret Hacker,
% Stanford University.

plottingConvention.default('y↑→x');

% load the example map and display its summary
mtexdata mylonite

% plot the phases
plot(ebsd)

%%
% The displayed |EBSD| summary reports four indexed phases and the scan
% extent. The phase map shows quartz ribbons between mixed feldspar layers,
% with smaller biotite regions.
%
% The full map is too large for the details below. We continue with a
% rectangle written as |[xmin, ymin, width, height]|.

region = [19000 1500 4000 1500];

% mark the selected region on the phase map
rectangle('Position',region,'EdgeColor','black','LineWidth',2)

%%
% <EBSD.inpolygon.html |inpolygon|> selects the measurements inside the
% rectangle. Its displayed summary confirms the new extent and phase counts.

ebsdRegion = ebsd(inpolygon(ebsd,region))

%% Grain reconstruction
%
% A grain is a phase-homogeneous, spatially connected region of EBSD pixels
% produced by segmentation. A phase change between neighbouring pixels is
% always a grain boundary.
%
% MTEX gives each measurement a spatial cell and links neighbouring cells
% that meet the segmentation criterion. Grain outlines follow the cell
% interfaces left between different linked groups.
%
% For neighbours of the same phase, <EBSD.calcGrains.html |calcGrains|>
% draws a boundary when their minimum symmetry-equivalent misorientation
% reaches the chosen angle. The test is local between neighbours.
% Consequently, a gradual orientation gradient can connect two ends of one
% grain even when those ends differ by more than the threshold.
%
% The 15 degree value below is an example parameter, not a universal grain
% definition. <GrainReconstruction.html Grain Reconstruction> explains how
% |'angle'|, |'minPixel'|, and |'alpha'| change the result.

% reconstruct grains and return the map with a grainId property
[grains,ebsdRegion] = calcGrains(ebsdRegion,'angle',15*degree);

% display the grain summary
grains

% plot the phase map of the selected region
plot(ebsdRegion)

% overlay the grain boundaries
hold on
plot(grains.boundary,'LineColor','black','LineWidth',1.5)
hold off

%%
% The grain summary reports a count for each phase and the number of
% boundary segments. In the figure, every outline follows interfaces
% between measurement cells rather than a hand-drawn curve.
% Each segment lies between neighbouring pixels assigned to different grains.
%
% Notice the many tiny polygons. Their size makes segmentation choices and
% spatial resolution important before any grain-size result is reported.

%% Pixel orientations and grain mean orientations
%
% A phase map says where quartz was indexed, but not how its lattice is
% oriented. We first colour every quartz measurement with an inverse pole
% figure key and draw the other phases pale.

quartzEbsd = ebsdRegion('Quartz');
quartzGrains = grains('Quartz');
ipfKey = ipfColorKey(quartzEbsd);

% plot the non-quartz grains as context
plot(grains({'Andesina','Biotite','Orthoclase'}),'FaceAlpha',0.4)

% add the quartz measurements using one explicit colour key
hold on
plot(quartzEbsd,ipfKey.orientation2color(quartzEbsd.orientations))
plot(grains.boundary,'LineColor','black')
legend off
hold off

%%
% Many boundaries coincide with abrupt colour changes. Colour variation
% also remains inside some grains, where it may represent orientation noise
% or a real lattice gradient.
%
% An IPF colour records where one specimen direction lies in the crystal.
% It is not a complete orientation-distance scale, so colour alone cannot
% validate a reconstruction. <EBSDIPFMap.html IPF Maps> explains the key.

% display the colour key used for both orientation maps
close all
plot(ipfKey)

%%
% The key identifies the crystal direction represented by each colour. The
% same key can now colour one mean orientation per quartz grain.

% plot the non-quartz grains as context
plot(grains({'Andesina','Biotite','Orthoclase'}),'FaceAlpha',0.4)

% colour each quartz grain by its mean orientation
hold on
plot(quartzGrains,ipfKey.orientation2color(quartzGrains.meanOrientation))
legend off
hold off

%%
% Compared with the pixel map, each quartz grain now has one flat colour.
% The mean suppresses intragranular variation rather than proving that the
% variation was noise. <GrainOrientationParameters.html Orientation
% Parameters> measures that variation explicitly.

%% Selecting and measuring grains
%
% Grain properties are arrays with one value per grain. Here |numPixel|
% records the number of measurements assigned to a grain, while
% <grain2d.area.html |area|> measures its sectional area in the scan unit.
%
% The next selection keeps quartz grains with at least ten measurements and
% removes grains cut by the edge of the map. The value ten only illustrates
% a logical selection; it is not a recommended quality criterion.

selectedQuartz = grains('Quartz',...
  grains.numPixel >= 10 & ~grains.isBoundary)

%%
% The displayed <grain2d.grain2d.html |grain2d|> summary reports what the
% selection retained. Because |calcGrains| returned |ebsdRegion| with a
% |grainId| property, the selection also leads back to its measurements.

selectedMeasurements = ebsdRegion(selectedQuartz)

%%
% The measurement summary contains only quartz pixels assigned to the
% selected grains. The grains themselves can be coloured by area.

close all
plot(grains,'FaceColor','lightgray','FaceAlpha',0.3)
hold on
plot(selectedQuartz,selectedQuartz.area)
hold off
legend off
mtexColorbar('title','sectional grain area')

%%
% The coloured regions are the selected interior quartz grains, and their
% colour represents area rather than orientation. Removing edge grains
% avoids treating a clipped grain as if its full section had been measured.
%
% A two-dimensional section does not directly give three-dimensional grain
% volume. Step size, segmentation settings, and the treatment of small or
% notIndexed regions must also be fixed before specimens are compared.
% |notIndexed| is the phase for measurements whose diffraction patterns
% could not be indexed.
% <ShapeParameters.html Shape Parameters> develops these measurements.

%% Boundaries between two phases
%
% A phase boundary is not a separate type of object. It is a grain boundary
% whose two neighbouring grains differ in phase, selected here by two names.
%
% Every segment between andesina and orthoclase carries a misorientation.
% Its angle is the minimum over the symmetries of both phases.

close all

% select the boundary segments between two phases and display their summary
aoBoundary = grains.boundary('Andesina','Orthoclase')

% store one angle per boundary segment in radians
boundaryAngle = aoBoundary.misorientation.angle;

% highlight an illustrative part of the angular range
plot(grains,'FaceAlpha',0.4)
hold on
plot(aoBoundary(boundaryAngle > 160*degree),...
  'LineWidth',2,'LineColor','red')
hold off

%%
% The red traces are the segments above the illustrative 160 degree filter.
% This filter is applied after reconstruction and did not define the grains.
% A phase change already made every andesina to orthoclase contact a boundary.
%
% One physical interface is represented by many connected segments. A
% segment count is therefore neither a count of interfaces nor a set of
% independent observations.

%%
% Weighting by <grainBoundary.segLength.html |segLength|> gives longer
% interfaces proportionally more influence. It avoids weighting every
% tessellation segment equally.

figure

% bin the angles and sum the segment lengths falling into each bin
[~,edges,binId] = histcounts(boundaryAngle./degree);
traceLength = accumarray(binId,aoBoundary.segLength,[numel(edges)-1 1]);

histogram('BinEdges',edges,'BinCounts',traceLength)
xlabel('minimum misorientation angle (degrees)')
ylabel('boundary trace length')
title('Andesina to orthoclase orientation relationships')

%%
% Notice how the traced boundary length is distributed across the angular
% range. This plot is descriptive, not evidence that either phase pair is
% related more often than chance.
%
% Such a claim needs a stated reference distribution and consistent
% sampling weights. Continue with <BoundaryTutorial.html the grain boundary
% tutorial>, then <BoundaryMisorientations.html Boundary Misorientations>
% and <MisorientationDistributionFunction.html Misorientation Distribution
% Functions>.

%% Next
%
% <SelectingGrains.html Selecting Grains> covers selection by position,
% phase, property, and orientation. <GrainSpatialPlots.html Grain Plots> and
% <ShapeParameters.html Shape Parameters> develop grain measurements.
%
% Grain mean orientations can also be used for pole figures and ODFs.
% Giving every grain one vote answers a different question from weighting
% pixels or grain area; <EBSD2ODF.html ODF Estimation> explains the choice.
%
% For your own data, read <EBSDReferenceFrame.html Reference Frame> before
% interpreting orientation-dependent results. The reconstructed regions
% continue into the <Grains.html Grains> chapter, while their interfaces
% continue into <GrainBoundaries.html Grain Boundaries>.

%% Further reading
%
% * F. Bachmann, R. Hielscher and H. Schaeben,
% <https://doi.org/10.1016/j.ultramic.2011.08.002 Grain detection from 2d
% and 3d EBSD data - Specification of the MTEX algorithm>, Ultramicroscopy
% 111 (2011), 1720-1733.
% * F.J. Humphreys, <https://doi.org/10.1023/A:1017973432592 Grain and
% subgrain characterisation by electron backscatter diffraction>, Journal
% of Materials Science 36 (2001), 3833-3854.
% * A.J. Schwartz et al., editors,
% <https://doi.org/10.1007/978-0-387-88136-2 Electron Backscatter Diffraction
% in Materials Science>, 2nd ed., Springer, 2009.
% * <https://www.iso.org/standard/74309.html ISO 13067:2020> specifies EBSD
% procedures for average grain size from two-dimensional sections and warns
% that highly deformed specimens require care.
% * <https://store.astm.org/e2627-13r19.html ASTM E2627-13(2019)> covers
% EBSD grain-size measurement in fully recrystallized polycrystals. That
% scope does not include the deformed mylonite used on this page.

%%
%#ok<*NOPTS>
