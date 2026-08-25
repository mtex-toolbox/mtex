%% Line Profiles
%
%%
% A map plotted as a picture shows a gradient as a change of colour, which
% is hard to read a number off. Restricting the data to a line and plotting
% a quantity against position along it turns the same gradient into a
% curve, where a slope is a slope and a jump is a jump.
%
% The example is the forsterite map, and the grain to look at is the one
% with the largest grain orientation spread - the grain whose orientation
% varies most within itself.

close all
plottingConvention.default('y↑→x');
mtexdata forsterite silent

% reconstruct grains
[grains,ebsd] = calcGrains(ebsd,'minPixel',5,'angle',15*degree);

% find the grain with maximum grain orientation spread
[~,id] = max(grains.GOS);
grain_selected = grains(id)

% plot the grain with its orientations
close all
plot(grain_selected.boundary,'linewidth',2)
hold on
plot(ebsd(grain_selected),ebsd(grain_selected).orientations)
hold off

%%
% Its spread is 9.7°, which for a single grain is a lot, and the colour
% changes visibly from one end to the other. A line drawn through it says
% how.

% line segment
lineSec =  [18826   6438; 18089 10599];

% draw the line into the plot
line(lineSec(:,1),lineSec(:,2),'linewidth',2)

%%
% <EBSD.spatialProfile.html |spatialProfile|> collects the measurements
% along that segment - 86 of them here.

ebsd_line = spatialProfile(ebsd(grain_selected),lineSec)

%%
% Two curves are worth plotting against position: how far each point has
% turned from the first point of the line, and how far it has turned from
% the point before it.

close all % close previous plots

% misorientation angle to the first orientation on the line
plot(ebsd_line.y,...
  angle(ebsd_line(1).orientations,ebsd_line.orientations)/degree)

% misorientation gradient
hold on
plot(0.5*(ebsd_line.y(1:end-1)+ebsd_line.y(2:end)),...
  angle(ebsd_line(1:end-1).orientations,ebsd_line(2:end).orientations)/degree)
hold off

xlabel('y'); ylabel('misorientation angle in degree')

legend('to reference orientation','orientation gradient')

%%
% The first curve climbs steadily to about 7° over two thirds of the line,
% then jumps to 20° and stays flat. The second curve says the same thing
% differently: it sits at a few tenths of a degree almost everywhere - that
% is the steady bending - with three isolated spikes, the largest of 21°.
%
% A jump of 21° inside one grain is worth a thought, since the grains were
% reconstructed with a threshold of 15°. It is not a contradiction: a grain
% is a connected region in which every *neighbouring* pair differs by less
% than the threshold, and the two parts of this grain are joined by a path
% that goes around the jump. The gaps in both curves are notIndexed points
% on the line.
%
%% The same profile in inverse pole figures
%
% Plotting the orientations of the line rather than a single number keeps
% the axis they turn about, and colouring the markers by position along the
% line keeps the order.

close
plotIPDF(ebsd_line.orientations,[xvector,yvector,zvector],...
  'property',ebsd_line.y,'markersize',20,'antipodal')

mtexColorbar

%%
% In each of the three figures the points fall into one tight cluster,
% coloured blue through green, and a separate yellow marker sitting well
% away from it. That is the jump of the profile again: the first two thirds
% of the line drift slowly through the cluster, and everything beyond the
% jump lands somewhere else.
%
