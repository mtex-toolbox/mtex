%% EBSD Tutorial 
%
% A quick guide on how to import and make basic plots with EBSD data in MTEX.
%
%% Data import
%
% MTEX allows you to import EBSD from all big vendors of EBSD systems. Prefered
% data formats are text based data files like |.ang|, |.ctf| or open binary
% formats like |.osc| or |.h5|. Most conveniently, EBSD data may be imported
% using the import wizard, by typing

import_wizard

%%
% or by the command <EBSD.load.html EBSD.load>

%load some test data packaged with your MTEX installation
fileName = [mtexDataPath filesep 'EBSD' filesep 'Forsterite.ctf'];
ebsd = EBSD.load(fileName)

%%
% This command outputs ebsd data stored in a single variable, called
% |ebsd|. This variable contains all relevant information, i.e., the
% spatial coordinates, the orientation information, a description of the
% crystal symmetries and all other parameters contained in the input data
% file.
%
%
%% Phase Plots
%
% In this example, the output above shows that the data set contains
% three different phases: Forsterite, Enstatite, and Diopside. The
% spatial distribution of the different phases can be visualized by the
% plotting command

plotx2east % this command tells MTEX to plot the x coordinates increasing to the east (left)
plot(ebsd,'coordinates','on')

%% 
% When importing EBSD data it is critically important to align it correctly
% to a fixed reference frame. This issue is exhaustively discussed in the
% topic <EBSDReferenceFrame.html Reference Frame Alignment>.
%
%% Orientation Plots
%
% Analyzing orientations of an EBSD map can be done only for each phase
% seperately. The key syntax to restrict the data to a single phase is 

ebsd('Forsterite')

%%
% Now we may restrict the variable to Forsterite orientations by

ebsd('Forsterite').orientations

%%
% and may use this syntax to plot an ipf map of all Forsterite orientations

plot(ebsd('Forsterite'),ebsd('Forsterite').orientations,'micronbar','off')

%%
% In this standard form a default color coding of the orientations is
% choosen. A more complete discussion about how to colorize orientations
% can be found in the topic <EBSDIPFMap.html IPF Maps>.

%% Grain reconstruction
% 
% MTEX contains a sophisticated algorithm for reconstructing the grain
% structure from EBSD data as described in the paper
% <https://www.researchgate.net/publication/51806709_Grain_detection_from_2d_and_3d_EBSD_data-Specification_of_the_MTEX_algorithm
% Grain detection from 2d and 3d EBSD data> and the topic
% <GrainReconstruction.html Grain Reconstruction>. The syntax is

% reconstruct grains with a theshold angle of 10 degrees
grains = calcGrains(ebsd('indexed'),'theshold',10*degree)

% smooth the grains to avoid the staircase effect
grains = smooth(grains,5);

%%
% This creates a variable |grains| of type @grain2d which containes the
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
% overlay the EBSD map with crystal shapes orienteted accordingly to the
% orientations of the grains we proceed as follows.

% define the crystal shape of Forsterite and store it in the variable cS
cS = crystalShape.olivine(ebsd('Forsterite').CS)

% select only grains with more then 100 pixels
grains = grains(grains.grainSize > 100);

% plot crystal shapes at the positions of the Forsterite grains
hold on
plot(grains('Forsterite'),0.7*cS,'FaceColor',[0.3 0.5 0.3])
hold off

%% Pole Figures
% 
% One of the most important tools for analysing the orientations in an EBSD
% map are <OrientationPoleFigure.html pole figure plots>. Those answer the
% question of how selected crystal directions, here |h|, are aligned with respect to specimen directions

% the selected crystal directions
h = Miller({1,0,0},{0,1,0},{0,0,1},ebsd('Forsterite').CS);

% plot their positions with respect to specimen coordinates
plotPDF(ebsd('Forsterite').orientations,h,'figSize','medium')

%% Inverse Pole Figures
% 
% Analogously one can ask for the crystal directions pointing in a selected
% specimen direction. The resulting plots are called
% <OrientationInversePoleFigure.html inverse pole figures>.

% select the specimen direction
r = vector3d.Z;

% plot the position of the z-Axis in crystal coordinates
plotIPDF(ebsd('Forsterite').orientations,r,'MarkerSize',5,...
  'MarkerFaceAlpha',0.05,'MarkerEdgeAlpha',0.05)
