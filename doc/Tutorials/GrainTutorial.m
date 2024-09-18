%% Grain Tutorial
%
%%
% The following script is a quick guide through the grain reconstruction
% capabilities of MTEX. It uses the same data set as in the corresponding
% publication
% <https://www.researchgate.net/publication/51806709_Grain_detection_from_2d_and_3d_EBSD_data-Specification_of_the_MTEX_algorithm
% Grain detection from 2d and 3d EBSD data>. Data courtesy of Daniel Rutte
% and Bret Hacker, Stanford.

mtexdata mylonite

% plot a phase map
plot(ebsd)

%%
% The phase map shows a multi-phase rock specimen with Andesina, Quartz,
% Biotite and Orthoclase. Lets restrict it to a smaller region of interest.
% The rectangle is defined by [xmin, ymin, xmax-xmin, ymax-ymin].

region = [19000 1500 4000 1500];
% overlay the selected region on the phase map
rectangle('position',region,'edgecolor','k','linewidth',2)

%%
% Now copy the EBSD data within the selected rectangle to a new variable

ebsd_region = ebsd(inpolygon(ebsd,region))

%% Grain Reconstruction
% Next we reconstruct the grains and grain boundaries in the region of
% interest, using a 15 degree orientation change threshold.

grains = calcGrains(ebsd_region,'angle',15*degree)

% plot a phase map of the region of interest
plot(ebsd_region)

% overlay the grain boundaries
hold on
plot(grains.boundary,'color','k','linewidth',1.5)
hold off

%%
% We may also visualize the different quartz orientations together with the
% grain boundaries.

% plot a phase map of three of the phases based on the grains data 
plot(grains({'Andesina','Biotite','Orthoclase'}),'FaceAlpha',0.4)

hold on
% add the quartz orientations as ipf map based on EBSD data
plot(ebsd_region('Quartz'),ebsd_region('Quartz').orientations)

% plot grain boundaries so that those in the Quartz are shown
plot(grains.boundary,'color','black');
legend off
hold off

%%
% For the map created, most of the phases are colored based on where they
% exist, while only the Quartz phase is colored according to the
% orientation. The quartz orientations are colored using the following ipf
% color key

close all
ipfKey = ipfColorKey(ebsd_region('Quartz'));
plot(ipfKey)


%%
% Alternatively, we may colorize each quartz grain according to its mean
% orientation.  Again, the other phases are colored based on where they
% exist.

plot(grains({'Andesina','Biotite','Orthoclase'}),'FaceAlpha',0.4)
hold on
plot(grains('Quartz'),grains('Quartz').meanOrientation)
legend off


%% Highlight specific boundaries
% We can create a phase map with certain grain boundaries highlighted.  In
% this case, we highlight where adjacent grains of Andesina and Orthoclase
% have a misorientation with rotational axis close to the c-axis.

close all
% copy all boundaries between Andesina, Orthoclase to a new variable
AOboundary = grains.boundary('Andesina','Orthoclase');
% copy the misorientation angle of this boundary in radians to a new variable.
angle = AOboundary.misorientation.angle;

plot(grains,'FaceAlpha',0.4)
hold on
% highlight boundaries where the angle between the Andesina and Orthoclase phase is over 160 degrees
plot(AOboundary(angle>160*degree),'linewidth',2,'linecolor','red')
hold off

%%
% We can also represent the angular misorientation data between these two
% phases as a histogram.

figure;histogram(angle./degree)
xlabel('angle in degrees of boundary segment')
ylabel('count of boundary segments')
title('angular relationships between Andesina and Orthoclase')
