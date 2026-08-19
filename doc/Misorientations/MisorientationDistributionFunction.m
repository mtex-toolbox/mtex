%% Misorientation Distribution Function
%
%%
% When speaking about the misorientation distribution function (MDF) one
% has to distinguish two cases
%
% # the boundary (correlated) misorientation distribution function
% # the uncorrelated misorientation distribution function
%
% While the first one considers only misorientations at grain boundaries
% the second one considers misorientations between arbitrary crystal
% orientations. To illustrate the difference lets consider the following
% EBSD data set and reconstruct its grains.

plottingConvention.default('y↑→x');
mtexdata forsterite silent

grains = calcGrains(ebsd)

%% The Boundary Misorientation Distribution Function
%
% In order to compute the boundary misorientation distribution function for
% the phase transition from Forsterite to Enstatite we first extract the
% misorientations along all Forsterite to Enstatite boundary segments

mori_boundary = grains.boundary('Fo','En').misorientation

%%
% and second compute the corresponding density function using the command
% <rotation.calcDensity.html calcDensity>

mdf_boundary = calcDensity(mori_boundary,'halfwidth',5*degree)

%%
% The misorientation distribution function can be processed as any other
% <SO3FunConcept.html orientation valued function>. E.g. we may compute the
% preferred misorientation

[v,mori] = max(mdf_boundary)

%%
% or plot it in an axis angle section 

plotSection(mdf_boundary,'axisAngle',90*degree)
mtexColorbar

%% The Uncorrelated Misorientation Distribution Function
%
% The uncorrelated misorientation distribution function is computed from
% misorientations between arbitrary orientations, which are extracted by
% <EBSD.calcMisorientation.html |calcMisorientation|>

mori = calcMisorientation(ebsd('En'),ebsd('Fo'))

mdf_uncor = calcDensity(mori)

%%
% Obviously it is different from the boundary misorientation distribution
% function.

plotSection(mdf_uncor,'axisAngle',90*degree)
mtexColorbar

%% Computing the Uncorrelated MDF from two ODFs
%
% The uncorrelated MDF does not require the individual orientations at all
% - it is fully determined by the two ODFs involved. Let us estimate them
% from the same data set

odf_fo = calcDensity(ebsd('fo').orientations,'halfwidth',10*degree)
odf_en = calcDensity(ebsd('en').orientations,'halfwidth',10*degree)

%%
% Then the uncorrelated misorientation function between these two ODFs is
% computed by <SO3Fun.calcMDF.html |calcMDF|>

mdf = calcMDF(odf_en,odf_fo)

%%
% This misorientation distribution function should be similar to the
% uncorrelated misorientation function computed directly from the EBSD data

plotSection(mdf,'axisAngle',90*degree)
mtexColorbar

%%
% Passing a single ODF to <SO3Fun.calcMDF.html |calcMDF|> gives the
% uncorrelated misorientations within one phase

mdf_fo = calcMDF(odf_fo)

%% Angle Distribution
%
% Let us compare the actual angle distribution of the boundary
% misorientations with the theoretical angle distribution of the
% uncorrelated MDF.

close all
plotAngleDistribution(grains.boundary('fo','en').misorientation)
hold on
plotAngleDistribution(mdf)
hold off
legend('boundary','uncorrelated')

%%
% It is often instructive to add the angle distribution of a uniform
% texture as a reference

close all
plotAngleDistribution(mdf)
hold on
plotAngleDistribution(ebsd('fo').CS,ebsd('en').CS)
hold off
legend('uncorrelated MDF','uniform ODF','Location','best')

%%
% For computing the exact values see the commands
% <SO3Fun.calcAngleDistribution.html calcAngleDistribution(mdf)> and
% <orientation.calcAngleDistribution.html calcAngleDistribution(ori)>.

%% Axis Distribution
%
% The same comparison can be made for the distribution of the
% misorientation axes. First the actual axis distribution of the boundary
% misorientations

plotAxisDistribution(grains.boundary('fo','en').misorientation,'smooth')

%%
% and now the theoretical axis distribution of the uncorrelated MDF

plotAxisDistribution(mdf)

%%
% For computing the exact values see the commands
% <SO3Fun.calcAxisDistribution.html calcAxisDistribution(mdf)> and
% <SO3Fun.calcAxisDistribution.html calcAxisDistribution(grains)>.

aD = calcDensity(axis(grains.boundary('fo','en').misorientation))

%#ok<*ASGLU,*NOPTS>
