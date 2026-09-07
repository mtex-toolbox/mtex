%% Smoothing Three-Dimensional Grain Boundaries
%
% Grains reconstructed from voxel data have a boundary that follows the
% voxel faces. Every face normal points along one of the three axes, so a
% boundary normal distribution or a curvature computed from it measures the
% grid, not the specimen. This page coarsens the voxel surface, smooths it,
% and looks at what stays fixed on the way.

plottingConvention.default('y↑→x');
how2plot = plottingConvention.default3D;

fname = fullfile(mtexDataPath,'EBSD','SmallIN100_MeshStats.dream3d');
ebsd = EBSD3.load(fname);
grains = calcGrains(ebsd,'angle',5*degree)

%% The boundary network is stratified
%
% A boundary face separates two grains. Along a triple line three grains
% meet, at a quadruple point four. <grain3Boundary.nodeType.html
% |nodeType|> counts the grains at every vertex and adds 10 on the outer
% hull of the measured volume, where a vertex inside a single grain also
% occurs. The counts show how much of the network is junction: about one
% vertex in eight lies on a triple line.

t = nodeType(grains.boundary);
n = accumarray(t(t>0),1);
[find(n), n(n>0)]

%%
% A junction must not be averaged with the interior of a face, which is why
% the smoothing below treats each stratum in turn.

%% Coarsen first
%
% <grain3d.reduceBoundary.html |reduceBoundary|> merges the vertices of each
% cell of twice the voxel size into one. Vertices that belong to different
% grains, or to different faces of the hull, never merge, so every triple
% line and quadruple point survives and the hull stays flat. The centroid
% of a cluster already averages the voxel steps; the flag |'quadric'| puts
% the vertex where the faces around it are best approximated instead, which
% keeps flat boundaries flat.

grainsC = reduceBoundary(grains,2,'quadric')

%%
% The number of faces drops by a factor of 2.6 and the total volume is
% unchanged. The largest grain shows the effect.

[~,id] = max(grains.volume);
plot(grains(id),'micronbar','off')
setCamera(how2plot)

%%
plot(grainsC(id),'micronbar','off')
setCamera(how2plot)

%% Smooth
%
% <grain3d.smoothBoundary.html |smoothBoundary|> moves the vertices and
% nothing else. Quadruple points and the hull stay fixed, every triple line
% is smoothed as a curve between its quadruple points, and every boundary
% face as a surface between its triple lines. The filters are the ones of
% the two-dimensional <GrainSmoothing.html grain smoothing>: |laplaceFilter|
% shrinks each grain a little per iteration, |taubinFilter| keeps the
% volumes approximately, |curvatureFilter| solves for a smoothing length in
% one step.

grainsS = smoothBoundary(grainsC,taubinFilter(20));
plot(grainsS(id),'micronbar','off')
setCamera(how2plot)

%%
% The staircase is gone and the triple lines are still where the three
% grains meet. Since the hull is fixed, the volumes of all grains together
% are conserved exactly. Per grain the Taubin filter changes the volume
% about half as much as the Laplace filter; the small grains lose most.

vol = [grains.volume, smoothBoundary(grainsC,laplaceFilter(20)).volume, grainsS.volume];
sum(vol)

%%
% The median relative change of a grain volume, Laplace against Taubin.

median(abs(vol(:,2:3) - vol(:,1)) ./ vol(:,1))

%%
% The option |'maxDisplacement'| bounds how far the surface may travel, half
% a voxel keeps a single voxel grain in place. The scheme |'coupled'|
% smooths all vertices at once, which is what DREAM.3D does, and lets the
% triple lines drift with the faces.

%% What the smoothing changes downstream
%
% The boundary normal distribution of the voxel surface has all its weight
% on the three axes. After smoothing the normals spread over the sphere.

gB = grains.boundary; gB = gB(all(gB.grainId > 0,2));
plot(calcGBND(gB),'upper','micronbar','off')
mtexColorbar

%%
gBS = grainsS.boundary; gBS = gBS(all(gBS.grainId > 0,2));
plot(calcGBND(gBS),'upper','micronbar','off')
mtexColorbar

%% Refine
%
% <grain3d.refineBoundary.html |refineBoundary|> splits every edge at its
% midpoint and every face into four. No vertex moves, so volumes, areas and
% the grains a face separates are inherited exactly. It restores the
% resolution a coarsened mesh lost, for instance before a filter with a
% short smoothing length.

grainsR = refineBoundary(grainsS);
[length(grainsS.boundary), length(grainsR.boundary)]

%% References
%
% * S. Maddali, S. Ta'asan, R. M. Suter,
% <https://doi.org/10.1016/j.commatsci.2016.08.021 Topology-faithful
% nonparametric estimation and tracking of bulk interface networks>,
% _Computational Materials Science_ 125 (2016), 328-340, the hierarchical
% treatment of quadruple points, triple lines and faces.
% * G. Taubin, <https://doi.org/10.1145/218380.218473 A signal processing
% approach to fair surface design>, SIGGRAPH 1995, the λ|μ filter without
% shrinkage.
% * M. Desbrun, M. Meyer, P. Schröder, A. H. Barr,
% <https://doi.org/10.1145/311535.311576 Implicit fairing of irregular
% meshes using diffusion and curvature flow>, SIGGRAPH 1999, smoothing as
% one linear solve.
% * J. Rossignac, P. Borrel, <https://doi.org/10.1007/978-3-642-78114-8_29
% Multi-resolution 3D approximations for rendering complex scenes>, Modeling
% in Computer Graphics, Springer 1993, vertex clustering.
% * P. Lindstrom, <https://doi.org/10.1145/344779.344912 Out-of-core
% simplification of large polygonal models>, SIGGRAPH 2000, the quadric
% placement of a cluster.
% * S. F. F. Gibson, <https://doi.org/10.1007/BFb0056277 Constrained elastic
% surface nets>, MICCAI 1998, the bound on the displacement.
% * M. A. Groeber, M. A. Jackson, <https://doi.org/10.1186/2193-9772-3-5
% DREAM.3D: a digital representation environment for the analysis of
% microstructure in 3D>, _Integrating Materials and Manufacturing
% Innovation_ 3 (2014), the node types and the coupled scheme.
%
%% Next
%
% <Grains3DProperties.html Properties> lists what can be measured on the
% smoothed grains, and <BoundaryNormalDistribution.html Boundary Normal
% Distribution> the analysis the smoothing was made for.
