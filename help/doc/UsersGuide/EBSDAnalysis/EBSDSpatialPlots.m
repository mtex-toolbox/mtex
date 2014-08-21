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

close all, plotx2east
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

%%
% By default, not indexed phases are plotted as white. To directly specify 
% a color for some ebsd data use the option |FaceColor|.

hold on
plot(ebsd('notIndexed'),'FaceColor','black')
hold off

%% Visualizing arbitrary properties
% Appart from the phase information we can use any other property to
% colorize the EBSD data. As an example we may plot the band contrast

plot(ebsd,ebsd.bc)

colormap gray % this makes the image grayscale

colorbar(gcm)

%% Visualizing orienations
% Actually, we can pass any list of numbers or colors as a second input
% argument to be visualized together with the ebsd data. In order to
% visualize orientations in an EBSD map we have first to compute a
% color for each orientation. The most simple way is to assign to each
% orientation its rotational angle. This is done by the command

plot(ebsd('Forsterite'),ebsd('Forsterite').orientations.angle./degree)
colorbar(gcm)

%%
% Lets make things a bit more formal. Therefore we define first a
% orientation mapping that assignes to each orientation its rotational
% angle

oM = angleOrientationMapping(ebsd('Fo'))

%%
% now the color, which is actually the rotational angle, is computed by the
% command

color = oM.orientation2color(ebsd('Fo').orientations);

%%
% and we can visuallize it by
plot(ebsd('Forsterite'),color)
colorbar(gcm)

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
close all
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
close all
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
%% Customizing the color
% In some cases, it might be useful to color certain orientations after
% one needs. This can be done in two ways, either to color a certain fibre,
% or a certain orientation.

%% SUB: Coloring certain fibres
% TODO:
% To color a fibre, one has to specify the crystal direction *h* together
% with its rgb color and the specimen direction *r*, which should be marked.

%close all
%plot(ebsd('fo'),'colorcoding',...
%  'ipdfCenter',{Miller(1,1,1),[0 0 1]},...
%  'r',zvector,...
%  'halfwidth',7.5*degree)

%%
% the option |halfwidth| controls half of the intensity of the color at a
% given distance. Here we have chosen the (111)[001] fibre to be drawn in blue,
% and at 7.5 degrees, where the blue should be only lighter.

%colorbar
%hold on
%circle(Miller(1,1,1),15*degree,'linewidth',2)
%set(gcf,'renderer','zbuffer')

%%
% the percentage of blue colored area in the map is equivalent to the fibre
% volume

vol = fibreVolume(ebsd('fo').orientations,Miller(1,1,1,ebsd('fo').CS),zvector,15*degree)

close all;
plotIPDF(ebsd('fo').orientations,zvector,'markercolor','k','marker','x')

%%
% we can easily extend the colorcoding

%hcolored = {Miller(0,0,1),[1 0 0],... 
%  Miller(0,1,1)   ,[0 1 0],...
%  Miller(1,1,1)   ,[0 0 1],...
%  Miller(11,4,4)  ,[1 0 1],...
%  Miller(5,0,2)   ,[1 1 0],...
%  Miller(5,5,2)   ,[0 1 1]};

%close all;
%plot(ebsd('fo'),'colorcoding',...
%  'ipdfCenter',hcolored,...
%  'r',xvector,...
%  'halfwidth',12.5*degree,...
%  'antipodal')

%%

%colorbar

%% SUB: Coloring certain orientations
% We might be interested to locate some special orientation in our orientation map. 
% Suppose the mode of the ODF somewhere in our spatial distribution of
% grains (the orientation map).

mode = mean(ebsd('Forsterite'))

%%
% The definition of colors for certain orientations is carried out similarly as 
% in the case of fibres

%close all;
%plot(ebsd('fo'),'colorcoding',...
%  'orientationCenter',{mode,[0 0 1]},...
%  'halfwidth',20*degree)

%%

%colorbar('sections',9,'sigma')

%%
% the area of the colored EBSD data in the map corresponds to the volume
% portion (in percent)

vol = 100 * volume(ebsd('fo').orientations,mode,20*degree)

%%
% actually, the colored measurements stress a peak in the ODF

odf = calcODF(ebsd('fo').orientations,'halfwidth',10*degree,'silent');
plot(odf,'sections',9,'antipodal','silent','sigma')
colorbar(gcm)

%% Coloring properties
%
%% SUB: Phase map
%

close all;
plot(ebsd)

%% SUB: Other properties
%
% Often the individual orientation measurements come along with some other
% properties, maybe something called background contrast, stored in our
% EBSD as *property* bc, we can plot it easily by specifing it as a
% plotting option

close all
plot(ebsd,ebsd.bc)
colorbar(gcm)
mtexColorMap white2black

%%
% the property could also be a Nx1 or an Nx3-vector containing the color
% information to be plotted, where N referes to the number of measurements
% in the EBSD data set.

plot(ebsd('fo'),ebsd('Forsterite').bc)
colorbar(gcm)

%% 
% if the size is just Nx1, the color can be adjusted with

mtexColorMap white2black

%% Combining different plots
% Combining different plots can be done either by plotting only subsets of
% the ebsd data, or via the option |'translucent'|. Note that the option
% |'translucent'| requires the renderer of the figure to be set to
% |'opengl'|.

close all;
plot(ebsd,ebsd.bc)
mtexColorMap white2black

% TODO
%hold on
%plot(ebsd('fo'),'colorcoding',...
%  'ipdfCenter',{Miller(1,1,1),[1 0 0]},'r',zvector,...
%  'translucent',.5)

%%
% another example

close all;
plot(ebsd,ebsd.bc)
mtexColorMap black2white

hold on, plot(ebsd('fo'),'translucent',0.35)

