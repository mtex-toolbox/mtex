%% Grids of Orientations
%
%%
% An orientation grid is a finite set of nodes in orientation space. Such
% grids are used to evaluate or approximate an ODF, to search for a best
% fit, and to provide orientations to another numerical method.
%
% Read <OrientationDefinition.html Orientations> and
% <OrientationFundamentalRegion.html Fundamental Regions> first. The
% spherical counterpart is <VectorGrids.html Spherical Grids>.
%
% The nodes should usually be spread uniformly with respect to volume on
% $\mathrm{SO}(3)$, not with respect to the coordinates used to describe a
% rotation. No finite construction is perfectly uniform, and different
% grids preserve different useful structures.
%
% For these figures, the plotting convention lays out the specimen
% reference frame with y up and x to the right. It does not alter the grid.

plottingConvention.default('y↑→x');

% cubic crystal symmetry and trivial specimen symmetry
cs = crystalSymmetry('432');

%% The Equispaced Grid
%
% <equispacedSO3Grid.html |equispacedSO3Grid|> covers the fundamental
% region of the supplied crystal and specimen symmetries with nearly
% constant node spacing. Here the specimen symmetry is the trivial default.
% Both global constructors accept a second symmetry. For an orientation it
% is a specimen symmetry; for a <Misorientations.html misorientation> it is
% the crystal symmetry on the other side.
%
% The |'resolution'| is a target spacing. The construction adjusts the
% angular steps to fit the fundamental region, so it is not a promise that
% every pair of neighbouring nodes is exactly $5^\circ$ apart.

equiGrid = equispacedSO3Grid(cs,'resolution',5*degree)

%%
% The summary reports 4923 orientations and identifies the result as an
% |SO3Grid| with $5^\circ$ resolution. An axis--angle plot shows the nodes
% throughout the cubic fundamental region.

plot(equiGrid,'axisAngle','all','MarkerSize',2);

%%
% The point cloud has no large empty patch or concentrated band. Its visual
% density still changes under axis--angle coordinates, so this plot alone
% cannot establish equal volume in orientation space.

%% The Regular Euler Grid
%
% <regularSO3Grid.html |regularSO3Grid|> instead takes regular steps in the
% three Euler angles. The same nominal resolution creates many more nodes.

regularGrid = regularSO3Grid(cs,'resolution',5*degree);

gridCounts = [length(equiGrid),length(regularGrid)]

%%
% The two entries are 4923 and 24624. Thus the regular grid has five times
% as many orientations at the same nominal resolution.

plot(regularGrid,'axisAngle','all','MarkerSize',1);

%%
% Lines and dense bands remain visible after transformation from Euler
% angles to axis--angle coordinates. They are the signature of regular
% coordinate steps, not extra resolution distributed uniformly over
% orientation space.

%% Why Regular Euler Steps Are Not Uniform
%
% In Bunge Euler angles, the invariant volume element on rotation space is
% proportional to
%
% $$ \sin\Phi\,\mathrm{d}\varphi_1\,\mathrm{d}\Phi\,\mathrm{d}\varphi_2. $$
%
% Equal increments of $\Phi$ therefore represent unequal volumes. A regular
% Euler grid places too many equal-weight nodes where the coordinate map is
% compressed. This is the three-dimensional counterpart of longitude lines
% meeting at the poles of a spherical grid.

%% An Equal-Weight Uniformity Diagnostic
%
% A practical diagnostic treats every node as the centre of an equally
% weighted kernel. If the nodes represent the invariant volume uniformly,
% the resulting ODF should be close to the uniform value 1. Its pole
% figures should therefore also be nearly flat at 1.
%
% The result depends on the kernel halfwidth, which is made explicit here.
% It tests equal-weight node placement at that smoothing scale. It does not
% prove equidistribution, measure nearest-neighbour spacing, or turn the
% nodes into a quadrature rule.

h = Miller({1,0,0},{1,1,0},{1,1,1},cs);
equiOdf = unimodalODF(equiGrid,'halfwidth',10*degree);

