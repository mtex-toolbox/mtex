%% Visualizing EBSD data with sharp textures
% Using spezialized orientation mappings is particularly usefull when
% visualizing sharp data. Let us consider the following data set

mtexdata sharp

oM = ipdfHSVOrientationMapping(ebsd);

close all;plot(ebsd,oM.orientation2color(ebsd.orientations))

%%
% and have a look into the 001 inverse pole figure.

% compute the positions in the inverse pole figure
h = ebsd.orientations .\ zvector;
h = project2FundamentalRegion(h);

% compute the azimuth angle in degree
color = h.rho ./ degree;

plotIPDF(ebsd,zvector,'property',color,'MarkerSize',3,'grid')
% colorbar % TODO

%%
% We see that all individual orientations are clustered around azimuth
% angle 25 degree with some outliers at 90 and 120 degree. In order to
% increase the contrast for the main group we restrict the colorrange from
% 20 degree to 29 degree.

caxis([20 29]-120);

% by the following lines we colorcode the outliers in purple.
cmap = colormap;
cmap(end,:) = [1 0 1];
cmap(1,:) = [1 0 1];
colormap(cmap)

%%
% The same colorcoding we can now apply to the EBSD map.

% plot the data with the customized color
plot(ebsd,color)

% set scaling of the angles to 20 - 29 degree
caxis([20 29]-120);

% colorize outliers in purple.
cmap = colormap;
cmap(end,:) = [1 0 1];
cmap(1,:) = [1 0 1];
colormap(cmap)

%%
% TODO: maybe remove this

close all;

oM = ipdfAzimuthOrientationMapping(ebsd('calcite'))
oM.inversePoleFigureDirection = zvector;

color = oM.orientation2color(ebsd.orientations);

plot(ebsd,color)

caxis([20 29]-120);
colormap(cmap);

%%
% using the option sharp MTEX automatically tries to focus on the main
% component in the orientation space and to increase there the contrast

plot(ebsd,'sharp')


%%
% observe how in the inverse pole figure the orientations are scattered
% closely around the white center. Together with the fact that the
% transition from white to color is quite rappidly this gives a high
% contrast.

colorbar
hold on
plotIPDF(ebsd,'points',10,'MarkerSize',10,'MarkerFaceColor','none','MarkerEdgeColor','k')
hold off

%% 
% Another example is when analyzing the orientation distribution within
% grains

mtexdata forsterite

% segment grains
grains = calcGrains(ebsd)

% find largest grains
largeGrains = grains(grainSize(grains)>500)

%%
% When plotting one specific grain with its orientations we see that they
% all are very similar and, hence, get the same color

% plot a grain 
close all
plotBoundary(largeGrains(1),'linewidth',2)
hold on
plot(largeGrains(1).ebsd,'property','orientations')
hold off

%%
% when applying the option sharp MTEX colors the mean orientation as white
% and scales the maximum saturation to fit the maximum misorientation
% angle. This way deviations of the orientation within one grain can be
% visualised. 

% plot a grain 
plotBoundary(largeGrains(1),'linewidth',2)
hold on
plot(largeGrains(1).ebsd,'property','orientations','sharp')
hold off

