%% Import Script for EBSD Data
%
% This script was automatically created by the import wizard. You should
% run the whole script or parts of it in order to import your data. There
% is no problem in making any changes to this script.

%% Specify Crystal and Specimen Symmetries

% crystal symmetry
csList = {crystal symmetry};

% how the map is aligned on screen
pC = {plottingConvention};

%% Specify File Names

% path to files
pname = {path to files};

% which files to be imported
fname = {file names};

%% Correct for the Euler Angle Reference Frame
%
% rotates the map coordinate system's axes into the Euler coordinate system's axes

EulerCorrection = {eulerCorrection};

%% Import the Data

% create an EBSD variable containing the data
% The interface (file format) is auto-detected from the file extension.
% pC goes into the import: data that lands in a named frame - anything from
% an Oxford instrument does - carries that frame's convention and would not
% follow the session otherwise.
ebsd = EBSD.load(fname,csList,{options}, ...
  'EulerCorrection',EulerCorrection,pC);

% everything derived later that states no frame of its own follows this
plottingConvention.default(pC);

%% Plot a First Sanity Check

{sanityPlot}
