%% EBSD
%
%%
% Electron backscatter diffraction measures one orientation at a time. The
% beam sits on a point of a polished surface, the pattern that comes back
% is indexed against a list of candidate phases, and the result is a phase
% and an orientation for that point. Step the beam across a grid and you
% have a map: hundreds of thousands of orientations, each with a position.
%
% That combination is what makes EBSD different from a diffraction
% experiment. A pole figure tells you which orientations are present in a
% volume; an EBSD map tells you which orientation is present *where*. Every
% question about microstructure - grain size, neighbourhood, gradients
% inside a grain, how a boundary is oriented - needs that "where", and this
% chapter is about getting it and trusting it.

plottingConvention.default('y↑→x');
mtexdata forsterite silent

% colour every Forsterite measurement by its orientation
plot(ebsd('Forsterite'),ebsd('Forsterite').orientations,'micronbar','off')

%%
% The colour is not a measurement. It is a *colour key*, a choice of how to
% turn a three-parameter orientation into three numbers you can see, and
% different keys make the same map look quite different. Nothing here can be
% read quantitatively off the colours alone.
%
%% What the data actually is
%
% A |ebsd| variable is a list, not an image. Each entry carries a position,
% a phase and an orientation, and the entries happen to sit on a grid
% because that is how they were measured. This matters more than it sounds:
% filtering the list to one phase leaves gaps rather than blanks, and any
% operation that needs neighbours has to reconstruct the grid first.
%
% Two kinds of entry are not ordinary measurements. Points whose pattern
% could not be indexed are given the *notIndexed* phase - they are recorded,
% not missing, and they matter, because a band of them along a boundary is
% information about the boundary rather than an inconvenience. Points
% outside the scanned region are not in the list at all.
%
%% The first thing to check is the reference frame
%
% An EBSD file contains two coordinate systems that need not agree: the one
% the stage moved in, and the one the Euler angles were written in. Vendors
% differ, software versions differ, and nothing in the file forces them to
% be consistent.
%
% The failure mode is unkind. A map with the wrong convention still plots,
% still reconstructs into grains, and still produces pole figures - they are
% simply rotated or mirrored, and there is no way to tell from the numbers
% alone. <EBSDReferenceFrame.html Reference Frame> is therefore not an
% advanced topic to come back to later. Read it once, on your own data,
% before you trust anything downstream.
%
%% Where to start
%
% <EBSDImport.html Import> then <EBSDReferenceFrame.html Reference Frame>,
% in that order and without skipping the second.
%
% <EBSDPlotting.html Plot> covers displaying a map, and
% <EBSDIPFMap.html IPF Maps> the colour keys behind the picture above.
% <EBSDOrientationPlots.html Orientation Plots> leaves the map behind and
% shows the same orientations in pole figures instead.
% <EBSDSharpPlot.html Sharp Color Keys> and
% <EBSDAdvancedMaps.html Advanced Plotting> are for when the default
% colouring hides what you are looking for.
%
% <EBSDSelect.html Select> and <EBSDIndex.html Select by Index> cut a map
% down - by phase, by region, by property, by condition. Most real analysis
% starts with one of these.
%
% <GrainReconstruction.html Grain Reconstruction> is the step from
% measurements to objects and the gateway to <Grains.html Grains>.
% <EBSD2ODF.html ODF Estimation> is the other way to summarise a map, as a
% density over orientations rather than as a set of regions.
%
% Real data is imperfect, and several pages address that.
% <EBSDDenoising.html Denoising> and
% <EBSDFilling.html Filling Missing Data> repair it;
% <EBSDPseudoSymmetry.html Pseudo Symmetry> deals with phases whose patterns
% are nearly indistinguishable under more than one orientation, which is an
% indexing failure rather than a noise problem.
% <EBSDGrid.html Square and Hex Grids>, <EBSDInter.html Regridding and
% Interpolation>, <EBSDMapsAndImages.html Maps and Images> and
% <EBSDSpatialTransform.html Spatial Transforms> concern the geometry of the
% grid itself, and <EBSDTrueEbsd.html TrueEBSD Distortion Correction>
% corrects the distortion that comes from measuring a tilted sample.
%
% Three pages measure orientation change within grains rather than between
% them: <EBSDKAM.html KAM> compares each point with its neighbours,
% <EBSDGROD.html Mis2Mean / GROD> compares it with its grain's mean, and
% <EBSDProfile.html Profiles> follows a line across the map.
% <EBSDOrientationAnalysis.html Orientation Analysis> collects the rest.
%
% <EBSDSimulation.html Simulation> generates maps with known answers, which
% is the honest way to test a processing chain.
% <EBSDInterfaceHDF5.html HDF5 Interface> and
% <EBSDExport.html Export> handle files.
%
%% Next
%
% <Grains.html Grains> and <GrainBoundaries.html Grain Boundaries> are what
% a map becomes once its regions are found. <EBSD3Analysis.html 3D - EBSD>
% extends all of this to volumes. The orientations themselves are
% <CrystalOrientations.html Orientations>, and their distribution is
% <ODFAnalysis.html ODF>.
%
