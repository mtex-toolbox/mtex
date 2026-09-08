%% The Three-Dimensional Boundary Network
%
% The boundary of a set of three-dimensional grains is one surface mesh for
% the whole volume. Every face separates two grains and, when the grains
% were reconstructed from voxels, knows the two voxels it separates. Along
% the edges where three grains meet run the triple lines, and where four
% grains meet sits a quadruple point. These contacts constrain grain growth
% and provide possible paths for intergranular transport or damage. This
% page measures how much interface is present and shows how the junctions
% connect it, using the IN100 volume of the reconstruction page.

plottingConvention.default('y↑→x');
how2plot = plottingConvention.default3D;

fname = fullfile(mtexDataPath,'EBSD','SmallIN100_MeshStats.dream3d');
ebsd = EBSD3.load(fname);
[grains,ebsd] = calcGrains(ebsd,'angle',5*degree);
gB = grains.boundary

%% One face, two grains, two voxels
%
% A face is a triangle, two per voxel face. |grainId| holds the two grains
% it separates, with the face normal pointing from the first into the
% second. |ebsdId| holds the two voxels on either side, and |misorientation|
% the misorientation between their orientations, computed from the voxels
% rather than from the grain means. Faces on the outer hull of this voxel
% reconstruction have a zero in the second column of both. In a general
% imported mesh the zero can occur on either side, so test both columns.

[gB.grainId(1:5,:), gB.ebsdId(1:5,:)]

%%
% Count area, not triangles: refining a face changes its mesh count without
% adding any physical interface. The following fractions distinguish the
% measurement hull from contacts between indexed grains.

faceArea = gB.area;
isHull = any(gB.grainId == 0,2);
isIndexed = all(gB.isIndexed,2) & ~isHull;
[sum(faceArea(isHull)), sum(faceArea(isIndexed))] / sum(faceArea)

%% Select faces
%
% A boundary is selected like a list: by the grains at its sides, by phase,
% or by any property of the faces. The faces of one grain, the faces between
% two grains, and the faces above a misorientation angle are three common
% selections.

[~,largestIndex] = max(grains.volume);
id = grains(largestIndex).id;
gBid = gB(any(gB.grainId == id,2));
neighbours = setdiff(unique(gBid.grainId(:)),[0 id]).';
gBpair = gB(any(gB.grainId == id,2) & any(gB.grainId == neighbours(1),2));
gBhigh = gB(gB.misorientation.angle > 30*degree & all(gB.grainId > 0,2));

[length(gBid), length(gBpair), length(gBhigh)]

%%
% The largest grain, with its faces coloured by the misorientation angle
% across them. Each triangle has one value, but the values may vary over a
% contact between the same two grains: they come from the local voxel
% orientations. Missing orientations and the measurement hull do not supply
% a meaningful misorientation angle.

plot(gBid,gBid.misorientation.angle./degree,'edgeAlpha',0.1,'micronbar','off')
setCamera(how2plot)
mtexColorbar('title','misorientation angle in degree')

%% Edges, triple lines and quadruple points
%
% <grain3Boundary.edges.html |edges|> lists every edge once and tells for
% each face which three edges bound it. An edge on two faces lies inside a
% boundary face, an edge on three or more faces on a triple line.
% <grain3Boundary.nodeType.html |nodeType|> counts the grains at every
% vertex: 2 inside a face, 3 on a triple line, 4 at a quadruple point, and
% 10 more for a vertex on the outer hull.

[E,F2E] = edges(gB);
isTripleLine = accumarray(F2E(:),1) >= 3;
t = nodeType(gB);

[size(E,1), nnz(isTripleLine), nnz(mod(t,10) == 3), nnz(mod(t,10) >= 4)]

%%
% The triple lines of the largest grain, drawn over its faces. Every line
% is where a neighbour ends and the next one begins, and the lines meet at
% the quadruple points.

V = gB.allV.xyz;
onGrain = false(size(V,1),1); onGrain(gBid.F(:)) = true;
onGrainEdge = false(size(E,1),1);
onGrainEdge(F2E(any(gB.grainId == id,2),:)) = true;
Eid = E(isTripleLine & onGrainEdge,:);
X = [V(Eid(:,1),1), V(Eid(:,2),1), nan(size(Eid,1),1)].';
Y = [V(Eid(:,1),2), V(Eid(:,2),2), nan(size(Eid,1),1)].';
Z = [V(Eid(:,1),3), V(Eid(:,2),3), nan(size(Eid,1),1)].';

