%% Advanced Color Keys
%
%%
% Besides the recommended color key <ipfHSVKey.html ipfHSVKey> MTEX
% includes a bunch of other color keys
%
% * <ipfTSLKey.html ipfTSLKey>
% * <ipfHKLKey.html ipfHKLKey>
% * <BungeColorKey.html BungeColorKey>
% * <PatalaColorKey.html PatalaColorKey>
% * <axisAngleColorKey.html axisAngleColorKey>
% * <spotColorKey.html spotColorKey>
% * <ipfSpotKey.html ipfSpotKey>


close all; plotx2east
mtexdata forsterite
csFo = ebsd('Forsterite').CS;

%% Euler Angle Coloring
% The oldest way to colorize orientations is to simply map the three Euler
% angles into the RGB values. This can be done by

colorKey = BungeColorKey(csFo);

plot(ebsd('fo'),colorKey.orientation2color(ebsd('fo').orientations))

%%

plot(colorKey)

%% Coloring certain orientations
% We might be interested in locating some special orientation in our
% orientation map. The definition of colors for certain orientations is
% carried out similarly as in the case of fibres

colorKey = spotColorKey(ebsd('Fo'));
colorKey.center = mean(ebsd('Forsterite').orientations,'robust');
colorKey.color = [0,0,1];
colorKey.psi = deLaValleePoussinKernel('halfwidth',20*degree);

plot(ebsd('fo'),colorKey.orientation2color(ebsd('fo').orientations))

% and the correspoding colormap
figure(2)
plot(colorKey,'sections',9,'sigma')

%%
% the area of the colored EBSD data in the map corresponds to the volume
% portion (in percent)

vol = 100 * volume(ebsd('fo').orientations,colorKey.center,20*degree)

%%
% actually, the colored measurements stress a peak in the ODF

close all
odf = calcODF(ebsd('fo').orientations,'halfwidth',10*degree,'silent');
plot(odf,'sections',9,'silent','sigma')
mtexColorbar


%% Coloring fibres
% To color a fibre, one has to specify the crystal direction *h* together
% with its RGB color and the specimen direction *r*, which should be marked.

% define a fibre
f = fibre(Miller(1,1,1,csFo),zvector);

% set up coloring
colorKey = ipfSpotKey(csFo);
colorKey.inversePoleFigureDirection = f.r;
colorKey.center = f.h;
colorKey.color = [0 0 1];
colorKey.psi = deLaValleePoussinKernel('halfwidth',7.5*degree);

plot(ebsd('fo'),colorKey.orientation2color(ebsd('fo').orientations))

%%
% the option |halfwidth| controls half of the intensity of the color at a
% given distance. Here we have chosen the (111)[001] fibre to be drawn in blue,
% and at 7.5 degrees, where the blue should be only lighter.

plot(colorKey)
hold on
circle(f.h.project2FundamentalRegion,15*degree,'linewidth',2)

%%
% the percentage of blue colored area in the map is equivalent to the fibre
% volume

vol = volume(ebsd('fo').orientations,f,15*degree)

plotIPDF(ebsd('fo').orientations,zvector,'markercolor','k','marker','x','points',200)
hold off

%%
% we can easily extend the colorcoding

% the centers in the inverse pole figure
colorKey.center = Miller({0 0 1},{0 1 1},{1 1 1},{11 4 4},{5 0 2},{5 5 2},csFo);

% the correspnding collors
colorKey.color = [[1 0 0];[0 1 0];[0 0 1];[1 0 1];[1 1 0];[0 1 1]];

% plot the key
plot(colorKey)
hold on
plot(ebsd('fo').orientations,'MarkerFaceColor','none','MarkerEdgeColor','k','MarkerSize',3,'points',1000)
hold off

%%

close all;
plot(ebsd('fo'),colorKey.orientation2color(ebsd('fo').orientations))



%% Combining different plots
% Combining different plots can be done either by plotting only subsets of
% the EBSD data or via the option |'faceAlpha'|. Note that the option
% |'faceAlpha'| requires the renderer of the figure to be set to
% |'opengl'|.

close all;
plot(ebsd,ebsd.bc,'micronbar','off')
mtexColorMap black2white

colorKey = ipfSpotKey(csFo);
colorKey.inversePoleFigureDirection = zvector;
colorKey.center = Miller(1,1,1,csFo);
colorKey.color = [0 0 1];
colorKey.psi = deLaValleePoussinKernel('halfwidth',7.5*degree);

hold on
plot(ebsd('fo'),colorKey.orientation2color(ebsd('fo').orientations),'FaceAlpha',0.5)
hold off

