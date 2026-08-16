%% Axis Distribution Function
%%
%
% The misorientation axis distribution is the counterpart of the
% <AngleDistributionFunction.html angle distribution> - it is what remains
% of a <MisorientationDistributionFunction.html misorientation
% distribution function> after integrating out the misorientation angle. It
% is a function on the sphere and is represented in MTEX by an
% <S2FunConcept.html S2Fun>.
%
%% The axis distribution of a uniform texture
%
% As for the angle, the reference case of completely random orientations
% does *not* give a uniform distribution. The reason is that the maximum
% possible misorientation angle depends on the direction of the axis - an
% axis for which the <MisorientationTheory.html fundamental region> extends
% further contributes more misorientations. The command
% <symmetry.calcAxisDistribution.html |calcAxisDistribution|> computes this
% reference distribution

cs = crystalSymmetry('432');

adf = calcAxisDistribution(cs)

%%
% Being an |S2Fun| it can be plotted, evaluated and integrated like any
% other spherical function. Restricted to the
% <CrystalSymmetries.html fundamental sector> of the crystal symmetry it
% looks as follows

plot(adf,'upper')
mtexColorbar

%%
% The same plot is produced directly by
% <plotAxisDistribution.html |plotAxisDistribution|>

plotAxisDistribution(cs)

%%
% The variation is substantial - over the fundamental sector the density
% ranges between

[min(adf) max(adf)]

%%
% i.e. by a factor of more than two. Any interpretation of a measured axis
% distribution has to be made against this reference, not against a
% constant.

%% The axis distribution of measured misorientations
%
% Let us again consider the Magnesium data set

plottingConvention.default('y↑→x');
mtexdata twins silent

grains = calcGrains(ebsd('indexed'),'threshold',5*degree);
grains = smoothBoundary(grains,5);

mori = grains.boundary('Magnesium','Magnesium').misorientation

%%
% The misorientation axes in crystal coordinates are returned by
% <orientation.axis.html |axis|>

mori.axis

%%
% and their distribution is displayed by
% <plotAxisDistribution.html |plotAxisDistribution|>

plotAxisDistribution(mori,'contourf','halfwidth',5*degree)
mtexColorbar

%%
% The single sharp maximum is the twinning axis. Compare this against the
% uniform reference, which is essentially flat over the same sector

plotAxisDistribution(mori.CS,mori.SS)
mtexColorbar

%% Crystal versus specimen coordinates
%
% All of the above lives in *crystal* coordinates - the axis is expressed
% relative to the crystal lattice and is therefore subject to crystal
% symmetry. A misorientation axis can equally well be given in *specimen*
% coordinates, and this is a different question with a different answer.
% Passing the two orientations separately rather than the misorientation
% gives the specimen version

ori1 = ebsd(grains.boundary('Magnesium','Magnesium').ebsdId(:,1)).orientations;
ori2 = ebsd(grains.boundary('Magnesium','Magnesium').ebsdId(:,2)).orientations;

plotAxisDistribution(ori1,ori2,'contourf','halfwidth',5*degree)
mtexColorbar

%%
% This is now a plot over the full sphere in specimen coordinates, with
% only the specimen symmetry imposed. The chapter
% <TiltAndTwistBoundaries.html Tilt and Twist Boundaries> uses exactly this
% distinction to classify boundaries.
%
%% The axis distribution of an ODF
%
% Finally, the axis distribution can also be computed for a misorientation
% distribution function rather than for a list of misorientations. This
% gives the uncorrelated reference for the given texture

odf = calcDensity(grains('Magnesium').meanOrientation,'halfwidth',10*degree);
mdf = calcMDF(odf);

adfMDF = calcAxisDistribution(mdf)

%%

plot(adfMDF,'upper')
mtexColorbar

%%
% It differs markedly from the boundary distribution above, which is
% precisely the statement that the twin boundaries are not a consequence of
% the texture.

%#ok<*ASGLU,*NOPTS>
