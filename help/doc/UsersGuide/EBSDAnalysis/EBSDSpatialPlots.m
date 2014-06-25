%% Plotting spatially indexed EBSD data
% How to visualize EBSD data
%
%% Open in Editor
%
%%
% This sections gives you an overview over the functionality MTEX offers to
% visualize spatial orientation data.
%
%% Contents
%

%% Phase Plots
% Let us first import some EBSD data with a [[matlab:edit mtexdata, script file]]

mtexdata forsterite

%%
% By default MTEX plots a phase map for EBSD data.

plot(ebsd)


%%
% You can access the color of each phase by

ebsd('Diopside').color

%%
% These values are RGB values, e.g. to make the color for diopside even
% more red we can do

ebsd('Diopside').color = [1 0 0];

plot(ebsd)

%% Visualizing arbitrary properties
% Appart from the phase information we can use any other property to
% colorize the EBSD data. As an example we may plot the band contrast

plot(ebsd,ebsd.bc)
colorbar


%% Visualizing orienations
% Actually, we can pass any list of numbers or colors as a second input
% argument to be visualized together with the ebsd data. Hence, in order to
% visualize the orientations in an EBSD map we have first to compute a
% color for each orientation. the most simple way is to assign to each
% orientation its rotational angle this is done by the command

plot(ebsd('Forsterite'),ebsd('Forsterite').orientations.angle)
colorbar

%%
% Lets make things a bit more formal. Therefore we define first a
% orientation mapping that assignes to each orientation its rotational
% angle

oM = angleOrientationMapping(ebsd('Fo'))

%%
% now the color, which is actually the rotatinal angle, is computed by the
% command

color = oM.orientation2color(ebsd('Fo').orientations);

%%
% and we can visuallize it by
plot(ebsd('Forsterite'),color)

%%
% While for the previous case this seems to be unnecesarily complicated it
% allows us to define arbitrary complex color mapping. Consider for example
% the following standard color mapping that uses an colorization of the
% fundamental sector in the inverse pole figure to assign a color to each
% orientation

% this defines a color mapping for the Forsterite phase
oM = ipdfHSVOrientationMapping(ebsd('Forsterite'))

% this is the colored fundamental sector
plot(oM)

%%
% Now we can proceed as above

% compute the colors
color = oM.orientation2color(ebsd('Fo').orientations);

% plot the colors
plot(ebsd('Forsterite'),color)

%%
% Orientation mappings usually provide several options to alter the
% alignment of colors. Lets give some examples

% we may interchange green and blue by setting
oM.colorPostRotation = reflection(yvector);

plot(oM)

%%
% or cycle of colors red, green, blue by
oM.colorPostRotation = rotation('axis',zvector,'angle',120*degree);

plot(oM)

%%
% Furthermore, we can explicitly set the inverse pole figure directions by

oM.inversePoleFigureDirection = zvector;

% compute the colors again
color = oM.orientation2color(ebsd('Forsterite').orientations);

% and plot them
plot(ebsd('Forsterite'),color)


%%
% Beside the recommented orientation mapping
% <ipdfHSVOrientationMapping.html ipdfHSVOrientationMapping> MTEX supports
% also a lot of other color mappings as summarized below
%
% * 
% *
% *
% *
%
%
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

%% Customizing the color
% In some cases, it might be useful to color certain orientations after
% one needs. This can be done in two ways, either to color a certain fibre,
% or a certain orientation.

%% SUB: Coloring certain fibres
% To color a fibre, one has to specify the crystal direction *h* together
% with its rgb color and the specimen direction *r*, which should be marked.

close all
plot(ebsd('fo'),'colorcoding',...
  'ipdfCenter',{Miller(1,1,1),[0 0 1]},...
  'r',zvector,...
  'halfwidth',7.5*degree)

%%
% the option |halfwidth| controls half of the intensity of the color at a
% given distance. Here we have chosen the (111)[001] fibre to be drawn in blue,
% and at 7.5 degrees, where the blue should be only lighter.

colorbar
hold on
circle(Miller(1,1,1),15*degree,'linewidth',2)
set(gcf,'renderer','zbuffer')

%%
% the percentage of blue colored area in the map is equivalent to the fibre
% volume

vol = fibreVolume(ebsd('fo'),Miller(1,1,1),zvector,15*degree)

close all;
plotIPDF(ebsd('fo'),zvector,'markercolor','k','marker','x')

%%
% we can easily extend the colorcoding

hcolored = {Miller(0,0,1),[1 0 0],... 
  Miller(0,1,1)   ,[0 1 0],...
  Miller(1,1,1)   ,[0 0 1],...
  Miller(11,4,4)  ,[1 0 1],...
  Miller(5,0,2)   ,[1 1 0],...
  Miller(5,5,2)   ,[0 1 1]};

close all;
plot(ebsd('fo'),'colorcoding',...
  'ipdfCenter',hcolored,...
  'r',xvector,...
  'halfwidth',12.5*degree,...
  'antipodal')

%%

colorbar

%% SUB: Coloring certain orientations
% We might be interested to locate some special orientation in our orientation map. 
% Suppose the mode of the ODF somewhere in our spatial distribution of
% grains (the orientation map).

mode = mean(ebsd('Forsterite'))

%%
% The definition of colors for certain orientations is carried out similarly as 
% in the case of fibres

close all;
plot(ebsd('fo'),'colorcoding',...
  'orientationCenter',{mode,[0 0 1]},...
  'halfwidth',20*degree)

%%

colorbar('sections',9,'sigma')

%%
% the area of the colored EBSD data in the map corresponds to the volume
% portion

vol = volume(ebsd('fo'),mode,20*degree)

%%
% actually, the colored measurements stress a peak in the ODF

odf = calcODF(ebsd('fo'),'halfwidth',10*degree,'silent');
plot(odf,'sections',9,'antipodal','silent','sigma')


%% Coloring properties
%
%% SUB: Phase map
%

close all;
plot(ebsd,'property','phase')

%% SUB: Other properties
%
% Often the individual orientation measurements come along with some other
% properties, maybe something called background contrast, stored in our
% EBSD as *property* bc, we can plot it easily by specifing it as a
% plotting option

close all
plot(ebsd,'property','bc')
mtexColorMap white2black

%%
% the property could also be a Nx1 or an Nx3-vector containing the color
% information to be plotted, where N referes to the number of measurements
% in the EBSD data set.

plot(ebsd('fo'),'property', ebsd('Forsterite').bc)

%% 
% if the size is just Nx1, the color can be adjusted with

mtexColorMap white2black

%% Combining different plots
% Combining different plots can be done either by plotting only subsets of
% the ebsd data, or via the option |'translucent'|. Note that the option
% |'translucent'| requires the renderer of the figure to be set to
% |'opengl'|.

close all;
plot(ebsd,'property','bc')
mtexColorMap white2black

hold on
plot(ebsd('fo'),'colorcoding',...
  'ipdfCenter',{Miller(1,1,1),[1 0 0]},'r',zvector,...
  'translucent',.5)

%%
% another example

close all;
plot(ebsd,'property','bc')
mtexColorMap white2black

hold on, plot(ebsd,'translucent',0.25)

