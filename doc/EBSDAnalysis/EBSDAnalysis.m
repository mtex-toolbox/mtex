%% EBSD
%
%%
% Electron backscatter diffraction (EBSD) measures crystal orientation at
% points on a polished specimen surface. The indexing algorithm compares the
% diffraction pattern with candidate phases. It assigns a phase and an
% orientation at each point. Moving the beam across a scan lattice
% produces a map: a list of orientations tied to positions on the specimen.
%
% This spatial link distinguishes an EBSD map from a bulk diffraction pole
% figure. A pole figure reports which orientations occur in a sampled
% volume. An EBSD map reports which orientation was assigned *where* on the
% measured surface. Grain size, neighbourhood, intragranular gradients, and
% boundary traces all depend on that where.
%
% The plotting convention below draws specimen Y upward and specimen X to
% the right. It changes the screen layout, not the measured data.

plottingConvention.default('y↑→x');
mtexdata forsterite

%%
% Read the displayed @EBSD summary as an inventory. It identifies the scan
% lattice and extent. It also lists the phases, the |notIndexed|
% measurements, and the available per-pixel properties.
%
% An @EBSD variable is a list, not an image. Each entry carries a position,
% a phase, and an orientation. The entries form an image-like map only
% because their positions usually lie on a square or hexagonal scan lattice.
%
%% Seeing phase and orientation
%
% The same measurements can answer different questions depending on what
% supplies the colour. The left panel colours every measurement by phase.
% The right panel retains the original orientation plot for Forsterite and
% colours it by the crystal direction parallel to specimen Z.

newMtexFigure('layout',[1,2],'figSize','large');
plot(ebsd,'micronbar','off');
mtexTitle('phases');

nextAxis;
fo = ebsd('Forsterite');
plot(fo,fo.orientations,'ipfDirection',zvector,'micronbar','off');
mtexTitle('Forsterite orientations');

