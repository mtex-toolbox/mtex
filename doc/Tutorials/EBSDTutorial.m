%% EBSD Tutorial 
%
% A quick guide on how to import and make basic plots with EBSD data in MTEX.
%
%% Data import
%
% MTEX allows you to import EBSD from all big vendors of EBSD systems. Preferred
% data formats are text based data files like |.ang|, |.ctf| or open binary
% formats like |.osc| or |.h5|. Most conveniently, EBSD data may be imported
% using the import wizard, by typing

import_wizard;

%%
% 
% <<importWizard.png>>
% 
%%
% or by the command <EBSD.load.html EBSD.load>

% load some test data packaged with your MTEX installation
fileName = [mtexDataPath filesep 'EBSD' filesep 'Forsterite.ctf'];
ebsd = EBSD.load(fileName,'EulerCorrection',rotation.id)

%%
% This command outputs ebsd data stored in a single variable, called
% |ebsd|. This variable contains all relevant information, i.e., the
% spatial coordinates, the orientation information, a description of the
% crystal symmetries and all other parameters contained in the input data
% file.
%
%% Phase Plots
%
% In this example, the output above shows that the data set contains
% three different phases: Forsterite, Enstatite, and Diopside. The
% spatial distribution of the different phases can be visualized by the
% plotting command

plot(ebsd,'refFrame','on')

%% 
% When importing EBSD data it is important to check the alignment of the
% map coordinate system and the Euler angle coordinate system. This issue
% is exhaustively discussed in the topic <EBSDReferenceFrame.html Reference
% Frame Alignment>.
%
%% Orientation Plots
%
% Analyzing orientations of an EBSD map has to be done for each phase
% separately. The key syntax to restrict the data to a single phase is

ebsd('Forsterite')

%%
% which allows us the access orientations of all Forsterite pixels with

ebsd('Forsterite').orientations

%%
% This syntax can be used to plot an ipf map of all Forsterite orientations

plot(ebsd('Forsterite'),ebsd('Forsterite').orientations,'micronbar','off')

%%
% Here the all Forsterite orientations a colored according to their
% alignment in a z inverse pole figure. A more complete discussion about
% how to colorize orientations can be found in the topic <EBSDIPFMap.html
% IPF Maps>.

%% Grain reconstruction
%
% MTEX contains sophisticated algorithms for reconstructing grains from
% EBSD data as described in the paper
% <https://www.researchgate.net/publication/51806709_Grain_detection_from_2d_and_3d_EBSD_data-Specification_of_the_MTEX_algorithm
% Grain detection from 2d and 3d EBSD data> and the topic
% <GrainReconstruction.html Grain Reconstruction>. The syntax is

% reconstruct grains with a threshold angle of 10 degrees
grains = calcGrains(ebsd,'threshold',10*degree,'minPixel',5)

% smooth the grains to avoid the staircase effect
grains = smoothBoundary(grains,5);

%%
% This creates a variable |grains| of type @grain2d which contains the
% full <ShapeParameters.html geometric information> about all grains and
% their <BoundaryProperties.html boundaries>. As the simplest
% application we may just plot the grain boundaries

% plot the grain boundaries on top of the ipf map
hold on
plot(grains.boundary,'lineWidth',2)
hold off

%% Crystal Shapes
%
% In order to make the visualization of crystal orientations more intuitive
% MTEX supports <CrystalShapes.html crystal shapes>. Those are polyhedrons
% computed to match the typical shape of ideal crystals. In order to
% overlay the EBSD map with crystal shapes oriented accordingly to the
% orientations of the grains we proceed as follows.

% define the crystal shape of Forsterite and store it in the variable cS
cS = crystalShape.olivine(ebsd('Forsterite').CS)

% select only Forsterite grains with more than 100 pixels
grains = grains('Forsterite',grains.numPixel > 100);

% plot crystal shapes at the positions of the Forsterite grains
hold on
plot(grains,0.7*cS,'colored')
hold off

%% Pole Figures
% 
% One of the most important tools for analyzing the orientations in an EBSD
% map are <OrientationPoleFigure.html pole figure plots>. Those answer the
% question of how selected crystal directions, here |h|, are aligned with
% respect to specimen directions

% the selected crystal directions
h = Miller({1,0,0},{0,1,0},{0,0,1},ebsd('Forsterite').CS);

% plot their distribution with respect to the specimen reference system
plotPDF(ebsd('Forsterite').orientations,h,'figSize','medium','contourf')

%% Inverse Pole Figures
% 
% Analogously one can ask for the crystal directions pointing in a selected
% specimen direction. The resulting plots are called
% <OrientationInversePoleFigure.html inverse pole figures>.

% select specimen directions
r = [vector3d.X,vector3d.Y,vector3d.Z];

% plot the distribution of the x, y, and z-Axis positions in crystal coordinates
plotIPDF(ebsd('Forsterite').orientations,r,'contour')

%%
%#ok<*NOPTS>