%% Import Script for ODF Data
%
% This script was automatically created by the import wizard. You should
% run the whoole script or parts of it in order to import your data. There
% is no problem in making any changes to this script.

%% Specify Crystal and Specimen Symmetries

% crystal symmetry
CS = {crystal symmetry};

% specimen symmetry
SS = {specimen symmetry};

% plotting convention
setMTEXpref('xAxisDirection',{xAxisDirection});
setMTEXpref('zAxisDirection',{zAxisDirection});

%% Specify File Names

% path to files
pname = {path to files};

% which files to be imported
fname = {file names};

%% Import the Data

% specify kernel
psi = {kernel name}('halfwidth',{halfwidth});

% load the ODF into the variable odf
odf = ODF.load(fname,CS,SS,{method},'kernel',psi,'resolution',{resolution},...
  'interface',{interface},{options});

%% Correct Data

rot = rotation.byEuler({phi1},{Phi},{phi2});
odf = rotate(odf,rot);
