%% Grain Boundaries
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

ebsd = ebsd('indexed');
[grains,ebsd.grainId] = calcGrains(ebsd)

%% The grain boundary
% The grain boundary of a list of grains can be extracted by

gB = grains.boundary

plot(gB)

%%
% Accordingly we can access the grain boundary of a specific grain by

grains(931).boundary

plot(grains(931).boundary)

%%
% lets combine it with the orientation measurements inside

% define the colorcoding such that the meanorientation becomes white
oM = ipdfHSVOrientationMapping(grains(931));
oM.inversePoleFigureDirection = grains(931).meanOrientation * oM.whiteCenter;
oM.colorStretching = 50;

% get the ebsd data of grain 931
ebsd_931 = ebsd(grains(931));

% plot the orientation data
hold on
plot(ebsd_931,oM.orientation2color(ebsd_931.orientations))
hold off


%% Visualizing special grain boundaries
%
%% SUB: Phase boundaries
% For multi-phase system, the location of specific phase transistions may
% be of interest. The following plot highlights all Forsterite to Enstatite
% phase transitions

close all
plot(grains,'faceAlpha',.3)
hold on
plot(grains.boundary('Fo','En'),'linecolor','r','linewidth',1.5)
hold off

%% SUB: Subboundaries
% Another type of boundaries, are boundaries between measurements that
% belong to the same grain. This happens if a grain has a texture gradient
% that loops around these two measurements.

close all
plot(grains.boundary)
hold on
plot(grains.innerBoundary,'linecolor','r','linewidth',2)


%% SUB: Misorientation
% Basicly there are two ways to visualize misorientations along grain
% boundary. The most simplest way is to colorize the grain boundaries
% with respect to the misorientation angle.

close all
gB_Fo = grains.boundary('Fo','Fo');
plot(grains,'translucent',.3)
legend off
hold on
plot(gB_Fo,gB_Fo.misorientation.angle./degree,'linewidth',1.5)
hold off
colorbar

%%
% The more sophisticated way is to colorize the misorientation space and
% apply the color to the respective grain boundaries. 
% TODO: apply here patala colorcoding!!!

close all
plot(grains,'translucent',.3)
legend off
hold on

oM = axisAngleOrientationMapping(gB_Fo);
oM.maxAngle = 180*degree;

plot(grains.boundary)
hold on

plot(gB_Fo,oM.orientation2color(gB_Fo.misorientation),'linewidth',1.5)

hold off

% plot the colorcoding
% plot(oM)

%% SUB: Classifing special boundaries
% Actually, it might be more informative, if we classify the grain
% boundaries after some special property. This is done by the command
% <GrainSet.specialBoundary.html specialBoundary>, which will be invoked
% by the plotting routine.
%%
% We can mark grain boundaries after its misorientation angle is in a
% certain range

close all

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
ind = angle(gB_Fo.misorientation,rot)<10*degree;

close all
plot(gB)
hold on
plot(gB_Fo(ind),'linewidth',1.5,'linecolor','r')

legend('>2^\circ','60^\circ/[001]')


%%
% In the same manner, we can classify after predefined special rotations,
% e.g. coincident site lattice (CSL) for cubic crystalls. Additionaly we
% specify a searching radius with the option |'delta'|, in this way, we
% control how far the misorientation of the boundary segment is actuall
% away from the specified rotation.
% TODO

% close all
% plot(gB)
% 
% 
% hold on
% plot(gB_Fo(angle(gB_Fo.misorientation,CSL(3))<2*degree),...
%   'linecolor','b','linewidth',2)
% plot(gB_Fo(angle(gB_Fo.misorientation,CSL(5))<4*degree),...
%   'linecolor','m','linewidth',2)
% plot(gB_Fo(angle(gB_Fo.misorientation,CSL(7))<4*degree),...
%   'linecolor','g','linewidth',2)
% plot(gB_Fo(angle(gB_Fo.misorientation,CSL(11))<4*degree),...
%   'linecolor','r','linewidth',2)
% 
% legend('>2^\circ',...
%   '\Sigma 3',...
%   '\Sigma 5',...
%   '\Sigma 7',...
%   '\Sigma 11')

%%
% Another kind of special boundaries are tilt and twist boundaries. We can
% find a tilt boundary by specifing the crystal form, which is tilted, i.e.
% the misorientation maps a lattice plane $h$  of on grain onto the others grain
% lattice plane.
% 
% $$ \left( g_1^{-1} * g_2 \right) * h = h, $$
% 
% where $g_1, g_2$ are neighbored orientations.
% TODO

%close all
%plot(grains.boundary)
%hold on
%plot(grains.boundary,'property',Miller(1,1,1),'delta',2*degree,...
%  'linecolor','r','linewidth',1.5)
%plot(grains.boundary,'property',Miller(0,0,1),'delta',2*degree,...
%  'linecolor','b','linewidth',1.5)
%
%legend('>2^\circ',...
%  '\{111\}',...
%  '\{001\}')

