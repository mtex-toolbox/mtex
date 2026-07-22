%% Import Script for EBSD Data
%
% This script was automatically created by the import wizard. You should
% run the whole script or parts of it in order to import your data. There
% is no problem in making any changes to this script.

%% Specify Crystal and Specimen Symmetries

% crystal symmetry
CS = {crystal symmetry};

% plotting convention
pC = plottingConvention({zAxisDirection},{xAxisDirection});

%% Specify File Names

% path to files
pname = {path to files};

% which files to be imported
fname = {file names};

%% Z-Values

Z = {Z-values};

%% Import the Data

% create an EBSD variable containing the data, correcting for the
% orientation of the Euler angle reference frame relative to the map.
% The interface (file format) is auto-detected from the file extension.
ebsd = EBSD.load(fname,CS,{Z},{options}, ...
  'EulerCorrection',rotation.byEuler({phi1},{Phi},{phi2}));
ebsd.how2plot = pC;
