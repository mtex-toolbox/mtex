%% SUB: Classifying special boundaries
% Actually, it might be more informative, if we classify the grain
% boundaries after some special property. 
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
plot(gB_Fo(id==1),'linecolor','b','linewidth',2,'DisplayName','<30^\circ')
plot(gB_Fo(id==2),'linecolor','g','linewidth',2,'DisplayName','30^\circ-60^\circ')
plot(gB_Fo(id==3),'linecolor','r','linewidth',2,'DisplayName','60^\circ-90^\circ')
plot(gB_Fo(id==4),'linecolor','y','linewidth',2,'DisplayName','> 90^\circ')

hold off

%%
% Or we mark the rotation axis of the misorientation.

close all
plot(gB)
hold on

rotAxis = Miller(1,0,0,ebsd('Fo').CS,'uvw');
ind = angle(gB_Fo.misorientation.axis,rotAxis)<5*degree;

plot(gB_Fo(ind),'linecolor','b','linewidth',2,'DisplayName','[100]')


%% 
% Or we mark a special rotation between neighboured grains. If a linecolor
% is not specified, then the boundary is colorcoded after its angular
% difference to the given rotation.

rotAxis = Miller(1,1,1,ebsd('Fo').CS,'uvw');
rot = orientation.byAxisAngle(rotAxis,60*degree);
ind = angle(gB_Fo.misorientation,rot)<10*degree;

close all
plot(gB,'DisplayName','>2^\circ')
hold on
plot(gB_Fo(ind),'lineWidth',1.5,'lineColor','r','DisplayName','60^\circ/[111]')


%%
% Another kind of special boundaries is tilt and twist boundaries. We can
% find a tilt boundary by specifying the crystal form, which is tilted, i.e.
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

