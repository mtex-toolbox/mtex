%% Misorientation Distribution Function
%
%% TODO: Please help to extend this section
% Let us consider the uncorrelated misorientation distribution function
% corresponding to our model ODF.

mtexdata titanium

odf = calcDensity(ebsd.orientations)

%%


% the uncorrelated misorientation density function
mdf = calcMDF(odf)

%%

plotSection(mdf,'axisAngle')


%% Axis / Angle Distribution
% Then we can plot the distribution of the rotation axes of this
% misorientation ODF

plotAxisDistribution(mdf)

%%
% and the distribution of the misorientation angles and compare them to a
% uniform ODF

close all
plotAngleDistribution(mdf)
hold on
plotAngleDistribution(ebsd.CS,ebsd.CS)
hold off
legend('model ODF','uniform ODF')

