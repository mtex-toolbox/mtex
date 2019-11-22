%% Misorientation Distribution Function
%
%% TODO: Please help to extend this section
% Let us consider the uncorrelated missorientation ODF corresponding to our
% model ODF.


mtexdata titanium

odf = calcDensity(ebsd.orientations)

%%


% the uncorrelated 
mdf = calcMDF(odf)

%%

plotSection(mdf,'axisAngle')


%% Axis / Angle Distribution
% Then we can plot the distribution of the rotation axes of this
% missorientation ODF

plotAxisDistribution(mdf)

%%
% and the distribution of the missorientation angles and compare them to a
% uniform ODF

close all
plotAngleDistribution(mdf)
hold all
plotAngleDistribution(ebsd.CS,ebsd.CS)
hold off
legend('model ODF','uniform ODF')

