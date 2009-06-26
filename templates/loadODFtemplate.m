%% Import Script for EBSD Data
%
% This script was automatically created by the import wizard. You should
% run the whoole script or parts of it in order to import your data. There
% is no problem in making any chages to this scrip.

%% Specify Crystal and Specimen Symmetries

% crystal symmetry
CS = {crystal symmetry};

% specimen symmetry
SS = {specimen symmetry};

% plotting convention
{plotting convention}

%% Specify File Names

% path to files
pname = {path to files};

% which files to be imported
fname = {file names};

%% Import the Data

% create an EBSD variable containing the data
odf = loadODF(fname,CS,SS,'interface',{interface} ...
  ,{options});

%% Plot some Pole Figures

plotpdf(odf,[Miller(1,0,0),Miller(1,1,0)])

