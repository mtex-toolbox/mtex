%% Sharp Color Keys
%
%%
% A colour key has to cover every orientation a phase can have, which is
% the right thing to do for a map of many grains and the wrong thing for a
% map whose orientations differ by a degree or two. All of them land on
% almost the same colour, and the picture is flat. A *sharp* colour key
% spends the whole range of colours on the small region the data actually
% occupies.
%
% The example is a calcite data set of 45451 pixels, of which 20119 are
% indexed.

mtexdata sharp

ipfKey = ipfColorKey(ebsd);

plot(ebsd,ipfKey.orientation2color(ebsd.orientations))
xlim(ebsd.extent(1:2)),ylim(ebsd.extent(3:4))

%%
% Nearly one shade of green. Faint diagonal bands can be made out and a
% few red pixels stand out from them, but a key built to hold every calcite
% orientation cannot resolve differences of a degree.
%
%% Colouring by one number
%
% The most direct way to sharpen is to leave orientations aside and colour
% by a single quantity that varies. In the $(101)$ inverse pole figure the
% orientations sit at almost the same place, and the azimuth of that place
% is one such number.

r = vector3d(1,0,1);

% compute the positions in the inverse pole figure
h = ebsd.orientations .\ r;
h = project2FundamentalRegion(h);

% compute the azimuth angle in degree
color = h.rho ./ degree;

plotIPDF(ebsd.orientations,r,'property',color,'MarkerSize',3,'grid','points','all')
mtexColorbar

%%
% The azimuth has a median of -22° and 98% of the measurements lie between
% -24° and -18°, with a thin tail reaching -42°. The colour bar is set by
% that tail, so almost all of the data shares one colour. Restricting the
% range to where the data is, and painting everything outside it purple,
% puts the contrast back.

setColorRange([-25 -14]);

% by the following lines we colorize the outliers in purple.
cmap = colormap;
cmap(end,:) = [1 0 1]; % make last color purple
cmap(1,:) = [1 0 1];   % make first color purple
colormap(cmap)

%%
% The same numbers and the same range, now on the map.

% plot the data with the customized color
plot(ebsd,color)
xlim(ebsd.extent(1:2)),ylim(ebsd.extent(3:4))

% the colour range where the data is, everything outside it purple
setColorRange([-25 -15]);

cmap = colormap;
cmap(end,:) = [1 0 1];
cmap(1,:) = [1 0 1];
colormap(cmap)

%%
% What was one flat hue is a map of sharp diagonal lamellae, and the purple
% pixels scattered over it are the tail of the distribution.
%
%% Sharpening the orientation colour key
%
% The same idea applies to the full orientation key rather than to a single
% number. Two settings do it: put the white centre of the key at the mean
% orientation of the data, and say how far from it the colours should
% saturate.

ipfKey = ipfHSVKey(ebsd.CS.properGroup);

% put the gray spot of the inverse pole figure at the mean orientation
ipfKey.ipfDirection = mean(ebsd.orientations,'robust') * ipfKey.whiteCenter;

close all;
plot(ebsd,ipfKey.orientation2color(ebsd.orientations))
xlim(ebsd.extent(1:2)),ylim(ebsd.extent(3:4))

%%
% Almost everything is grey, since almost everything is at the mean, and
% the few pixels that are far away come out black. Half the measurements
% are within 2.6° of the mean, so a saturation distance of that order is
% what the data asks for.

ipfKey.maxAngle = 7.5*degree;
plot(ebsd,ipfKey.orientation2color(ebsd.orientations))
xlim(ebsd.extent(1:2)),ylim(ebsd.extent(3:4))

%%
% |maxAngle| is worth varying. White is the mean orientation, and a colour
% becomes more saturated and finally dark the further an orientation is
% from it, so a smaller |maxAngle| gives more contrast and saturates
% earlier.
%
% Drawing the key itself, with the orientations plotted into it, shows what
% has happened.

plot(ipfKey,'resolution',0.25*degree)

% plot orientations into the color key
hold on
plotIPDF(ebsd.orientations,'points',10,'MarkerSize',1,'MarkerFaceColor','w','MarkerEdgeColor','w')
hold off

%%
% The orientations sit in a tight cloud around the white centre, and the
% transition from white to full colour happens right there. That is the
% whole trick: the steep part of the key is where the data is.
%
%% The axis angle colour key
%
% A different approach to the same problem is the @axisAngleColorKey, which
% colours the deviation from a reference orientation by the axis and angle
% of that deviation. The natural reference is each grain's own mean, so
% grains come first.

[grains,ebsd] = calcGrains(ebsd,'angle',1.5*degree,'minPixel',5);
grains = smoothBoundary(grains,5);

%%
% Note the segmentation threshold of 1.5°, an order of magnitude below the
% usual 10°: these are the differences the page is about.

ipfKey = axisAngleColorKey(ebsd);

% use for the reference orientation the grain mean orientation
ipfKey.oriRef = grains.meanOrientation(ebsd('indexed').grainId);

plot(ebsd('indexed'),ipfKey.orientation2color(ebsd('indexed').orientations))

hold on
plot(grains.boundary,'lineWidth',4,'LineColor','white')
plot(grains.boundary,'lineWidth',2,'LineColor','black')
hold off

%%
% Each grain is now drawn relative to itself, so the colours say how the
% orientation varies inside a grain rather than between grains.
%
% One thing this makes visible is what a denoising filter does, since the
% changes it makes are of exactly this size - see
% <EBSDDenoising.html Denoising>.

F = halfQuadraticFilter;

ebsdS = smooth(ebsd,F,'fill',grains);

% use for the reference orientation the grain mean orientation
ipfKey.oriRef = grains.meanOrientation(ebsdS('indexed').grainId);

plot(ebsdS('indexed'),ipfKey.orientation2color(ebsdS('indexed').orientations))

hold on
plot(grains.boundary,'lineWidth',4,'LineColor','white')
plot(grains.boundary,'lineWidth',2,'LineColor','black')
hold off

%%
% The speckle has gone and the gradients within the grains have not, which
% is what the filter is supposed to do and what no ordinary colour key
% would have shown.
%
%% Orientation gradients inside one grain
%
% The last application is a single grain of the forsterite map, the largest
% one it has.

plottingConvention.default('y↑→x');
mtexdata forsterite silent

% segment grains
[grains,ebsd] = calcGrains(ebsd);

% find largest grains
[~,ind] = max(grains.numPixel);
largeGrains = grains(ind);

ebsd = ebsd(largeGrains)

%%
% Plotted with the ordinary key it is one colour, as a grain should be.

% plot a grain
close all
plot(largeGrains.boundary,'linewidth',2)
hold on
plot(ebsd,ebsd.orientations)
hold off

%%
% Sharpening the key against the mean orientation of this grain alone
% reveals the gradient inside it.

% plot a grain
plot(largeGrains.boundary,'linewidth',2)
hold on
ipfKey = ipfHSVKey(ebsd);
ipfKey.ipfDirection = mean(ebsd.orientations) * ipfKey.whiteCenter;
ipfKey.maxAngle = 10*degree;
plot(ebsd,ipfKey.orientation2color(ebsd.orientations))
hold off

%%
% At this scale the grain is not uniform at all. It falls into large
% domains a few degrees apart, with gradual transitions between them, and
% the single colour of the previous figure hid every bit of it.
%
