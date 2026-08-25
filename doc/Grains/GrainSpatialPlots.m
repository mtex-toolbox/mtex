%% Plotting
%
%%
% A grain is a polygon, so plotting grains means filling each polygon with a
% colour. Everything on this page is about where that colour comes from: the
% phase, the mean orientation of the grain, or any number you have computed
% for it.
%
% Note the difference to plotting an EBSD map, where one colour is drawn per
% measurement. A grain map has one colour per grain, so it shows what the
% reconstruction decided and nothing of the scatter inside a grain.

% import a demo data set
plottingConvention.default('y↑→x');
mtexdata forsterite silent

% perform grain segmentation
[grains,ebsd] = calcGrains(ebsd,'minPixel',5);

%% Phase maps
%
% Called with no second argument, <grain2d.plot.html |plot|> colours each
% grain by its phase, using the colour stored with the crystal symmetry.

close all
plot(grains)

%%
% That colour is a property of the phase and can be changed, which is the
% simplest way to make one phase stand out.

grains('Fo').CS.color = "salmon";
plot(grains)

%%
% A single grain, or any subset, can be given a colour of its own with the
% option |'FaceColor'|. Here the largest grain is filled in grey, half
% transparent so that the boundary underneath stays visible.

% detect the largest grain
[~,id] = max(grains.area);

hold on
plot(grains(id),'FaceColor','darkgray','FaceAlpha',0.7)
hold off

%% Orientation maps
%
% Passing the mean orientations as the second argument colours every grain
% by the direction its lattice points in, exactly as an
% <EBSDIPFMap.html IPF map> does for the measurements. Orientations of
% different phases are not comparable, so this is done one phase at a time.

plot(grains('Fo'),grains('Fo').meanOrientation)

%%
% MTEX picks a colour key for you here and says so in the command window. To
% decide yourself which direction the colours refer to, build the key
% explicitly and ask it for the colours.

% a colour key for the forsterite phase
ipfKey = ipfColorKey(grains('Fo'));

% colour by which lattice direction points along x, rather than along z
ipfKey.ipfDirection = vector3d.X;

color = ipfKey.orientation2color(grains('Fo').meanOrientation);

plot(grains('Fo'),color)

%%
% The map has changed completely although the orientations have not. What
% the colours mean is in the key, which is worth plotting beside any such
% map.

figure
plot(ipfKey)

%%
% Red is [001], yellow is [100] and blue is [010], so a red grain in the map
% above has its [001] axis close to the x axis of the specimen - and in the
% figure before it, drawn with the default direction, red meant [001] close
% to z. A colour means nothing without the key that produced it, which is why
% <EBSDIPFMap.html IPF maps> should always be published with theirs.

%% Colouring by any property
%
% The second argument may also be a list of numbers, one per grain, which a
% colormap turns into colours. Any property of the grains will do - here the
% aspect ratio, the length of the grain divided by its width.

plot(grains,grains.aspectRatio)

%%
% Almost the whole map sits at the bottom of the colour range, because a
% handful of ribbon shaped grains reach an aspect ratio of 13 and stretch it.
% Fixing the range to the interval that matters makes the rest visible.

setColorRange([1 5])

%%
% Now the elongated grains stand out from the equant ones, at the price that
% the eight grains above an aspect ratio of 5 are no longer distinguishable
% from each other. Every fixed colour range makes that trade.

%% Colouring a direction
%
% A property that is an angle needs a colormap that closes on itself. The
% direction of the long axis of a grain is such a property: 0 and 180 degrees
% describe the same direction and must get the same colour, or the map shows
% a seam where there is none.

% consider only elongated grains
elongatedGrains = grains(grains.aspectRatio > 1.2);

% angle of the long axis to the x axis of the specimen
omega = angle(vector3d.X, elongatedGrains.longAxis, grains.N);

plot(elongatedGrains,omega ./ degree,'micronbar','off')

% a cyclic colormap
mtexColorMap(colorcet('C2'))
mtexColorbar

%%
% Grains of the same colour are aligned the same way, and green dominates
% the map: half of the elongated grains have their long axis between 60 and
% 105 degrees from the x axis, which is close to vertical here. The grain
% shapes say the same thing at a glance, and a colour that clusters like
% this is what a shape preferred orientation looks like.

