%% Fill Missing Data in Orientation Maps
%
% A |notIndexed| pixel is a real scan measurement whose diffraction pattern
% could not be indexed. Patterns measured at grain boundaries may combine
% signal from both neighbouring grains. Cracks, pores, scratches, surface
% contamination, or a phase omitted during indexing may also prevent a
% usable solution.
%
% A missing lattice site is different: no measurement occupies that
% position. This can happen when a scan is interrupted or when selecting or
% cropping a map leaves an irregular footprint. The experimental meanings
% of the two cases differ.
%
% For filling, both are the same: a position without an orientation.
% <EBSD.fill.html |fill|> assigns an orientation to every such position
% inside the scanned area, unless a mask excludes it. The assigned values
% are reconstructions, not measurements. Keep that provenance when the
% filled map is used for quantitative analysis.
%
% This page assumes familiarity with <EBSDSelect.html selecting EBSD data>,
% <EBSDIPFMap.html orientation maps>, and
% <GrainReconstruction.html grain reconstruction>. Reducing random error at
% positions that already have orientations is the separate subject of
% <EBSDDenoising.html Denoising Orientation Maps>.
% Filling also cannot correct an indexed but wrong orientation. The next
% page, <EBSDPseudoSymmetry.html Correcting Pseudo Symmetry>, treats one
% important source of that different error.

%% A complete map for comparison
%
% The first example is an orientation map of ferrite. The object summary
% reports the indexed ferrite measurements and the measurements whose phase
% is |notIndexed|.

% import the data in its measurement frame
plottingConvention.default('y↓→x');
mtexdata ferrite

% reconstruct the grain structure
grains = calcGrains(ebsd,'angle',12*degree,'minPixel',10);

% smooth the pixel staircase of the grain boundaries
grains = smoothBoundary(grains,5);

% plot the orientation map and its reconstructed grain boundaries
plot(ebsd,'ipfz')
hold on
plot(grains.boundary,'linewidth',1.5)
hold off

%%
% These boundaries come from the complete map. They are the reference for
% the boundaries reconstructed from sparse data below.

%% A very sparse measured data set
%
% To make the two filling methods easy to compare, we mark approximately
% 75 percent of the measurements as |notIndexed| and keep approximately 25
% percent. A marked pixel keeps its position and its other properties, but
% its orientation no longer counts as measured.

ebsdSub = ebsd;
ebsdSub(rand(length(ebsd),1) > 0.25) = 'notIndexed'

% plot the retained data
plot(ebsdSub,'ipfz')

%%
% The object summary gives the exact retained counts. The plot now consists
% of isolated coloured measurements, so the original grain shapes cannot be
% read from the orientation map alone.
%
% We first reconstruct grains from the retained quarter of the map. The
% option |'alpha'| closes narrow notIndexed regions during segmentation; it
% does not itself assign orientations. See
% <GrainReconstruction.html Grain Reconstruction> for that distinction.

% reconstruct the grain structure
[grainsSub,ebsdSub] = calcGrains(ebsdSub,'angle',9*degree, ...
  'minPixel',2,'alpha',15);

grainsSub = smoothBoundary(grainsSub,5);

hold on
% full data grain boundaries 
plot(grains.boundary,'linewidth',1.5,'LineColor','gray')

% sparse data grain boundaries 
plot(grainsSub.boundary,'linewidth',2.5)
hold off

%%
% The black boundaries come from the sparse data, the grey ones from the
% complete map. Almost everywhere the black line covers the grey one, so
% the sparse data recover the grain outlines. The sparse reconstruction
% also produces small extra grains, most visibly in the fine-grained region
% at the lower left.
%
% The boundaries also divide the map into interiors that may be filled and
% boundary corridors that should remain unresolved.

%% Filling by nearest-neighbour interpolation
%
% <EBSD.fill.html |fill|> repeats the orientation of the nearest measured
% pixel. It fills every |notIndexed| pixel and every missing lattice site
% inside the convex hull of the measurements. Pass the reconstructed grains
% whenever boundaries are known. A pixel then takes an orientation only from
% its own grain, so no orientation is carried across a grain boundary.
%
% Some pixels have no grain to fill from:
%
% * A pixel a grain boundary passes through belongs to no grain and stays
% |notIndexed|.
% * The pixels of a |notIndexed| grain stay |notIndexed|.
%
% Without the grains, a missing lattice site takes the grain of its nearest
% pixel instead, which fills most of the corridors along the boundaries as
% well.

ebsdSub_filled = fill(ebsdSub,grainsSub);

plot(ebsdSub_filled('indexed'), 'ipfz');
hold on
plot(grainsSub.boundary,'linewidth',1.5)
hold off

%%
% The grain interiors are now coloured. Sharp patches remain because a
% nearest-neighbour estimate repeats a measured orientation instead of
% creating a gradual orientation field. The white pixels lie on grain
% boundaries: they belong to no grain and remain |notIndexed|.

