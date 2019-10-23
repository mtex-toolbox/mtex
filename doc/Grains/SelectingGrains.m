%% Selecting Grains
%
% TODO: This help page needs to be improved
%
%%
% In this section we discuss how to select grains by properties. We start
% our discussion by reconstructing the grain structure from a sample EBSD
% data set.

% load sample EBSD data set
mtexdata forsterite

% restrict it to a subregion of interest.
ebsd = ebsd(inpolygon(ebsd,[5 2 10 5]*10^3));

% remove all not indexed pixels
ebsd = ebsd('indexed')

% reconstruct grains
[grains, ebsd.grainId] = calcGrains(ebsd,'angle',5*degree)

% smooth them
grains = smooth(grains,5);

% plot the orientation data of the Forsterite phase
plot(ebsd('fo'),ebsd('fo').orientations)

% plot the grain boundary on top of it
hold on
plot(grains.boundary,'lineWidth',2)
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


%% The grainId and how to select EBSD inside specific grains
%
% Besides, the list of grains the command <EBSD.calcGrains.html calcGrains>
% returns also two other output arguments. 


largeGrains = grains(grains.grainSize > 50);

text(largeGrains,largeGrains.id)


%%


%%
% The second output argument grainId is a list with the same size as the
% EBSD measurements that stores for each measurement the corresponding
% grainId. The above syntax stores this list directly inside the ebsd
% variable. This enables MTEX to select EBSD data by grains. The following
% command returns all the EBSD data that belong to grain number 33.

ebsd(grains(33))

%%
% and is equivalent to the command

ebsd(ebsd.grainId == 33) 

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
ori = orientation.byEuler(350*degree,50*degree,100*degree,grains('fo').CS)

% select all grain with misorientation angle to ori less then 20 degree
grains_selected = grains_fo(angle(grains_fo.meanOrientation,ori)<20*degree)

plot(grains_selected)


%% Changing lists of grains
%
% As with any list in MTEX, one can single out specific grains by conditions
% using the syntax

% this gives all grains with more the 1000 pixels
largeGrains = grains(grains.grainSize > 1000)

hold on
% mark only large Forsterite grains
plot(largeGrains('Fo').boundary,'linewidth',2,'linecolor','k')
hold off

%% boundary grains
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
