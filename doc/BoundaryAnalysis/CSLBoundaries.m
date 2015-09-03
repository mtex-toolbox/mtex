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
% and overlay it with the orientation map

plot(ebsd,log(ebsd.prop.iq),'figSize','large')
mtexColorMap black2white
CLim(gcm,[.5,5])

% the option 'FaceAlpha',0.4 makes the plot a bit transluent
hold on
plot(grains,grains.meanOrientation,'FaceAlpha',0.4)
hold off

%% Detecting CSL Boundaries
% In order to detect CSL boundaries within the data set we first restrict
% the grain boundaries to iron to iron phase transitions and check then the
% boundary misorientations to be a CSL(3) misorientation with threshold of
% 3 degree.

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
gB5 = gB(gB.isTwinning(CSL(5),delta));
gB7 = gB(gB.isTwinning(CSL(7),delta));
gB9 = gB(gB.isTwinning(CSL(9),delta));
gB11 = gB(gB.isTwinning(CSL(11),delta));

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
% In the previous sections we have checked whether the boundary
% misorientations belong to certain specific classes of misorientations. In
% order to analyze the distribution of misorientations we may colorize the
% grain boundaries according to their misorientation. See S. Patala, J. K.
% Mason, and C. A. Schuh, 2012, for details. The coresponding orientation
% to color mapping is implemented into MTEX as

oM = patalaOrientationMapping(gB)

%%
% Colorizing the grain boundaries is now straight forward

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
% Lets examine the colormap. We plot it as axis angle sections and add 300
% random boundary misorientations on top of it. Note that in this plot
% misorientations |mori| and |inv(mori)| are associated.

plot(oM,'axisAngle',(5:5:60)*degree)

hold on
plot(gB.misorientation,'points',300,...
  'MarkerFaceColor','none','MarkerEdgeColor','w')
hold off


%% Misorientations in the 3d fundamental zone
% We can also look at the boundary misorienations in the 3 dimensional
% fundamental orientation zone. 

% compute the boundary of the fundamental zone
oR = fundamentalRegion(oM.CS1,oM.CS2,'antipodal');
plot(oR)

% plot 500 random misorientations in the 3d fundamenal zone
mori = discreteSample(gB.misorientation,500);
hold on
plot(mori.project2FundamentalRegion('antipodal'))
hold off


% mark the CSL(3) misorientation
% TODO: not yet working
%hold on
%plot(CSL(3),'MarkerColor','r','DisplayName','CSL 3','MarkerSize',10)
%hold off

%% Analyzing the misorientation distribution function
% In order to analyze more quantitively the boundary misorientation
% distribution we can compute the so called misorientation distribution
% function. The option |antipodal| is applied since we want to identify
% |mori| and |inv(mori)|.

mdf = calcMDF(gB.misorientation,'antipodal','halfwidth',2.5*degree)

%%
% Next we can visualize the misorientation distribution function in axis
% angle sections.

% TODO: this antipodal should be stored later directly in the mdf
plot(mdf,'axisAngle',(25:5:60)*degree,'colorRange',[0 15],'antipodal')

annotate(CSL(3),'label','$CSL_3$','backgroundcolor','w')
annotate(CSL(5),'label','$CSL_5$','backgroundcolor','w')
annotate(CSL(7),'label','$CSL_7$','backgroundcolor','w')
annotate(CSL(9),'label','$CSL_9$','backgroundcolor','w')

drawNow(gcm)

%%
% The MDF can be now used to compute prefered misorientations

mori = mdf.calcModes(2)

%%
% and their volumes

volume(gB.misorientation,CSL(3),2*degree)

volume(gB.misorientation,CSL(9),2*degree)


%%
% or to plot the MDF along certain fibres

omega = linspace(0,55*degree);
fibre100 = orientation('axis',xvector,'angle',omega,mdf.CS,mdf.SS)
fibre111 = orientation('axis',vector3d(1,1,1),'angle',omega,mdf.CS,mdf.SS)
fibre101 = orientation('axis',vector3d(1,0,1),'angle',omega,mdf.CS,mdf.SS)

close all
plot(omega ./ degree,mdf.eval(fibre101))

%%
% or to evaluate it in an misorientation directly

mori = orientation('Euler',15*degree,28*degree,14*degree,mdf.CS,mdf.CS)

mdf.eval(mori)