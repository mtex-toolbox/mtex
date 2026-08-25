%% Grain Tutorial
%
%%
% This tutorial turns a map of measurements into grains and then asks
% questions that only make sense once grains exist: which phases touch
% which, and how their lattices are related where they do. The specimen is
% the mylonite of
% <https://www.researchgate.net/publication/51806709_Grain_detection_from_2d_and_3d_EBSD_data-Specification_of_the_MTEX_algorithm
% Grain detection from 2d and 3d EBSD data>, data courtesy of Daniel Rutte
% and Bret Hacker, Stanford.

plottingConvention.default('y↑→x');
mtexdata mylonite

% plot a phase map
plot(ebsd)

%%
% Four minerals - andesina, quartz, biotite and orthoclase - in a rock that
% has been sheared, which is what the banding in the map is: ribbons of
% quartz between mixed feldspar layers. The whole map is large, so we
% continue with a rectangle of it, given as
% |[xmin, ymin, width, height]|.

region = [19000 1500 4000 1500];
% overlay the selected region on the phase map
rectangle('position',region,'edgecolor','k','linewidth',2)

%%
% <EBSD.inpolygon.html |inpolygon|> selects the measurements inside it.

ebsd_region = ebsd(inpolygon(ebsd,region))

%% Grain reconstruction
%
% Neighbouring measurements that differ by less than 15 degrees become one
% grain - and a change of phase is always a boundary, whatever the
% orientations do.

grains = calcGrains(ebsd_region,'angle',15*degree)

% plot a phase map of the region of interest
plot(ebsd_region)

% overlay the grain boundaries
hold on
plot(grains.boundary,'color','k','linewidth',1.5)
hold off

%%
% Note the count: 996 grains out of 2846 measurements, and two thirds of
% them are single pixels. This map is at its resolution limit, and a
% quantitative study of grain sizes here would have to set a minimum grain
% size - see <GrainReconstruction.html Grain Reconstruction>. For what
% follows, which is about the boundaries between phases, everything is kept.

%% Orientations inside one phase
%
% The phase map says where quartz is; it says nothing about how the quartz
% is oriented. Drawing the other phases pale and the quartz by its
% orientations puts both in one figure.

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
% The quartz colours change from grain to grain but stay constant within a
% grain, which is what the reconstruction assumed and a check that it was
% right. What the colours mean is in the key:

close all
ipfKey = ipfColorKey(ebsd_region('Quartz'));
plot(ipfKey)

%%
% The same map drawn from the grains rather than the measurements - one mean
% orientation per grain, so one flat colour each.

plot(grains({'Andesina','Biotite','Orthoclase'}),'FaceAlpha',0.4)
hold on
plot(grains('Quartz'),grains('Quartz').meanOrientation)
legend off

%%
% Compare it with the previous figure: the mean orientation throws away the
% variation inside a grain, which is either noise worth removing or a bent
% lattice worth keeping, depending on the specimen.

%% Boundaries between two phases
%
% Every boundary segment knows the two grains it separates, so the segments
% between two named phases are one selection. Here the interfaces between
% andesina and orthoclase, and the misorientation across each of them.

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
% The red segments are those whose misorientation exceeds 160 degrees - 97
% of the 1180 andesina to orthoclase segments, or eight percent. They are
% scattered through the two mixed bands wherever the two feldspars meet,
% rather than gathered anywhere in particular, so this is a property of the
% pair of minerals and not of one place in the specimen.

%%
% The whole distribution rather than one threshold:

figure;histogram(angle./degree)
xlabel('angle in degrees of boundary segment')
ylabel('count of boundary segments')
title('angular relationships between Andesina and Orthoclase')

%%
% The peak below 20 degrees holds a third of all segments, far more than
% chance would put there, and there is a second rise towards 180. Both are
% signatures of a relationship between the two lattices;
% <MisorientationDistributionFunction.html the misorientation distribution
% function> is the tool that tests such an impression properly.
