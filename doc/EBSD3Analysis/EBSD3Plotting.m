%% Volume Data and Slices
%
% An @EBSD3 object stores one measurement per voxel: its position, phase,
% orientation, and whatever properties the file provides. It is the volume
% counterpart of a two-dimensional @EBSD map, and the representation to use
% while the question still concerns individual measurements rather than
% whole-grain geometry.
%
% This page imports such a volume, displays it, and cuts planar slices out
% of it. A slice is an ordinary two-dimensional EBSD map, so everything
% written for planar data applies to it unchanged. The polyhedral @grain3d
% representation is the subject of
% <Grains3D.html Three-Dimensional Grains>.

plottingConvention.default('y↑→x');

%% Import a volume
%
% <EBSD3.load.html |EBSD3.load|> detects the file format automatically. The
% sample data set is a simulated nine-phase volume written in the Xnovo
% GrainMapper3D format,
%
%    ebsd = EBSD3.load(fullfile(mtexDataPath,'EBSD3','SimulatedMultiPhase.h5'))
%
% which |mtexdata| resolves by name.

ebsd = mtexdata('xnovo')

%%
% The summary reports a 50 x 50 x 50 array rather than a list, i.e. the
% measurements are held in an @EBSD3square whose entries are addressed as
% |ebsd(i,j,k)|. The three array dimensions carry $x$, $y$ and $z$. Each of
% the nine phases occupies roughly a twelfth of the voxels and the remaining
% fifth is not indexed.
%
% The voxel is 10 micron on a side and the volume spans about half a
% millimetre in each direction.

ebsd.extent

%% Display the volume
%
% <EBSD3.plot.html |plot|> hands the volume to the MATLAB volume viewer,
% which cuts three slice planes through the data and renders them on the
% graphics card. The planes are dragged with the mouse, and the volume is
% rotated, clipped and cropped interactively, so this is a live window
% rather than a figure:
%
%    plot(ebsd)                          % colour by phase
%    plot(ebsd,ebsd.prop.grainId)        % colour by a property
%
% Voxel colours are never interpolated, so a boundary stays where the
% measurement puts it, and voxels that are not indexed are painted in the
% background colour.
%
% Interaction is what that window is for. Anything that has to end up in a
% figure, a publication, or a further calculation goes through a slice.

%% Cut a slice
%
% <EBSD3.slice.html |slice|> resamples the volume onto a regular grid inside
% a @plane3d and returns a two-dimensional @EBSD map. The plane is given by
% its normal and one point on it.

ebsdZ = slice(ebsd,plane3d(vector3d.Z,vector3d(0,0,0)))

%%
% The result is an @EBSDsquare like any imported map, it carries all nine
% phases, and it plots like one.

plot(ebsdZ)

%%
% The section is a disc, so the simulated specimen is round in the $xy$
% plane rather than filling its bounding box. The grains are equiaxed and
% the nine phases are mixed through the section without any layering.

%% Slices at several depths
%
% Repeating the cut at different heights shows how the microstructure
% develops through the volume. Each panel is a full EBSD map.

newMtexFigure('layout',[1,3],'figSize','large');

for z = [-0.15 0 0.15]
  plot(slice(ebsd,plane3d(vector3d.Z,vector3d(0,0,z))),'micronbar','off')
  mtexTitle(['z = ' num2str(z) ' mm'])
  if z < 0.15, nextAxis; end
end

%%
% The three discs have the same diameter, so the specimen is a cylinder
% standing along $z$. The grain pattern is different in each panel because
% every section meets a different set of grains.

%% An arbitrary plane
%
% The normal is unrestricted. The measurements of a section keep their
% position in the specimen, so a section that does not lie in the $xy$
% plane would be seen edge on from the default viewing direction. |slice|
% therefore gives the section a @plottingConvention of its own that looks
% along the plane normal, and the map is drawn face on without moving any
% data.

newMtexFigure('layout',[1,2],'figSize','large');

plot(slice(ebsd,plane3d(vector3d.X,vector3d(0,0,0))),'micronbar','off')
mtexTitle('normal || x')
nextAxis
plot(slice(ebsd,plane3d(vector3d(1,1,1),vector3d(0,0,0))),'micronbar','off')
mtexTitle('normal || (1,1,1)')

%%
% The section normal to $x$ is rectangular and shows the full height of the
% cylinder. The oblique section is the larger of the two because that plane
% crosses more of the specimen; its grid is regular within the plane, not in
% the specimen axes.
%
% A section normal to $z$ needs no new convention and keeps the one the
% volume already carries, so it is drawn exactly as an imported map is.

%% Colour a slice
%
% A slice carries the orientations, phases and properties of the voxels it
% passes through, so it is coloured by exactly the same commands as an
% imported map. Orientation colouring needs a single phase at a time, which
% for a multi-phase section means one call per phase.

for p = ebsdZ.indexedPhasesId
  ebsdP = ebsdZ(ebsdZ.CSList(p).mineral);
  plot(ebsdP,ebsdP.orientations,'micronbar','off')
  hold on
end
hold off

%%
% Each phase is coloured by its own inverse pole figure key, so colours are
% comparable within a phase but not between phases.

%% A slice is an ordinary EBSD map
%
% Nothing distinguishes the result of |slice| from an imported map, so the
% planar toolchain applies to it directly. Here the section is segmented
% into grains and the boundaries drawn over the phase map.

grains = calcGrains(ebsdZ('indexed'));

plot(ebsdZ,'micronbar','off')
hold on
plot(grains.boundary,'lineWidth',2)
hold off

%%
% These grains are the sections of the three-dimensional grains, not the
% grains themselves, and they inherit the bias any single section carries.
% This data set also ships the segmentation of the full volume as the voxel
% property |grainId|, which the slice carries along.
%
% Reconstructing grains in the volume as closed polyhedra is described in
% <Grains3D.html Three-Dimensional Grains>.

%% References
%
% * F. Bachmann, R. Hielscher, and H. Schaeben,
% <https://doi.org/10.1016/j.ultramic.2011.08.002 Grain Detection from 2d
% and 3d EBSD Data - Specification of the MTEX Algorithm>,
% _Ultramicroscopy_ 111 (2011), 1720--1733, specifies the segmentation that
% <EBSD.calcGrains.html |calcGrains|> applies to the section.

%% Next
%
% Continue with <Grains3D.html Three-Dimensional Grains> to turn a volume
% into polyhedra and to work with their faces and normals.

%#ok<*NOPTS>
