%% Plotting
%
%%
% An EBSD map is a picture of a list. Each measurement gets one small patch
% at the position it was taken, and the patch is filled with a colour that
% stands for something measured there. Which quantity that is, is entirely
% your choice, and the choice decides what the picture can show. This page
% goes through the three kinds of quantity a map is usually coloured by -
% the phase, a per point number, and the orientation itself.

close all;
plottingConvention.default('y↑→x');
mtexdata forsterite

%% Phase maps
%
% With no second argument the map is coloured by phase, which is the
% quickest way to see what is in the specimen and where.

plot(ebsd)

%%
% This is a peridotite: a forsterite matrix in light blue with enstatite in
% green and smaller diopside grains in orange. The white speckle marks the
% *notIndexed* points, whose patterns could not be matched to any of the
% three phases. A quarter of the map is of that kind, and it is not spread
% evenly - it crowds along the grain boundaries, where the beam sees two
% crystals at once.
%
% Each phase carries its own colour, as an RGB triple

ebsd('Diopside').color

%%
% and any RGB triple can be put in its place. The function
% <str2rgb.html str2rgb> saves you looking one up, since it turns a colour
% name into the triple.

ebsd('Diopside').color = str2rgb('salmon');

plot(ebsd)

%%
% The notIndexed points are white by default, which reads as "nothing here"
% rather than as a measurement. Giving them a colour of their own is done
% on the phase itself and puts them in the legend with the rest.

ebsd('notIndexed').CS.color = str2rgb('gray');

plot(ebsd)

%%
% Now the notIndexed class is visible as such, and the pattern it forms -
% dense along the boundaries, sparse inside the grains - is information
% about the specimen rather than a gap in it.
%
%% Maps of a measured property
%
% Any list of numbers with one entry per measurement can take the place of
% the phase. An EBSD file usually brings several such columns along, listed
% as the properties of the variable; here they are |bands|, |bc|, |bs|,
% |error|, |mad| and |oldId|. The most useful of them is normally the band
% contrast |bc|, a measure of how sharp the diffraction pattern was.

plot(ebsd,ebsd.bc)

colormap gray % make the image gray-scale
mtexColorbar

%%
% No orientation went into this picture, and the microstructure is in it
% anyway: a pattern collected where the beam straddles two crystals is
% blurred, so the boundaries come out as dark lines. The horizontal banding
% is an artefact of the acquisition rather than a feature of the rock, and
% the dark rectangle at the top left is a patch where the patterns were
% poor throughout.
%
%% Maps of the orientation
%
% Orientations are not numbers, so before they can be plotted they have to
% be turned into colours. The simplest attempt is to use the rotational
% angle of each orientation and let a colour map do the rest.

plot(ebsd('Forsterite'),ebsd('Forsterite').orientations.angle./degree)
mtexColorbar

%%
% The grains are recognisable, but only just. The angles run from 20° to
% 118° while 91% of them fall between 70° and 110°, so almost the whole map
% is squeezed into a narrow band of the colour bar - and two grains that
% turn by the same angle about quite different axes get the same colour
% anyway. One number cannot separate a three parameter quantity.
%
% The usual answer is an *inverse pole figure colour key*: paint the
% fundamental sector of the inverse pole figure once, then give each
% orientation the colour of the crystal direction that points along a fixed
% specimen direction.

% this defines an ipf color key for the Forsterite phase
ipfKey = ipfColorKey(ebsd('Forsterite'));
ipfKey.ipfDirection = vector3d.Z;

% this is the colored fundamental sector
plot(ipfKey)

%%
% The three corners of the sector are the axes of the forsterite cell, and
% reading the map is now reading this key: a red point is a measurement
% whose crystallographic $c$ axis points along the specimen normal, a green
% one its $a$ axis and a blue one its $b$ axis.

colors = ipfKey.orientation2color(ebsd('Forsterite').orientations);
plot(ebsd('Forsterite'),colors)

%%
% The colour is still a choice and not a measurement, and a different key
% makes the same data look different. <EBSDIPFMap.html IPF Maps> is about
% those choices, and <EBSDAdvancedMaps.html Advanced Plotting> about colour
% keys that answer other questions than "which direction points where".
%
%% Two maps in one figure
%
% Different plots combine either by drawing subsets of the data on top of
% each other, or by making the upper one transparent with |'faceAlpha'|.

plot(ebsd,ebsd.bc)
mtexColorMap black2white

hold on
plot(ebsd('Forsterite'),colors,'FaceAlpha',0.5)
hold off

%%
% The band contrast supplies the boundaries and the surface detail, the
% orientation colours supply the identity of each grain, and neither hides
% the other.
%
