%% Example for 2d EBSD Data analysis
%
%  data by Daniel Rutte with Bret Hacker, Stanford.
%
% The following script mainly generate the figures shown in "Grain detection
% from 2d and 3d EBSD data - Specification of the MTEX algorithm" - section "Practical
% application to a 2d EBSD data set". The only imposed restriction is the size of the
% data set, which was scaled down.
%

%% Open in Editor
%

%% Data import
% plotting convention

mtexdata mylonite

plotx2east

%% Phase map
% Phase map of multi-phase rock specimen with Andesina (blue), Quartz (red),
% Biotite (green) and Orthoclase (yellow)

figure('position',[100 100  750 300]);
plot(ebsd,'property','phase')

%% Restrict to the region of interest (RoI)
% the box is given by [xmin ymin xmax-xmin ymax-ymin] and indicates a
% region of interest (RoI).

region = [19000 1500 4000 1500];
rectangle('position',region,'edgecolor','r','linewidth',2)

%%
% to which we restrict the data

ebsd_region = ebsd(inpolygon(ebsd,region))

%% Recover grains
% Next we reconstruct the grains (and grain boundareis in the region of interest

grains = calcGrains(ebsd_region,'angle',15*degree)

%% Plot grain boundaries and phase
% (RoI) Detailed phase map with measurement locations and reconstructed grain
% boundaries.

figure('position',[100 100  750 300]);
hold all
plot(ebsd_region,'property','phase')
plotBoundary(grains,'color','k')
hold off
% set(gcf,'renderer','zbuffer')

%%
% (RoI) Individual orientation measurements of quartz together with the grain
% boundaries.

figure('position',[100 100 750 300]);
hold all
plot(grains({'Andesina','Biotite','Orthoclase'}),'property','phase','FaceAlpha',0.2)
plotBoundary(grains,'color','black');
plot(ebsd_region('Quartz-new'),'r',zvector)
legend off
hold off

%%
% colored according to the false color map of its inverse polefigure

colorbar('Position',[825 100 300 300])

%%
% (RoI) The reconstructed grains. The quartz grains are colored according to
% their mean orientation while the remaining grains are colored according to
% there phase.

figure('position',[100 100  750 300]);
hold all
plot(grains({'Andesina','Biotite','Orthoclase'}),'property','phase','FaceAlpha',0.2)
plot(grains('Quartz'))
legend off
hold off



%% Highlight specific boundaries
% (RoI) Phase map with grain boundaries highlighted, where adjacent grains have
% a misorientation with rotational axis close to the c-axis.

figure('position',[100 100  750 300]);
hold all
plot(grains,'property','phase','FaceAlpha',0.4)
plotBoundary(grains,'property',Miller(0,0,1),'linewidth',2,'linecolor','red')
hold off


