%% Plotting grains and grain boundaries
%
%% Open in Editor
%
%% Contents
%

%%
%

mtexdata aachen

%%
% 

grains = calcGrains(ebsd,'threshold',2*degree)

%% Plotting grains and combined plots
% the most naive way to plot grains is just

plot(grains)

%%
% nevertheless, the plot command accepts options like the ebsd plot spatial
% command. 

plot(grains,'property','phase')

%%
% particularly one can apply the color coding of orientations.

plot(grains,'colorcoding','h',{Miller(1,1,1),[0 0 1]},'r',zvector)

%%
% With the *hold on* command, one can combine several plots, e.g. let us
% take a look at the mad and the phase at the same time

plot(ebsd,'property','mad')
colormap(grayColorMap)

hold on
plot(grains,'property','phase','translucent',0.25)


%%
% the reconstructed grains contain the same properties as the initial EBSD
% data and hence can be colored accordingly

plotspatial(grains(grainSize(grains)>15),'property','bc')

%%
% futhermore as property a data vector can be given

plot(grains,'property',shapefactor(grains))


%%
% the brighter regions indicate bad indexing
%
%% Visualizing grain boundaries
% Plotting grain boundaries may be a usefull task, e.g. marking special
% grain boundaries, generally this is done by the <grain.plotBoundary.html
% plotBoundary> command.

close all
plotBoundary(grains)

%%
% A grain boundaries plot can be easily combined with further plots by *hold
% on command, so we can plot various information together


hold on
plot(ebsd,'property','bc')
colormap(gray)

%%
% e.g. we want also to see all one pixel grains

grains_selection = grains( grainSize(grains) == 1) ;
hold on
plotBoundary(grains_selection,'color','r','linewidth',2)

%% Visualizing special grain boundaries
% Most interesting is a closer look at special grain boundaries. This can
% be done by specifing a *property* which should be marked. 
%
%%
% *phase boundaries*
%

close all
plot(grains,'translucent',.15)
hold on 
plotBoundary(grains,'property','phase','color','r','linewidth',1.5)


%%
% 

plotBoundary(grains,'property','phasetransition','linewidth',1.5)


%% 
% *subboundaries*
% 
% another special type of boundaries, are boundaries that are located
% within a grain, nevertheless this happens, if two adjacent measurements
% are somehow conneted by a orientation gradient inside.

close all
plotBoundary(grains,'external')
hold on
plotBoundary(grains,'internal','color','r','linewidth',2)


%%
%

hold on
plot(grains,'property','mis2mean')

%%
% *misorientation angle*

plotBoundary(grains,'property','angle','linewidth',1.5)
colorbar

%%
% *classified after misorientation angle*
%
% Actually, it might be more informative, if we classify the grain
% boundaries after there misorientation angle

plotBoundary(grains,'color','k')
hold on, plotBoundary(grains,'property',[10 15]*degree,'color','b','linewidth',2)
hold on, plotBoundary(grains,'property',[ 5 10]*degree ,'color','g','linewidth',2)
hold on, plotBoundary(grains,'property',[ 2  5]*degree  ,'color','r','linewidth',2)

legend('>15^\circ',...
  '10^\circ-15^\circ',...
  '5^\circ-10^\circ',...
  '2^\circ-5^\circ')


%%
% *misorientation*
% 
% or visualise the misorientation between neighboured grains of the same
% phase

figure
plotBoundary(grains)
hold on
plotBoundary(grains,'property','misorientation','colorcoding','hkl','r',vector3d(1,1,1),...
  'linewidth',1.5)

%%
% *special misorientations*
%
%  mark special misorientations between neighboured grains

plotBoundary(grains)

rot = rotation('axis',vector3d(1,1,1),'angle',60*degree);
hold on,
plotBoundary(grains,'property',rot,'color','b','linewidth',2)

legend('>2^\circ',...
  '60^\circ/[001]')

%%
% classify after special rotations, additionaly we specify a searching
% radius with the option |'delta'|, in this way, we controll how far the
% misorientation of the boundary segment is actuall away.

plotBoundary(grains,'color','k')

hold on, plotBoundary(grains,'property',CSL(3),'delta',2*degree,...
  'color','b','linewidth',2)
hold on, plotBoundary(grains,'property',CSL(5),'delta',4*degree,...
  'color','m','linewidth',2)
hold on, plotBoundary(grains,'property',CSL(7),'delta',4*degree,...
  'color','g','linewidth',2)
hold on, plotBoundary(grains,'property',CSL(11),'delta',4*degree,...
  'color','r','linewidth',2)

legend('>2^\circ',...
  '\Sigma 3',...
  '\Sigma 5',...
  '\Sigma 7',...
  '\Sigma 11')

%%
% *tilt boundaries*
%
%

figure
plotBoundary(grains)
hold on
plotBoundary(grains,'property',Miller(1,1,1),'delta',2*degree,...
  'color','r','linewidth',1.5)
plotBoundary(grains,'property',Miller(0,0,1),'delta',2*degree,...
  'color','b','linewidth',1.5)

legend('>2^\circ',...
  '\{111\}',...
  '\{001\}')

%%
% more *tilt*
%
%

plotBoundary(grains)
hold on
plotBoundary(grains,'property',{Miller(1,1,1),Miller(0,0,1)},'delta',2*degree,...
  'color','g','linewidth',1.5)

%%
% *misorientation axis*

plotBoundary(grains)
hold on
plotBoundary(grains,'property',vector3d(1,1,1),'delte',2*degree,...
  'color','b','linewidth',1.5)




