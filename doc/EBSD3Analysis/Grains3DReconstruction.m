%% Grain Reconstruction from Voxel Data
%
% A three-dimensional EBSD measurement arrives as voxels, whether it comes
% from serial sectioning or from a diffraction technique that probes the
% volume. Each voxel carries a position, a phase and an orientation. A grain
% is a phase-homogeneous, spatially connected region of such voxels. This
% page asks how the segmentation criterion changes the grains we measure.
% Unlike the simulated multiphase volume in the overview, this example uses
% the DREAM.3D IN100 data so that one phase can be coloured by orientation.

plottingConvention.default('y↑→x');
how2plot = plottingConvention.default3D;

%% Load the voxel data
%
% <EBSD3.load.html |EBSD3.load|> reads the cell data of a DREAM.3D file into
% an @EBSD3square, the voxel counterpart of a square grid EBSD map. The
% voxels form a three-dimensional array, so |ebsd(i,j,k)| addresses one of
% them. Every further scalar array of the file becomes a property.

fname = fullfile(mtexDataPath,'EBSD','SmallIN100_MeshStats.dream3d');
ebsdImported = EBSD3.load(fname);
ebsd = ebsdImported

%% Reconstruct the grains
%
% <EBSD3square.calcGrains.html |calcGrains|> works as its two-dimensional
% counterpart: two neighbouring voxels belong to the same grain when their
% misorientation angle stays below the threshold. Voxels are 6-connected.
% The boundary between two grains consists of the voxel faces they share,
% each stored as two triangles, so every grain is a closed surface.

[grains,ebsd] = calcGrains(ebsd,'angle',5*degree)

%%
% The summary lists the grains with their volume and mean orientation. The
% second output is the same voxel data with a |grainId| per voxel. Plotting
% the mean orientation colours every face on the outside of the volume.

plot(grains,grains.meanOrientation,'edgeAlpha',0.1,'micronbar','off')
setCamera(how2plot)

%%
% The colour is constant over each grain and changes sharply at the grain
% boundaries. The staircase texture of the outer faces is the voxel grid
% itself; the boundary follows the voxel faces exactly.

%% Volumes
%
% Every grain is a closed surface, so its volume follows from the divergence
% theorem and equals the number of its voxels times the voxel volume. The
% volumes of all grains add up to the measured box.

[sum(grains.volume), prod(size(ebsd)) * ebsd.dx * ebsd.dy * ebsd.dz]

%%
% Most grains are small. The largest grain is worth a look on its own.

histogram(grains.volume)
xlabel('grain volume (length units^3)')
ylabel('number of grains')

%%
[~,id] = max(grains.volume);
plot(grains(id),'micronbar','off','edgeAlpha',0.2)
setCamera(how2plot)

%% Grains stored in the file
%
% DREAM.3D and GrainMapper3D files carry the grain id the vendor software
% assigned to every voxel, which the importer stores as |ebsd.grainId|. The
% flag |'grainId'| builds the grains from these ids instead of the
% orientations, so the stored segmentation becomes a @grain3d with the same
% closed surfaces, volumes and boundary as a reconstruction of our own.

grainsStored = calcGrains(ebsdImported,'grainId')

%%
% The second output of |calcGrains| replaces |ebsd.grainId|, so the stored
% segmentation must be read from |ebsdImported|. Grain labels are arbitrary:
% subtracting the two ID arrays would not measure agreement. First compare
% a physically meaningful quantity, the equivalent-sphere diameter,
% $d_V=(6V/\pi)^{1/3}$, for indexed grains in each reconstruction.

gMTEX = grains('indexed');
gStored = grainsStored('indexed');
dMTEX = (6*gMTEX.volume/pi).^(1/3);
dStored = (6*gStored.volume/pi).^(1/3);
diameterEdges = linspace(0,max([dMTEX;dStored]),25);

histogram(dMTEX,diameterEdges,'DisplayName','MTEX, 5 degrees')
hold on
histogram(dStored,diameterEdges,'DisplayName','stored segmentation')
hold off
legend('Location','best')
xlabel('equivalent-sphere diameter (length units)')
ylabel('number of grains')

%%
% Similar distributions do not establish voxel-by-voxel agreement. They do
% show whether the two segmentations give similar grain sizes. To locate
% discrepancies, compare their |grainId| properties on the same slice.

%% Small grains
%
% A handful of voxels with a stray orientation form a grain of their own.
% The option |minPixel| removes indexed grains below a number of voxels. Their
% voxels are marked notIndexed and form notIndexed grains, exactly as in two
% dimensions.

[grainsClean,ebsdClean] = calcGrains(ebsdImported,'angle',5*degree,'minPixel',10);
[length(grains('indexed')), length(grainsClean('indexed'))]

%%
% A cutoff is a choice of minimum resolved volume: ten voxels correspond to
% the volume below. It can suppress isolated indexing errors, but also remove
% real small grains. Check the affected regions before interpreting a loss
% of fine grains as a material feature.

minimumVolume = 10 * ebsd.dx * ebsd.dy * ebsd.dz
removedFraction = nnz(ebsdImported.isIndexed & ~ebsdClean.isIndexed) / ...
  nnz(ebsdImported.isIndexed)

%% The grain boundary
%
% |grains.boundary| is a @grain3Boundary. Each face records the two voxels it
% separates, |ebsdId|, the two grains, |grainId|, and the misorientation
% between the two voxels. Faces on the outside of the volume have a zero in
% the second column of |grainId|. The misorientation angle across the inner
% faces shows where the low angle boundaries are.

gB = grains.boundary;
isInner = all(gB.grainId > 0,2) & all(gB.isIndexed,2);
histogram(gB.misorientation(isInner).angle ./ degree)
xlabel('local misorientation angle (degrees)')
ylabel('number of mesh faces')

%% Next
%
% <Grains3DSmoothing.html Smoothing> removes voxel steps before surface
% measurements. <Grains3DProperties.html Properties> measures the reconstructed
% grains, and <Grains3DOperations.html Operations> relates sections to their
% parent grains. <Grains3DBoundaries.html Boundary Network> measures internal
% interfaces. The <Grains3D.html Three-Dimensional Grains> page reads the
% surface mesh DREAM.3D stored alongside the voxels.

%#ok<*NOPTS>
