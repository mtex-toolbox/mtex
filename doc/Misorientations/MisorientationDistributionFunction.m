%% Misorientation Distribution Function
%
%%
% A single misorientation describes one pair of crystals. A whole map holds
% thousands of them, and the way to look at all of them at once is a
% density on the space of misorientations - the misorientation distribution
% function, MDF.
%
% There are two of them, and confusing them is the classic mistake:
%
% # the *boundary* or *correlated* MDF, built from misorientations between
% grains that actually touch;
% # the *uncorrelated* MDF, built from misorientations between arbitrary
% pairs of orientations, whether or not they are neighbours.
%
% The second is what the two textures alone imply. The first is what the
% microstructure did. Comparing them is how a real orientation relationship
% is told apart from an accident of texture.

plottingConvention.default('y↑→x');
mtexdata forsterite silent

grains = calcGrains(ebsd)

%% The Boundary Misorientation Distribution Function
%
% Take the misorientations along every forsterite to enstatite boundary
% segment.

mori_boundary = grains.boundary('Fo','En').misorientation

%%
% <rotation.calcDensity.html |calcDensity|> turns them into a density, in
% the same way a list of orientations becomes an
% <DensityEstimation.html ODF>.

mdf_boundary = calcDensity(mori_boundary,'halfwidth',5*degree)

%%
% The result is an <SO3FunConcept.html orientation valued function> and
% supports everything such a function does. Its maximum is the preferred
% misorientation.

[v,mori] = max(mdf_boundary)

%%
% 118 times as likely as random, at a misorientation of $90^\circ$ about the
% $(001)$ axis. Forsterite and enstatite share lattice planes in this
% relationship, and it dominates the phase boundaries of this map.

mori.angle ./ degree

%%
% Drawn as an axis-angle section at $90^\circ$:

plotSection(mdf_boundary,'axisAngle',90*degree)
mtexColorbar

%% The Uncorrelated Misorientation Distribution Function
%
% <EBSD.calcMisorientation.html |calcMisorientation|> takes pairs of
% orientations without regard to where they sit in the map.

mori = calcMisorientation(ebsd('En'),ebsd('Fo'))

%%

mdf_uncor = calcDensity(mori)

%%
% Its maximum is 2, not 118 - the relationship found above is nowhere to be
% seen. That is the point of the comparison: the peak in the boundary MDF is
% a property of the boundaries, not something the two textures would produce
% by themselves.

max(mdf_uncor)

%%

plotSection(mdf_uncor,'axisAngle',90*degree)
mtexColorbar

%% The Uncorrelated MDF from Two ODFs
%
% The uncorrelated MDF needs no individual orientations at all. It is
% determined by the two ODFs, and can be computed from them.

odf_fo = calcDensity(ebsd('fo').orientations,'halfwidth',10*degree)

%%

odf_en = calcDensity(ebsd('en').orientations,'halfwidth',10*degree)

%%
% <SO3Fun.calcMDF.html |calcMDF|> does the convolution.

mdf = calcMDF(odf_en,odf_fo)

%%
% It agrees with the uncorrelated MDF computed from the data directly - the
% two differ by 5 percent in the $L^2$ norm, which is the smoothing of the
% two ODFs rather than a difference in content.

norm(mdf - mdf_uncor) ./ norm(mdf_uncor)

%%

plotSection(mdf,'axisAngle',90*degree)
mtexColorbar

%%
% With a single ODF, |calcMDF| gives the uncorrelated misorientations within
% one phase.

mdf_fo = calcMDF(odf_fo)

%% Angle Distribution
%
% The full MDF is a function on a three dimensional space, so it is usually
% reduced further - to the distribution of the misorientation angle alone.

close all
plotAngleDistribution(grains.boundary('fo','en').misorientation)
hold on
plotAngleDistribution(mdf)
hold off
legend('boundary','uncorrelated')

%%
% The boundary curve has the peak near $90^\circ$ that the MDF maximum
% announced; the uncorrelated one does not.
%
% A uniform texture gives a third reference curve, which is the shape a
% misorientation angle distribution has when nothing is going on. It is not
% flat - large angles are simply more numerous than small ones, as on
% <RotationPlotting.html Plotting Rotations>.

close all
plotAngleDistribution(mdf)
hold on
plotAngleDistribution(ebsd('fo').CS,ebsd('en').CS)
hold off
legend('uncorrelated MDF','uniform ODF','Location','best')

%%
% The numbers behind the curves come from
% <SO3Fun.calcAngleDistribution.html |calcAngleDistribution(mdf)|> and
% <orientation.calcAngleDistribution.html |calcAngleDistribution(ori)|>, see
% <AngleDistributionFunction.html Angle Distribution>.

%% Axis Distribution
%
% The other reduction keeps the misorientation axis and forgets the angle.
% For the boundary misorientations:

plotAxisDistribution(grains.boundary('fo','en').misorientation,'smooth')

%%
% and for the uncorrelated MDF:

plotAxisDistribution(mdf)

%%
% The boundary axes concentrate where the preferred misorientation sits,
% while the uncorrelated ones spread over the whole sector. The values are
% available as a spherical function, see
% <AxisDistributionFunction.html Axis Distribution>.

aD = calcDensity(axis(grains.boundary('fo','en').misorientation))

%% Next
%
% The two reductions have pages of their own,
% <AngleDistributionFunction.html Angle Distribution> and
% <AxisDistributionFunction.html Axis Distribution>. What a misorientation
% is in the first place is <MisorientationTheory.html Theory>.

%#ok<*ASGLU,*NOPTS>
