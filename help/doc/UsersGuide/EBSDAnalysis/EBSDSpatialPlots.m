%% Plotting spatially indexed EBSD data
% How to plot spatially indexed orientations
%
%% Open in Editor
%
%%
% This sections gives you an overview over the functionality MTEX offers to
% visualize spatial orientation data.
%
%% Contents
%

%%
% Let us first import some EBSD data with a [[matlab:edit mtexdata, script file]]

mtexdata aachen

%% Coloring of spatial orientation data
% If the EBSD data are provided with spatial coordinates, one can
% assign a color to each orientation and [[EBSD.plotspatial.html,plot]]
% a colored map

plot(ebsd('Fe'))

%%
% The orientations of the spatial map are mapped according to a
% <ColorCodingEBSD_demo.html colorcoding>. A standard way to color
% orientations is to assign each fibre $g*h=r$ a chromatic value, where the
% specimen direction $r$ is fixed. Then the map can be interpreted as
% colored inverse pole figure, where a certain crystallographic form (plane, axis)
% is associated with a specified color in relation to the crystal reference
% frame.

colorbar('Position',[100 100 400 200])

%%
% The [[orientation2color.html, colorcoding]] could be specified by an
% option

close all, plot(ebsd('Fe'),'colorcoding','hkl')

%%

colorbar('Position',[100 100 300 300])

%% Customizing the color
% In some cases, it might be useful to color certain orientations after
% one needs. This can be done in two ways, either to color a certain fibre,
% or a certain orientation.

%% SUB: Coloring certain fibres
% To color a fibre, one has to specify the crystal direction *h* together
% with its rgb color and the specimen direction *r*, which should be marked.

close all, 
plot(ebsd('Fe'),'colorcoding',...
  'h',{Miller(1,1,1),[0 0 1]},...
  'r',zvector,...
  'halfwidth',7.5*degree)

%%
% the option |halfwidth| controls half of the intensity of the color at a
% given distance. Here we have chosen the (111)[001] fibre to be drawn in blue,
% and at 7.5 degrees, where the blue should be only lighter.

colorbar('Position',[100 100 400 200])
hold on
circle(Miller(1,1,1),15*degree,'linewidth',2)
set(gcf,'renderer','zbuffer')

%%
% the percentage of blue colored area in the map is equivalent to the fibre
% volume

vol = fibreVolume(ebsd('fe'),Miller(1,1,1),zvector,15*degree)

close all;
plotipdf(ebsd('fe'),zvector,'markercolor','k','marker','x')

%%
% we can easily extend the colorcoding

hcolored = {Miller(0,0,1),[1 0 0],... 
  Miller(0,1,1)   ,[0 1 0],...
  Miller(1,1,1)   ,[0 0 1],...
  Miller(11,4,4)  ,[1 0 1],...
  Miller(5,0,2)   ,[1 1 0],...
  Miller(5,5,2)   ,[0 1 1]};

close all;
plot(ebsd('Fe'),'colorcoding',...
  'h',hcolored,...
  'r',xvector,...
  'halfwidth',12.5*degree,...
  'antipodal')

%%

colorbar('position',[100 100 300 300])

%% SUB: Coloring certain orientations
% We might be interested to locate some special orientation in our orientation map. 
% Suppose the mode of the ODF somewhere in our spatial distribution of
% grains (the orientation map).

mode = orientation('euler',90*degree,50*degree,45*degree,'ABG')

%%
% The definition of colors for certain orientations is carried out similarly as 
% in the case of fibres

close all;
plot(ebsd('Fe'),'colorcoding',...
  'orientations',{mode,[0 0 1]},...
  'halfwidth',10*degree)

%%

colorbar('sections',9)

%%
% the area of the colored EBSD data in the map corresponds to the volume
% portion

vol = volume(ebsd('fe'),mode,20*degree)

%%
% actually, the colored measurements stress a peak in the ODF

odf = calcODF(ebsd('fe'),'halfwidth',10*degree,'silent');
plot(odf,'sections',9,'antipodal','silent')


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
colormap gray

%%
% the property could also be a Nx1 or an Nx3-vector containing the color
% information to be plotted, where N referes to the number of measurements
% in the EBSD data set.

p1 = get(ebsd('Fe'),'bc');
plot(ebsd('Fe'),'property', p1)

%% 
% if the size is just Nx1, the color can be adjusted with

colormap(grayColorMap)

%% Combining different plots
% Combining different plots can be done either by plotting only subsets of
% the ebsd data, or via the option |'translucent'|. Note that the option
% |'translucent'| requires the renderer of the figure to be set to
% |'opengl'|.

close all;
plot(ebsd,'property','bc')
colormap(grayColorMap)

hold on
plot(ebsd('fe'),'colorcoding',...
  'h',{Miller(1,1,1),[1 0 0]},'r',zvector,...
  'translucent',.5)

%%
% another example

close all;
plot(ebsd,'property','bc')
colormap(grayColorMap)

hold on, plot(ebsd,'translucent',0.25)

