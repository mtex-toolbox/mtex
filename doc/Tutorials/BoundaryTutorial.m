%% Grain Boundary Tutorial
% A quick guide to grain boundary analysis
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

%%
% Now we can extract from the grains its boundary and save it to a seperate
% variable

gB = grains.boundary

%%
% The output tells us that we have 3219 Magnesium to Magnesium boundary
% segments and 606 boundary segements where the grains are cutted by the
% scanning boundary. To restrict the grain boundaries to a specific phase
% transistion you shall do

gB_MgMg = gB('Magnesium','Magnesium')

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

plot(gB_MgMg,gB_MgMg.misorientation.angle./degree,'linewidth',2)
mtexColorbar

%%



hold on
plot(gB('notIndexed'),'lineColor','blue','linewith',5)
hold off


%%

grains.innerBoundary
