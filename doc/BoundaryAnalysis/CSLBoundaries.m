%% CSL Boundaries
% Explains how to analyze CSL grain boundaries
%
%% Open in Editor
%
%% Contents
%
%% Data import and grain detection
%
% Lets import some iron data and segment grains within the data set.
mtexdata csl

% grain segementation
[grains,ebsd.grainId] = calcGrains(ebsd('indexed'))

% grain smoothing
grains = smooth(grains,2) 

% plot the result
plot(grains,grains.meanOrientation)

%%
% Next we plot image quality as it makes the grain boundaries visible.

plot(ebsd,log(ebsd.prop.iq),'figSize','large')
mtexColorMap black2white
CLim(gcm,[.5,5])

% and overlay it with the orientation map
hold on
plot(grains,grains.meanOrientation,'FaceAlpha',0.4)
hold off

%% Detecting CSL Boundaries
% In order to detect CSL boundaries within the data set we first restrict
% the grain boundaries to iron to iron phase transitions and check then
% the boundary misorientations to be a CSL(3) misorientation with threshold
% of 3 degree.

% restrict to iron to iron phase transition
gB = grains.boundary('iron','iron')

% select CSL(3) grain boundaries
gB3 = gB(angle(gB.misorientation,CSL(3)) < 3*degree);

% overlay CSL(3) grain boundaries with the existing plot
hold on
plot(gB3,'lineColor','g','linewidth',2,'DisplayName','CSL 3')
hold off

%% Merging grains with common CSL(3) boundary
% Next we merge all grains together which have a common CSL(3) boundary.
% This is done with the command <grain2d_merge.html merge>.

% this merges the grains
[mergedGrains,parentIds] = merge(grains,gB3);

% overlay the boundaries of the merged grains with the previous plot
hold on
plot(mergedGrains.boundary,'linecolor','w','linewidth',2)
hold off

%%
% Finaly, we check for all other types of CSL boundaries and overlay them
% with our plot.

delta = 5*degree;
gB5 = gB(gB.isTwinning(CSL(5),delta))
gB7 = gB(gB.isTwinning(CSL(7),delta))
gB9 = gB(gB.isTwinning(CSL(9),delta))
gB11 = gB(gB.isTwinning(CSL(11),delta))

hold on
plot(gB5,'lineColor','b','linewidth',2,'DisplayName','CSL 5')
hold on
plot(gB7,'lineColor','r','linewidth',2,'DisplayName','CSL 7')
hold on
plot(gB9,'lineColor','m','linewidth',2,'DisplayName','CSL 9')
hold on
plot(gB11,'lineColor','c','linewidth',2,'DisplayName','CSL 11')
hold off

%% Colorizing misorientations 
%

oM = patalaOrientationMapping(gB)

plot(ebsd,log(ebsd.prop.iq),'figSize','large')
mtexColorMap black2white
CLim(gcm,[.5,5])

% and overlay it with the orientation map
hold on
plot(grains,grains.meanOrientation,'FaceAlpha',0.4)

hold on
plot(gB,oM.orientation2color(gB.misorientation),'linewidth',2)
hold off

%%
% The corresponding colormap is shown by

plot(oM)

