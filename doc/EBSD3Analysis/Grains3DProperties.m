%% Properties of Three-Dimensional Grains
%
% <Grains3D.html Three-Dimensional Grains> defines the @grain3d collection
% and its polyhedral representation. Three-dimensional grains retain
% material properties such as |meanOrientation|, but their size and shape
% require volume and surface measures rather than planar area and perimeter.
%
% The main whole-grain properties are
%
% || Property || Meaning ||
% || |numPixel| || number of measured volume elements assigned to the grain ||
% || |numFaces| || number of boundary faces belonging to the grain ||
% || <grain3d.volume.html |volume|> || enclosed volume ||
% || <grain3d.surface.html |surface|> || total area of all boundary faces ||
% || <grain3d.diameter.html |diameter|> || greatest distance between two grain vertices ||
% || <grain3d.principalComponents.html |principalComponents|> || three principal half-axes of a volume-matched ellipsoid ||
% || <grain3d.numNeighbors.html |numNeighbors|> || number of neighbouring grains ||
% || <grain3Boundary.grain3Boundary.html |boundary|> || boundary faces of the grain ||
% || |V| || vertices used by the grain ||
% || <grain3d.centroid.html |centroid|> || volume centroid of the grain ||
%
% Several @grain2d shape properties do not yet have three-dimensional
% counterparts: |caliper|, |equivalentRadius|, |equivalentPerimeter|,
% |shapeFactor|, |isBoundary|, |hasHole|, and |isInclusion|.

plottingConvention.default('y↑→x');

%% Load the example microstructure
%
% The bundled data set is a Neper tessellation. The previous
% <NeperInterface.html Neper Interface> page explains how such a collection
% is generated or imported.

mtexdata NeperGrain3d

plot(grains,grains.meanOrientation,'micronbar','off')
setCamera(plottingConvention.default3D)

%%
% Each colour represents one mean orientation. The faceted outlines are the
% boundary polygons from which the geometric properties are computed.

%% Compare size measures
%
% Diameter, surface area, and volume answer different questions. The diameter
% spans the two most distant vertices. Surface sums the areas of all faces,
% while volume measures the enclosed polyhedron. Their units follow the mesh
% coordinates; for this data set they are micrometres, square micrometres,
% and cubic micrometres.
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
% Grain 9 has diameter 19.456 micrometres, surface area 765.91 square
% micrometres, and volume 1431.84 cubic micrometres. The three values cannot
% be substituted for one another because grains with equal volume can have
% very different elongation and surface roughness.
%
% Face and neighbourhood counts provide complementary structural measures.

[grain.numFaces, grain.numNeighbors]

%%
% Grain 9 has 18 boundary faces and 17 neighbouring grains. Its face on the
% outside of the tessellated volume contributes to |numFaces| but does not
% introduce a neighbouring grain.

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
xlabel('grain volume (µm³)')
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
xlabel('surface area (µm²)')
ylabel('number of grains')
mtexTitle('Number weighted')

nextAxis
histogram(grains,grains.surface,surfaceEdges)
xlabel('surface area (µm²)')
mtexTitle('Volume weighted')

%%
% The right panel asks what fraction of the total material belongs to grains
% in each surface-area interval. It does not show a surface-area fraction.

%% Relate diameter and volume
%
% A scatter plot tests how two measures covary. Taking the cube root of
% volume puts both axes in units of length. Similar grain shapes should lie
% near a common trend; elongated or irregular grains can depart from it.

close all
scatter(grains.volume.^(1/3),grains.diameter,18,grains.color,'filled')
xlabel('cube root of volume (µm)')
ylabel('diameter (µm)')

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

close all
plotEllipsoid(grains.centroid,a,b,c,'faceColor',color);
setCamera(plottingConvention.default3D)

%%
% The ellipsoids preserve centroid, principal directions, and volume, while
% discarding individual facets. Long thin ellipsoids therefore identify
% anisotropic shape without reproducing every boundary face.

%% Vertices and three kinds of centre
%
% |grain.V| contains the vertices used by the selected grain. Its |centroid|
% is the centre of the enclosed volume. Each entry of |grain.boundary| is one
% face, and |grain.boundary.centroid| contains one area centroid per face.

grain = grains('id',5);

plot(grain,'FaceAlpha',0.5,'linewidth',2)
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

%% Boundary-face properties
%
% A three-dimensional grain boundary stores one entry per polygonal face.
% Its principal geometric and crystallographic properties are
%
% || Property || Meaning ||
% || |area| || face area in square micrometres ||
% || |N| || stored face-normal direction ||
% || |diameter| || greatest distance between two face vertices ||
% || |perimeter| || length around the face ||
% || |centroid| || area centroid of the face ||
% || |grainId| || IDs of the neighbouring grains ||
% || |misorientation| || misorientation between their mean orientations ||
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
% across each remaining face.

indexedBoundary = grains.boundary('indexed');
plot(indexedBoundary,indexedBoundary.misorientation.angle./degree, ...
  'micronbar','off')
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
