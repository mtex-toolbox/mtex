%% Properties of Three-Dimensional Grains
%
% <Grains3D.html Three-Dimensional Grains> defines the @grain3d collection
% and its polyhedral representation. Three-dimensional grains retain
% material properties such as |meanOrientation|, but their size and shape
% require volume and surface measures rather than planar area and perimeter.
%
% Start with size: how much material belongs to the large grains? Then
% distinguish elongated grains from compact ones, and identify shapes cut
% short by the measurement boundary. These questions need different measures
% and different statistical weights.

plottingConvention.default('y↑→x');

%% Load the example microstructure
%
% The bundled data set is a Neper tessellation. The previous
% <NeperInterface.html Neper Interface> page explains how such a collection
% is generated or imported. Loading the existing file needs no Neper
% installation. Its lengths are expressed in the tessellation coordinate
% units; assign a physical scale before comparing with an experiment.

% Assign trigonal quartz symmetry, as on the Neper Interface page.
cs = crystalSymmetry.load('quartz.cif');
tessFile = fullfile(mtexDataPath,'Neper','my100grains.tess');
grains = grain3d.load(tessFile,'CS',cs)

plot(grains,grains.meanOrientation,'micronbar','off','edgeAlpha',0.1)
setCamera(plottingConvention.default3D)

%%
% Each colour represents one mean orientation. The faceted outlines are the
% boundary polygons from which the geometric properties are computed.

%% Compare size measures
%
% Diameter, surface area, and volume answer different questions. The diameter
% spans the two most distant vertices. Surface sums the areas of all faces,
% while volume measures the enclosed polyhedron. Their units follow the mesh
% coordinates: length, length squared, and length cubed. A tessellation has
% no experimental length calibration merely because it can be plotted.
%
% Select by grain ID so the choice remains meaningful after subsetting.

grainId = 9;
grain = grains('id',grainId);

grain.diameter

%%

grain.surface

%%

grain.volume

%%
% Equal volumes need not mean equal elongation or equal surface area.
% The equivalent-sphere diameter provides a size measure independent of
% surface roughness; sphericity compares the measured surface with that of
% a sphere enclosing the same volume. A sphere has sphericity one.

equivalentDiameter = (6*grains.volume/pi).^(1/3);
sphericity = (36*pi)^(1/3) * grains.volume.^(2/3) ./ grains.surface;

%%
% Face and neighbourhood counts provide complementary structural measures.

[grain.numFaces, grain.numNeighbors]

%%
% A triangulated interface can contain many mesh faces but still separate
% only two grains. |numFaces| depends on the mesh; |numNeighbors| describes
% grain connectivity. A face on the outside has no neighbouring grain.

%% Which grains are completely inside the measurement?
%
% A grain meeting the measurement hull is truncated: its measured volume
% is only the part inside the box. The zero grain ID identifies the exterior
% and lets us find these grains without relying on a bounding-box tolerance.
% Make this selection on the full collection, before selecting a phase.

gB = grains.boundary;
hullIds = unique(gB.grainId(any(gB.grainId == 0,2),:));
isInterior = ~ismember(grains.id,hullIds);
[length(grains), nnz(isInterior)]

%%
% Interior grains have complete measured shapes. Excluding hull grains also
% preferentially excludes large grains, which are more likely to meet the
% box. Report the selection with a size distribution. Below we retain the
% whole synthetic tessellation so that the two weightings use the same set.

%% Number-weighted and volume-weighted distributions
%
% MATLAB's numeric <matlab:doc('histogram') |histogram|> gives every grain
% one count. This answers how many grains fall in a size interval.
% <grain3d.histogram.html |histogram(grains,...)|> weights each grain by its
% volume and reports relative volume in percent. For questions about the
% fraction of material in an interval, this is the more realistic view.

volumeEdges = linspace(0,max(grains.volume)+eps,21);
newMtexFigure('layout',[1,2]);
histogram(grains.volume,volumeEdges,'FaceColor',grains.color)
xlabel('grain volume (length units^3)')
ylabel('number of grains')
mtexTitle('Number weighted')

