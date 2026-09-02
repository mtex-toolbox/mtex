%% Grain Reconstruction from Voxel Data
%
% A three-dimensional EBSD measurement arrives as voxels, whether it comes
% from serial sectioning or from a diffraction technique that probes the
% volume. Each voxel carries a position, a phase and an orientation. A grain
% is a phase-homogeneous, spatially connected region of such voxels. This
% page reconstructs the grains of a measured volume and looks at what comes
% out.

plottingConvention.default('y↑→x');
how2plot = plottingConvention.default3D;

%% Load the voxel data
%
% <EBSD3.load.html |EBSD3.load|> reads the cell data of a DREAM.3D file into
% an @EBSD3square, the voxel counterpart of a square grid EBSD map. The
% voxels form a three-dimensional array, so |ebsd(i,j,k)| addresses one of
% them. Every further scalar array of the file becomes a property.

fname = fullfile(mtexDataPath,'EBSD','SmallIN100_MeshStats.dream3d');
ebsd = EBSD3.load(fname)

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

plot(grains,grains.meanOrientation,'LineStyle','none','micronbar','off')
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

%%
[~,id] = max(grains.volume);
plot(grains(id),'micronbar','off')
setCamera(how2plot)

%% Grains stored in the file
%
% DREAM.3D and GrainMapper3D files carry the grain id the vendor software
% assigned to every voxel, which the importer stores as |ebsd.grainId|. The
% flag |'grainId'| builds the grains from these ids instead of the
% orientations, so the stored segmentation becomes a @grain3d with the same
% closed surfaces, volumes and boundary as a reconstruction of our own.

grainsStored = calcGrains(ebsd,'grainId')

%%
% The two segmentations agree on most voxels. Where they differ, the
% threshold decided about a low angle boundary that the stored ids
% either keep or drop.

%% Small grains
%
% A handful of voxels with a stray orientation form a grain of their own.
% The option |minPixel| removes indexed grains below a number of voxels. Their
% voxels are marked notIndexed and form notIndexed grains, exactly as in two
% dimensions.

grains = calcGrains(ebsd,'angle',5*degree,'minPixel',10)

%% The grain boundary
%
% |grains.boundary| is a @grain3Boundary. Each face records the two voxels it
% separates, |ebsdId|, the two grains, |grainId|, and the misorientation
% between the two voxels. Faces on the outside of the volume have a zero in
% the second column of |grainId|. The misorientation angle across the inner
% faces shows where the low angle boundaries are.

gB = grains.boundary;
isInner = all(gB.grainId > 0,2);
histogram(gB.misorientation(isInner).angle ./ degree)
xlabel('misorientation angle in degree')

%% Next
%
% <Grains3DProperties.html Properties> lists the geometric properties of the
% reconstructed grains, and <Grains3DOperations.html Operations> covers
% selection, slicing and the boundary normal distribution. The
% <Grains3D.html 3D-Grains> page reads the same microstructure from the
% surface mesh DREAM.3D stored alongside the voxels.
