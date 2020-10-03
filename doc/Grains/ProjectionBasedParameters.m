%% Projection Based Shape Parameters
%
%%
% In this section we discuss shape parameters grains that depend on one
% dimensional projections, i.e., 
%
% || <grain2d.caliper.html |caliper|>  || caliper or Feret diameter in $\mu m$ || <grain2d.diameter.html |diameter|>  || diameter in $\mu m$ || 
%
% In order to demonstrate these parameters we first import a small sample
% data set.

% load sample EBSD data set
mtexdata forsterite silent

% reconstruct grains and smooth them
[grains, ebsd.grainId] = calcGrains(ebsd('indexed'),'angle',5*degree);
ebsd(grains(grains.grainSize<5)) = [];
[grains, ebsd.grainId] = calcGrains(ebsd('indexed'),'angle',5*degree);
grains = smooth(grains,5);

% plot all grains and highlight a specific one
plot(grains)

id = 734;
hold on
plot(grains(id).boundary,'lineWidth',5,'linecolor','blue')
hold off

%%
% The most well known projection based paramter is the
% <grain2d.diamter.html |diameter|> which refers to the longest distance
% between any two boundary points and is given in $\mu m$.

grains(id).diameter

%%
% The diameter is a special case of the <grain2d.caliper.html |caliper|> or
% Feret diameter of a grain. By definition the caliper is the length of a
% grain when projected onto a line. Hence, the length of the longest
% projection is coincides with the diameter, while the quotient between
% longest and shortest projection gives an indication about the shape of
% the grain

grains(id).caliper('longest')
grains(id).caliper('shortest')

%% 
% We may trace the caliper with respect to projection direction

close all
omega = linspace(0,180);
plot(omega,grains(id+(-1:2)).caliper(omega*degree),'LineWidth',2)
xlim([0,180])

%%
% The difference between the longest and the shortest caliper can also be
% taken as a measure how round a grain is. The function
% <grain2d.caliper.html |caliper|> provides as second output argument also
% the angle |omega| of the longest distance between any vertices of the
% grain. This direction is comparable to the <grain2d.longAxis.html
% |grains.longAxis|> computed from an ellipse fitted to the grain.

cMin = grains.caliper('shortest');
[cMax, omega] = grains.caliper('longest');

longAxis = vector3d.byPolar(pi/2,omega,'antipodal');

plot(grains,(cMax - cMin)./cMax,'micronbar','off')
mtexColorbar('title','TODO')

% and on top the long axes
hold on
quiver(grains,grains.longAxis,'Color','white')
quiver(grains,longAxis,'Color','red')
hold off

%%
% TODO: some more to explain
% <grain2d.paror.html |grains.paror|>   cummulative particle projection function  
%

mtexdata forsterite
[grains,ebsd.grainId] = ebsd.calcGrains;
ebsd(grains(grains.grainSize<50))=[];
[grains,ebsd.grainId] =ebsd.calcGrains;
outerBoundary_id = any(grains.boundary.grainId==0,2);
grain_id = grains.boundary(outerBoundary_id).grainId;
 grain_id(grain_id==0) = [];
 grains(grain_id) = [];
 grains=grains('indexed');

 cumpl = paror(grains);
 plot(grains)
 
 %%
 
 figure
 plot(0:180,cumpl);
