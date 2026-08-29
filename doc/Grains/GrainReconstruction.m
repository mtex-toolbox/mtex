%% Grain Reconstruction
%
%%
% A *grain* is a phase-homogeneous, spatially connected region of EBSD pixels
% produced by segmentation. A phase change between neighbouring pixels is
% always a grain boundary. Within one phase, the usual segmentation rule asks
% whether the orientations differ by more than a chosen angle. The command
% that applies these rules is <EBSD.calcGrains.html |calcGrains|>.
%
% This page assumes that you can select and plot an
% <EBSDAnalysis.html EBSD map>. If the angle between two orientations is new
% to you, first see <MisorientationTheory.html Misorientation Theory>.
%
% Three settings shape the result. They are the boundary misorientation
% angle, the treatment of measurements that could not be indexed, and the
% minimum number of pixels returned as a grain.
% They are segmentation choices, not properties measured independently from
% the specimen. We take them one at a time on a map that exercises all three.

% import the data
plottingConvention.default('y↑→x');
mtexdata forsterite silent

% restrict it to a subregion of interest
ebsd = ebsd(inpolygon(ebsd,[5 2 10 5]*10^3))

% make a phase plot
plot(ebsd,'micronbar','off')

%%
% The colours are the phases: forsterite, enstatite and diopside. The white
% speckle is the first phase in the displayed summary, |notIndexed|. Its
% diffraction patterns could not be indexed. One measurement in five on this
% map is notIndexed. Most lie where boundaries will be reconstructed.

%% A first reconstruction
%
% We choose a 10 degree threshold and leave |'alpha'| and |'minPixel'| at
% their defaults. The displayed @grain2d summary is useful here: it reports
% the number of grains and their phases.

grains = calcGrains(ebsd,'angle',10*degree)

%%
% Each grain is one entry of the list, with its own phase, mean orientation,
% size and shape. The boundaries are stored separately in
% |grains.boundary|, which we plot on top of the map.

plot(ebsd,'micronbar','off')
hold on
plot(grains.boundary,'linewidth',1.5)
hold off

%%
% MTEX first partitions the measured surface into one spatial cell per
% measurement. Neighbouring cells are then connected or separated by the
% segmentation rule, and connected cells are collected into grains. On this
% regular grid, the cell edges lie between measurement points. The plotted
% boundaries therefore follow the grid in steps rather than passing through
% the points.
%
% Although a fifth of the map is notIndexed, only one grain is notIndexed:
% the long white bar right of centre. The other notIndexed pixels have been
% absorbed by adjacent grains. The section on |'alpha'| below explains this
% default behaviour.

%% The threshold angle
%
% The option |'angle'| sets the misorientation above which two neighbouring
% measurements of the same phase are separated by a boundary. Its default is
% 15 degrees. Values between 10 and 15 degrees are long-standing conventions,
% not measurements; see the discussion in <Grains.html the chapter opener>.
%
% On a recrystallised map like this one the exact value hardly matters.

for threshold = [2 5 10 15]*degree
  g = calcGrains(ebsd,'angle',threshold);
  fprintf('%2d degree threshold: %3d indexed grains\n',...
    round(threshold./degree),length(g('indexed')));
end

%%
% Between 5 and 15 degrees the printed count changes by less than one tenth.
% It rises sharply only at 2 degrees. Neighbouring measurements on this map
% are usually either far below all these thresholds or far above them.
% Few ambiguous pairs lie in between. This is a property of the material,
% not of the algorithm. It stops being true in the deformed example later on.

%% Measurements that were not indexed
%
% A notIndexed measurement is not missing from the map. Its diffraction
% pattern could not be indexed, and MTEX records that fact as the degenerate
% phase |notIndexed|. Like any other phase, a connected notIndexed area can
% form a grain with a boundary around it.
%
% Whether this is what you want depends on the patch. A wide unindexed region
% is part of the specimen about which you know nothing. It should remain a
% grain of its own. A one-pixel-wide seam along a grain boundary instead
% records indexing failure where two lattices overlap. Leaving such a seam
% creates a spurious grain between the indexed grains on either side.
%
% The option |'alpha'| controls the spatial closing that distinguishes these
% cases. Its value is a radius in multiples of the pixel spacing. A
% notIndexed area narrower than about |2*alpha| pixel spacings is absorbed by
% the surrounding grains, while a wider area survives. The default is
% |alpha = 3.1|.

