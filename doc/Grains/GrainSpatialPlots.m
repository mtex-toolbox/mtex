%% Plotting
%
%%
% We start by importing some EBSD data and reconstructing some grains

% import a demo data set
mtexdata forsterite silent

% perform grain segmentation
[grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd('indexed'),'minPixel',5);

%% Phase maps
% When using the <grain2d.plot.html |plot|> command without additional
% argument the associated color is defined by color stored in the crystal
% symmetry for each phase

close all
plot(grains)

%%
% Accordingly, changing the color stored in the crystal symmetry changes the
% color in the map

grains('Fo').CS.color = str2rgb('salmon')
plot(grains)

%%
% The color can also been specified directly by using the option
% |FaceColor|.

% detect the largest grain
[~,id] = max(grains.area);

% plot the grain in dark black with some transparency
hold on
plot(grains(id),'FaceColor','darkgray','FaceAlpha',0.7)
hold off


%% Orientation Maps
% Coloring grains according to their mean orientations is very similar to
% EBSD maps colored by orientations. The most important thing is that the
% misorientation can only extracted from grains of the same phase.

% the implicit way
plot(grains('Fo'),grains('fo').meanOrientation)

%%
% This implicit way gives no control about how the color is computed from
% the meanorientation. When using the explicit way by defining a
% orientation to color map

% this defines a ipf color key
ipfKey = ipfColorKey(grains('Fo'));

%%
% we can set the inverse pole figure direction and many other properties

ipfKey.inversePoleFigureDirection = xvector;

% compute the color from the meanorientation
color = ipfKey.orientation2color(grains('Fo').meanOrientation);

% and use them for plotting
plot(grains('fo'),color)

%% Plotting arbitrary properties
% As we have seen in the previous section the |plot| command accepts as
% second argument any list of RGB values specifying a color. Instead of RGB
% values the second argument can also be a list of values which are then
% transformed by a colormap into color.
%
%%
% As an example we colorize the grains according to their aspect ratio.

plot(grains,grains.aspectRatio)

%%
% we see that we have a very elongated grain which makes it difficult to
% distinguish the aspect ration of the other grains. A solution for this is
% to specify the values of the aspect ration which should mapped to the
% top and bottom color of the colormap

setColorRange([1 5])

%% Colorizing circular properties
% Sometimes the property we want to display is a circular, e.g., the
% direction of the grain elongation. In this case it is important to use a
% circular colormap which assign the same color to high values and low
% values. In the case of the direction of the grain elongation the angles 0
% and 180 should get the same color since they represent the same
% direction.

% consider only elongated grains
elongated_grains = grains(grains.aspectRatio > 1.2);

% angle of the long axis to (1 0 0)
%omega = angle(alongated_grains.longAxis, vector3d.X, grains.N);
omega = mod(elongated_grains.longAxis.rho, pi);

% plot the direction
plot(elongated_grains,omega ./ degree,'micronbar','off')

% change the default colormap to a circular one
mtexColorMap(colorcet('C2'))

% display the colormap
mtexColorbar

%% Colorizing two scalar properties
% Above we plotted the long axis of grains admitting that for low aspect
% ratio grains, also the long axis is poorly defined. Another way to
% overcome this situation is to desaturate the color as a function of
% aspect ratio.

% In order to do so, we define a planar colorkey.
pK = planarColorKey(colorcet('C2'))

% Since we want to plot the grain long axis direction, we tell the
% colorkley that hue-encoded value is periodic. Also we can set ranges for
% the individual values.
pK.periode  = pi; 
pK.range2 = [1 3];

% Now we can derive color from the colorkey.
prop1 = mod(grains.longAxis.rho, pi);
prop2 = grains.aspectRatio;

colors = pK.property2color(prop1, prop2);
plot(grains,colors)


% In order to get a nice colorkey, we can set labels and plot the key.
pK.label1 = 'long axis'
pK.label2 = 'aspect ratio'

figure
plot(pK,prop1/degree,prop2)

% Similarly we can colorcode any combination of two scalar grain
% properties.

%% Plotting the orientation within a grain
% In order to plot the orientations of EBSD data within certain grains one
% first has to extract the EBSD data that belong to the specific grains.

% let have a look at the biggest grain
[~,id] = max(grains.area)

% and select the corresponding EBSD data
ebsd_maxGrain = ebsd(ebsd.grainId == id)

% the previous command is equivalent to the more simpler 
ebsd_maxGrain = ebsd(grains(id));

%%

% compute the color out of the orientations
color = ipfKey.orientation2color(ebsd_maxGrain.orientations);

% plot it
plot(ebsd_maxGrain, color,'micronbar','off')

% plot the grain boundary on top
hold on
plot(grains(id).boundary,'linewidth',2)
hold off

%% Visualizing directions
% 
% We may also visualize directions by arrows placed at the center of the
% grains using the command <grain2d.quiver.html |quiver|>.

% load some single phase data set
mtexdata csl

% compute and plot grains
[grains,ebsd.grainId] = calcGrains(ebsd,'minPixel',5);
grains = smooth(grains,5);
plot(grains,grains.meanOrientation,'micronbar','off','figSize','large','region',[50 300 100 250])

% next we want to visualize the direction of the 100 axis
dir = grains.meanOrientation * Miller(1,0,0,grains.CS);

% the length of the vectors should depend on the grain diameter
len = 0.25*grains.diameter;

% arrows are plotted using the command quiver. We need to switch of auto
% scaling of the arrow length
hold on
quiver(grains,len.*dir,'autoScale','off','color','black')
hold off

%% Labeling Grains
% In the above example the vectors are centered at the centroids of the
% grains. We may also use the command <grain2d.text.html |text|> to display
% an arbitrary text on top of each grain.

% plot them
plot(grains,grains.meanOrientation,'micronbar','off','region',[50 300 100 250])

% only the big grains
big_grains = grains(grains.numPixel>100);

% plot on top their ids
text(big_grains,int2str(big_grains.id))

%#ok<*NASGU>