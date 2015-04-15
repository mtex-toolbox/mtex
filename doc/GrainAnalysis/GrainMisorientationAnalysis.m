%% Misorientation Analysis
% How to analyse misorientations.
%
%% Open in Editor
%
%% Contents
%
%% Definition
%
% In MTEX the misorientation between two orientations o1, o2 is defined as
%
% $$ mis(o_1,o_2) = o_1^{-1} * o_2  $$
%
% In the case of EBSD data, intergranular misorientations, misorientations
% between neighbouring grains, and misorientations between random
% measurments are of interest.


%% The sample data set
% Let us first import some EBSD data by a [[matlab:edit mtexdata, script file]]

mtexdata forsterite
plotx2east

%%
% and <EBSD.calcGrains.html reconstruct> grains by

% perform grain segmentation
[grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd('indexed'),'threshold',5*degree);


%% Intergranular misorientations
% The intergranular misorientation is automatically computed while
% reconstructing the grain structure. It is stored as the property
% |mis2mean| within the ebsd variable and can be accessed by

% get the misorientations to mean
mori = ebsd('Fo').mis2mean

% plot a histogram of the misorientation angles
plotAngleDistribution(mori)
xlabel('Misorientation angles in degree')

%%
% The visualization of the misorientation angle can be done by

close all
plot(ebsd('Forsterite'),ebsd('Forsterite').mis2mean.angle./degree)
mtexColorMap WhiteJet
colorbar
hold on
plot(grains.boundary,'edgecolor','k','linewidth',.5)
hold off

%%
% In order to visualize the misorientation by an ipdf colorcoding we first
% define an orientation to colormapping and set the |colorStretching| to
% increase the contrast around the white center. Note that the
% inversPoleFigureDirection of the ipdf map is automatically set to the
% white center to colorize grains with a small texture gradient with light
% colors.

oM = ipdfHSVOrientationMapping(mori)
oM.colorStretching = 5;

plot(oM)

%%


plot(ebsd('Forsterite'),oM.orientation2color(ebsd('Forsterite').mis2mean))
hold on
plot(grains.boundary,'edgecolor','k','linewidth',.5)
hold off


%% Boundary misorientations
% The misorientation between adjacent grains can be computed by the command
% <grainBoundary.misorientation.html>

plot(grains)

hold on

bnd_FoFo = grains.boundary('Fo','Fo')

plot(bnd_FoFo,'linecolor','r')

hold off

bnd_FoFo.misorientation


%%

plot(ebsd,'facealpha',0.5)

hold on
plot(grains.boundary)
plot(bnd_FoFo,bnd_FoFo.misorientation.angle./degree,'linewidth',2)
mtexColorMap blue2red
colorbar
hold off


%%
% In order to visualize the the misorientation between any two adjacent
% grains there are two possibilities in MTEX.
%
% * plot the angle distribution for all phase combinations
% * plot the axis distribution for all phase combinations
%
%% The angle distribution
%
% The following command plot the angle distribution of all misorientations
% grouped according to phase trasistions.

close all
plotAngleDistribution(grains.boundary)

%%
% The above angle distributions can be compared with the uncorrelated angle
% distributions. The uncorrelated angle distributions can be obtained in
% two ways. First one can do the following
%
% # estimate an ODF for each phase
% # compute for any phase transition a misorientation distribution function
% (MDF)
% # compute the continuous angle distribution of the MDFs
%
% All these steps are performed by the single command

close all
plotAngleDistribution(ebsd)


%%
% Another possibility is to compute an uncorrelated angle distribution from
% the EBSD data set by taking only into account those pairs of measurements 
% that are sufficently far from each other (uncorrelated points). The uncorrelated angle
% distribution is plotted by

%plotAngleDistribution(ebsd,'ODF')

%%
% In order to consider only a specific phase transistion one can use the
% syntax

close all
plotAngleDistribution(ebsd('Fo'),ebsd('En'))

%% The axis distribution
% 
% Let's start here with the uncorrelated axis distribution, which depends
% only on the underlying ODFs. 

close all
mtexFig = newMtexFigure;
plotAxisDistribution(ebsd('Fo'),'smooth','parent',mtexFig.gca)
mtexTitle('uncorrelated axis distribution')
mtexFig.drawNow('figSize','normal')

%%
% We may plot the axes of the boundary misorientations directly into this
% plot

mtexFig.nextAxis
plotAxisDistribution(grains.boundary('Fo','Fo'),'smooth','parent',mtexFig.gca)
mtexTitle('boundary axis distribution')
colorbar

%%
% This shows a much stronger preference of the (1,1,1) axis in comparison
% to the uncorrelated distribution.
