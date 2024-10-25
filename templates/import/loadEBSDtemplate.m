%% Import Script for EBSD Data
%
% This script was automatically created by the import wizard. You should
% run the whole script or parts of it in order to import your data. There
% is no problem in making any changes to this script.

%% Specify Crystal and Specimen Symmetries

% crystal symmetry
CS = {crystal symmetry};

% plotting convention
how2plot = plottingConvention({zAxisDirection},{xAxisDirection});

%% Specify File Names

% path to files
pname = {path to files};

% which files to be imported
fname = {file names};

%% Z-Values

Z = {Z-values};

%% Import the Data

% create an EBSD variable containing the data
ebsd = EBSD.load(fname,CS,'interface',{interface},{Z},{options});
ebsd.plottingConvention = how2plot;

%% Correct Data

rot = rotation.byEuler({phi1},{Phi},{phi2});
ebsd = rotate(ebsd,rot,{rotationOption});
