%% Working with Grains
% How to index grains and access shape properties.
%
%% Open in Editor
%
%% Contents
%
%% 
% Grains have several intrinsic properties, which can be used for
% statistical, shape as well as for spatial analysis
%
%%
% Let us first import some EBSD data and reconstruct grains

plotx2east
mtexdata forsterite
ebsd = ebsd(inpolygon(ebsd,[5 2 10 5]*10^3));
grains = calcGrains(ebsd)

plot(ebsd)
hold on
plot(grains.boundary,'linewidth',2)
hold off


%% Accessing individual grains
% The variable |grains| is essentially a large vector of grains. Thus when
% applying a function like <Grain2d.area.html area> to this variable we
% obtain a vector of the same lenght with numbers representing the area of
% each grain

grain_area = grains.area;

%%
% As a first rather simple application we could colorize the grains
% according to their area, i.e., according to the numbers stored in
% |grain_area|

plot(grains,grain_area)

%%
% As a second application, we can ask for the largest grain within our data
% set. The maximum value and its position within a vector are found by the
% Matlab command |max|.

[max_area,max_id] = max(grain_area)

%%
% The number |max_id| is the position of the grain with a maximum area within
% the variable |grains|. We can access this specific grain by direct
% indexing

grains(max_id)

%%
% and so we can plot it

hold on
plot(grains(max_id).boundary,'linecolor','red','linewidth',1.5)
hold off

%%
% Note that this way of addressing individual grains can be generalized to
% many grains. E.g. assume we are interested in the largest 5 grains. Then
% we can sort the vector |grain_area| and take the indices of the 5 largest
% grains.

[sorted_area,sorted_id] = sort(grain_area,'descend');

large_grain_id = sorted_id(1:5);

hold on
plot(grains(large_grain_id).boundary,'linecolor','green','linewidth',1.5)
hold off


%% Indexing by a Condition 
% By the same syntax as above we can also single out grains that satisfy a
% certain condition. I.e., to access are grains that are at least half as
% large as the largest grain we can do

condition = grain_area > max_area/2;

hold on
plot(grains(condition).boundary,'linecolor','red','linewidth',1.5)
hold off

%%
% This is a very powerful way of accessing grains as the condition can be
% build up using any grain property. As an example let us consider the
% phase. The phase of the first five grains we get by

grains(1:5).phase

%%
% Now we can access or grains of the first phase Forsterite by the
% condition

condition = grains.phase == 1;
plot(grains(condition))

%%
% To make the above more directly you can use the mineral name for indexing

grains('forsterite')


%%
% Logical indexing allows also for more complex queries, e.g. selecting all
% grains perimeter larger than 6000 and at least 600 measurements within

condition = grains.perimeter>6000 & grains.grainSize >= 600;

selected_grains = grains(condition)

plot(selected_grains)

%% Indexing by orientation or position
% One can also select a grain by its spatial coordinates using the syntax
% |grains(x,y)|

x = 12000; y = 4000;

plot(grains);

hold on

plot(grains(x,y).boundary,'linewidth',2,'linecolor','r')

plot(x,y,'marker','s','markerfacecolor','k',...
  'markersize',10,'markeredgecolor','w')
hold off

%%
% In order to select all grains with a certain orientation one can do

% restrict first to Forsterite phase
grains_fo = grains('fo') 

% the reference orientation
ori = orientation('Euler',350*degree,50*degree,100*degree,grains('fo').CS)

% select all grain with misorientation angle to ori less then 20 degree
grains_selected = grains_fo(angle(grains_fo.meanOrientation,ori)<20*degree)

plot(grains_selected)

%% Grain-size Analysis
% Let's go back to the grain size and analyze its distribution. To this end,
% we consider the complete data set.

mtexdata forsterite
% consider only indexed data for grain segmentation
ebsd = ebsd('indexed');
% perform grain segmentation
[grains,ebsd.grainId] = calcGrains(ebsd)

%%
% Then the following command gives you a nice overview over the grain size
% distributions of the grains

hist(grains)

%%
% Sometimes it is desirable to remove all boundary grains as they might
% distort grain statistics. To do so one should remember that each grain
% boundary has a property |grainId| which stores the ids of the neigbouring
% grains. In the case of an outer grain boundary, one of the neighbouring
% grains has the id zero. We can filter out all these boundary segments by

% ids of the outer boundary segment 
outerBoundary_id = any(grains.boundary.grainId==0,2);

plot(grains)
hold on
plot(grains.boundary(outerBoundary_id),'linecolor','red','linewidth',2)
hold off

%%
% Now |grains.boundary(outerBoundary_id).grainId| is a list of grain ids
% where the first column is zero, indicating the outer boundary, and the
% second column contains the id of the boundary grain. Hence, it remains to
% remove all grains with these ids.

% next we compute the corresponding grain_id
grain_id = grains.boundary(outerBoundary_id).grainId;

% remove all zeros
grain_id(grain_id==0) = [];

% and plot the boundary grains
plot(grains(grain_id))

%%
% finally, we can remove the boundary grains by
grains(grain_id) = []

plot(grains)

%% 
% Beside the area, there are various other geometric properties that can be
% computed for grains, e.g., the <grain2d.perimeter.html perimeter>, the
% <grain2d.diameter.html diameter>, the <grain2d.equivalentRadius.html
% equivalentRadius>, the <grain2d.equivalentPerimeter.html
% equivalentPerimeter>, the <grain2d.aspectRatio.html aspectRatio>, and the
% <grain2d.shapeFactor.html shapeFactor>. The following is a simple scatter
% plot of shape factor against aspect ratio to check for correlation.
%

% the size of the dots corresponds to the area of the grains
close all
scatter(grains.shapeFactor, grains.aspectRatio, 70*grains.area./max(grains.area))

%%

plot(grains,log(grains.aspectRatio))


%% Spatial Dependencies
% One interesting question would be, whether a polyphase system has
% dependence in the spatial arrangement or not, therefore, we can count the
% transitions to a neighbour grain

%[J, T, p ] = joinCount(grains,grains.phase)

