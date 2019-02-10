%% Import Script for PoleFigure Data
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

% background
pname = {path to bg files};
fname_bg = {bg file names};

% defocusing
pname = {path to def files};
fname_def = {def file names};

% defocusing background
pname = {path to defbg files};
fname_defbg = {defbg file names};


%% Specify Miller Indice

h = {Miller};

%% Specifiy Structural Coefficients for Superposed Pole Figures

c = {structural coefficients};

%% Import the Data

% create a Pole Figure variable containing the data
pf = PoleFigure.load(fname,h,CS,SS,{structural coefficients},'interface',{interface},{options});

% background
pf_bg = PoleFigure.load(fname_bg,h,CS,SS,{structural coefficients},'interface',{interface},{options});

% defocussing
pf_def = PoleFigure.load(fname_def,h,CS,SS,{structural coefficients},'interface',{interface},{options});

% defocussing background
pf_defbg = PoleFigure.load(fname_defbg,h,CS,SS,{structural coefficients},'interface',{interface},{options});

% correct data
pf = correct(pf,{corrections});

%% Correct Data

rot = rotation.byEuler({phi1},{Phi},{phi2});
pf = rotate(pf,rot,{rotationOption});
