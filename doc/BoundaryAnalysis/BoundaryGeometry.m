%% Grain Boundary Tutorial
% geometrical properties of grain boundaries
%
%% Open in Editor
%
%% Contents
%
%% Grain boundaries generation
%
% To work with grain boundaries we need some ebsd data and have to detect
% grains within the data set. 

% load some example data
mtexdata twins

% detect grains
[grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd('indexed'))

% smooth them
grains = grains.smooth

% visualize the grains
plot(grains,grains.meanOrientation)

% extract the grain boundaries
gB = grains.boundary


%% Properties of grain boundaries
%
% A variable of type grain boundary contains the following properties
%
% * misorientation
% * direction
% * segLength
%
% These can be used to colorize the grain boundaries. By the following
% command we plot the grain boundaries colorized by the misorientation
% angle

plot(gB('indexed'),gB('indexed').misorientation.angle./degree,'linewidth',2)
mtexColorbar


%%
% The output tells us that we have 3219 Magnesium to Magnesium boundary
% segments and 606 boundary segements where the grains are cutted by the
% scanning boundary. To restrict the grain boundaries to a specific phase
% transistion you shall do

plot(gB,gB.direction.rho,'linewidth',2)


%% Line intersections
%
% Let start by defining some line by its endpoints and plot in on top of
% the boundary plot

xy1 = [0,10];   % staring point
xy2 = [31,41]; % end point

plot(grains.boundary)
line([xy1(1);xy2(1)],[xy1(2);xy2(2)],'linestyle',':','linewidth',2,'color','cyan')

%%
% The command <grainBoundary_intersect.html intersect> computes the
% intersections of all boundary segments with the given line

[x,y] = grains.boundary.intersect(xy1,xy2);
hold on
scatter(x,y,'red')
hold off
% find the number of intersection points
sum(~isnan(x))




