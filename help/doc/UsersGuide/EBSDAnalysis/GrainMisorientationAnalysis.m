%% Misorientation Analysis
% How to analyse misorientations.
%
%% Open in Editor
%
%% Contents
%
%% Definition
%
% In MTEX the misorientation between two orientations x, y is defined as
%
% $$ mis(x,y) = x^{-1} * y  $$
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

[grains,ebsd] = calcGrains(ebsd,'threshold',5*degree);


%% Intergranular misorientations
% The intergranular misorientation is automatically computed while
% reconstructing the grain structure. It is stored as the property
% *mis2mean* within the ebsd variable and can be accessed by the command
% <ebsd_get.html,get>.

% get the misorientations to mean
mori = ebsd('Fo').mis2mean

% plot a histogram of the misorientation angles
% TODO: plotAngleDistribution(mori)
close all
hist(mori.angle/degree)
xlabel('Misorientation angles in degree')

%%
% The visualization of the misorientation can be done by

close all
plot(ebsd('Forsterite'),ebsd('Forsterite').mis2mean.angle./degree)
mtexColorMap WhiteJet
colorbar(gcm)
hold on
plot(grains.boundary,'edgecolor','k','linewidth',.5)
hold off

%% Boundary misorientations
% The misorientation between adjacent grains can be computed by the command
% <grainBoundary.misorientation.html>

% get the id of the largest grain
[~,id] = max(grains.grainSize);


plot(grains(id))

%%

plot(grains(id).boundary({'Fo','Fo'}),'linecolor','r')

grains(id).boundary({'Fo','Fo'}).misorientation

%%



%%

% get the neigbours of this grain
neigbourId = find(grains.A_G(:,id));

% find the largest neigbouring grain
[~,id2] = max(grains(neigbourId).grainSize);
id2 = neigbourId(id2);

% plot these grains
plot(grains([id,id2]))


%%
% Note that MTEX computes misorientations for all grain boundary segments
% between two grains
mori = calcMisorientation(grains(id),grains(id2))

%%
% The mean misorientation is computed by
mean(mori)

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
plotAngleDistribution(grains)

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

hold on
plotAngleDistribution(ebsd,'ODF')
hold off

%%
% Another possibility is to compute an uncorrelated angle distribution from
% the EBSD data set by taking only into account those pairs of measurements 
% that are sufficently far from each other (uncorrelated points). The uncorrelated angle
% distribution is plotted by

close all
plotAngleDistribution(grains,'uncorrelated')

%%
% In order to consider only a specific phase transistion one can use the
% syntax

close all
plotAngleDistribution(grains('Fo'),grains('En'),'uncorrelated')

%% The axis distribution
% 
% Let's start here with the uncorrelated axis distribution, which depends
% only on the underlying ODFs. 

plotAxisDistribution(grains('Fo'),'uncorrelated','contourf','antipodal')
colorbar

%%
% We may plot the axes of the boundary misorientations directly into this
% plot

hold on
plotAxisDistribution(grains('Fo'),'antipodal','SampleSize',100,...
  'MarkerSize',4,'MarkerFaceColor','none','MarkerEdgeColor','red')
mtexColorMap white2black
hold off

%%
% However, this might serve only for a qualitative comparison. For a better
% comparison we plot the axis distribiution of the boundary misorientations
% also as a density plot.

plotAxisDistribution(grains('Fo'),'antipodal','contourf')
colorbar

%%
% This shows a much stronger preference of the (1,1,1) axis in comparison
% to the uncorrelated distribution.
