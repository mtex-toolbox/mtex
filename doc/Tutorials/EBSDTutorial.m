%% EBSD Tutorial
%
%%
% This is one path from a measurement file to the standard figures of a
% texture analysis: a phase map, an orientation map, reconstructed grains,
% and the pole figures that summarise the orientations of the whole map. It
% takes a few minutes to run and every step links to the chapter that
% treats it properly.

%% Data import
%
% MTEX reads the formats of all the big EBSD vendors - text based ones like
% |.ang| and |.ctf|, and the open binary ones like |.osc| and |.h5|. The
% import wizard walks through the options, in particular the ones that
% cannot be read from the file:

import_wizard;

%%
%
% <<importWizard.png>>
%
%%
% It ends by writing the script that does the import, which is what
% <EBSD.load.html |EBSD.load|> does directly:

% load some test data packaged with your MTEX installation
fileName = [mtexDataPath filesep 'EBSD' filesep 'Forsterite.ctf'];
ebsd = EBSD.load(fileName,'EulerCorrection',rotation.id)

%%
% Everything the file contained is now in one variable: the position of each
% measurement, its orientation, its phase, the crystal symmetries, and any
% extra columns the vendor stored. The display lists the phases and how many
% measurements each has - three minerals here, plus the measurements that
% could not be indexed.

%% Phase map
%
% Plotted with nothing else specified, an EBSD map is coloured by phase.

plot(ebsd,'refFrame','on')

%%
% Forsterite dominates, with enstatite and diopside as separate regions, and
% the white speckle is the notIndexed measurements. The arrows in the corner
% say which specimen direction points where - that alignment is worth
% checking against how the data were measured before anything else is done,
% see <EBSDReferenceFrame.html Reference Frame Alignment>.

%% Orientation map
%
% Orientations of different phases cannot be compared, so anything to do
% with orientations is done one phase at a time. A phase name selects:

ebsd('Forsterite')

%%
% and its orientations are

ebsd('Forsterite').orientations

%%
% Passing them as the second argument colours each measurement by its
% orientation.

plot(ebsd('Forsterite'),ebsd('Forsterite').orientations,'micronbar','off')

%%
% Regions of one colour are grains: a colour here means an orientation, so
% wherever the colour is constant the lattice is. The colour key used is the
% inverse pole figure key for the z direction, and MTEX says so in the
% command window - which key was used matters, and
% <EBSDIPFMap.html IPF Maps> is where that is taken seriously.

%% Grain reconstruction
%
% What the eye did in the last paragraph, <EBSD.calcGrains.html |calcGrains|>
% does properly: neighbouring measurements whose orientations agree to
% within a threshold become one grain.

% reconstruct grains with a threshold angle of 10 degrees
grains = calcGrains(ebsd,'threshold',10*degree,'minPixel',5)

% smooth the grains to avoid the staircase effect
grains = smoothBoundary(grains,5);

%%
% 873 grains, 489 of them forsterite. Each carries its shape, its size and
% its mean orientation - see <ShapeParameters.html Shape Parameters> and
% <BoundaryProperties.html Boundary Properties>. Their boundaries drawn over
% the orientation map:

% plot the grain boundaries on top of the ipf map
hold on
plot(grains.boundary,'lineWidth',2)
hold off

%%
% The boundaries follow the colour changes, which is the check that the
% threshold was a sensible one - <GrainReconstruction.html Grain
% Reconstruction> is about what happens when it is not.

%% Crystal shapes
%
% An orientation is easier to picture as a crystal than as a colour. A
% <CrystalShapes.html crystal shape> is a polyhedron with the habit of the
% mineral, and drawing one per grain in the orientation of that grain turns
% the map into something one can read as a rock.

% define the crystal shape of Forsterite and store it in the variable cS
cS = crystalShape.olivine(ebsd('Forsterite').CS)

% select only Forsterite grains with more than 100 pixels
grains = grains('Forsterite',grains.numPixel > 100);

% plot crystal shapes at the positions of the Forsterite grains
hold on
plot(grains,0.7*cS,'colored')
hold off

%%
% 262 grains are large enough to be worth drawing. Note how many of them
% present a similar face to the viewer - that is a texture, seen directly.

%% Pole figures
%
% The proper way to say the same thing is a
% <OrientationPoleFigure.html pole figure>: where a chosen crystal direction
% points, over all the measurements at once.

% the selected crystal directions
h = Miller({1,0,0},{0,1,0},{0,0,1},ebsd('Forsterite').CS);

% plot their distribution with respect to the specimen reference system
plotPDF(ebsd('Forsterite').orientations,h,'figSize','medium','contourf')

%%
% Three lattice directions, three quite different pictures. The (010) poles
% gather in one strong maximum near the rim; the (100) poles spread along a
% broad band through the centre; the (001) poles scatter in several patches.
% A specimen of randomly oriented crystals would give three featureless
% figures, so every concentration here is texture.

%% Inverse pole figures
%
% The same information read the other way round: which crystal direction
% points along a chosen specimen direction.

% select specimen directions
r = [vector3d.X,vector3d.Y,vector3d.Z];

% plot the distribution of the x, y, and z-Axis positions in crystal coordinates
plotIPDF(ebsd('Forsterite').orientations,r,'contour')

%%
% The x axis of the specimen lies along the crystal [010] far more often
% than anywhere else - the single maximum in the first figure, and the same
% fact the (010) pole figure showed. The y and z axes are spread along the
% edge between [001] and [100] instead.
%
% Both kinds of figure describe the orientations measurement by measurement.
% Turning them into a function that can be evaluated, integrated and
% compared is the subject of <ODFTutorial.html the ODF tutorial>.

%%
%#ok<*NOPTS>