for alpha = [0 1 3.1 6]
  g = calcGrains(ebsd,'angle',10*degree,'alpha',alpha);
  fprintf('alpha = %3.1f: %4d grains, %4d of them notIndexed\n',...
    alpha,length(g),length(g('notIndexed')));
end

%%
% With |alpha = 0| nothing is absorbed. The notIndexed pixels then contribute
% more than one thousand grains of their own, five times the number of
% indexed grains found with the default. Their seams also divide regions that
% should be single indexed grains, so the indexed count rises from 210 to
% 525. A closing radius of one pixel removes almost all of them. The default
% keeps only the wide notIndexed region, while |alpha = 6| absorbs that one
% too.
%
% The effect is easiest to see when the two extremes are drawn on the same
% part of the map.

region = [5 2 2 1.5]*10^3;
ebsdSub = ebsd(inpolygon(ebsd,region));

grainsSharp = calcGrains(ebsd,'angle',10*degree,'alpha',0);

newMtexFigure('layout',[1,2])

plot(ebsdSub,'micronbar','off')
hold on
plot(grainsSharp.boundary,'linewidth',1.5)
hold off
xlim(region(1)+[0 region(3)]), ylim(region(2)+[0 region(4)])

nextAxis
plot(ebsdSub,'micronbar','off')
hold on
plot(grains.boundary,'linewidth',1.5)
hold off
xlim(region(1)+[0 region(3)]), ylim(region(2)+[0 region(4)])

%%
% On the left, at |alpha = 0|, isolated white pixels are fenced off and white
% seams cut the blue forsterite into pieces. On the right, at the default,
% the same white measurements remain visible and remain notIndexed, but they
% no longer separate the surrounding grains. The isolated orange pixels keep
% boundaries on both sides because they are indexed diopside. The
% |'minPixel'| option below deals with such small indexed grains.

%% Small indexed grains
%
% Even with the unindexed seams absorbed, a threshold criterion produces
% grains of one, two or three pixels where a few measurements are
% mis-indexed. On this map the isolated indexed islands are implausible, but
% a small grain can be real in another specimen. Inspect the map before
% choosing a cutoff. The option |'minPixel'| removes an indexed grain below
% the cutoff from the returned list. It marks that grain's measurements
% notIndexed rather than merging them into a neighbour.

for minPixel = [1 5 10]
  g = calcGrains(ebsd,'angle',10*degree,'minPixel',minPixel);
  fprintf('minPixel = %2d: %3d indexed grains, holding %4.1f%% of the indexed pixels\n',...
    minPixel,length(g('indexed')),100*sum(g('indexed').numPixel)/nnz(ebsd.isIndexed));
end

%%
% More than half of the indexed grains contain fewer than five pixels. Yet
% together they hold only about one indexed measurement in one hundred.
% Removing them changes count-based grain statistics greatly. It scarcely
% changes the large-scale microstructure visible in the map. For a
% quantitative study, report the cutoff and test nearby values.

%% Smoothing the boundaries
%
% Because the boundaries run between measurement points, they follow the
% measurement grid in steps - the staircase effect. This is a property of
% the reconstruction, not of the material. It biases measurements such as
% boundary length and direction. The command
% <grain2d.smoothBoundary.html |smoothBoundary|> first simplifies the
% staircase, then resamples the boundary at even spacing, and finally applies
% a smoothing filter. With the default filter, its numeric argument is the
% number of Laplacian smoothing iterations.

grains = calcGrains(ebsd,'angle',10*degree,'minPixel',5);
grains = smoothBoundary(grains,5);

plot(ebsd,'micronbar','off')
hold on
plot(grains.boundary,'linewidth',1.5)
hold off

