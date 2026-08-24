%% Tutorials
%
%%
% Each tutorial below is a complete short analysis, from importing data to
% a result worth looking at. They are the fastest way into MTEX, and they
% are meant to be run rather than read: every documentation page is an
% executable script, so you can open one, step through it section by
% section, and change the numbers to see what depends on what.
%
%   edit EBSDTutorial
%
% They are also deliberately incomplete. A tutorial shows one path through a
% subject and says little about the choices made along the way; the chapters
% they link into are where those choices are explained. If a tutorial does
% something to your data that you did not expect, the chapter is the place
% to look, not the tutorial.
%
%% Which one to start with
%
% That depends on how your data was measured, and the split is genuine
% rather than cosmetic.
%
% If you have *orientation maps* - data measured point by point across a
% surface, from EBSD - start with <EBSDTutorial.html EBSD>. It imports a
% map, plots it, and reconstructs grains. Follow it with
% <GrainTutorial.html Grains> for measuring those grains and
% <BoundaryTutorial.html Grain Boundaries> for what lies between them.
% Those three in order are a reasonable first hour with MTEX.
%
% If you have *diffraction data* - pole figures from X-ray or neutron
% measurement - start with <PoleFigureTutorial.html Pole Figure Data>,
% which imports pole figures and reconstructs an orientation distribution
% from them, and continue with <ODFTutorial.html ODFs> for working with the
% result.
%
% <ODFTutorial.html ODFs> is worth reading in either case. An orientation
% distribution is the common language between the two kinds of measurement,
% and it is what lets a map and a pole figure be compared at all.
%
% <VPSCImport.html VPSC> is narrower: it reads the output of the
% visco-plastic self-consistent deformation code, for readers who arrive
% with modelling results rather than measurements.
%
%% Before you start
%
% Two things repay a few minutes in advance.
%
% <GeneralConcepts.html General Concepts> explains the habits that run
% through all of MTEX - that a variable holds a whole list rather than one
% object, and how to select a subset of it. Almost every tutorial line uses
% both.
%
% <EBSDReferenceFrame.html Reference Frame> matters if you are importing
% your own map. The coordinate system the stage moved in and the one the
% Euler angles were written in need not agree, and when they disagree
% everything still runs and every result is quietly rotated. The tutorials
% use data where this is already settled; your own data is not.
%
%% Next
%
% After the tutorials, the chapters they draw on are
% <EBSDAnalysis.html EBSD>, <Grains.html Grains>,
% <GrainBoundaries.html Grain Boundaries>,
% <PoleFigureAnalysis.html Pole Figures> and <ODFAnalysis.html ODF>. The
% underlying objects - directions, rotations, orientations, symmetry -
% start at <Vectors.html Vectors> and <CrystalGeometry.html Crystal
% Geometry>.
%
