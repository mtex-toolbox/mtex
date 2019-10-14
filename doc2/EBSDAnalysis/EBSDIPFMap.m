%% IPF Maps
%
%%
% This section explains various options to customize ipf orientation maps.
% The mathematics behind the default MTEX color key is explained in detail
% in the paper <http://dx.doi.org/10.1107/S1600576716012942 Orientations -
% perfectly colored>. Let us first import some sample EBSD data.

close all; plotx2east
mtexdata forsterite
csFo = ebsd('Forsterite').CS;

%% The basic setup
% In order to transform orientations into color one usually defines a
% <orientationColorKey.orientationColorKey.html orientation color key>
% ,e.g,

ipfKey = ipfHSVKey(ebsd('Forsterite').CS)

%%
% Note that a mandatory argument to any color key is always the symmetry of
% the objects to be transformed into colors. When plotting the color key we
% see that plotting region automatically adapts to the fundamental sector
% of orthorhombic crystal symmetry

plot(ipfKey)

%%
% In order to apply this color key for colorizing the map we proceed as
% follows

% compute the colors
color = ipfKey.orientation2color(ebsd('Fo').orientations);

% plot the colors
close all
plot(ebsd('Forsterite'),color)

%% Customizing the color key
% Orientation color keys usually provide several options to alter the
% alignment of colors. Let's give some examples

% we may interchange green and blue by setting
ipfKey.colorPostRotation = reflection(yvector);

plot(ipfKey)

%%
% or cycle of colors red, green, blue by
ipfKey.colorPostRotation = rotation.byAxisAngle(zvector,120*degree);

plot(ipfKey)

%%
% Furthermore, we can explicitly set the inverse pole figure directions by

ipfKey.inversePoleFigureDirection = zvector;

% compute the colors again
color = ipfKey.orientation2color(ebsd('Forsterite').orientations);

% and plot them
close all
plot(ebsd('Forsterite'),color)


%% Laue or Enantiomorphic symmetry groups
% As the Euler angles provided by the EBSD measurement devices describe
% proper rotations only they do not include any improper symmetry
% operation. For this reason it is entirely justified to consider for the
% ipf map proper symmetries only. Lets define the corresponding color key

% the colore key corresponding to the purely enantiomorphic symmetry group
ipfKey = ipfHSVKey(ebsd('Forsterite').CS.properGroup)
plot(ipfKey)

%%
% We oberseve that the key is twice as large and hence allows for a better
% distinction between orientations.

close all
color = ipfKey.orientation2color(ebsd('Fo').orientations);
plot(ebsd('Forsterite'),color)


%% Other inverse pole figure keys
% Beside the default ipf color key MTEX provides the default color keys are
% they are used by other popular EBSD systems.

plot(ipfTSLKey(csFo))

%%
% 

plot(ipfHKLKey(csFo))

%%
% The user should be aware that for certain symmetry groups these color key
% lead to color jumps.
