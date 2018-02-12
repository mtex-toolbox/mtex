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

plot(ebsd)

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

plot(ebsd_region)
hold on
plot(grains.boundary,'color','k')
hold off

%%
% (RoI) Individual orientation measurements of quartz together with the grain
% boundaries.

plot(grains({'Andesina','Biotite','Orthoclase'}),'FaceAlpha',0.2)
hold on
plot(ebsd_region('Quartz'))
plot(grains.boundary,'color','black');
legend off
hold off

%%
% colored according to the false color map of its inverse polefigure

close all
ipfKey = ipfColorKey(ebsd_region('Quartz'));
plot(ipfKey,'Position',[825 100 300 300])


%%
% (RoI) The reconstructed grains. The quartz grains are colored according to
% their mean orientation while the remaining grains are colored according to
% there phase.

plot(grains({'Andesina','Biotite','Orthoclase'}),'FaceAlpha',0.2)
hold on
plot(grains('Quartz'))
legend off




%% Highlight specific boundaries
% (RoI) Phase map with grain boundaries highlighted, where adjacent grains have
% a misorientation with rotational axis close to the c-axis.
% TODO

close all
AOboundary = grains.boundary('Andesina','Orthoclase');
angle = AOboundary.misorientation.angle;

hist(angle./degree)

%%

plot(grains,'FaceAlpha',0.4)
hold on

plot(AOboundary(angle>160*degree),'linewidth',2,'linecolor','red')
hold off