%% Filling with a denoising filter
%
% A denoising filter can estimate the missing orientations while smoothing
% the orientation field. <EBSD.smooth.html |smooth|> fills the same
% positions as |fill| before it filters, so pass it the grains as well.
% The @l1TVFilter used here is a total-variation method for rotation-valued
% data; its mathematical basis is described by
% <https://doi.org/10.3934/ipi.2016001 Bergmann et al. (2016)>.
%
% In contrast to nearest-neighbour interpolation, the filter can create a
% smooth transition between the estimated orientations. It is still an
% estimate, and the reconstructed grain boundaries still constrain it.
% Neither method reconstructs the grains again. The supplied boundaries
% remain the segmentation model for the filled map.

% interpolate and smooth the missing orientations
F = l1TVFilter;
F.alpha = 0.21;
ebsdSub_smoothed = smooth(ebsdSub,F,grainsSub);

plot(ebsdSub_smoothed('indexed'), 'ipfz')
hold on
plot(grainsSub.boundary,'linewidth',1.5)
hold off

%%
% The repeated colour patches have become continuous fields inside the
% grains. The white corridors still follow the reconstructed boundaries,
% so the smoother result has not erased the segmentation constraint.

%% Which data is interpolated
%
% In these grain-constrained calls, both |fill| and |smooth| recover the
% orientation, phase, and |grainId| of a filled position. The other
% per-pixel properties keep what the pixel had. The ferrite map carries
% these properties:

string(fieldnames(ebsdSub_filled.prop)).'

%%
% The properties |ci|, |fit|, and |iq| describe the recorded pattern or its
% indexing solution. The property |sem_signal| is the simultaneously
% recorded SEM signal. A pixel marked |notIndexed| keeps the values
% recorded with it. A lattice site that was never measured has none, so
% MTEX leaves each of them as |NaN| there.

plot(ebsdSub_filled,ebsdSub_filled.ci)
mtexColorbar('title','confidence index')

%%
% The confidence index therefore does not tell which orientations were
% filled. Take that from the map before filling: a pixel without an
% orientation then and with one afterwards was filled. A pixel |calcGrains|
% absorbed into a grain has the grain's phase but no orientation, so both
% conditions are needed.

noOrientation = ~ebsdSub.isIndexed | isnan(ebsdSub.rotations);
isFilled = noOrientation & ebsdSub_filled.isIndexed;
fprintf('%d of %d positions have a filled orientation\n', ...
  nnz(isFilled),length(ebsdSub_filled))

%%
% The command |smooth| provides a second marker. It stores a per-pixel
% property named |quality| and sets it to zero at every position that had no
% orientation before filtering: the |notIndexed| pixels and the missing
% lattice sites.

fprintf('%d positions had no orientation before smoothing\n', ...
  nnz(ebsdSub_smoothed.quality == 0))

%% Filling is not resampling
%
% If all per-pixel properties are needed at arbitrary query positions, use
% <EBSD.interp.html |interp|>. It transfers the complete record of the
% nearest existing measurement to a requested position. The page
% <EBSDInter.html Interpolating EBSD Data> develops that operation.
%
% The requested position must be covered by an existing measurement cell.
% Thus |interp| resamples a map but does not fill a hole. Conversely, |fill|
% reconstructs missing orientations but leaves the other properties as they
% were.

%% A multiphase geological map
%
% Geological samples often contain many notIndexed measurements because of
% relief, fractures, or phases that are difficult to index. The forsterite
% example also shows why phase and grain boundaries must constrain filling.

close all;
plottingConvention.default('y↑→x');
mtexdata forsterite silent
ebsd = ebsd(inpolygon(ebsd,[10 4 5 3]*10^3));

fprintf('The submap contains %.1f percent notIndexed measurements\n', ...
  100*nnz(~ebsd.isIndexed)/length(ebsd))

plot(ebsd,'ipfz')
hold on

% compute and smooth grains
[grains,ebsd] = calcGrains(ebsd,'angle',10*degree, ...
  'minPixel',3,'alpha',3);
grains = smoothBoundary(grains,5);

% plot the boundary of all grains
plot(grains.boundary,'linewidth',2)
hold off

%%
% The printed fraction is 29.0 percent, and most of that white is speckle
% inside the grains. Some grains are peppered with it while their
% neighbours are almost clean, and 48 percent of all white pixels sit more
% than one 50 micrometre step from any boundary between two indexed grains.
% The two large white patches are areas that could not be indexed at all,
% which segmentation kept as notIndexed grains of their own.
%
% Each phase is drawn with its own IPF key, so a colour identifies an
% orientation within a phase and not the phase itself. The figure shows
% where orientations are missing, not which mineral sits where.
%
% The white that does follow the black outlines is the case filling must
% respect. There the interaction volume straddles two crystals, and giving
% such a position one neighbour's orientation would erase the uncertainty
% that marks the boundary.
%
%% Fill only grain interiors
%
% The command |smooth| fills every |notIndexed| pixel that |calcGrains|
% assigned to an indexed grain. The |notIndexed| measurements on grain
% boundaries belong to no grain, and the two large patches are |notIndexed|
% grains; both remain |notIndexed|.

F = l1TVFilter;
F.alpha = 1.25;

ebsdS = smooth(ebsd,F,grains);

plot(ebsdS,'ipfz')
hold on