nextAxis
histogram(grains,grains.volume,volumeEdges)
mtexTitle('Volume weighted')

%%
% Large grains are relatively inconspicuous in the count histogram but gain
% weight in the second panel. Neither weighting is universally preferable;
% the denominator must match the scientific question.
%
% The same distinction applies to any other property. Here the horizontal
% coordinate is surface area, while the weight remains grain volume.

surfaceEdges = linspace(0,max(grains.surface)+eps,16);
newMtexFigure('layout',[1,2]);
histogram(grains.surface,surfaceEdges,'FaceColor',grains.color)
xlabel('surface area (length units^2)')
ylabel('number of grains')
mtexTitle('Number weighted')

nextAxis
histogram(grains,grains.surface,surfaceEdges)
xlabel('surface area (length units^2)')
mtexTitle('Volume weighted')

%%
% The right panel asks what fraction of the total material belongs to grains
% in each surface-area interval. It does not show a surface-area fraction.

%% Relate diameter and volume
%
% A scatter plot tests how two measures covary. Taking the cube root of
% volume puts both axes in units of length. Similar grain shapes should lie
% near a common trend; elongated or irregular grains can depart from it.

figure
scatter(grains.volume.^(1/3),grains.diameter,18,grains.color,'filled')
xlabel('cube root of volume (length units)')
ylabel('diameter (length units)')

%%
% The overall increase confirms that larger volumes usually have larger
% diameters. The vertical spread at a fixed cube-root volume records shape
% variation rather than a change of units.

%% Ellipsoid-based shape
%
% <grain3d.principalComponents.html |principalComponents|> computes three
% orthogonal vectors |a|, |b|, and |c| from the grain's volume moments. Their
% directions are the principal directions, and their lengths are the
% half-axes of an ellipsoid scaled to the same volume as the grain.
% <plotEllipsoid.html |plotEllipsoid|> draws them.

[a,b,c] = principalComponents(grains);

% Compute one IPF colour for each ellipsoid.
cKey = ipfColorKey(grains.CS);
color = cKey.orientation2color(grains.meanOrientation);

figure
plotEllipsoid(grains.centroid,a,b,c,'faceColor',color);
setCamera(plottingConvention.default3D)

%%
% The ellipsoids preserve centroid, principal directions, and volume, while
% discarding individual facets. Long thin ellipsoids therefore identify
% anisotropic shape without reproducing every boundary face.

%% Is shape anisotropy associated with grain size?
%
% The ratio of the longest to the shortest ellipsoid half-axis separates
% elongation from size. Colouring by sphericity adds a surface measure:
% grains can have similar aspect ratios yet differ in how faceted they are.

axisLengths = [norm(a), norm(b), norm(c)];
aspectRatio = max(axisLengths,[],2) ./ min(axisLengths,[],2);
figure
scatter(equivalentDiameter,aspectRatio,24,sphericity,'filled')
xlabel('equivalent-sphere diameter (length units)')
ylabel('longest / shortest principal half-axis')
cb = colorbar;
cb.Label.String = 'sphericity';

%%
% The ellipsoid reduces each grain to a few shape descriptors. It cannot
% resolve narrow necks or individual facets. For voxel reconstructions,
% <Grains3DSmoothing.html compare smoothing choices> before interpreting
% sphericity, because staircase surfaces inflate the denominator.

%% Vertices and three kinds of centre
%
% |grain.V| contains the vertices used by the selected grain. Its |centroid|
% is the centre of the enclosed volume. Each entry of |grain.boundary| is one
% face, and |grain.boundary.centroid| contains one area centroid per face.

grain = grains('id',5);

plot(grain,'FaceAlpha',0.5,'edgeAlpha',0.2,'micronbar','off')
hold on
plot(grain.centroid)
plot(grain.V)
plot(grain.boundary.centroid)
hold off
setCamera(plottingConvention.default3D)

