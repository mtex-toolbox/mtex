%% Line intersections
%
%
%%
% In this section we discus how to analyze grain boundary by intersecting
% them with certain lines. Lets start by importing some EBSD data and
% computing grain boundaries.

% load some example data
mtexdata twins silent

% detect grains
[grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd('indexed'));

% smooth them
grains = grains.smooth;

% visualize the grains
plot(grains,grains.meanOrientation)

% extract all grain boundaries
gB = grains.boundary;

hold on
plot(gB,'LineWidth',2)
hold off

%% 
% Let start by defining some line by its endpoints and plot in on top of
% the boundary plot

xy1 = [10,10];   % staring point
xy2 = [41,41]; % end point

line([xy1(1);xy2(1)],[xy1(2);xy2(2)],'linestyle',':','linewidth',4,'color','white')

%%
% The command <grainBoundary.intersect.html intersect> computes the
% intersections of all boundary segments with the given line

[x,y] = grains.boundary.intersect(xy1,xy2);
hold on
scatter(x,y,'blue','linewidth',2)
hold off
% find the number of intersection points
sum(~isnan(x))