% plot the boundary of all grains
plot(grains.boundary,'linewidth',1.5)
hold off

%%
% Colour now extends through holes in the grain interiors. The narrow white
% corridors that remain coincide with reconstructed boundaries, so the
% filled map does not claim a phase or orientation where the segmentation
% was deliberately unresolved.

%% Filling selected pixels
%
% A mask restricts filling to the pixels it marks. It never fills a pixel
% that |smooth| would leave alone, so grain boundaries and |notIndexed|
% grains stay |notIndexed| whatever the mask says. A mask can select by
% phase, here the pixels of the enstatite grains.

% the pixels of the enstatite grains
isEnstatite = ismember(ebsd.grainId,grains('Enstatite').id);
ebsdEn = smooth(ebsd,F,grains,'fill',isEnstatite);

plot(ebsdEn,'ipfz')
hold on
plot(grains.boundary,'linewidth',1.5)
hold off

%%
% The enstatite grains are filled, while the holes in the forsterite and
% diopside grains remain.
%
% A mask can also use any property of the pixels. The band contrast |bc|
% measures the quality of the diffraction pattern. A |notIndexed| pixel with
% a low band contrast probably did not see a crystal at all, for example
% above a pore. The next call fills only the pixels whose band contrast is
% at least 80; nine in ten indexed measurements exceed 85.

% the pixels with a pattern of at least moderate contrast
hasPattern = ebsd.bc >= 80;
ebsdBC = smooth(ebsd,F,grains,'fill',hasPattern);

plot(ebsdBC('notIndexed'),'faceColor','black')
hold on
plot(ebsdBC('indexed'),'ipfz')
plot(grains.boundary,'linewidth',1.5)
hold off

%%
% The black pixels are |notIndexed|: they lie on grain boundaries or in the
% |notIndexed| grains. The white holes inside the grains are the pixels
% with a weak pattern, which the mask left unfilled.

%% Read the recovered orientation field
%
% Absolute orientation colours can hide small intragranular changes. An
% @axisAngleColorKey compares every orientation with its grain's mean
% orientation. The misorientation axis determines the hue, and the angle
% controls the colour saturation up to the chosen 2.5 degree maximum.

colorKey = axisAngleColorKey(ebsdS('Fo'));
colorKey.oriRef = grains(ebsdS('Fo').grainId).meanOrientation;
colorKey.maxAngle = 2.5*degree;

color = colorKey.orientation2color(ebsdS('Fo').orientations);
plot(ebsdS('Fo'),color,'micronbar','off')

hold on
colorKey.oriRef = grains(ebsdS('En').grainId).meanOrientation;

plot(ebsdS('En'), ...
  colorKey.orientation2color(ebsdS('En').orientations))

% plot boundaries
plot(grains.boundary,'linewidth',4)
plot(grains('En').boundary,'lineWidth',4,'lineColor','r')
hold off

%%
% The colour changes smoothly through positions that previously lacked an
% orientation. This continuity is the filter's reconstruction of the
% intragranular orientation gradient, not newly measured deformation.
%
% Compare it with the same view of the original map.

colorKey.oriRef = grains(ebsd('Fo').grainId).meanOrientation;
colorKey.maxAngle = 2.5*degree;

color = colorKey.orientation2color(ebsd('Fo').orientations);
plot(ebsd('Fo'),color,'micronbar','off')

hold on
colorKey.oriRef = grains(ebsd('En').grainId).meanOrientation;

plot(ebsd('En'),colorKey.orientation2color(ebsd('En').orientations))

% plot boundaries
plot(grains.boundary,'linewidth',4)
plot(grains('En').boundary,'lineWidth',4,'lineColor','r')
hold off

%%
% The original view breaks those smooth colour fields with white regions.
% The comparison shows exactly where filling supplied continuity and guards
% against reading the reconstructed pixels as independent observations.

%% Further reading
%
% * F. Bachmann, R. Hielscher and H. Schaeben,
% <https://doi.org/10.1016/j.ultramic.2011.08.002 Grain detection from 2d
% and 3d EBSD data - specification of the MTEX algorithm>, _Ultramicroscopy_
% 111, 1720-1733, 2011, explains the spatial grain reconstruction that makes
% the boundary constraint possible.
% * R. Hielscher, C. B. Silbermann, E. Schmidl and J. Ihlemann,
% <https://doi.org/10.1107/S1600576719009075 Denoising of crystal
% orientation maps>, _Journal of Applied Crystallography_ 52, 984-996,
% 2019, compares filters, hole filling, and their effects on derived
% quantities.
% * A. J. Schwartz, M. Kumar, B. L. Adams and D. P. Field, editors,
% <https://doi.org/10.1007/978-0-387-88136-2 Electron Backscatter
% Diffraction in Materials Science>, second edition, Springer, 2009,
% provides the experimental background to indexing and cleanup.
% * <https://doi.org/10.1520/E2627-13R19 ASTM E2627-13(2019)> standardizes
% EBSD grain-size measurements for fully recrystallized materials and
% requires a high proportion of reliably indexed patterns. It is a reminder
% that filled orientations do not increase the measured indexing rate.
