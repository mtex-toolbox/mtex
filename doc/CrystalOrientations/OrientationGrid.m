%% Grids of Orientations
%
%%
% Numerical work on the rotation group needs orientations spread as evenly
% as possible over it - to integrate an ODF, to sample one, or to search for
% a best fit. As on the sphere, there is no perfectly even arrangement, and
% the constructions on offer differ in how close they come.

plottingConvention.default('y↑→x');

% define a crystal symmetry
cs = crystalSymmetry('432')

%% The Equispaced Grid
%
% <equispacedSO3Grid.html |equispacedSO3Grid|> covers the fundamental region
% of the given symmetry with a nearly constant spacing.

ori = equispacedSO3Grid(cs,'resolution',5*degree)

%%
% Just under 5000 orientations at $5^\circ$ for cubic symmetry. Seen in axis
% angle space they fill the fundamental region evenly.

plot(ori,'axisAngle')

%% Checking for Equidistribution
%
% Even spacing is easier to claim than to achieve, and the honest test is to
% treat the grid as a data set: an ODF built from it should be the uniform
% one, and the pole figures of a uniform ODF are flat at 1.

odf = unimodalODF(ori)

plotPDF(odf,Miller({1,0,0},{1,1,0},{1,1,1},cs))
mtexColorbar

%%
% Between 0.93 and 1.02 - flat to within a few percent, which is what a
% usable grid looks like.

%% The Regular Grid
%
% <regularSO3Grid.html |regularSO3Grid|> instead steps through the three
% Euler angles regularly.

ori = regularSO3Grid(cs,'resolution',5*degree)

%%
% Five times as many orientations for the same nominal resolution, 24624
% against 4923.

plot(ori,'axisAngle')

%%
% And the extra points do not buy uniformity. The same test now runs from
% 0.79 to 2.62 - the grid piles up wherever Euler angle space is compressed,
% exactly as the regular grid on the sphere piles up at the poles, see
% <VectorGrids.html Spherical Grids>.

odf = unimodalODF(ori)

plotPDF(odf,Miller({1,0,0},{1,1,0},{1,1,1},cs))
mtexColorbar

%%
% Use the regular grid when the Euler angle raster itself is wanted, for
% instance to write an ODF to a file that expects one, and the equispaced
% grid for everything else.

%% Grids Around a Given Orientation
%
% <localOrientationGrid.html |localOrientationGrid|> covers a ball around
% one orientation rather than the whole region, which is what a local search
% or a perturbation study needs.

center = orientation.byEuler(10*degree,20*degree,30*degree,cs);

ori = localOrientationGrid(center,10*degree,'resolution',2.5*degree)

%%
% 265 orientations arranged in shells about the centre. The outermost shell
% sits at 8.75 degree, half a resolution step inside the radius that was
% asked for.

max(angle(ori,center)) ./ degree

%% Next
%
% Sampling an ODF at random rather than on a grid is
% <RandomSampling.html Random Sampling>. Curves through orientation space,
% along which many real textures lie, are
% <OrientationFibre.html Fibres of Orientations>.

%#ok<*NOPTS>
