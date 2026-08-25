%% Import Script for EBSD Data
%
% This script was automatically created by the import wizard. You should
% run the whole script or parts of it in order to import your data. There
% is no problem in making any changes to this script.

%% Specify Crystal and Specimen Symmetries

% crystal symmetry
csList = {crystal symmetry};

% plotting convention
% Applied after loading so that file metadata cannot override it.

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
ebsd = EBSD.load(fname,csList,{options}, ...
  'EulerCorrection',EulerCorrection);
% the convention applies to the session, not to this one object
plottingConvention.default({plottingConvention});

%% Plot a First Sanity Check

{sanityPlot}
