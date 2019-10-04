%% Misorientation Distribution Function
% Explains how to compute and analyze misorientation distribution
% functions. 
%
%% Open in Editor
%
%% Contents
%

%% Computing a misorientation distribution function from EBSD data
% 
% Lets import some EBSD data and reconstruct the grains.

mtexdata forsterite
grains = calcGrains(ebsd)

%% SUB: The boundary misorientation distribution function
%
% The boundary misorientation distribution function for the phase
% transition from Forsterite to Enstatite can be computed by

mdf_boundary = calcODF(grains.boundary('Fo','En').misorientation,'halfwidth',10*degree)

%%
% The misorientation distribution function can be processed as any other
% ODF. E.g. we can compute the prefered misorientation via

[v,mori] = max(mdf_boundary)

%%
% or plot the pole figure corresponding to the crystal axis (1,0,0)

plotPDF(mdf_boundary,Miller(1,0,0,ebsd('Fo').CS))

%% SUB: The uncorrelated misorientation distribution function
% 
% Alternatively the uncorrelated misorientation distribution function can be
% computed by providing the option *uncorrelated*

mori = calcMisorientation(ebsd('En'),ebsd('Fo'))
mdf_uncor = calcODF(mori)

%%
% Obviously it is different from the boundary misorientation distribution
% function.

plotPDF(mdf_uncor,Miller(1,0,0,ebsd('Fo').CS))

%% Computing the uncorrelated misorientation function from two ODFs
%
% Let given two odfs

odf_fo = calcODF(ebsd('fo').orientations,'halfwidth',10*degree)
odf_en = calcODF(ebsd('en').orientations,'halfwidth',10*degree)

%%
% Then the uncorrelated misorientation function between these two ODFs can
% be computed by

mdf = calcMDF(odf_en,odf_fo)

%%
% This misorientation distribution function should be similar to the
% uncorrelated misorientation function computed directly from the ebsd data

plotPDF(mdf,Miller(1,0,0,ebsd('Fo').CS))

%% Analyzing misorientation functions
%
% 

%% SUB: Angle distribution
%
% Let us first compare the actual angle distribution of the boundary
% misorientations with the theoretical angle distribution of the
% uncorrelated MDF.

close all
plotAngleDistribution(grains.boundary('fo','en').misorientation)

hold on

plotAngleDistribution(mdf)

hold off

%%
% For computing the exact values see the commands
% <ODF.calcAngleDistribution.html calcAngleDistribution(mdf)> and
% <EBSD.calcAngleDistribution.html calcAngleDistribution(grains)>.
 
%% SUB: Axis distribution
%
% The same we can do with the axis distribution. First the actual angle distribution of the boundary
% misorientations

plotAxisDistribution(grains.boundary('fo','en').misorientation,'smooth')

%%
% Now the theoretical axis distribution of the
% uncorrelated MDF.

plotAxisDistribution(mdf)

%%
% For computing the exact values see the commands
% <ODF.calcAxisDistribution.html calcAxisDistribution(mdf)> and
% <EBSD.calcAxisDistribution.html calcAxisDistribution(grains)>.