plotPDF(equiOdf,h);
setColorRange([0.7 2.7]);
mtexColorbar;

%%
% On the common colour range used for both constructions, all three pole
% figures appear flat. Their values span 0.93 to 1.02, so the equispaced
% grid stays within about 7 percent of 1 in this diagnostic. Flat to
% within a few percent is what a usable grid looks like.

regularOdf = unimodalODF(regularGrid,'halfwidth',10*degree);

plotPDF(regularOdf,h);
setColorRange([0.7 2.7]);
mtexColorbar;

%%
% The regular grid develops a strong peak. Its (100) pole figure spans 0.79
% to 2.62, and the three pole figures together span 0.75 to 2.62. The extra
% points therefore do not buy equal-weight uniformity.

%% Choosing a Global Grid
%
% Use a regular grid when values must lie on an Euler-angle raster, for
% example when <ODFExport.html exporting an ODF> to a format that expects
% one. Use an equispaced grid when approximately uniform equal-weight nodes
% matter more than rectangular Euler indexing.
%
% A nearly uniform point set is not automatically an integration rule.
% Exactness for a class of band-limited functions requires nodes together
% with their prescribed weights; see <SO3FunQuadrature.html Quadrature of
% Rotational Functions>.

%% Grids Around a Given Orientation
%
% <localOrientationGrid.html |localOrientationGrid|> covers a ball around
% one orientation rather than the full symmetry-reduced region. This is the
% useful construction for a local search or a perturbation study.

center = orientation.byEuler(10*degree,20*degree,30*degree,cs);
localGrid = localOrientationGrid(center,10*degree, ...
  'resolution',2.5*degree);

localCount = length(localGrid)
maxLocalAngle = max(angle(localGrid,center)) ./ degree

%%
% The grid contains 265 orientations arranged in shells about the centre.
% Its outermost shell is $8.75^\circ$ from the centre, half a resolution
% step inside the requested $10^\circ$ radius.

plot(localGrid,angle(localGrid,center)./degree, ...
  'axisAngle','all','MarkerSize',4);
hold on
plot(center,'MarkerFaceColor','r','MarkerSize',10);
hold off
mtexColorbar('title','angle to centre in degree');

%%
% The red point marks the centre, and colour records rotational distance
% from it. The ball appears as two patches because it crosses a boundary of
% the fundamental region and wraps to a symmetrically equivalent face.
% Despite that split in the plot, every node lies within the requested ball.

%% Further Reading
%
% * H.-J. Bunge,
% <https://shop.elsevier.com/books/texture-analysis-in-materials-science/bunge/978-0-408-10642-9
% Texture Analysis in Materials Science: Mathematical Methods>,
% Butterworths, 1982. Sections on the invariant measure and Euler space
% give the texture-analysis foundation for the volume element above.
% * A. Morawiec,
% <https://doi.org/10.1007/978-3-662-09156-2 Orientations and Rotations:
% Computations in Crystallographic Textures>, Springer, 2004. This book
% develops rotation-space geometry and symmetry-reduced regions.
% * A. Yershova, S. Jain, S. M. LaValle and J. C. Mitchell,
% <https://doi.org/10.1177/0278364909352700 Generating Uniform Incremental
% Grids on SO(3) Using the Hopf Fibration>, _The International Journal of
% Robotics Research_ 29(7), 801--812, 2010. The paper compares criteria for
% uniform deterministic grids on rotation space.
% * D. Roşca, A. Morawiec and M. De Graef,
% <https://doi.org/10.1088/0965-0393/22/7/075013 A New Method of
% Constructing a Grid in the Space of 3D Rotations and Its Applications to
% Texture Analysis>, _Modelling and Simulation in Materials Science and
% Engineering_ 22, 075013, 2014. This paper develops a volume-preserving
% cubochoric construction for texture analysis.

%% Next
%
% Curves through orientation space, along which many real textures lie, are
% <OrientationFibre.html Fibres of Orientations>. Sampling an ODF
% statistically rather than placing a grid is
% <RandomSampling.html Random Sampling>.

%#ok<*NOPTS>