%%
% The single interior marker is the volume centroid. Vertex markers lie on
% polygon corners, while the face-centroid markers lie within the boundary
% faces. These point sets describe different levels of the same geometry.

%% Whole-grain property reference
%
% The main whole-grain properties are
%
% || Property || Purpose || Property || Purpose ||
% || <grain3d.volume.html |volume|> || enclosed volume || <grain3d.surface.html |surface|> || enclosing surface area ||
% || <grain3d.diameter.html |diameter|> || largest vertex-to-vertex distance || <grain3d.principalComponents.html |principalComponents|> || volume-matched ellipsoid half-axes ||
% || <grain3d.centroid.html |centroid|> || volume centroid || |V| || grain vertices ||
% || |numPixel| || voxel count after reconstruction || |numFaces| || number of mesh faces ||
% || <grain3d.numNeighbors.html |numNeighbors|> || number of neighbouring grains || <grain3Boundary.grain3Boundary.html |boundary|> || enclosing boundary faces ||
%
% Several @grain2d shape properties do not yet have three-dimensional
% counterparts: |caliper|, |equivalentRadius|, |equivalentPerimeter|,
% |shapeFactor|, |isBoundary|, |hasHole|, and |isInclusion|.

%% Boundary-face properties
%
% A three-dimensional grain boundary stores one entry per polygonal face.
% Its principal geometric and crystallographic properties are
%
% || Property || Purpose || Property || Purpose ||
% || <grain3Boundary.area.html |area|> || face area (length squared) || |N| || stored normal direction ||
% || <grain3Boundary.diameter.html |diameter|> || largest vertex-to-vertex distance || <grain3Boundary.perimeter.html |perimeter|> || length around the face ||
% || <grain3Boundary.centroid.html |centroid|> || area centroid || |grainId| || IDs of adjacent grains ||
% || |misorientation| || orientation difference across the face || |ebsdId| || adjacent voxel IDs after reconstruction ||
%
% The stored normal has one direction for a shared face. The
% <Grains3D.html outward-normal example> explains how |I_GF| changes that
% sign for one chosen grain. Here |'antipodal'| deliberately treats opposite
% normal directions as equivalent and emphasizes the boundary-plane axes.

hold on
quiver(grain.boundary,grain.boundary.N,'antipodal','linewidth',2)
hold off

%%
% The arrows are normal to the faces on which they start. Because they are
% plotted antipodally, this figure does not claim that every arrow points
% outwards.

%% Misorientation across indexed faces
%
% An indexed face separates two grains whose mean orientations are known.
% Filtering with |'indexed'| excludes faces for which that crystallographic
% comparison is unavailable. The colour below is the misorientation angle
% across each remaining face. In this tessellation it comes from grain mean
% orientations; a voxel reconstruction instead stores the difference between
% the neighbouring voxel orientations.

indexedBoundary = grains.boundary('indexed');
plot(indexedBoundary,indexedBoundary.misorientation.angle./degree, ...
  'micronbar','off','edgeAlpha',0.1)
setCamera(plottingConvention.default3D)
cb = colorbar('location','southoutside');
cb.Label.String = 'misorientation angle (degrees)';

%%
% Faces with similar colours separate grain pairs with similar
% misorientation angles. The colour does not encode face orientation or
% face area, which are the separate properties |N| and |area|.

%% References
%
% * R. Quey, P. R. Dawson and F. Barbe,
% <https://doi.org/10.1016/j.cma.2011.01.002 Large-scale 3D random
% polycrystals for the finite element method: Generation, meshing and
% remeshing>, _Computer Methods in Applied Mechanics and Engineering_ 200
% (2011), 1729--1745, describes the synthetic polycrystal generation behind
% the example tessellation.

%% Next
%
% Continue with <Grains3DOperations.html Operations with Three-Dimensional
% Grains> to cut, triangulate, and rotate the grains whose properties were
% measured here.

%#ok<*NOPTS>
