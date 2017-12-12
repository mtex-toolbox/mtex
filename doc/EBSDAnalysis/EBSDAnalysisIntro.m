%% First Steps
% Get in touch with EBSD data in MTEX
%
%% Contents
%
%% Import EBSD data
% 
% Importing EBSD data can be done guided by the import wizard

import_wizard('EBSD')

%%
% or directly by the command <loadEBSD.html loadEBSD>

% specify file name
fname = fullfile(mtexDataPath,'EBSD','Forsterite.ctf');

ebsd = loadEBSD(fname,'convertEuler2SpatialReferenceFrame')

%% Correct EBSD data
% The EBSD data are now represented by the variable |ebsd|. Which is
% essentially a long list of x and y values together with phase infotmation
% and orientations. To acces any of these properties do, e.g., the
% orientations of the Forsterite phase do

ebsd('Forsterite').orientations




%%
% 





%%


% EBSD data is stored in the class <EBSD_index.html EBSD> while grains are
% stored as variables of type <grain2d_index.html grain2d>. The following
% mindmap may induce a general idea analysing EBSD Data with MTEX.
%
% <<grain.png>>
%
%

%% Modelling Grains
%
% *<GrainReconstruction.html Grains>*  are a basic concept for spatially indexed EBSD Data.
% With grain modelling comes up the possebility getting more information out of EBSD Data
% - e.g. fabric analysis, characterisation of misorientation
%

%% Analyzing EBSD Data
%
% *<EBSDOrientationPlots.html Visualizing EBSD Data>* is a central to understand
% a specimen. The most naive way is plotting of the individual orientations as 
% pole point plots or spatially indexed in some map with colorcoded orientations. 
% Moreover one gets with grains the possibility to take a closer look on grain
% boundaries.
%
% *<EBSD2odf.html Estimating ODFs from EBSD Data>* is of interest,
% furthermore selecting the optimal halfwidth is a difficult question, in
% particular in matters of grains.
%
