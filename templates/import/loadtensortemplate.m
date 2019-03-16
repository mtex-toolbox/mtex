%% Import Script for Tensor Data
%
% This script was automatically created by the import wizard. You should
% run the whoole script or parts of it in order to import your data. There
% is no problem in making any changes to this script.

%% Specify Crystal and Specimen Symmetries

% crystal symmetry
CS = {crystal symmetry};

% plotting convention
setMTEXpref('xAxisDirection',{xAxisDirection});
setMTEXpref('zAxisDirection',{zAxisDirection});

%% Specify File Names

% path to files
pname = {path to files};

% which files to be imported
fname = {file names};

%% Import the Data

% create a Tensor variable containing the data
tensor = tensor.load(fname,CS,'interface',{interface},{options});
