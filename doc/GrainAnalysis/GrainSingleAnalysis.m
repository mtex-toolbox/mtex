%% Analyzing Individual Grains
% how to work with single grains
%
%
%% Open in Editor
%
%% Contents
%
%% Connection between grains and EBSD data
% As usual, we start by importing some EBSD data and computing grains

close all
mtexdata forsterite
plotx2east

% consider only indexed data for grain segmentation
ebsd = ebsd('indexed');

% compute the grains
[grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd);

%%
% 
% The <grain2d_index.html grains> contain. We can
% access these data by

grain_selected = grains( grains.grainSize >=  1160)
ebsd_selected = ebsd(grain_selected)

%%
% A more convenient way to select grains in daily practice is by spatial
% coordinates. 

grain_selected = grains(12000,3000)

%%
% you can get the id of this grain by

grain_selected.id

%%
% let's look for the grain with the largest grain orientation spread

[~,id] = max(grains.GOS)
grain_selected = grains(id)


%%
%

plot(grain_selected.boundary,'linewidth',2)
hold on
plot(ebsd(grain_selected))
hold off

%% Visualize the misorientation within a grain
% 

close
plot(grain_selected.boundary,'linewidth',2)
hold on
plot(ebsd(grain_selected),ebsd(grain_selected).mis2mean.angle./degree)
hold off
mtexColorbar

%% Testing on Bingham distribution for a single grain
% Although the orientations of an individual grain are highly concentrated,
% they may vary in the shape. In particular, if the grain was deformed by
% some process, we are interested in quantifications.

cs = ebsd(grain_selected).CS;
ori = ebsd(grain_selected).orientations;
plotPDF(ori,[Miller(0,0,1,cs),Miller(0,1,1,cs),Miller(1,1,1,cs)],'antipodal')


%%
% Testing on the distribution shows a gentle prolatness, nevertheless we
% would reject the hypothesis for some level of significance, since the
% distribution is highly concentrated and the numerical results vague.

calcBinghamODF(ori,'approximated')

%%
%

T_spherical = bingham_test(ori,'spherical','approximated');
T_prolate   = bingham_test(ori,'prolate',  'approximated');
T_oblate    = bingham_test(ori,'oblate',   'approximated');

[T_spherical T_prolate T_oblate]

%% Profiles through a single grain
% Sometimes, grains show large orientation difference when being deformed
% and then its of interest, to characterize the lattice rotation. One way
% is to order orientations along certain line segment and look at the
% profile.
%%
% We proceed by specifying such a line segment

close,   plot(grain_selected.boundary,'linewidth',2)
hold on, plot(ebsd(grain_selected),ebsd(grain_selected).orientations)

% line segment
lineSec =  [18826   6438; 18089 10599];

line(lineSec(:,1),lineSec(:,2),'linewidth',2)

%%
% The command <EBSD.spatialProfile.html spatialProfile> restricts the EBSD
% data to this line

ebsd_line = spatialProfile(ebsd(grain_selected),lineSec);

%% 
% Next, we plot the misorientation angle to the first point of the line
% as well as the orientation gradient

close all % close previous plots

% misorientation angle to the first orientation on the line
plot(ebsd_line.y,...
  angle(ebsd_line(1).orientations,ebsd_line.orientations)/degree)

% misorientation gradient
hold all
plot(0.5*(ebsd_line.y(1:end-1)+ebsd_line.y(2:end)),...
  angle(ebsd_line(1:end-1).orientations,ebsd_line(2:end).orientations)/degree)
hold off

xlabel('y'); ylabel('misorientation angle in degree')

legend('to reference orientation','orientation gradient')

%%
% We can also plot the orientations along this line into inverse pole
% figures and colorize them according to their y-coordinate

close, plotIPDF(ebsd_line.orientations,[xvector,yvector,zvector],...
  'property',ebsd_line.y,'markersize',3,'antipodal')

mtexColorbar
