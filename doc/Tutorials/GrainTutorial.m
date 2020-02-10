%% Grain Tutorial
%
%%
% The following script is a quick guide through the grain reconstruction
% capabilities of MTEX. It uses the same data set as in the corresponding
% publication
% <https://www.researchgate.net/publication/51806709_Grain_detection_from_2d_and_3d_EBSD_data-Specification_of_the_MTEX_algorithm
% Grain detection from 2d and 3d EBSD data>. Data courtasy was by Daniel
% Rutte and Bret Hacker, Stanford.

mtexdata mylonite

% plot a phase map
plot(ebsd)

%%
% The phase map shows a multi-phase rock specimen with Andesina, Quartz,
% Biotite and Orthoclase. Lets restrict it some smaller region of interest.
% The box is given by [xmin, ymin, xmax-xmin, ymax-ymin].

region = [19000 1500 4000 1500];
rectangle('position',region,'edgecolor','k','linewidth',2)

%%
% to which we restrict the data

ebsd_region = ebsd(inpolygon(ebsd,region))

%% Grain Reconstruction
% Next we reconstruct the grains and grain boundareis in the region of
% interest

grains = calcGrains(ebsd_region,'angle',15*degree)

% phase map of the region of interest
plot(ebsd_region)

% the grain boundaries
hold on
plot(grains.boundary,'color','k','linewidth',1.5)
hold off

%%
% We may also visualize the different quarz orientations together with the
% grain boundaries.

% phase map
plot(grains({'Andesina','Biotite','Orthoclase'}),'FaceAlpha',0.4)

hold on
% quarz orientations as ipf map
plot(ebsd_region('Quartz'),ebsd_region('Quartz').orientations)

% grain boundaries
plot(grains.boundary,'color','black');
legend off
hold off

%%
% colored according to the following ipf color key

close all
ipfKey = ipfColorKey(ebsd_region('Quartz'));
plot(ipfKey)


%%
% Alternatively, we may also colorize the entire quarz grains according to
% its mean orientations

plot(grains({'Andesina','Biotite','Orthoclase'}),'FaceAlpha',0.4)
hold on
plot(grains('Quartz'),grains('Quartz').meanOrientation)
legend off


%% Highlight specific boundaries
% Phase map with grain boundaries highlighted, where adjacent grains have
% a misorientation with rotational axis close to the c-axis.
% TODO

close all
AOboundary = grains.boundary('Andesina','Orthoclase');
angle = AOboundary.misorientation.angle;

histogram(angle./degree)

%%

plot(grains,'FaceAlpha',0.4)
hold on

plot(AOboundary(angle>160*degree),'linewidth',2,'linecolor','red')
hold off
