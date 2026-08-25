%% Inverse Pole Figure Color Coding of Orientation Maps
%
%%
% An orientation has three parameters and a colour has three numbers, so
% turning one into the other looks easy. It is not: the orientations of a
% crystal form a curved space with symmetry, colour space is a flat box,
% and no map between them is at once smooth, one to one and free of
% arbitrary choices. An *inverse pole figure colour key* is the compromise
% MTEX uses by default. This page explains where its colours come from,
% what can be read off them, and what the alternatives do differently. The
% mathematics is in <http://dx.doi.org/10.1107/S1600576716012942
% Orientations - perfectly colored>.

plottingConvention.default('y↑→x');
mtexdata olivine
ebsd('olivine').CS = ebsd('olivine').CS.Laue;

%% From a crystal to a colour
%
% Start with the crystal itself. Olivine grows with a characteristic
% habitus, and MTEX knows it as a @crystalShape.

cS = crystalShape.olivine;

plot(cS,'colored')

%%
% Drawing that shape in the orientation measured for each grain already
% shows the texture, since a grain is described by the way its crystal sits
% in the specimen.

% 1. reconstruct the grains
[grains,ebsd] = calcGrains(ebsd,'minPixel',5);

% 2. smooth the grain boundaries a bit
grains = smoothBoundary(grains,10);

% 3. plot the grain boundaries
plot(grains.boundary,'lineWidth',1.5,'micronbar','off')

% 4. select only very large grains
big_grains = grains(grains.numPixel > 150);

% 5.  plot the crystals
hold on
plot(big_grains('olivine'),0.8*cS,'linewidth',2,'colored')
hold off
legend off

%%
% Seventy four grains are large enough to carry a crystal here, and each
% crystal is coloured by its faces. The idea of the colour key is to use
% the colour of the face that points towards you. A crystal shape has only
% six of them, so only six colours would ever appear - the way out is to
% replace the faceted crystal by a ball whose surface is coloured
% continuously.

close all
ipfKey = ipfHSVKey(ebsd('olivine'));
plot(ipfKey,'3d')

%%
% Placing that ball on each grain, turned into the grain's orientation,
% gives the same picture as the crystals did, with a continuum of colours
% instead of six.

plot(grains.boundary,'lineWidth',1.5,'micronbar','off')

hold on
plot(big_grains('olivine'),ipfKey)
hold off
legend off

%%
% The colour at the centre of each ball - the colour pointing at the viewer
% - is the colour of that grain. Computing it for a list of orientations is
% what the key is for.

% this computes the colors for each orientation specified as input
colors = ipfKey.orientation2color(big_grains('olivine').meanOrientation);

% this plots the grains colorized according to the RGB values stored in colors
plot(big_grains('o'),colors)

%% Reading the map
%
% Flattened into a stereographic projection and labelled with the crystal
% axes, the ball becomes the legend of that map.

plot(ipfKey,'complete','upper')

%%
% Because olivine is orthorhombic, one quarter of it is enough to hold
% every direction once, and that quarter is what the key normally shows.
% A red grain has its $c$ axis along the specimen normal, a green one its
% $a$ axis, a blue one its $b$ axis.
%
% The same information plotted the other way round puts each grain at the
% crystal direction that points along the normal, with the marker scaled by
% the grain's area.

plotIPDF(big_grains('olivine').meanOrientation,colors,vector3d.Z,...
  'MarkerSize',0.05*big_grains('olivine').area,'markerEdgeColor','k')

%%
% The markers cover the whole sector rather than clustering in a corner, so
% these grains have no strongly preferred axis along the specimen normal.
% The one exception is the largest grain of the map, the big red marker
% sitting exactly in the $c$ axis corner.
%
%% Choosing the reference direction
%
% Nothing forces the reference direction to be the specimen normal. Any
% specimen fixed direction will do - a rolling direction, a foliation, the
% axis of a cylinder - and it is the |ipfDirection| of the key.

% set the reference direction to X
ipfKey.ipfDirection = vector3d.X;

% compute the colors
colors = ipfKey.orientation2color(ebsd('olivine').orientations);

% plot the ebsd data together with the colors
plot(ebsd('o'),colors)

%%
% The microstructure is unchanged and the colours are completely different,
% which is worth remembering before comparing two published maps. The
% |ipfDirection| may also be a list of directions, one per measurement,
% which is what a round specimen needs when "normal to the surface" is a
% different direction at every point.
%
%% Customizing the color key
%
% The assignment of colours to the sector can be moved around without
% changing which orientations are distinguished. Reflecting it interchanges
% green and blue

% we may interchange green and blue by setting
ipfKey.colorPostRotation = reflection(yvector);

plot(ipfKey)

%%
% and rotating it by 120° cycles red, green and blue.

ipfKey.colorPostRotation = rotation.byAxisAngle(zvector,120*degree);

plot(ipfKey)

%% Laue or enantiomorphic symmetry groups
%
% An EBSD system reports Euler angles, and Euler angles describe proper
% rotations only - no measurement of this kind can see an improper symmetry
% operation. It is therefore legitimate to build the key from the proper
% symmetries alone.

% the color key corresponding to the purely enantiomorphic symmetry group
ipfKey = ipfHSVKey(ebsd('olivine').CS.properGroup);
plot(ipfKey)

%%
% Olivine is |mmm| and its proper subgroup is |222|, which has half as many
% operations, so the sector is twice as large - here half a hemisphere
% rather than a quarter. Twice the sector means twice the room for colours,
% and orientations that the smaller key had to give the same colour become
% distinguishable.

close all
color = ipfKey.orientation2color(ebsd('olivine').orientations);
plot(ebsd('olivine'),color)

%% Other inverse pole figure keys
%
% Other EBSD systems colour their maps differently, and MTEX provides their
% keys as well, so that a map can be reproduced as a reader may know it.

plot(ipfTSLKey(ebsd('olivine').CS))

%%
%

plot(ipfHKLKey(ebsd('olivine').CS))

%%
% For an orthorhombic phase the TSL key is hard to tell from the default
% one. The HKL key differs plainly: it blends the three corner colours
% directly, so the middle of the sector goes dark, where the other two keep
% it bright.
%
% There is a more serious difference. For some symmetry groups the sector
% cannot be mapped onto the colour box smoothly and one to one at the same
% time, and these keys then jump: two directions a fraction of a degree
% apart come out in different colours, which shows up in a map as an edge
% that is not a boundary. MTEX says so when such a key is built.

plot(ipfTSLKey(crystalSymmetry('-3m')),'complete','upper')

%%
% The seams are visible in the complete key above, between green and blue,
% exactly where the warning says to expect them.
%
