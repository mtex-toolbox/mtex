%% Documentation
%
%%
% Every picture below opens a chapter. Together they are most of what MTEX
% does: crystal geometry, orientation maps, diffraction data, the
% distributions they are summarised by, and the material properties that
% follow from them.
%
% If you are new, the quickest route in is
% <Tutorials.html Tutorials>, which walks a complete analysis from importing
% a file to a result. <Glossary.html Glossary> and
% <NotationAndConventions.html Notation and Conventions> are worth knowing
% about early - the second collects the choices, such as Euler angle
% convention and reference frame alignment, that quietly decide whether your
% numbers agree with someone else's.
%
%% Start here
%
% How to run MTEX at all, and how to make it draw things.
%
% <<group_StartHere.png>>
%
% <Tutorials.html Tutorials>, <GeneralConcepts.html General Concepts>, <Plotting.html Plotting>
%
%% Geometry
%
% Directions, rotations, symmetry, and the orientation of one crystal in one
% specimen. Everything else is built on these.
%
% <<group_Geometry.png>>
%
% <Vectors.html Vectors>, <Rotations.html Rotations>, <CrystalGeometry.html Crystal Geometry>, <CrystalOrientations.html Orientations>, <Misorientations.html Misorientations>
%
%% Orientation maps
%
% Measuring orientations point by point across a surface, and turning the
% result into grains, boundaries and volumes.
%
% <<group_Maps.png>>
%
% <EBSDAnalysis.html EBSD>, <Grains.html Grains>, <GrainBoundaries.html Grain Boundaries>, <EBSD3Analysis.html 3D - EBSD>
%
%% Texture
%
% Describing a whole population of orientations rather than one crystal, and
% the mathematics that makes it computable.
%
% <<group_Texture.png>>
%
% <PoleFigureAnalysis.html Pole Figures>, <ODFAnalysis.html ODF>, <SphericalFunctions.html Spherical Functions>, <SO3Functions.html Orientation Functions>
%
%% Material properties
%
% What the texture implies for how the material behaves - how stiff it is,
% how sound travels through it, how it deforms and how it transforms.
%
% <<group_Properties.png>>
%
% <Tensors.html Tensors>, <Elasticity.html Elasticity>, <Plasticity.html Plasticity>, <PhaseTransitions.html Phase Transitions>
%
%% These pages are scripts
%
% Every page here is an executable MATLAB script, and you have a copy of it
% in your MTEX installation. The file name is the last part of the URL with
% |.html| swapped for |.m|, so this page is |Documentation.m| and you can
% open it with
%
%   edit Documentation
%
% Run a page section by section, change the numbers, and see what depends on
% what. That is the fastest way to learn what a command actually does, and
% these scripts are a reasonable starting point for your own.
%
%% Contributing
%
% Documenting a project like MTEX is an ongoing job, so corrections,
% examples and explanations are all welcome, and everybody who contributes
% appears on the
% <https://github.com/mtex-toolbox/mtex/graphs/contributors contributors
% page>.
%
% The easiest route is through GitHub: sign in, open the page you want to
% change, click *edit page* at the top to reach the file, then the pencil
% icon to edit it in the browser. *Propose changes* and *create pull
% request* at the bottom send it to us. You may also simply
% <mailto:ralf.hielscher@mathematik.tu-chemnitz.de email> the change.
%
% To preview a page you have altered, use the MATLAB
% <https://de.mathworks.com/help/matlab/matlab_prog/publishing-matlab-code.html publish>
% command, which writes an |html| folder next to it:
%
%   publish filename
%