%%
% The steps are gone while the larger-scale course of each boundary remains.
% Smoothing is still a measurement choice rather than recovered sub-pixel
% truth, and the default filter can shrink grains. How far to smooth and
% which filter to use are the subject of
% <GrainSmoothing.html Grain Boundary Smoothing>.

%% Keeping map and grains together
%
% |calcGrains| returns a second output: the map with one per-pixel property
% added. The |grainId| property records which grain contains each
% measurement. Almost every map-to-grain operation in this chapter needs it.
% It is therefore worth requesting from the start.

[grains, ebsd] = calcGrains(ebsd,'angle',10*degree,'minPixel',5);

% the measurements inside the largest grain
[~,id] = max(grains.numPixel);
ebsd(grains(id))

%%
% The displayed summary belongs to the measurements in the largest grain.
% The grain object in |ebsd(grains(id))| supplies its stored grain id. That id
% need not equal its position in a shortened or reordered grain list.
% <SelectingGrains.html Selecting Grains> develops this distinction.
%
% The returned map contains the same measurement positions, but it is not an
% untouched copy of the import. Absorption through |'alpha'| and removal
% through |'minPixel'| rewrite affected phases. Reconstructing grains from
% this returned map a second time is therefore not meaningful.

%% Grain reconstruction in heavily deformed microstructures
%
% Everything above rests on one assumption: that a misorientation between
% two neighbouring pixels means the same thing everywhere on the map. A
% single threshold should then separate "inside a grain" from "across a grain
% boundary". In a heavily deformed material that assumption fails from both
% sides. Inside a grain the lattice is bent. Small neighbour-to-neighbour
% changes can accumulate to tens of degrees across it. Between two grains,
% the misorientation may be below any threshold one would call high angle.
%
% We use an austenitic steel deformed in situ. It was indexed by spherical
% pattern matching rather than by the Hough transform. Its orientation noise
% is about 0.1 degree. This is roughly one order of magnitude below that of a
% typical Hough-indexed map, so the deformation substructure is resolved.

plottingConvention.default('y↓→x');
mtexdata EMSphinx silent

% the deformed austenite
ebsd = ebsd('Iron fcc');

plot(ebsd,ebsd.orientations,'ipfDirection',zvector)

%%
% The colour gradients within the elongated grains show the bent lattice. We
% zoom into a smaller region to see what a threshold makes of it.

region = [40 30 80 60];
ebsd = ebsd(inpolygon(ebsd,region));

plot(ebsd,ebsd.orientations,'ipfDirection',zvector)

%%
% At the usual 10 degree threshold, the reconstruction misses every boundary
% below that angle. The figure shows several such low-angle boundaries with
% no black line on them.

grains = smoothBoundary(calcGrains(ebsd,'angle',10*degree,'minPixel',10),5);

plot(ebsd,ebsd.orientations,'ipfDirection',zvector)
hold on
plot(grains.boundary,'linewidth',1.5)
hold off

%%
% Lowering the threshold does not solve the problem. Before it reaches all
% the boundary angles of interest, it cuts through the bent lattice inside
% grains. The dense black lines in the next figure follow contours of the
% smooth orientation field rather than physical grain boundaries.

grains = smoothBoundary(calcGrains(ebsd,'angle',0.5*degree,'minPixel',10),5);

plot(ebsd,ebsd.orientations,'ipfDirection',zvector)
hold on
plot(grains.boundary,'linewidth',1.5)
hold off

%% Fast multiscale clustering
%
% The way out is to stop asking about pixel pairs in isolation. Fast
% multiscale clustering, <gbcFMC.gbcFMC.html |gbcFMC|>, builds a hierarchy of
% progressively coarser pixel aggregates. It fits the lattice gradient within
% each aggregate. It then compares the residual misorientation between
% aggregates with their internal orientation spread. A 1 degree step between
% two uniform aggregates can therefore be a boundary. A comparable step
% explained by bending within one grain is not. FMC has no threshold angle.
%
% The option |'fmc'| selects this criterion. Its value is |cmaha|. This
% controls how sharply an unexpected residual misorientation suppresses the
% coupling between two aggregates. Larger values return more grains.