%%
% In the phase map, contiguous areas of the same colour show where each
% indexed phase occurs, while the white speckle is |notIndexed|. The broad
% colour domains in the orientation map are spatially coherent orientations
% within Forsterite. White now also includes every other phase,
% because only the Forsterite selection was plotted.
%
% Orientation colour is not a measurement. An *orientation colour key* is
% a rule for turning a three-parameter orientation into three RGB values.
% Different keys can make the same orientations look different, and colour
% alone is not a quantitative orientation scale.
%
%% Recorded, missing, and derived data
%
% A |notIndexed| entry is a recorded measurement whose diffraction pattern
% could not be indexed. It is a phase value, not an absent scan position.
% A band of |notIndexed| measurements along a boundary may therefore carry
% information about pattern overlap or specimen quality. Points outside the
% scanned region are absent from the list. So are lattice sites at which no
% measurement was retained.
%
% Selecting one phase removes the other entries from the list; it does not
% replace them with blank pixels. The remaining positions can therefore have
% gaps. An operation that needs neighbours must recover the scan lattice,
% either internally or through an explicit gridding step.
%
% Grains and orientation distributions are derived from this measurement
% list. A *grain* is a phase-homogeneous, spatially connected region of EBSD
% pixels produced by segmentation. Its outline depends on the segmentation
% rule; it is not a boundary measured directly by the detector. An
% *orientation distribution function* (ODF) discards position. It estimates
% a continuous density over orientation space.
%
% These distinctions determine what a number means. On an equally spaced
% map, a pixel fraction measures surface area. It is not automatically a bulk
% specimen volume fraction. Step size, phase selection, and indexing quality
% can change a downstream result. So can filling, denoising, and grain
% segmentation.
%
%% Check the reference frame before analysis
%
% A *reference frame* is the coordinate system in which data are expressed.
% EBSD positions describe how the stage moved, while the Euler angles encode
% orientations in a specimen frame. The two frames need not arrive aligned.
% Vendors and software versions use different conventions, and a file may
% not record the relationship completely.
%
% The failure is quiet. A map with the wrong relationship still plots,
% reconstructs into grains, and produces pole figures. The results are
% rotated or mirrored. The numerical values alone do not expose the mistake.
% Read <EBSDReferenceFrame.html Reference Frame Alignment> for your
% own data before trusting any downstream result.
%
%% Recommended reading order
%
% Begin with <EBSDImport.html Import>, then check
% <EBSDReferenceFrame.html Reference Frame Alignment>. Also review
% <OrientationDefinition.html Orientations> if the crystal-to-specimen map
% is new to you.
%
% Continue with <EBSDPlotting.html Plotting EBSD Maps> and
% <EBSDIPFMap.html IPF Maps>. The first explains the |plot(where,what)|
% pattern; the second explains the colour key used above. Then read
% <EBSDSelect.html Select>, <EBSDIndex.html Select by Index>, and
% <EBSDGrid.html Square and Hex Grids>. The first two cut a map down - by
% phase, by region, by property, by condition - and most real analysis starts
% with one of these. Together the three pages establish phase, logical,
% positional, list, identifier, row-column, and lattice indexing. Learn those
% distinctions before using neighbour-based operations.
%
% <EBSDOrientationPlots.html Orientation Plots> then shows pole figures,
% inverse pole figures, sections, and orientation-space views of a selection.
% <GrainReconstruction.html Grain Reconstruction> turns
% measurements into grains and is the gateway to <Grains.html Grains>.
%
% After that foundation, choose the branch that matches the question.
%
% * For data quality, use <EBSDDenoising.html Denoising>,
% <EBSDFilling.html Filling Missing Data>, and
% <EBSDPseudoSymmetry.html Pseudo Symmetry>. These pages treat random scatter,
% missing orientations, and indexed-but-wrong alternatives as separate
% problems.
% * For map geometry, continue from the grid page to
% <EBSDInter.html Regridding and Interpolation>,
% <EBSDMapsAndImages.html Maps and Images>,
% <EBSDSpatialTransform.html Spatial Transforms>, and
% <EBSDTrueEbsd.html TrueEBSD Distortion Correction>.
% * For orientation statistics, use
% <EBSDOrientationAnalysis.html Orientation Analysis> and
% <EBSD2ODF.html ODF Estimation>. The latter estimates a density over
% orientations rather than spatial regions.
% * For intragranular orientation change, use <EBSDKAM.html KAM> for local
% neighbour comparisons. <EBSDGROD.html Mis2Mean / GROD> uses a grain
% reference, while <EBSDProfile.html Profiles> follows a line.
% These pages assume grain reconstruction and basic
% <MisorientationTheory.html misorientation geometry>.
% * For specialised orientation colours, read
% <EBSDSharpPlot.html Sharp Color Keys> when a broad key hides small changes,
% then <EBSDAdvancedMaps.html Advanced Plotting> for keys tailored to a
% particular orientation population or question.
%
% <EBSDSimulation.html Simulation> creates maps with known answers for
% testing a processing chain. <EBSDInterfaceHDF5.html HDF5 Interface> is a
% developer guide for vendor JSON configurations, while
% <EBSDExport.html Export> explains what different output formats preserve.
%
%% Further reading
%
% * A. J. Schwartz, M. Kumar, B. L. Adams, and D. P. Field, editors,
% <https://doi.org/10.1007/978-0-387-88136-2 Electron Backscatter Diffraction
% in Materials Science>, second edition, Springer, 2009.
% * A. J. Wilkinson and T. B. Britton,
% <https://doi.org/10.1016/S1369-7021(12)70163-3 Strains, planes, and EBSD in
% materials science>, Materials Today 15 (2012), 366-376.
% * <https://www.iso.org/standard/82749.html ISO 24173:2024>, Microbeam
% analysis - Guidelines for orientation measurement using electron
% backscatter diffraction, covers specimen preparation, calibration,
% acquisition, and reproducibility.
%
%% Next
%
% <Grains.html Grains> and <GrainBoundaries.html Grain Boundaries> develop
% the regions and boundary network obtained by segmentation. A grain
% boundary in MTEX is a segment between neighbouring EBSD pixels assigned to
% different grains. It is derived from the map, not measured as a separate
% detector signal.
%
% <EBSD3Analysis.html 3D EBSD> extends spatial analysis from a surface to a
% volume. <CrystalOrientations.html Orientations> develops the orientation
% geometry itself, and <ODFAnalysis.html ODF> develops continuous orientation
% distributions.