plot(gBid,'FaceColor',[0.85 0.85 0.85],'edgeAlpha',0.1,'micronbar','off')
hold on
line(X(:),Y(:),Z(:),'Color','r','LineWidth',1.5)
isQuad = mod(t,10) >= 4 & onGrain;
scatter3(V(isQuad,1),V(isQuad,2),V(isQuad,3),30,'b','filled')
hold off
setCamera(how2plot)

%%
% The counts describe mesh vertices, not numbers of physical junctions.
% A triple line has many vertices, and voxel corners can join more than four
% grains. Types above 10 identify junctions on the measurement hull.

n = accumarray(t(t>0),1);
[find(n), n(n>0)]

%% From faces to the boundary character
%
% Each face carries all five parameters of a grain boundary: the
% misorientation of the two grains and the normal of the face. The normals
% of the voxel surface point along the axes, so the surface has to be
% smoothed first, see <Grains3DSmoothing.html Smoothing>, before the
% <BoundaryNormalDistribution.html boundary normal distribution> or the
% boundary character distribution reads anything but the voxel grid.

grainsS = smoothBoundary(reduceBoundary(grains,2,'quadric'),taubinFilter(20));
gBS = grainsS.boundary('indexed');

plot(calcGBND(gBS),'upper','micronbar','off')
mtexColorbar

%% How much internal boundary is there per unit volume?
%
% Boundary area per specimen volume is a useful geometric input when
% comparing interfacial storage or transport between microstructures. Each
% shared face appears once in |grains.boundary|. Summing |grains.surface|
% instead would count an internal interface twice and include the hull.

internal = all(grainsS.boundary.grainId > 0,2);
internalArea = sum(grainsS.boundary(internal).area);
boundaryAreaDensity = internalArea / sum(grainsS.volume)

%%
% The unit is inverse length. This value uses all internal contacts and the
% full reconstructed volume. To report only indexed grain boundaries, use
% |grainsS.boundary('indexed')| and state the corresponding volume denominator.

%% What fraction of indexed boundary area has a low angle?
%
% Use a stated angle threshold and weight by face area. This describes the
% local misorientation stored on the reconstructed faces, rather than a
% count of low-angle grain pairs. After coarsening, the retained faces carry
% inherited misorientations; remeasure from the original data if local
% orientation gradients are the quantity of interest.

angleLimit = 15*degree;
lowAngle = gBS.misorientation.angle < angleLimit;
lowAngleAreaFraction = sum(gBS(lowAngle).area) / sum(gBS.area)

%%
% A low-angle fraction alone does not establish a connected boundary path.
% Connectivity also requires the grain pairs and junction network. Likewise,
% the specimen-frame normal distribution above describes preferred interface
% inclinations, not preferred crystallographic planes. For one selected phase,
% |calcGBND(gBS,grainsS('phase name'))| transforms normals into the crystal
% frame; see <BoundaryNormalDistribution.html Boundary Normal Distribution>.

%% Function reference
%
% || Function || Purpose || Function || Purpose ||
% || <grain3Boundary.edges.html |edges|> || list mesh edges and face incidence || <grain3Boundary.nodeType.html |nodeType|> || classify junction vertices ||
% || <grain3Boundary.plot.html |plot|> || colour boundary faces || <grain3Boundary.quiver.html |quiver|> || draw face-normal directions ||
% || <grain3Boundary.calcGBND.html |calcGBND|> || estimate the normal distribution || <grain3d.neighbors.html |neighbors|> || list adjacent grain pairs ||

%% References
%
% * G. S. Rohrer, <https://doi.org/10.1111/j.1551-2916.2011.04384.x
% Measuring and interpreting the structure of grain-boundary networks>,
% _Journal of the American Ceramic Society_ 94 (2011), 633-646, the five
% parameter description of a boundary and its distribution from a triangle
% mesh.
% * M. A. Groeber, M. A. Jackson, <https://doi.org/10.1186/2193-9772-3-5
% DREAM.3D: a digital representation environment for the analysis of
% microstructure in 3D>, _Integrating Materials and Manufacturing
% Innovation_ 3 (2014), the node types of the boundary network.
%
%% Next
%
% Continue with <NeperInterface.html Neper Interface> to construct a
% synthetic comparison, or go to <Grains3DProperties.html Properties> to
% measure grain size and shape. <Grains3DSmoothing.html Smoothing> explains
% the geometric treatment used before the surface measurements above.

%#ok<*NOPTS>
