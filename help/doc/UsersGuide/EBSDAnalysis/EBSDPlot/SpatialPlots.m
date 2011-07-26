%% Plotting Spatial Orientation Data
% Howto plot spatially indexed orientations 
%
%% Open in Editor
%
%% 
% This sections gives you an overview over the functionality MTEX offers to
% visualize spatial orientation data.
%
%% Contents
%

%% 
% Let us first import some EBSD data with a [[matlab:edit mtexdata, script file]]

mtexdata aachen

%%
% and model some grains

[grains, ebsd] = calcGrains(ebsd);


%% Coloring spatially orientation data 
% If the EBSD data are provided with spatial coordinates, one can 
% assign a color to each orientation and [[EBSD.plotspatial.html,plots]]
% a map of these colors.

plot(ebsd('Fe'))

%%
% The orientations are mapped to a color, by a
% [[ColorCodingEBSD_demo.html,colorcoding]], as a standard way according to
% its inverse polefigure

colorbar
set(gcf,'Position',[100 100 400 200])

%%
% the [[orientation2color.html, colorcoding]] could be choose by specifing
% it as an option

close all;
plot(ebsd('Fe'),'colorcoding','hkl')

%%
%

colorbar
set(gcf,'Position',[100 100 230 200])

%%
% and of course there an equivallent command for
% [[grain.plotgrains.html,plotting grains]]

close all;
plot(grains('Fe'),'colorcoding','hkl')

%%
% In order to understand the colorcoding better one can plot the coloring 
% of the corresponding inverse pole figure and the orientations together


colorbar
hold on
plotipdf(grains('Fe'),xvector,'points',500,...
  'markerSize',3,'marker','+','markerfacecolor','k','markeredgecolor','w')
hold off
set(gcf,'renderer','opengl')


%% Visualising Grain Boundaries
% Plotting grain boundaries may be a usefull task, e.g. marking special
% grain boundaries, generally this is done by the 
% [[grain.plotboundary.html,plotboundary]] command.

close all
plotboundary(grains)

%%
% The *hold on* and  *hold off* command allows us to plot various
% information together, e.g. we want to see where are all one pixel
% grains

grains_selection = grains( grainSize(grains) == 1) ;
hold on
plotboundary(grains_selection,'color','r','linewidth',2)

%%
% by specifing a *property* we can mark special boundaries, e.g phase
% boundaries

close all
plotboundary(grains,'property','phase')
colormap(hsv)

%%
% or visualise the misorientation between neighboured grains of the same
% phase

plotboundary(grains,'property','colorcoding','hkl')

%%
% or mark really special misorientations between neighbours

rot = rotation('axis',vector3d(1,1,1),'angle',60*degree);
plotboundary(grains,'property',rot)


%% Coloring other properties
% Often the individual orientation measurements come along with some other
% properties, maybe something called background contrast, stored in our
% EBSD as *property* bc, we can plot it easily by specifing it as a
% plotting option

close all
plot(ebsd,'property','bc')

%%
% also modelled grains could be colored according to a property, by
% [[grain.copyProperty.html,copying]] it form the corresponding EBSD
% object.

grains = copyproperty(grains,ebsd)
plot(grains,'property','bc')

%%
% futhermore as property a data vector can be given

plot(grains,'property',shapefactor(grains))

