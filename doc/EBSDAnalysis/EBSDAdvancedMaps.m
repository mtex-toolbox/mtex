%% Advanced Color Keys
%
%%
% Colouring an orientation map means choosing a map from orientation space
% to colour space, and one would like that map to have five properties:
%
% # symmetrically equivalent orientations get the same colour
% # similar orientations get similar colours
% # different orientations get different colours
% # the whole of colour space is used, for full contrast
% # if the orientations occupy only a small part of orientation space, the
% whole of colour space is spent on that part
%
% No map has all of them, and the reason is not a lack of effort: colour
% space is a box and orientation space is curved and has symmetry, so
% something has to give. Euler angle colouring keeps the third property and
% breaks the second, putting colour jumps between neighbouring
% orientations; the default <ipfHSVKey.html MTEX key> keeps the second and
% breaks the third, giving one colour to orientations that differ.
%
% The choice is therefore made by the question being asked, and MTEX offers
%
% * |@ipfHSVKey|, the default
% * |@ipfTSLKey| and |@ipfHKLKey|, the keys of other EBSD systems
% * |@BungeColorKey|, the Euler angles as RGB
% * |@PatalaColorKey|
% * |@axisAngleColorKey|, deviation from a reference orientation
% * |@spotColorKey| and |@ipfSpotKey|, marking chosen orientations
%
% <EBSDIPFMap.html IPF Maps> covers the first three and
% <EBSDSharpPlot.html Sharp Color Keys> the fifth property; this page is
% about the rest.

close all;
plottingConvention.default('y↑→x');
mtexdata forsterite silent
csFo = ebsd('Forsterite').CS;

%% Euler angle colouring
%
% The oldest key of all: take the three Euler angles as the three colour
% channels.

colorKey = BungeColorKey(ebsd('Fo'));

plot(ebsd('fo'),colorKey.orientation2color(ebsd('fo').orientations))

%%
% Grains come out in flat, well separated colours, and the key itself looks
% perfectly smooth.

plot(colorKey)

%%
% The jumps are there all the same, and cutting orientation space into
% <SigmaSections.html sigma sections> - surfaces of constant
% $\phi_1 - \phi_2$ - brings them out.

plot(colorKey,'sections',6,'sigma')

%%
% Along the edges of these sections the colour changes abruptly although
% the orientations do not, so two grains of almost the same orientation can
% be drawn in unrelated colours. That is the price of using the Euler
% angles directly.
%
%% Marking one orientation
%
% A different question: where in the map does a chosen orientation sit? The
% @spotColorKey paints the orientations near a chosen one and fades
% everything else to white.

colorKey = spotColorKey(ebsd('Fo'));
colorKey.center = mean(ebsd('Forsterite').orientations,'robust');
colorKey.color = [0,0,1];
colorKey.psi = SO3DeLaValleePoussinKernel('halfwidth',20*degree);

plot(ebsd('fo'),colorKey.orientation2color(ebsd('fo').orientations))

% and the corresponding color-map
figure(2)
plot(colorKey,'sections',9,'sigma')

%%
% The blue area of the map is the volume fraction of orientations within
% the spot, and it can be computed as such.

vol = 100 * volume(ebsd('fo').orientations,colorKey.center,20*degree)

%%
% 12% of the measurements lie within 20° of that orientation, which is a
% lot for a spot of that size and says the orientations are concentrated
% there. Estimating a density from the same data shows the same thing as a
% peak.

close all
odf = calcDensity(ebsd('fo').orientations,'halfwidth',10*degree,'silent');
plot(odf,'sections',9,'silent','sigma')
mtexColorbar

%% Marking a fibre
%
% The same for a fibre rather than a single orientation: a crystal
% direction |h| that is to be marked, a specimen direction |r| it should
% point along, and a colour.

% define a fibre
f = fibre(Miller(1,1,1,csFo),zvector);

% set up coloring
colorKey = ipfSpotKey(csFo);
colorKey.ipfDirection = f.r;
colorKey.center = f.h;
colorKey.color = [0 0 1];
colorKey.psi = S2DeLaValleePoussinKernel('halfwidth',7.5*degree);

plot(ebsd('fo'),colorKey.orientation2color(ebsd('fo').orientations))

%%
% The halfwidth is the distance at which the colour has lost half its
% intensity, 7.5° here, so the blue fades out over roughly 15°. Drawing a
% circle of that radius into the key shows how far the marked region
% reaches.

plot(colorKey)
hold on
circle(f.h.project2FundamentalRegion,15*degree,'linewidth',2)

%%
% As with the spot, the blue area of the map is the fibre volume - a
% quarter of the measurements have their $(111)$ axis within 15° of the
% specimen normal.

vol = volume(ebsd('fo').orientations,f,15*degree)

plotIPDF(ebsd('fo').orientations,zvector,'markercolor','k','marker','x','points',200)
hold off

%%
% Several centres can be marked at once, each with its own colour.

% the centers in the inverse pole figure
colorKey.center = Miller({0 0 1},{0 1 1},{1 1 1},{11 4 4},{5 0 2},{5 5 2},csFo);

% the corresponding colors
colorKey.color = [[1 0 0];[0 1 0];[0 0 1];[1 0 1];[1 1 0];[0 1 1]];

% plot the key
plot(colorKey)
hold on
plot(ebsd('fo').orientations,'MarkerFaceColor','none','MarkerEdgeColor','k','MarkerSize',3,'points',1000)
hold off

%%
% and the map answers, for every pixel, which of the six it is nearest to.

close all;
plot(ebsd('fo'),colorKey.orientation2color(ebsd('fo').orientations))

%% Combining two keys in one figure
%
% A marked orientation is easier to place when the microstructure is
% underneath it. Drawing the band contrast first and the coloured
% orientations on top with |'faceAlpha'| does that.

close all;
plot(ebsd,ebsd.bc,'micronbar','off')
mtexColorMap black2white

colorKey = ipfSpotKey(csFo);
colorKey.ipfDirection = zvector;
colorKey.center = Miller(1,1,1,csFo);
colorKey.color = [0 0 1];
colorKey.psi = S2DeLaValleePoussinKernel('halfwidth',7.5*degree);

hold on
plot(ebsd('fo'),colorKey.orientation2color(ebsd('fo').orientations),'FaceAlpha',0.5)
hold off

%%
% The blue grains are the ones near the marked fibre, and the grey behind
% them says where the other grains and the boundaries are.
%
%#ok<*NASGU>