grains = calcGrains(ebsd,'fmc',0.5,'minPixel',10);
grains = smoothBoundary(grains,5);

plot(ebsd,ebsd.orientations,'ipfDirection',zvector)
hold on
plot(grains.boundary,'linewidth',1.5)
hold off

%%
% The low-angle boundaries missed by the 10 degree threshold now appear,
% without the dense spurious contours produced by the 0.5 degree threshold.
%
% Raising |cmaha| resolves more of the substructure within those grains,
% including the dislocation cells that carry the deformation.

grains = calcGrains(ebsd,'fmc',1.5,'minPixel',10);
grains = smoothBoundary(grains,5);

plot(ebsd,ebsd.orientations,'ipfDirection',zvector)
hold on
plot(grains.boundary,'linewidth',1.5)
hold off

%%
% Finally, we apply the same reconstruction to the full map. Unlike a local
% threshold criterion, FMC clusters the entire map at once rather than one
% pixel pair at a time, which is why this takes a few seconds. The
% |'verbose'| flag prints how far the hierarchy coarsened and the scales
% from which the final grains were read.

mtexdata EMSphinx silent
ebsd = ebsd('Iron fcc');

grains = calcGrains(ebsd,'fmc',1.5,'minPixel',10,'verbose');
grains = smoothBoundary(grains,5);

plot(ebsd,ebsd.orientations,'ipfDirection',zvector)
hold on
plot(grains.boundary)
hold off

%% More ways to reconstruct grains
%
% The threshold angle and fast multiscale clustering are two of several
% criteria by which |calcGrains| can separate neighbouring pixels. MTEX
% represents them as interchangeable
% <grainBoundaryCriterion.html |grainBoundaryCriterion|> objects.
% <GrainReconstructionAdvanced.html Advanced Grain Reconstruction> explains
% phase-dependent and soft thresholds. It also covers segmentation by another
% property and custom criteria. <GrainReconstructionMCL.html Markovian
% Clustering> turns criterion weights into grains in a second way, by
% clustering the map instead of taking connected components.
%
% Continue with <GrainSpatialPlots.html Plotting Grains>, then
% <SelectingGrains.html Selecting Grains>. The latter uses the |grainId|
% relationship established above. The resulting boundary network is the
% subject of <GrainBoundaries.html Grain Boundaries>.

%% References
%
% * F. Bachmann, R. Hielscher and H. Schaeben, "Grain detection from 2d and
% 3d EBSD data - Specification of the MTEX algorithm", _Ultramicroscopy_ 111
% (2011), 1720-1733,
% <https://doi.org/10.1016/j.ultramic.2011.08.002 doi:10.1016/j.ultramic.2011.08.002>.
% This paper derives the Voronoi-cell reconstruction used by |calcGrains|.
%
% * C. McMahon et al., "Boundary identification in EBSD data with a
% generalization of fast multiscale clustering", _Ultramicroscopy_ 133
% (2013), 16-25,
% <https://doi.org/10.1016/j.ultramic.2013.04.009 doi:10.1016/j.ultramic.2013.04.009>.
%
% * R. Hielscher, F. Bartel and T. B. Britton, "Gazing at crystal balls:
% Electron backscatter diffraction pattern analysis and cross correlation on
% the sphere", _Ultramicroscopy_ 207 (2019), 112836,
% <https://doi.org/10.1016/j.ultramic.2019.112836 doi:10.1016/j.ultramic.2019.112836>.
% For a direct precision comparison with Hough indexing, see G. Sparks et al.,
% _Ultramicroscopy_ 222 (2021), 113187,
% <https://doi.org/10.1016/j.ultramic.2020.113187 doi:10.1016/j.ultramic.2020.113187>.
%
% * <https://www.iso.org/standard/74309.html ISO 13067:2020> describes EBSD
% measurement of average grain size. It warns that highly deformed specimens
% require careful interpretation. <https://doi.org/10.1520/E2627-13R19 ASTM
% E2627-13(2019)> applies to fully recrystallised polycrystalline materials.
% Both make reconstruction choices part of the reported measurement method.