%% Colouring by two properties at once
%
% The long axis of a nearly round grain is arbitrary, so the previous map
% gives the same weight to a direction that is well defined and to one that
% is not. A |planarColorKey| solves this by mapping one property to the hue
% and a second one to the saturation:
% direction as colour, aspect ratio as how strong that colour is.

% hue from a cyclic colormap, and periodic, since the long axis is an axis
pK = planarColorKey(colorcet('C2'));
pK.periode = pi;

% aspect ratio 1 desaturates to grey, 3 and above is fully saturated
pK.range2 = [1 3];

prop1 = angle(vector3d.X, grains.longAxis, grains.N);
prop2 = grains.aspectRatio;

colors = pK.property2color(prop1, prop2);
plot(grains,colors)

%%
% The round grains have faded to nearly white and only the elongated ones
% still carry a direction, so the eye is no longer drawn to angles that mean
% nothing. The key itself can be plotted, with the data drawn into it, so
% that the reader can see which combinations actually occur.

pK.label1 = 'long axis';
pK.label2 = 'aspect ratio';

figure
plot(pK,prop1/degree,prop2)

%%
% Any pair of scalar grain properties may be combined this way.

%% The measurements inside a grain
%
% A grain map hides the scatter within a grain by construction. To see it,
% go back to the measurements, which the |grainId| property of the map ties
% to the grains.

% the biggest grain
[~,id] = max(grains.area);

% the measurements inside it
ebsdMaxGrain = ebsd(ebsd.grainId == id);

% which is what this shorter form does as well
ebsdMaxGrain = ebsd(grains(id));

%%
% Colouring them with the key from above puts the measurements and the grain
% on the same colour scale.

color = ipfKey.orientation2color(ebsdMaxGrain.orientations);

plot(ebsdMaxGrain, color,'micronbar','off')

hold on
plot(grains(id).boundary,'linewidth',2)
hold off

%%
% Most of these 2683 measurements are the same shade of blue, but the narrow
% neck on the left is visibly lighter: the lattice is bent there, and the
% measurements in it depart from the mean orientation of the grain by up to
% 6 degrees. <GrainOrientationParameters.html Orientation Parameters> is
% where that departure is measured rather than eyeballed.
%
% The white pixels scattered through the grain are the unindexed
% measurements that |'alpha'| absorbed into it during the reconstruction:
% they belong to the grain and have no orientation to draw. The white bay in
% the middle is something else - the boundary runs around it, so it is not
% part of this grain at all.

%% Arrows on grains
%
% A direction attached to each grain is better drawn than coloured.
% <grain2d.quiver.html |quiver|> puts one arrow per grain at its centroid.

% load a single phase data set
plottingConvention.default('y↓→x');
mtexdata csl silent

[grains,ebsd] = calcGrains(ebsd,'minPixel',5);
grains = smoothBoundary(grains,5);
plot(grains,grains.meanOrientation,'micronbar','off','figSize','large','region',[50 300 100 250])

% where the [100] axis of each grain points
dir = grains.meanOrientation * Miller(1,0,0,grains.CS);

hold on
quiver(grains,dir,'color','black')
hold off

%%
% Each arrow is one [100] axis seen from above, drawn a fifth of its grain's
% diameter long. Length therefore carries no information of its own except
% one: an arrow that comes out short points steeply out of the plane of the
% section, because what is drawn is its projection into that plane. Pass
% |'noScaling'| to set the lengths yourself.
%
% An axis pointing into the screen would be hidden below the map, so those
% arrows are drawn tail out, ending at the grain centre. The small dot marks
% the centre they belong to.

%% Labelling grains
%
% <grain2d.text.html |text|> writes an arbitrary string on top of each grain,
% at the same centroid the arrows started from. Labelling every grain is
% unreadable, so this is normally done for a selection - here the grains
% larger than a hundred pixels, labelled with their id.

plot(grains,grains.meanOrientation,'micronbar','off','region',[50 300 100 250])

big_grains = grains(grains.numPixel>100);

text(big_grains,int2str(big_grains.id))

%%
% Those ids are what <SelectingGrains.html Selecting Grains> uses to pick
% single grains out of the map.

%#ok<*NASGU>
