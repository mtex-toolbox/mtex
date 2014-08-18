%% Visualizing grain boundaries
% Overview about colorizing grain boundaries 
%
%% Open in Editor
%
%% Contents
%

%%
% Lets import some EBSD data and compute the grains.

close all
mtexdata forsterite
plotx2east

[grains,ebsd] = calcGrains(ebsd)

%% The grain boundary
% The grain boundary of a list of grains can be extracted by

gB = grains.boundary

plot(gB)

%%
% A grain boundaries plot can be easily combined with further plots by *hold
% on command, so we can plot various information together

hold on
plot(ebsd,ebsd.bc)
mtexColorMap white2black

%%
% e.g. we want also to see all one pixel grains

grains_selection = grains( grains.grainSize == 1) ;

hold on
plot(grains_selection.boundary,'linecolor','r','linewidth',2)

%% Visualizing special grain boundaries
% Most interesting is a closer look at special grain boundaries. This can
% be done by specifing a *property* which should be marked. 
%
%% SUB: Phase boundaries
% For multi-phase system, the location of phase boundaries may be of
% interest.

close all
plot(grains,'translucent',.3)
hold on
plot(grains.boundary,'linecolor','r','linewidth',1.5)


%%
% Also, one can encode the combination of phases at the grain boundary. Here, for
% instance we have three types occuring: Fe-Fe, Fe-Mg and Mg-Mg

close, plot(grains.boundary)

%% SUB: Subboundaries
% Another special type of boundaries, are boundaries that are located
% within a grain, nevertheless this happens, if two adjacent measurements
% are somehow conneted by a lattice rotation within a grain.
% TODO:

close all
plot(grains.boundary,'external')
hold on
plot(grains.boundary,'internal','linecolor','r','linewidth',2)

%%
% We also want to see the rotation within the grain.

hold on, plot(ebsd(grains('fo')),ebsd(grains('fo')).mis2mean.angle./degree)

%% SUB: Misorientation
% Basicly there are two ways to visualize misorientation along a grain
% boundary. The most simplest way is to colorize the grain boundaries
% with respect to the misorientation angle.


close all
plot(grains.boundary({'Fo','Fo'}),grains.boundary({'Fo','Fo'}).misorientation.angle./degree,'linewidth',1.5)
colorbar

%%
% The more sophisticated way is to colorize the misorientation space and
% apply the color to the respectibe grain boundaries. More details [TODO]

close all
plot(grains.boundary)
hold on

% TODO
%plotBoundary(grains('Fo'),'property','misorientation',...
%  'colorcoding','patala','linewidth',1.5)

% plot the colorbar
% colorbar

%% SUB: Classifing special boundaries
% Actually, it might be more informative, if we classify the grain
% boundaries after some special property. This is done by the command
% <GrainSet.specialBoundary.html specialBoundary>, which will be invoked
% by the plotting routine.
%%
% We can mark grain boundaries after its misorientation angle is in a
% certain range

close all


gB_Fo = gB({'Fo','Fo'});
mAngle = gB_Fo.misorientation.angle./ degree;

%%

hist(mAngle)

[~,id] = histc(mAngle,0:30:120);

%%

plot(gB,'linecolor','k')

hold on
plot(gB_Fo(id==1),'linecolor','b','linewidth',2)
plot(gB_Fo(id==2),'linecolor','g','linewidth',2)
plot(gB_Fo(id==3),'linecolor','r','linewidth',2)
plot(gB_Fo(id==4),'linecolor','r','linewidth',2)

legend('>40^\circ',...
  '20^\circ-40^\circ',...
  '10^\circ-20^\circ',...
  '< 10^\circ')

hold off

%%
% Or we mark the rotation axis of the misorientation.

close all
plot(gB)
hold on

ind = angle(gB_Fo.misorientation.axis,xvector)<5*degree;

plot(gB_Fo(ind),'linecolor','b','linewidth',2)

legend('>5^\circ','[100]')

%% 
% Or we mark a special rotation between neighboured grains. If a
% linecolor is not specified, then the boundary is colorcoded after its angular
% difference to the given rotation.

rot = rotation('axis',vector3d(1,1,1),'angle',60*degree);

close all
plot(gB)
hold on
plotBoundary(grains,'property',rot,'linewidth',1.5)
% hold on, plotBoundary(grains,'property',rot,'linecolor','b','linewidth',1)

legend('>2^\circ','60^\circ/[001]')
colorbar

%%
% In the same manner, we can classify after predefined special rotations,
% e.g. coincident site lattice (CSL) for cubic crystalls. Additionaly we
% specify a searching radius with the option |'delta'|, in this way, we
% control how far the misorientation of the boundary segment is actuall
% away from the specified rotation.

close all
plot(gB,'color','k')


hold on
plot(gB_Fo(angle(gB_Fo.misorientation,CSL(3))<2*degree),...
  'linecolor','b','linewidth',2)
plot(gB_Fo(angle(gB_Fo.misorientation,CSL(5))<4*degree),...
  'linecolor','m','linewidth',2)
plot(gB_Fo(angle(gB_Fo.misorientation,CSL(7))<4*degree),...
  'linecolor','g','linewidth',2)
plot(gB_Fo(angle(gB_Fo.misorientation,CSL(11))<4*degree),...
  'linecolor','r','linewidth',2)

legend('>2^\circ',...
  '\Sigma 3',...
  '\Sigma 5',...
  '\Sigma 7',...
  '\Sigma 11')

%%
% Another kind of special boundaries are tilt and twist boundaries. We can
% find a tilt boundary by specifing the crystal form, which is tilted, i.e.
% the misorientation maps a lattice plane $h$  of on grain onto the others grain
% lattice plane.
% 
% $$ \left( g_1^{-1} * g_2 \right) * h = h, $$
% 
% where $g_1, g_2$ are neighbored orientations.

close all
plot(grains.boundary)
hold on
plot(grains.boundary,'property',Miller(1,1,1),'delta',2*degree,...
  'linecolor','r','linewidth',1.5)
plot(grains.boundary,'property',Miller(0,0,1),'delta',2*degree,...
  'linecolor','b','linewidth',1.5)

legend('>2^\circ',...
  '\{111\}',...
  '\{001\}')

