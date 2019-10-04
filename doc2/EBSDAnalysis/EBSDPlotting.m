%% Plotting
%
%%
% This section gives you an overview of the functionality MTEX offers to
% visualize spatial orientation data. Let us first import some sample EBSD
% data.

close all; plotx2east
mtexdata forsterite
csFo = ebsd('Forsterite').CS;

%% Phase Plots
% By default, MTEX plots a phase map for EBSD data.

plot(ebsd)

%%
% You can access the color of each phase by

ebsd('Diopside').color

%%
% These values are RGB values which can be altered to any other RGB triple.
% A more convinient way for changing the color is the function
% <str2rgb.html str2rgb> which converts color names into RGB triplets

ebsd('Diopside').color = str2rgb('salmon');

plot(ebsd('indexed'))

%%
% By default, not indexed phases are plotted as white and it is impossible
% to assign a different color as we did it for real phases. Instead we need
% to use option |FaceColor| to specify the color directly in the plotting
% command.

hold on
plot(ebsd('notIndexed'),'FaceColor','Gray')
hold off

%% Visualizing arbitrary properties
% Apart from the phase information, we can use any other property to
% colorize the EBSD data. As an example, we may plot the band contrast

plot(ebsd,ebsd.bc)

colormap gray % make the image grayscale
mtexColorbar

%% Visualizing orientations
% Actually, we can pass any list of numbers or colors as a second input
% argument to be visualized together with the ebsd data. In order to
% visualize orientations in an EBSD map, we have first to compute a
% color for each orientation. The most simple way is to assign to each
% orientation its rotational angle. This is done by the command

plot(ebsd('Forsterite'),ebsd('Forsterite').orientations.angle./degree)
mtexColorbar

%%
% Obviously, the rotational angle is not a very distintive representative
% for orientations. A more common approach is to define a colorization of
% the fundamental secor of the inverse pole figure, a so called ipf color
% key, and to colorize orientations according to their position in a fixed
% inverse pole figure. Let's consider the following standard key.

% this defines an ipf color key for the Forsterite phase
ipfKey = ipfColorKey(ebsd('Forsterite'));
ipfKey.inversePoleFigureDirection = vector3d.Z;

% this is the colored fundamental sector
plot(ipfKey)

%%
% Next we may utilize this key to turn the orientations into colors, which
% are than passed to the <EBSD.plot.html plot> command.

colors = ipfKey.orientation2color(ebsd('Forsterite').orientations);
plot(ebsd('Forsterite'),colors)

%%
% The above ipf color key can be largely customizied. This is explained in
% more detail in <EBSDIPFMap IPF Maps>. Beside IPF maps there are also more
% specific ways to colorize orientations as they are discussed in
% <EBSDAdvancedMaps.html Advanced Plotting>.
%
%% Superposing different plots
% Combining different plots can be done either by plotting only subsets of
% the EBSD data or via the option |'faceAlpha'|. Note that the option
% |'faceAlpha'| requires the renderer of the figure to be set to
% |'opengl'|.

close all;
plot(ebsd,ebsd.bc)
mtexColorMap black2white

hold on
plot(ebsd('fo'),'FaceAlpha',0.5)
hold off
